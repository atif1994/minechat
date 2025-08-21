import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:minechat/model/data/faq_model.dart';

class FAQsController extends GetxController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Loading States
  var isLoading = false.obs;
  var isSaving = false.obs;

  // FAQ Controllers
  final questionCtrl = TextEditingController();
  final answerCtrl = TextEditingController();
  final categoryCtrl = TextEditingController();

  // Validation Errors
  var questionError = ''.obs;
  var answerError = ''.obs;
  var categoryError = ''.obs;

  // FAQs List
  var faqs = <FAQModel>[].obs;

  @override
  void onInit() {
    super.onInit();
    loadFAQs();
  }

  String getCurrentUserId() {
    return FirebaseAuth.instance.currentUser?.uid ?? '';
  }

  /// Load existing FAQs
  Future<void> loadFAQs() async {
    try {
      isLoading.value = true;
      final userId = getCurrentUserId();
      if (userId.isEmpty) throw Exception("User not authenticated");

      final querySnapshot = await _firestore
          .collection('faqs')
          .where('userId', isEqualTo: userId)
          .orderBy('createdAt', descending: true)
          .get();

      faqs.value = querySnapshot.docs
          .map((doc) => FAQModel.fromMap({
        'id': doc.id,
        ...doc.data(),
      }))
          .toList();
    } catch (e) {
      if (!e.toString().contains('User not authenticated')) {
        Get.snackbar('Error', 'Failed to load FAQs: $e');
      }
    } finally {
      isLoading.value = false;
    }
  }

  /// Add new FAQ
  Future<void> addFAQ() async {
    if (!_validateForm()) {
      Get.snackbar('Validation Error', 'Please fix the errors in the form',
          backgroundColor: Colors.red, colorText: Colors.white);
      return;
    }

    try {
      isSaving.value = true;
      final userId = getCurrentUserId();

      if (userId.isEmpty) throw Exception("User not logged in");

      final faq = FAQModel(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        question: questionCtrl.text.trim(),
        answer: answerCtrl.text.trim(),
        category: categoryCtrl.text.trim(),
        userId: userId,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      await _firestore
          .collection('faqs')
          .doc(faq.id)
          .set(faq.toMap());

      // Add to local list
      faqs.insert(0, faq);

      // Clear form
      _clearForm();

      Get.snackbar('Success', 'FAQ added successfully!',
          backgroundColor: Colors.green, colorText: Colors.white);
    } catch (e) {
      Get.snackbar('Error', 'Failed to add FAQ: $e',
          backgroundColor: Colors.red, colorText: Colors.white);
    } finally {
      isSaving.value = false;
    }
  }

  /// Update FAQ
  Future<void> updateFAQ(String id) async {
    if (!_validateForm()) {
      Get.snackbar('Validation Error', 'Please fix the errors in the form',
          backgroundColor: Colors.red, colorText: Colors.white);
      return;
    }

    try {
      isSaving.value = true;
      final userId = getCurrentUserId();

      if (userId.isEmpty) throw Exception("User not logged in");

      final updatedFAQ = FAQModel(
        id: id,
        question: questionCtrl.text.trim(),
        answer: answerCtrl.text.trim(),
        category: categoryCtrl.text.trim(),
        userId: userId,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      await _firestore
          .collection('faqs')
          .doc(id)
          .update(updatedFAQ.toMap());

      // Update local list
      final index = faqs.indexWhere((item) => item.id == id);
      if (index != -1) {
        faqs[index] = updatedFAQ;
      }

      // Clear form
      _clearForm();

      Get.snackbar('Success', 'FAQ updated successfully!',
          backgroundColor: Colors.green, colorText: Colors.white);
    } catch (e) {
      Get.snackbar('Error', 'Failed to update FAQ: $e',
          backgroundColor: Colors.red, colorText: Colors.white);
    } finally {
      isSaving.value = false;
    }
  }

  /// Delete FAQ
  Future<void> deleteFAQ(String id) async {
    try {
      await _firestore.collection('faqs').doc(id).delete();

      // Remove from local list
      faqs.removeWhere((item) => item.id == id);

      Get.snackbar('Success', 'FAQ deleted successfully!',
          backgroundColor: Colors.green, colorText: Colors.white);
    } catch (e) {
      Get.snackbar('Error', 'Failed to delete FAQ: $e',
          backgroundColor: Colors.red, colorText: Colors.white);
    }
  }

  /// Load FAQ for editing
  void loadForEdit(FAQModel faq) {
    questionCtrl.text = faq.question;
    answerCtrl.text = faq.answer;
    categoryCtrl.text = faq.category;
  }

  /// Clear form
  void _clearForm() {
    questionCtrl.clear();
    answerCtrl.clear();
    categoryCtrl.clear();

    // Clear errors
    questionError.value = '';
    answerError.value = '';
    categoryError.value = '';
  }

  /// Validation Methods
  void validateQuestion(String value) {
    questionError.value = value.trim().isEmpty ? "Question is required" : '';
  }

  void validateAnswer(String value) {
    answerError.value = value.trim().isEmpty ? "Answer is required" : '';
  }

  void validateCategory(String value) {
    categoryError.value = value.trim().isEmpty ? "Category is required" : '';
  }

  bool _validateForm() {
    validateQuestion(questionCtrl.text);
    validateAnswer(answerCtrl.text);
    validateCategory(categoryCtrl.text);

    return questionError.value.isEmpty &&
        answerError.value.isEmpty &&
        categoryError.value.isEmpty;
  }

  @override
  void onClose() {
    questionCtrl.dispose();
    answerCtrl.dispose();
    categoryCtrl.dispose();
    super.onClose();
  }
}
