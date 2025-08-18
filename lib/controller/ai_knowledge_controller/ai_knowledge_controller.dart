import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:minechat/model/data/ai_knowledge_model.dart';
import '../../model/repositories/ai_knowledge_repository.dart';

class AIKnowledgeController extends GetxController {
  final AIKnowledgeRepository _repository = AIKnowledgeRepository();

  // Tab Management
  var selectedTabIndex = 0.obs;

  // Loading States
  var isLoading = false.obs;
  var isSaving = false.obs;

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


      }
    } catch (e) {
      if (!e.toString().contains('User not authenticated')) {
        Get.snackbar('Error', 'Failed to load AI Knowledge: $e');
      }
    } finally {
      isLoading.value = false;
    }
  }

  /// Save AI Knowledge
  Future<void> saveAIKnowledge() async {
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

        userId: userId,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      await _repository.saveAIKnowledge(aiKnowledge);

      Get.snackbar('Success', 'AI Knowledge saved successfully!',
          backgroundColor: Colors.green, colorText: Colors.white);
    } catch (e) {
      Get.snackbar('Error', 'Failed to save AI Knowledge: $e',
          backgroundColor: Colors.red, colorText: Colors.white);
    } finally {
      isSaving.value = false;
    }
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

    return businessNameError.value.isEmpty &&
        phoneError.value.isEmpty &&
        addressError.value.isEmpty &&
        emailError.value.isEmpty &&
        companyStoryError.value.isEmpty &&
        paymentDetailsError.value.isEmpty &&
        discountsError.value.isEmpty &&
        policyError.value.isEmpty &&
        additionalNotesError.value.isEmpty &&
        thankYouMessageError.value.isEmpty;
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
