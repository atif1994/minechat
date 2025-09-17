import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:minechat/model/data/ai_assistant_model.dart';
import '../../model/data/chat_mesage_model.dart';
import '../../model/repositories/ai_assistant_repository.dart';
import '../../core/services/openai_service.dart';
import '../../model/data/ai_knowledge_model.dart';
import '../../model/data/product_service_model.dart';
import '../../model/data/faq_model.dart';
import '../../model/repositories/ai_knowledge_repository.dart';

class AIAssistantController extends GetxController {
  final AIAssistantRepository _repository = AIAssistantRepository();
  final AIKnowledgeRepository _knowledgeRepository = AIKnowledgeRepository();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  var currentStep = "AI Assistant".obs; // default active ste
  // Form Controllers
  final nameCtrl = TextEditingController();
  final introMessageCtrl = TextEditingController();
  final shortDescriptionCtrl = TextEditingController();
  final aiGuidelinesCtrl = TextEditingController();
  final messageController = TextEditingController();

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
  
  // Knowledge Data
  var businessInfo = Rx<AIKnowledgeModel?>(null);
  var productsServices = <ProductServiceModel>[].obs;
  var faqs = <FAQModel>[].obs;

  final List<String> responseLengthOptions = ['Short', 'Normal', 'Long'];

  @override
  void onInit() {
    super.onInit();
    loadCurrentAIAssistant();
    loadAllKnowledgeData();
  }
  String getCurrentUserId() {
    return FirebaseAuth.instance.currentUser?.uid ?? '';
  }
  /// Load existing assistant (no duplicates)
  Future<void> loadCurrentAIAssistant() async {
    try {
      isLoading.value = true;
      
      // Debug: Print current user ID
      final userId = getCurrentUserId();
      print('DEBUG: Current User ID: $userId');
      
      final assistant = await _repository.getCurrentUserAIAssistant();
      print('DEBUG: Assistant loaded: ${assistant?.name}');
      
      if (assistant != null) {
        currentAIAssistant.value = assistant;
        nameCtrl.text = assistant.name;
        introMessageCtrl.text = assistant.introMessage;
        shortDescriptionCtrl.text = assistant.shortDescription;
        aiGuidelinesCtrl.text = assistant.aiGuidelines;
        selectedResponseLength.value = assistant.responseLength;
        print('DEBUG: Assistant data loaded successfully');
      } else {
        print('DEBUG: No assistant found for user: $userId');
      }
    } catch (e) {
      print('DEBUG: Error loading assistant: $e');
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
    messageController.clear(); // Clear the input field
    
    // Show loading indicator
    isLoading.value = true;
    
    try {
      final assistant = currentAIAssistant.value;
      if (assistant == null) {
        addMessage("I'm not yet configured. Please set me up first.", MessageType.ai);
        return;
      }

      // Debug: Print current knowledge data
      print('DEBUG: Sending message to AI with:');
      print('DEBUG: - ${productsServices.length} products');
      print('DEBUG: - ${faqs.length} FAQs');
      print('DEBUG: - Business info: ${businessInfo.value != null ? "loaded" : "not loaded"}');
      
      if (productsServices.isNotEmpty) {
        print('DEBUG: Products:');
        for (var product in productsServices) {
          print('DEBUG:   - ${product.name}: ${product.description}');
        }
      }

      // Call OpenAI API with enhanced knowledge
      final aiResponse = await OpenAIService.generateResponseWithKnowledge(
        userMessage: message,
        assistantName: assistant.name,
        introMessage: assistant.introMessage,
        shortDescription: assistant.shortDescription,
        aiGuidelines: assistant.aiGuidelines,
        responseLength: assistant.responseLength,
        businessInfo: businessInfo.value,
        productsServices: productsServices,
        faqs: faqs,
      );
      
      addMessage(aiResponse, MessageType.ai);
    } catch (e) {
      print('Error generating AI response: $e');
      addMessage("Sorry, I encountered an error. Please try again.", MessageType.ai);
    } finally {
      isLoading.value = false;
    }
  }

  void addMessage(String message, MessageType type, {String? attachedFilePath, String? attachedFileName, String? attachedFileType}) {
    chatMessages.add(ChatMessageModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      message: message,
      type: type,
      timestamp: DateTime.now(),
      aiAssistantId: currentAIAssistant.value?.id,
      attachedFilePath: attachedFilePath,
      attachedFileName: attachedFileName,
      attachedFileType: attachedFileType,
    ));
  }

