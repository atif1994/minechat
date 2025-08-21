import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:minechat/model/data/faq_model.dart';
import 'package:minechat/controller/ai_assistant_controller/ai_assistant_controller.dart';
import 'package:permission_handler/permission_handler.dart';
import 'dart:io';

class FAQsController extends GetxController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Loading States
  var isLoading = false.obs;
  var isSaving = false.obs;
  var isUploading = false.obs;

  // FAQ Controllers for individual entries
  final questionCtrl = TextEditingController();
  final answerCtrl = TextEditingController();

  // Validation Errors
  var questionError = ''.obs;
  var answerError = ''.obs;

  // FAQs List
  var faqs = <FAQModel>[].obs;

  // File upload
  var selectedFile = ''.obs;
  var lastPickedFileName = ''.obs;

  @override
  void onInit() {
    super.onInit();
    loadFAQs();
  }

  String getCurrentUserId() {
    return FirebaseAuth.instance.currentUser?.uid ?? '';
  }

  /// Check and request storage permissions
  Future<bool> checkAndRequestPermissions() async {
    try {
      print('🔍 Checking storage permissions...');
      
      // Check storage permission
      PermissionStatus status = await Permission.storage.status;
      print('🔍 Storage permission status: $status');
      
      if (status.isDenied) {
        print('🔍 Requesting storage permission...');
        status = await Permission.storage.request();
        print('🔍 Storage permission after request: $status');
      }
      
      // For Android 13+ (API 33+), also check media permissions
      if (await Permission.photos.status.isDenied) {
        print('🔍 Requesting photos permission...');
        await Permission.photos.request();
      }
      
      if (await Permission.manageExternalStorage.status.isDenied) {
        print('🔍 Requesting manage external storage permission...');
        await Permission.manageExternalStorage.request();
      }
      
      return status.isGranted || status.isLimited;
    } catch (e) {
      print('❌ Permission check error: $e');
      return false;
    }
  }

  /// Load existing FAQs (no composite index needed)
  Future<void> loadFAQs() async {
    try {
      print('🔍 Starting loadFAQs...');
      isLoading.value = true;
      final userId = getCurrentUserId();
      print('🔍 Loading FAQs for user: $userId');
      if (userId.isEmpty) throw Exception("User not authenticated");

      final querySnapshot = await _firestore
          .collection('faqs')
          .where('userId', isEqualTo: userId)
          .get();

      print('🔍 Found ${querySnapshot.docs.length} FAQ documents');

      final items = querySnapshot.docs
          .map((doc) {
            print('🔍 Processing FAQ document: ${doc.id}');
            return FAQModel.fromMap({
              'id': doc.id,
              ...doc.data(),
            });
          })
          .toList();

      // Sort locally by createdAt desc
      items.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      faqs.value = items;
      print('✅ Loaded ${faqs.length} FAQs');
    } catch (e) {
      print('❌ Error loading FAQs: $e');
      if (!e.toString().contains('User not authenticated')) {
        Get.snackbar('Error', 'Failed to load FAQs: $e');
      }
    } finally {
      isLoading.value = false;
      print('🔍 loadFAQs finished');
    }
  }

  /// Add new individual FAQ
  Future<void> addIndividualFAQ() async {
    print('🔍 Starting addIndividualFAQ...');
    print('🔍 Question: ${questionCtrl.text}');
    print('🔍 Answer: ${answerCtrl.text}');
    
    if (!_validateForm()) {
      print('❌ Form validation failed');
      Get.snackbar('Validation Error', 'Please fill in both question and answer',
          backgroundColor: Colors.red, colorText: Colors.white);
      return;
    }

    try {
      isSaving.value = true;
      final userId = getCurrentUserId();
      print('🔍 User ID: $userId');
      
      if (userId.isEmpty) throw Exception("User not logged in");

      final faq = FAQModel(
        id: '', // Will be set by Firestore
        question: questionCtrl.text.trim(),
        answer: answerCtrl.text.trim(),
        category: 'General', // Default category
        userId: userId,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      print('🔍 FAQ model created: ${faq.toMap()}');
      print('🔍 Adding to Firestore...');

      final docRef = await _firestore
          .collection('faqs')
          .add(faq.toMap());

      print('✅ FAQ added to Firestore with ID: ${docRef.id}');

      // Add to local list with correct ID
      final newFAQ = faq.copyWith(id: docRef.id);
      faqs.insert(0, newFAQ);
      print('✅ FAQ added to local list');

      // Clear form
      _clearForm();
      print('✅ Form cleared');

      // Refresh AI Assistant's knowledge data
      try {
        print('🔍 Refreshing AI knowledge data...');
        Get.find<AIAssistantController>().refreshKnowledgeData();
        print('✅ AI knowledge data refreshed');
      } catch (e) {
        print('⚠️ Error refreshing AI knowledge: $e');
      }

      Get.snackbar('Success', 'FAQ added successfully!',
          backgroundColor: Colors.green, colorText: Colors.white);
      print('✅ FAQ addition completed successfully');
    } catch (e) {
      print('❌ Error adding FAQ: $e');
      print('❌ Error type: ${e.runtimeType}');
      Get.snackbar('Error', 'Failed to add FAQ: $e',
          backgroundColor: Colors.red, colorText: Colors.white);
    } finally {
      isSaving.value = false;
      print('🔍 addIndividualFAQ finished');
    }
  }

  /// Upload FAQ file
  Future<void> uploadFAQFile() async {
    try {
      print('🔍 Starting file upload process...');
      isUploading.value = true;
      final userId = getCurrentUserId();
      
      print('🔍 User ID: $userId');
      if (userId.isEmpty) throw Exception("User not logged in");
      
      print('🔍 Selected file path: ${selectedFile.value}');
      if (selectedFile.value.isEmpty) throw Exception("No file selected");

      // Read file content (any file type)
      final file = File(selectedFile.value);
      print('🔍 File exists: ${await file.exists()}');
      if (!await file.exists()) throw Exception("File not found");

      final fileName = file.path.split(Platform.pathSeparator).last;
      final extension = fileName.split('.').last.toLowerCase();
      print('🔍 File name: $fileName, Extension: $extension');

      // Read file as bytes for any file type
      List<int> fileBytes = await file.readAsBytes();
      String fileContent = '';
      
      // Try to read as text for text-based files
      if (extension == 'txt' || extension == 'csv') {
        try {
          fileContent = await file.readAsString();
          print('🔍 File content length: ${fileContent.length}');
        } catch (e) {
          print('⚠️ Could not read file as text: $e');
        }
      } else {
        print('🔍 Binary file detected, saving as bytes');
      }

      // Save file info to Firebase
      final fileData = {
        'fileName': fileName,
        'filePath': selectedFile.value,
        'fileContent': fileContent,
        'fileBytes': fileBytes, // Save file bytes for any file type
        'fileSize': fileBytes.length,
        'userId': userId,
        'uploadedAt': DateTime.now().toIso8601String(),
        'fileType': extension,
        'isBinary': extension != 'txt' && extension != 'csv',
      };

      print('🔍 Saving file data to Firebase...');
      await _firestore.collection('faq_files').add(fileData);
      print('✅ File data saved to Firebase');

      // Process text content only for text files
      if (fileContent.isNotEmpty && (extension == 'txt' || extension == 'csv')) {
        print('🔍 Processing file content for FAQs...');
        await _processFileContent(fileContent, userId);
        print('✅ File content processed');
      } else {
        print('🔍 Skipping FAQ processing for binary file');
      }

      // Remember last picked name and clear selection
      lastPickedFileName.value = fileName;
      // Don't clear selectedFile.value here - keep it for potential re-upload
      
      // Refresh AI Assistant's knowledge data
      try {
        print('🔍 Refreshing AI knowledge data...');
        Get.find<AIAssistantController>().refreshKnowledgeData();
        print('✅ AI knowledge data refreshed');
      } catch (e) {
        print('⚠️ Error refreshing AI knowledge: $e');
      }

      Get.snackbar('Success', 'File uploaded successfully: $fileName',
          backgroundColor: Colors.green, colorText: Colors.white);
      print('✅ File upload completed successfully');
    } catch (e) {
      print('❌ File upload error: $e');
      print('❌ Error type: ${e.runtimeType}');
      Get.snackbar('Error', 'Failed to upload file: $e',
          backgroundColor: Colors.red, colorText: Colors.white);
    } finally {
      isUploading.value = false;
      print('🔍 Upload process finished');
    }
  }

  /// Process file content to extract FAQs
  Future<void> _processFileContent(String content, String userId) async {
    try {
      final lines = content.split('\n');
      List<Map<String, String>> extractedFAQs = [];

      for (int i = 0; i < lines.length - 1; i++) {
        final line = lines[i].trim();
        if (line.startsWith('Q:') || line.startsWith('Question:')) {
          final question = line.replaceFirst(RegExp(r'^Q:\s*|Question:\s*'), '');
          if (i + 1 < lines.length) {
            final nextLine = lines[i + 1].trim();
            if (nextLine.startsWith('A:') || nextLine.startsWith('Answer:')) {
              final answer = nextLine.replaceFirst(RegExp(r'^A:\s*|Answer:\s*'), '');
              extractedFAQs.add({'question': question, 'answer': answer});
            }
          }
        }
      }

      for (final faqData in extractedFAQs) {
        final faq = FAQModel(
          id: '',
          question: faqData['question'] ?? '',
          answer: faqData['answer'] ?? '',
          category: 'Imported',
          userId: userId,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );
        await _firestore.collection('faqs').add(faq.toMap());
      }

      await loadFAQs();
    } catch (e) {
      print('Error processing file content: $e');
    }
  }

  /// Save all FAQs
  Future<void> saveAllFAQs() async {
    try {
      isSaving.value = true;
      try {
        Get.find<AIAssistantController>().refreshKnowledgeData();
      } catch (e) {
        print('⚠️ Error refreshing AI knowledge: $e');
      }
      Get.snackbar('Success', 'All FAQs saved successfully!',
          backgroundColor: Colors.green, colorText: Colors.white);
    } catch (e) {
      print('Error saving FAQs: $e');
      Get.snackbar('Error', 'Failed to save FAQs',
          backgroundColor: Colors.red, colorText: Colors.white);
    } finally {
      isSaving.value = false;
    }
  }

  /// Delete FAQ
  Future<void> deleteFAQ(String id) async {
    try {
      await _firestore.collection('faqs').doc(id).delete();
      faqs.removeWhere((item) => item.id == id);
      try {
        Get.find<AIAssistantController>().refreshKnowledgeData();
      } catch (e) {
        print('⚠️ Error refreshing AI knowledge: $e');
      }
      Get.snackbar('Success', 'FAQ deleted successfully!',
          backgroundColor: Colors.green, colorText: Colors.white);
    } catch (e) {
      Get.snackbar('Error', 'Failed to delete FAQ: $e',
          backgroundColor: Colors.red, colorText: Colors.white);
    }
  }

  void loadForEdit(FAQModel faq) {
    questionCtrl.text = faq.question;
    answerCtrl.text = faq.answer;
  }

  void _clearForm() {
    questionCtrl.clear();
    answerCtrl.clear();
    questionError.value = '';
    answerError.value = '';
  }

  void validateQuestion(String value) {
    questionError.value = value.trim().isEmpty ? "Question is required" : '';
  }

  void validateAnswer(String value) {
    answerError.value = value.trim().isEmpty ? "Answer is required" : '';
  }

  /// Clear file selection
  void clearFileSelection() {
    selectedFile.value = '';
    lastPickedFileName.value = '';
  }

  bool _validateForm() {
    validateQuestion(questionCtrl.text);
    validateAnswer(answerCtrl.text);
    return questionError.value.isEmpty && answerError.value.isEmpty;
  }

  @override
  void onClose() {
    questionCtrl.dispose();
    answerCtrl.dispose();
    super.onClose();
  }
}
