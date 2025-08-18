import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:minechat/model/data/faq_model.dart';

class FAQController extends GetxController {
  var faqs = <FAQModel>[].obs;
  var isLoading = false.obs;
  var selectedFAQFile = ''.obs;

  @override
  void onInit() {
    super.onInit();
    // Add initial FAQ if empty
    if (faqs.isEmpty) {
      addNewFAQ();
    }
  }

  void addNewFAQ() {
    final newFAQ = FAQModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      questionCtrl: TextEditingController(),
      answerCtrl: TextEditingController(),
      questionError: ''.obs,
      answerError: ''.obs,
    );
    faqs.add(newFAQ);
  }

  void removeFAQ(FAQModel faq) {
    faqs.remove(faq);
    // Ensure at least one FAQ remains
    if (faqs.isEmpty) {
      addNewFAQ();
    }
  }

  bool validateFAQQuestion(String value) {
    if (value.trim().isEmpty) {
      return false;
    }
    return true;
  }

  bool validateFAQAnswer(String value) {
    if (value.trim().isEmpty) {
      return false;
    }
    return true;
  }

  bool validateAllFAQs() {
    bool isValid = true;
    
    for (var faq in faqs) {
      if (!validateFAQQuestion(faq.question)) {
        faq.questionError.value = 'Question is required';
        isValid = false;
      } else {
        faq.questionError.value = '';
      }
      
      if (!validateFAQAnswer(faq.answer)) {
        faq.answerError.value = 'Answer is required';
        isValid = false;
      } else {
        faq.answerError.value = '';
      }
    }
    
    return isValid;
  }

  @override
  void onClose() {
    // Dispose all controllers
    for (var faq in faqs) {
      faq.questionCtrl.dispose();
      faq.answerCtrl.dispose();
    }
    super.onClose();
  }
}