  /// Send message with file attachment
  Future<void> sendMessageWithAttachment(String message, File file) async {
    if (message.trim().isEmpty && file.path.isEmpty) return;

    final fileName = file.path.split('/').last;
    final fileExtension = fileName.split('.').last.toLowerCase();
    final fileType = _getFileType(fileExtension);

    // Add user message with attachment
    addMessage(
      message.trim().isEmpty ? 'Sent a file' : message,
      MessageType.user,
      attachedFilePath: file.path,
      attachedFileName: fileName,
      attachedFileType: fileType,
    );
    
    // Show loading indicator
    isLoading.value = true;
    
    try {
      final assistant = currentAIAssistant.value;
      if (assistant == null) {
        addMessage("I'm not yet configured. Please set me up first.", MessageType.ai);
        return;
      }

      // Process file and send to AI for analysis
      final aiResponse = await OpenAIService.generateResponseWithFile(
        userMessage: message.trim().isEmpty ? '' : message,
        assistantName: assistant.name,
        introMessage: assistant.introMessage,
        shortDescription: assistant.shortDescription,
        aiGuidelines: assistant.aiGuidelines,
        responseLength: assistant.responseLength,
        attachedFile: file,
        fileType: fileType,
        businessInfo: businessInfo.value,
        productsServices: productsServices,
        faqs: faqs,
      );
      
      addMessage(aiResponse, MessageType.ai);
    } catch (e) {
      print('Error processing file attachment: $e');
      addMessage("Sorry, I encountered an error processing your file. Please try again.", MessageType.ai);
    } finally {
      isLoading.value = false;
    }
  }

  /// Pick and send image
  Future<void> pickAndSendImage() async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 80,
      );
      
      if (image != null) {
        final file = File(image.path);
        await sendMessageWithAttachment('', file);
      }
    } catch (e) {
      print('Error picking image: $e');
      Get.snackbar(
        'Error',
        'Failed to pick image: $e',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  /// Pick and send document
  Future<void> pickAndSendDocument() async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? file = await picker.pickMedia();
      
      if (file != null) {
        final fileObj = File(file.path);
        await sendMessageWithAttachment('', fileObj);
      }
    } catch (e) {
      print('Error picking document: $e');
      Get.snackbar(
        'Error',
        'Failed to pick document: $e',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  /// Determine file type based on extension
  String _getFileType(String extension) {
    final imageExtensions = ['jpg', 'jpeg', 'png', 'gif', 'bmp', 'webp'];
    final documentExtensions = ['pdf', 'doc', 'docx', 'txt', 'rtf'];
    
    if (imageExtensions.contains(extension)) {
      return 'image';
    } else if (documentExtensions.contains(extension)) {
      return 'document';
    } else {
      return 'file';
    }
  }
  Future<AIAssistantModel?> getCurrentUserAIAssistant() async {
    final userId = getCurrentUserId();
    if (userId.isEmpty) throw Exception("User not authenticated");

    final doc = await FirebaseFirestore.instance
        .collection('ai_assistants')
        .where('userId', isEqualTo: userId)
        .orderBy('updatedAt', descending: true)
        .limit(1)
        .get();

    if (doc.docs.isNotEmpty) {
      final docData = doc.docs.first;
      return AIAssistantModel.fromMap({
        'id': docData.id,
        ...docData.data(),
      });
    }
    return null;
  }

  /// Load all knowledge data for AI responses
  Future<void> loadAllKnowledgeData() async {
    try {
      final userId = getCurrentUserId();
      if (userId.isEmpty) return;

      // Load Business Information
      final businessData = await _knowledgeRepository.getCurrentUserAIKnowledge();
      if (businessData != null) {
        businessInfo.value = businessData;
      }

      // Load Products & Services
      final productsSnapshot = await _firestore
          .collection('products_services')
          .where('userId', isEqualTo: userId)
          .get();
      
      productsServices.value = productsSnapshot.docs
          .map((doc) => ProductServiceModel.fromMap({
                'id': doc.id,
                ...doc.data(),
              }))
          .toList();

      // Load FAQs
      final faqsSnapshot = await _firestore
          .collection('faqs')
          .where('userId', isEqualTo: userId)
          .get();
      
      faqs.value = faqsSnapshot.docs
          .map((doc) => FAQModel.fromMap({
                'id': doc.id,
                ...doc.data(),
              }))
          .toList();

      print('DEBUG: Loaded ${productsServices.length} products and ${faqs.length} FAQs');

    } catch (e) {
      print('Error loading knowledge data: $e');
    }
  }

  /// Refresh knowledge data - can be called from other controllers
  Future<void> refreshKnowledgeData() async {
    await loadAllKnowledgeData();
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
        return '${response.split('.').first}.';
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
    messageController.dispose();
    super.onClose();
  }
}
