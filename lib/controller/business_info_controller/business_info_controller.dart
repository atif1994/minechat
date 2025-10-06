import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:minechat/model/data/ai_knowledge_model.dart';
import '../../model/repositories/ai_knowledge_repository.dart';

class BusinessInfoController extends GetxController {
  final AIKnowledgeRepository _repository = AIKnowledgeRepository();
  final FirebaseStorage _storage = FirebaseStorage.instance;

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
  var selectedFileName = ''.obs;
  var selectedFilePath = ''.obs;
  var uploadedFileUrl = ''.obs;

  final fullPhone = ''.obs;   // e.g., +923001234567
  final isoCode   = 'PK'.obs; // country ISO
  final dialCode  = '+92'.obs;

  @override
  void onInit() {
    super.onInit();
    loadBusinessInfo();
  }

  String getCurrentUserId() {
    return FirebaseAuth.instance.currentUser?.uid ?? '';
  }

  /// Load existing Business Information
  Future<void> loadBusinessInfo() async {
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
        Get.snackbar('Error', 'Failed to load Business Information: $e');
      }
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> pickFile() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.any,
        allowMultiple: false,
        withData: false,
        withReadStream: false,
        lockParentWindow: true,
      );

      if (result != null && result.files.isNotEmpty) {
        final file = result.files.single;
        selectedFileName.value = file.name;
        selectedFilePath.value = file.path ?? '';
        await uploadFileToFirebase(file);

        Get.snackbar(
          'Success',
          'File selected and uploaded: ${file.name}',
          backgroundColor: Colors.green,
          colorText: Colors.white,
          duration: const Duration(seconds: 2),
        );
      }
    } catch (e) {
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

  Future<void> uploadFileToFirebase(PlatformFile file) async {
    try {
      isUploadingFile.value = true;
      
      final userId = getCurrentUserId();
      if (userId.isEmpty) throw Exception("User not logged in");

      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final fileName = '${userId}_${timestamp}_${file.name}';
      
      final storageRef = _storage.ref().child('business_info_files/$fileName');
      
      if (file.path != null) {
        final fileToUpload = File(file.path!);
        final uploadTask = storageRef.putFile(fileToUpload);
        
        uploadTask.snapshotEvents.listen((TaskSnapshot snapshot) {
          final progress = snapshot.bytesTransferred / snapshot.totalBytes;
          print('Upload progress: ${(progress * 100).toStringAsFixed(2)}%');
        });
        
        final snapshot = await uploadTask;
        final downloadUrl = await snapshot.ref.getDownloadURL();
        uploadedFileUrl.value = downloadUrl;
        
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

  /// Save Business Information
  Future<void> saveBusinessInfo() async {
    if (!_validateForm()) {
      Get.snackbar('Validation Error', 'Please fix the errors in the form',
          backgroundColor: Colors.red, colorText: Colors.white);
      return;
    }

    try {
      isSaving.value = true;
      final userId = getCurrentUserId();
      
      if (userId.isEmpty) throw Exception("User not logged in");

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
        uploadedFileUrl: uploadedFileUrl.value,
        userId: userId,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      await _repository.saveAIKnowledge(aiKnowledge);

      Get.snackbar('Success', 'Business Information saved successfully',
          backgroundColor: Colors.green, colorText: Colors.white);
    } catch (e) {
      Get.snackbar('Error', 'Failed to save Business Information: $e',
          backgroundColor: Colors.red, colorText: Colors.white);
    } finally {
      isSaving.value = false;
    }
  }

  void clearFile() async {
    if (uploadedFileUrl.value.isNotEmpty) {
      try {
        final storageRef = _storage.refFromURL(uploadedFileUrl.value);
        await storageRef.delete();
      } catch (e) {
        print('Error deleting file from Firebase Storage: $e');
      }
    }
    
    selectedFileName.value = '';
    selectedFilePath.value = '';
    uploadedFileUrl.value = '';
  }

  String extractFileNameFromUrl(String url) {
    try {
      final uri = Uri.parse(url);
      final pathSegments = uri.pathSegments;
      if (pathSegments.isNotEmpty) {
        final fileName = pathSegments.last;
        final cleanFileName = Uri.decodeComponent(fileName.split('?').first);
        return cleanFileName;
      }
    } catch (e) {
      print('Error extracting filename from URL: $e');
    }
    return 'Uploaded File';
  }

  /// Validation Methods - All fields are now optional
  void validateBusinessName(String value) {
    // Optional field - no validation required
    businessNameError.value = '';
  }

  void validatePhone(String value) {
    // Optional field - no validation required
    phoneError.value = '';
  }

  void validateAddress(String value) {
    // Optional field - no validation required
    addressError.value = '';
  }

  void validateEmail(String value) {
    // Only validate email format if email is provided
    if (value.trim().isNotEmpty && !GetUtils.isEmail(value.trim())) {
      emailError.value = "Please enter a valid email";
    } else {
      emailError.value = '';
    }
  }

  void validateCompanyStory(String value) {
    // Optional field - no validation required
    companyStoryError.value = '';
  }

  void validatePaymentDetails(String value) {
    // Optional field - no validation required
    paymentDetailsError.value = '';
  }

  void validateDiscounts(String value) {
    // Optional field - no validation required
    discountsError.value = '';
  }

  void validatePolicy(String value) {
    // Optional field - no validation required
    policyError.value = '';
  }

  void validateAdditionalNotes(String value) {
    // Optional field - no validation required
    additionalNotesError.value = '';
  }

  void validateThankYouMessage(String value) {
    // Optional field - no validation required
    thankYouMessageError.value = '';
  }

  bool _validateForm() {
    // Run validation for all fields (now all optional)
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

    // All fields are optional, so form is always valid
    // Only email format validation can cause errors
    return emailError.value.isEmpty;
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
