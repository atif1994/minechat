import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:minechat/model/data/ai_assistant_model.dart';
import '../../model/data/chat_mesage_model.dart';
import '../../model/repositories/ai_assistant_repository.dart';

class AIAssistantController extends GetxController {
  final AIAssistantRepository _repository = AIAssistantRepository();

  // Form Controllers
  final nameCtrl = TextEditingController();
  final introMessageCtrl = TextEditingController();
  final shortDescriptionCtrl = TextEditingController();
  final aiGuidelinesCtrl = TextEditingController();

  // Reactive States
  var selectedResponseLength = 'Short'.obs;
  var isLoading = false.obs;
  var isSaving = false.obs;

  // Validation Errors
  var nameError = ''.obs;
  var introMessageError = ''.obs;
  var shortDescriptionError = ''.obs;
  var aiGuidelinesError = ''.obs;

  // Chat & Assistant Data
  var currentAIAssistant = Rx<AIAssistantModel?>(null);
  var chatMessages = <ChatMessageModel>[].obs;

  final List<String> responseLengthOptions = ['Short', 'Normal', 'Long'];

  @override
  void onInit() {
    super.onInit();
    loadCurrentAIAssistant();
  }
  String getCurrentUserId() {
    return FirebaseAuth.instance.currentUser?.uid ?? '';
  }
  /// Load existing assistant (no duplicates)
  Future<void> loadCurrentAIAssistant() async {
    try {
      isLoading.value = true;
      final assistant = await _repository.getCurrentUserAIAssistant();
      if (assistant != null) {
        currentAIAssistant.value = assistant;
        nameCtrl.text = assistant.name;
        introMessageCtrl.text = assistant.introMessage;
        shortDescriptionCtrl.text = assistant.shortDescription;
        aiGuidelinesCtrl.text = assistant.aiGuidelines;
        selectedResponseLength.value = assistant.responseLength;
      }
    } catch (e) {
      if (!e.toString().contains('User not authenticated')) {
        Get.snackbar('Error', 'Failed to load AI assistant: $e');
      }
    } finally {
      isLoading.value = false;
    }
  }

  /// Save or update assistant (UID-based)
  Future<void> saveAIAssistant() async {
    if (!_validateForm()) {
      Get.snackbar('Validation Error', 'Please fix the errors in the form',
          backgroundColor: Colors.red, colorText: Colors.white);
      return;
    }

    try {
      isSaving.value = true;
      final userId = _repository.getCurrentUserId();
      if (userId == null) throw Exception("User not logged in");

      final assistant = AIAssistantModel(
        id: userId, // ✅ Always use UID so no duplicates
        name: nameCtrl.text.trim(),
        introMessage: introMessageCtrl.text.trim(),
        shortDescription: shortDescriptionCtrl.text.trim(),
        aiGuidelines: aiGuidelinesCtrl.text.trim(),
        responseLength: selectedResponseLength.value,
        userId: userId,
        createdAt: currentAIAssistant.value?.createdAt ?? DateTime.now(),
        updatedAt: DateTime.now(),
      );

      await _repository.saveAIAssistant(assistant); // merge in repo
      currentAIAssistant.value = assistant;

      Get.snackbar('Success', 'AI Assistant updated successfully!',
          backgroundColor: Colors.green, colorText: Colors.white);
    } catch (e) {
      Get.snackbar('Error', 'Failed to save AI Assistant: $e',
          backgroundColor: Colors.red, colorText: Colors.white);
    } finally {
      isSaving.value = false;
    }
  }

  /// Send and get AI/stored response
  Future<void> sendMessage(String message) async {
    if (message.trim().isEmpty) return;

    addMessage(message, MessageType.user);
    await Future.delayed(const Duration(milliseconds: 400));

    final aiResponse = generateAIResponse(message);
    addMessage(aiResponse, MessageType.ai);
  }

