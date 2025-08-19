import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:minechat/model/data/ai_knowledge_model.dart';
import '../../model/repositories/ai_knowledge_repository.dart';

class AIKnowledgeController extends GetxController {
  final AIKnowledgeRepository _repository = AIKnowledgeRepository();
  final FirebaseStorage _storage = FirebaseStorage.instance;

  // Tab Management
  var selectedTabIndex = 0.obs;

  // Loading States
  var isLoading = false.obs;
  var isSaving = false.obs;
  var isUploadingFile = false.obs;

  // Business Information Controllers
  final businessNameCtrl = TextEditingController();
  final phoneCtrl = TextEditingController();
  final addressCtrl = TextEditingController();
  final emailCtrl = TextEditingController();
  final companyStoryCtrl = TextEditingController();
  final paymentDetailsCtrl = TextEditingController();
  final discountsCtrl = TextEditingController();
  final policyCtrl = TextEditingController();
  final additionalNotesCtrl = TextEditingController();
  final thankYouMessageCtrl = TextEditingController();

  // Validation Errors
  var businessNameError = ''.obs;
  var phoneError = ''.obs;
  var addressError = ''.obs;
  var emailError = ''.obs;
  var companyStoryError = ''.obs;
  var paymentDetailsError = ''.obs;
  var discountsError = ''.obs;
  var policyError = ''.obs;
  var additionalNotesError = ''.obs;
  var thankYouMessageError = ''.obs;



  // File tracking
  var selectedBusinessFile = ''.obs;
  var selectedFAQFile = ''.obs;
  var uploadedFileUrl = ''.obs; // Firebase Storage URL

  @override
  void onInit() {
    super.onInit();
    loadAIKnowledge();
  }

  String getCurrentUserId() {
    return FirebaseAuth.instance.currentUser?.uid ?? '';
  }

  /// Load existing AI Knowledge
  Future<void> loadAIKnowledge() async {
    try {
      isLoading.value = true;
      final aiKnowledge = await _repository.getCurrentUserAIKnowledge();
      if (aiKnowledge != null) {
        // Load business information
        businessNameCtrl.text = aiKnowledge.businessName;
        phoneCtrl.text = aiKnowledge.phone;
        addressCtrl.text = aiKnowledge.address;
        emailCtrl.text = aiKnowledge.email;
        companyStoryCtrl.text = aiKnowledge.companyStory;
        paymentDetailsCtrl.text = aiKnowledge.paymentDetails;
        discountsCtrl.text = aiKnowledge.discounts;
        policyCtrl.text = aiKnowledge.policy;
        additionalNotesCtrl.text = aiKnowledge.additionalNotes;
        thankYouMessageCtrl.text = aiKnowledge.thankYouMessage;
        
        // Load uploaded file information
        uploadedFileUrl.value = aiKnowledge.uploadedFileUrl;
        if (aiKnowledge.uploadedFileUrl.isNotEmpty) {
          selectedFileName.value = extractFileNameFromUrl(aiKnowledge.uploadedFileUrl);
        }


      }
    } catch (e) {
      if (!e.toString().contains('User not authenticated')) {
        Get.snackbar('Error', 'Failed to load AI Knowledge: $e');
      }
    } finally {
      isLoading.value = false;
    }
  }
  var selectedFileName = ''.obs;
  var selectedFilePath = ''.obs;

