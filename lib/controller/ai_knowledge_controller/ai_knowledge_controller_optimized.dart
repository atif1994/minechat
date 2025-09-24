import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:minechat/core/controllers/base_controller.dart';
import 'package:minechat/model/data/ai_knowledge_model.dart';
import '../../model/repositories/ai_knowledge_repository.dart';

/// Optimized AI Knowledge Controller - Reduced from ~500 to ~200 lines
class AIKnowledgeControllerOptimized extends BaseController {
  final AIKnowledgeRepository _repository = AIKnowledgeRepository();
  final FirebaseStorage _storage = FirebaseStorage.instance;

  // Tab Management
  var selectedTabIndex = 0.obs;

  // Form Controllers
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
  var uploadedFileUrl = ''.obs;

  @override
  void onInit() {
    super.onInit();
    loadAIKnowledge();
  }

  @override
  void disposeControllers() {
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
  }

  /// Load existing AI Knowledge
  Future<void> loadAIKnowledge() async {
    setLoading(true);
    try {
      final userId = getCurrentUserId();
      if (userId.isEmpty) return;

      final knowledge = await _repository.getCurrentUserAIKnowledge();
      if (knowledge != null) {
        _populateForm(knowledge);
      }
    } catch (e) {
      setError('Failed to load AI knowledge: ${e.toString()}');
    } finally {
      setLoading(false);
    }
  }

  /// Populate form with existing data
  void _populateForm(AIKnowledgeModel knowledge) {
    businessNameCtrl.text = knowledge.businessName ?? '';
    phoneCtrl.text = knowledge.phone ?? '';
    addressCtrl.text = knowledge.address ?? '';
    emailCtrl.text = knowledge.email ?? '';
    companyStoryCtrl.text = knowledge.companyStory ?? '';
    paymentDetailsCtrl.text = knowledge.paymentDetails ?? '';
    discountsCtrl.text = knowledge.discounts ?? '';
    policyCtrl.text = knowledge.policy ?? '';
    additionalNotesCtrl.text = knowledge.additionalNotes ?? '';
    thankYouMessageCtrl.text = knowledge.thankYouMessage ?? '';
    uploadedFileUrl.value = knowledge.uploadedFileUrl ?? '';
  }

  /// Save AI Knowledge
  Future<void> saveAIKnowledge() async {
    if (!_validateForm()) return;

    setSaving(true);
    try {
      final userId = getCurrentUserId();
      if (userId.isEmpty) return;

      final knowledge = AIKnowledgeModel(
        id: userId,
        userId: userId,
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
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      await _repository.saveAIKnowledge(knowledge);
      showSuccess('AI Knowledge saved successfully');
    } catch (e) {
      setError('Failed to save AI knowledge: ${e.toString()}');
    } finally {
      setSaving(false);
    }
  }

  /// Validate form
  bool _validateForm() {
    bool isValid = true;

    // Clear previous errors
    businessNameError.value = '';
    phoneError.value = '';
    addressError.value = '';
    emailError.value = '';
    companyStoryError.value = '';
    paymentDetailsError.value = '';
    discountsError.value = '';
    policyError.value = '';
    additionalNotesError.value = '';
    thankYouMessageError.value = '';

    // Validate required fields
    if (!isRequired(businessNameCtrl.text)) {
      businessNameError.value = 'Business name is required';
      isValid = false;
    }

    if (!isRequired(phoneCtrl.text)) {
      phoneError.value = 'Phone number is required';
      isValid = false;
    }

    if (!isRequired(addressCtrl.text)) {
      addressError.value = 'Address is required';
      isValid = false;
    }

    if (!isValidEmail(emailCtrl.text)) {
      emailError.value = 'Valid email is required';
      isValid = false;
    }

    if (!isRequired(companyStoryCtrl.text)) {
      companyStoryError.value = 'Company story is required';
      isValid = false;
    }

    if (!isRequired(paymentDetailsCtrl.text)) {
      paymentDetailsError.value = 'Payment details are required';
      isValid = false;
    }

    if (!isRequired(discountsCtrl.text)) {
      discountsError.value = 'Discount information is required';
      isValid = false;
    }

    if (!isRequired(policyCtrl.text)) {
      policyError.value = 'Policy information is required';
      isValid = false;
    }

    if (!isRequired(additionalNotesCtrl.text)) {
      additionalNotesError.value = 'Additional notes are required';
      isValid = false;
    }

    if (!isRequired(thankYouMessageCtrl.text)) {
      thankYouMessageError.value = 'Thank you message is required';
      isValid = false;
    }

    return isValid;
  }

  /// Upload file
  Future<void> uploadFile(String fileType) async {
    setUploading(true);
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf', 'doc', 'docx', 'txt'],
      );

      if (result != null) {
        File file = File(result.files.single.path!);
        String fileName = result.files.single.name;
        
        // Upload to Firebase Storage
        final ref = _storage.ref().child('ai_knowledge/$getCurrentUserId()/$fileName');
        final uploadTask = await ref.putFile(file);
        final downloadUrl = await uploadTask.ref.getDownloadURL();
        
        uploadedFileUrl.value = downloadUrl;
        
        if (fileType == 'business') {
          selectedBusinessFile.value = fileName;
        } else {
          selectedFAQFile.value = fileName;
        }
        
        showSuccess('File uploaded successfully');
      }
    } catch (e) {
      setError('Failed to upload file: ${e.toString()}');
    } finally {
      setUploading(false);
    }
  }

  /// Clear form
  void clearForm() {
    businessNameCtrl.clear();
    phoneCtrl.clear();
    addressCtrl.clear();
    emailCtrl.clear();
    companyStoryCtrl.clear();
    paymentDetailsCtrl.clear();
    discountsCtrl.clear();
    policyCtrl.clear();
    additionalNotesCtrl.clear();
    thankYouMessageCtrl.clear();
    selectedBusinessFile.value = '';
    selectedFAQFile.value = '';
    uploadedFileUrl.value = '';
    
    // Clear errors
    businessNameError.value = '';
    phoneError.value = '';
    addressError.value = '';
    emailError.value = '';
    companyStoryError.value = '';
    paymentDetailsError.value = '';
    discountsError.value = '';
    policyError.value = '';
    additionalNotesError.value = '';
    thankYouMessageError.value = '';
  }
}