  void addMessage(String message, MessageType type) {
    chatMessages.add(ChatMessageModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      message: message,
      type: type,
      timestamp: DateTime.now(),
      aiAssistantId: currentAIAssistant.value?.id,
    ));
  }
  Future<AIAssistantModel?> getCurrentUserAIAssistant() async {
    final userId = getCurrentUserId();
    if (userId == null) throw Exception("User not authenticated");

    final doc = await FirebaseFirestore.instance
        .collection('ai_assistants')
        .doc(userId)
        .get();

    if (!doc.exists) return null;
    return AIAssistantModel.fromMap(doc.data()!);
  }


  String generateAIResponse(String userMessage) {
    final assistant = currentAIAssistant.value;
    if (assistant == null) {
      return "I’m not yet configured. Please set me up first.";
    }

    final msg = userMessage.toLowerCase();
    final name = assistant.name;
    final intro = assistant.introMessage;
    final desc = assistant.shortDescription;
    final guidelines = assistant.aiGuidelines;
    final tone = _getToneEmoji(guidelines);

    bool hasAllData = name.isNotEmpty && intro.isNotEmpty && desc.isNotEmpty;

    String reply;
    if (msg.contains('hi') || msg.contains('hello')) {
      reply = hasAllData
          ? "$tone Hi! My name is $name. How can I help you today?"
          : "$tone Hello! I don’t have all your details yet.";
    }
    else if (msg.contains('your name') || msg.contains('who are you')) {
      reply = name.isNotEmpty ? "$tone My name is $name." : "$tone I don’t know my name yet.";
    }
    else if (msg.contains('experience') || msg.contains('years') || msg.contains('how long')) {
      reply = desc.isNotEmpty
          ? "$tone I have $desc."
          : "$tone I don’t have experience details saved yet.";
    }
    else if (msg.contains('intro') || msg.contains('what do you do') || msg.contains('about you')) {
      reply = intro.isNotEmpty ? "$tone $intro" : "$tone No intro saved.";
    }
    else if (msg.contains('guideline') || msg.contains('rules')) {
      reply = guidelines.isNotEmpty ? "$tone My guidelines are: $guidelines" : "$tone No guidelines saved.";
    }
    else {
      reply = "$tone No data available about this.";
    }

    return _applyResponseLength(reply, assistant.responseLength);
  }


  String _getToneEmoji(String guidelines) {
    final lower = guidelines.toLowerCase();
    if (lower.contains('friendly')) return "😊";
    if (lower.contains('professional')) return "👔";
    if (lower.contains('casual')) return "😎";
    if (lower.contains('supportive')) return "🤝";
    return "🤖";
  }

  String _applyResponseLength(String response, String length) {
    switch (length) {
      case 'Short':
        return response.split('.').first + '.';
      case 'Long':
        return "$response Let me know if you'd like to go deeper.";
      default:
        return response;
    }
  }

  /// Validation
  void validateName(String value) {
    nameError.value = value.trim().isEmpty
        ? "Name is required"
        : value.trim().length < 3
        ? "Name must be at least 3 characters"
        : '';
  }

  void validateIntroMessage(String value) {
    introMessageError.value = value.trim().isEmpty ? "Intro message is required" : '';
  }

  void validateShortDescription(String value) {
    shortDescriptionError.value = value.trim().isEmpty ? "Short description is required" : '';
  }

  void validateAIGuidelines(String value) {
    aiGuidelinesError.value = value.trim().isEmpty ? "Guidelines are required" : '';
  }

  bool _validateForm() {
    validateName(nameCtrl.text);
    validateIntroMessage(introMessageCtrl.text);
    validateShortDescription(shortDescriptionCtrl.text);
    validateAIGuidelines(aiGuidelinesCtrl.text);
    return nameError.value.isEmpty &&
        introMessageError.value.isEmpty &&
        shortDescriptionError.value.isEmpty &&
        aiGuidelinesError.value.isEmpty;
  }

  @override
  void onClose() {
    nameCtrl.dispose();
    introMessageCtrl.dispose();
    shortDescriptionCtrl.dispose();
    aiGuidelinesCtrl.dispose();
    super.onClose();
  }
}