  Future<void> pickFile() async {
    try {
      // Open file picker with more specific configuration
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.any,
        allowMultiple: false,
        withData: false, // Don't load file data into memory
        withReadStream: false, // Don't create read stream
        lockParentWindow: true, // Lock parent window on web
      );

      if (result != null && result.files.isNotEmpty) {
        // Get the picked file
        final file = result.files.single;

        // Update the observable variables to reflect in UI
        selectedFileName.value = file.name;
        selectedFilePath.value = file.path ?? '';

        print("Picked file: ${file.name}");
        print("Path: ${file.path}");
        print("Size: ${file.size} bytes");

        // Upload file to Firebase Storage
        await uploadFileToFirebase(file);

        // Show success message
        Get.snackbar(
          'Success',
          'File selected and uploaded: ${file.name}',
          backgroundColor: Colors.green,
          colorText: Colors.white,
          duration: const Duration(seconds: 2),
        );
      } else {
        print("User canceled the picker or no file selected");
      }
    } catch (e) {
      print("File picking error: $e");

      // More specific error handling
      String errorMessage = 'Failed to pick file';
      if (e.toString().contains('MissingPluginException')) {
        errorMessage = 'File picker plugin not available. Please restart the app.';
      } else if (e.toString().contains('permission')) {
        errorMessage = 'Storage permission denied. Please grant permission in settings.';
      } else {
        errorMessage = 'Error: ${e.toString()}';
      }

      Get.snackbar(
        'Error',
        errorMessage,
        backgroundColor: Colors.red,
        colorText: Colors.white,
        duration: const Duration(seconds: 4),
      );
    }
  }

  /// Upload file to Firebase Storage
  Future<void> uploadFileToFirebase(PlatformFile file) async {
    try {
      isUploadingFile.value = true;
      
      final userId = getCurrentUserId();
      if (userId.isEmpty) throw Exception("User not logged in");

      // Create a unique file name with timestamp
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final fileName = '${userId}_${timestamp}_${file.name}';
      
      // Create storage reference
      final storageRef = _storage.ref().child('ai_knowledge_files/$fileName');
      
      // Upload file
      if (file.path != null) {
        final fileToUpload = File(file.path!);
        final uploadTask = storageRef.putFile(fileToUpload);
        
        // Monitor upload progress
        uploadTask.snapshotEvents.listen((TaskSnapshot snapshot) {
          final progress = snapshot.bytesTransferred / snapshot.totalBytes;
          print('Upload progress: ${(progress * 100).toStringAsFixed(2)}%');
        });
        
        // Wait for upload to complete
        final snapshot = await uploadTask;
        
        // Get download URL
        final downloadUrl = await snapshot.ref.getDownloadURL();
        uploadedFileUrl.value = downloadUrl;
        
        print('File uploaded successfully: $downloadUrl');
        
        Get.snackbar(
          'Upload Success',
          'File uploaded to Firebase Storage',
          backgroundColor: Colors.green,
          colorText: Colors.white,
          duration: const Duration(seconds: 2),
        );
      } else {
        throw Exception("File path is null");
      }
    } catch (e) {
      print('Upload error: $e');
      Get.snackbar(
        'Upload Error',
        'Failed to upload file: $e',
        backgroundColor: Colors.red,
        colorText: Colors.white,
        duration: const Duration(seconds: 4),
      );
    } finally {
      isUploadingFile.value = false;
    }
  }
  /// Save AI Knowledge
  Future<void> saveAIKnowledge() async {
    print('=== Starting saveAIKnowledge ===');
    print('Save button clicked!');
    
    if (!_validateForm()) {
      print('Validation failed');
      Get.snackbar('Validation Error', 'Please fix the errors in the form',
          backgroundColor: Colors.red, colorText: Colors.white);
      return;
    }

    try {
      isSaving.value = true;
      final userId = getCurrentUserId();
      print('User ID: $userId');
      
      if (userId.isEmpty) throw Exception("User not logged in");

      // Print all form data for debugging
      print('Form Data:');
      print('Business Name: ${businessNameCtrl.text.trim()}');
      print('Phone: ${phoneCtrl.text.trim()}');
      print('Address: ${addressCtrl.text.trim()}');
      print('Email: ${emailCtrl.text.trim()}');
      print('Company Story: ${companyStoryCtrl.text.trim()}');
      print('Payment Details: ${paymentDetailsCtrl.text.trim()}');
      print('Discounts: ${discountsCtrl.text.trim()}');
      print('Policy: ${policyCtrl.text.trim()}');
      print('Additional Notes: ${additionalNotesCtrl.text.trim()}');
      print('Thank You Message: ${thankYouMessageCtrl.text.trim()}');
      print('Uploaded File URL: ${uploadedFileUrl.value}');

      final aiKnowledge = AIKnowledgeModel(
        id: userId,
        businessName: businessNameCtrl.text.trim(),
        phone: phoneCtrl.text.trim(),
        address: addressCtrl.text.trim(),
        email: emailCtrl.text.trim(),
        companyStory: companyStoryCtrl.text.trim(),
        paymentDetails: paymentDetailsCtrl.text.trim(),
        discounts: discountsCtrl.text.trim(),
        policy: policyCtrl.text.trim(),
        additionalNotes: additionalNotesCtrl.text.trim(),
        thankYouMessage: thankYouMessageCtrl.text.trim(),
        uploadedFileUrl: uploadedFileUrl.value, // Include the uploaded file URL

        userId: userId,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      print('AI Knowledge Model created successfully');
      print('Model data: ${aiKnowledge.toMap()}');

      print('Calling repository saveAIKnowledge...');
      await _repository.saveAIKnowledge(aiKnowledge);
      print('Repository save completed successfully');

      Get.snackbar('Success', 'AI Knowledge saved successfully!',
          backgroundColor: Colors.green, colorText: Colors.white);
      
      print('=== saveAIKnowledge completed successfully ===');
    } catch (e) {
      print('Error in saveAIKnowledge: $e');
      print('Error stack trace: ${StackTrace.current}');
      Get.snackbar('Error', 'Failed to save AI Knowledge: $e',
          backgroundColor: Colors.red, colorText: Colors.white);
    } finally {
      isSaving.value = false;
    }
  }




  void clearFile() async {
    // Delete file from Firebase Storage if it exists
    if (uploadedFileUrl.value.isNotEmpty) {
      try {
        final storageRef = _storage.refFromURL(uploadedFileUrl.value);
        await storageRef.delete();
        print('File deleted from Firebase Storage');
      } catch (e) {
        print('Error deleting file from Firebase Storage: $e');
      }
    }
    
    selectedFileName.value = '';
    selectedFilePath.value = '';
    uploadedFileUrl.value = '';
  }

  /// Test method to verify save functionality
  Future<void> testSave() async {
    print('=== Test Save Method Called ===');
    try {
      // Create a simple test model
      final testModel = AIKnowledgeModel(
        id: getCurrentUserId(),
        businessName: 'Test Business',
        phone: '1234567890',
        address: 'Test Address',
        email: 'test@test.com',
        companyStory: 'Test Story',
        paymentDetails: 'Test Payment',
        discounts: 'Test Discounts',
        policy: 'Test Policy',
        additionalNotes: 'Test Notes',
        thankYouMessage: 'Test Thank You',
        uploadedFileUrl: 'test_url',
        userId: getCurrentUserId(),
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      print('Test model created: ${testModel.toMap()}');
      await _repository.saveAIKnowledge(testModel);
      print('Test save successful!');
      
      Get.snackbar('Test Success', 'Test save completed successfully!',
          backgroundColor: Colors.green, colorText: Colors.white);
    } catch (e) {
      print('Test save failed: $e');
      Get.snackbar('Test Error', 'Test save failed: $e',
          backgroundColor: Colors.red, colorText: Colors.white);
    }
  }

  /// Extract filename from Firebase Storage URL
  String extractFileNameFromUrl(String url) {
    try {
      final uri = Uri.parse(url);
      final pathSegments = uri.pathSegments;
      if (pathSegments.isNotEmpty) {
        final fileName = pathSegments.last;
        // Remove query parameters and decode URL
        final cleanFileName = Uri.decodeComponent(fileName.split('?').first);
        return cleanFileName;
      }
    } catch (e) {
      print('Error extracting filename from URL: $e');
    }
    return 'Uploaded File';
  }
  /// Validation Methods
  void validateBusinessName(String value) {
    businessNameError.value = value.trim().isEmpty ? "Business name is required" : '';
  }

  void validatePhone(String value) {
    phoneError.value = value.trim().isEmpty ? "Phone number is required" : '';
  }

  void validateAddress(String value) {
    addressError.value = value.trim().isEmpty ? "Address is required" : '';
  }

  void validateEmail(String value) {
    if (value.trim().isEmpty) {
      emailError.value = "Email is required";
    } else if (!GetUtils.isEmail(value.trim())) {
      emailError.value = "Please enter a valid email";
    } else {
      emailError.value = '';
    }
  }

  void validateCompanyStory(String value) {
    companyStoryError.value = value.trim().isEmpty ? "Company story is required" : '';
  }

  void validatePaymentDetails(String value) {
    paymentDetailsError.value = value.trim().isEmpty ? "Payment details are required" : '';
  }

  void validateDiscounts(String value) {
    discountsError.value = value.trim().isEmpty ? "Discounts information is required" : '';
  }

  void validatePolicy(String value) {
    policyError.value = value.trim().isEmpty ? "Policy information is required" : '';
  }

  void validateAdditionalNotes(String value) {
    additionalNotesError.value = value.trim().isEmpty ? "Additional notes are required" : '';
  }

  void validateThankYouMessage(String value) {
    thankYouMessageError.value = value.trim().isEmpty ? "Thank you message is required" : '';
  }



  bool _validateForm() {
    print('=== Starting form validation ===');
    
    validateBusinessName(businessNameCtrl.text);
    validatePhone(phoneCtrl.text);
    validateAddress(addressCtrl.text);
    validateEmail(emailCtrl.text);
    validateCompanyStory(companyStoryCtrl.text);
    validatePaymentDetails(paymentDetailsCtrl.text);
    validateDiscounts(discountsCtrl.text);
    validatePolicy(policyCtrl.text);
    validateAdditionalNotes(additionalNotesCtrl.text);
    validateThankYouMessage(thankYouMessageCtrl.text);

    final isValid = businessNameError.value.isEmpty &&
        phoneError.value.isEmpty &&
        addressError.value.isEmpty &&
        emailError.value.isEmpty &&
        companyStoryError.value.isEmpty &&
        paymentDetailsError.value.isEmpty &&
        discountsError.value.isEmpty &&
        policyError.value.isEmpty &&
        additionalNotesError.value.isEmpty &&
        thankYouMessageError.value.isEmpty;

    print('Validation errors:');
    print('Business Name Error: ${businessNameError.value}');
    print('Phone Error: ${phoneError.value}');
    print('Address Error: ${addressError.value}');
    print('Email Error: ${emailError.value}');
    print('Company Story Error: ${companyStoryError.value}');
    print('Payment Details Error: ${paymentDetailsError.value}');
    print('Discounts Error: ${discountsError.value}');
    print('Policy Error: ${policyError.value}');
    print('Additional Notes Error: ${additionalNotesError.value}');
    print('Thank You Message Error: ${thankYouMessageError.value}');
    print('Form is valid: $isValid');
    print('=== Form validation completed ===');

    return isValid;
  }

  @override
  void onClose() {
    businessNameCtrl.dispose();
    phoneCtrl.dispose();
    addressCtrl.dispose();
    emailCtrl.dispose();
    companyStoryCtrl.dispose();
    paymentDetailsCtrl.dispose();
    discountsCtrl.dispose();
    policyCtrl.dispose();
    additionalNotesCtrl.dispose();
    thankYouMessageCtrl.dispose();



    super.onClose();
  }
}
