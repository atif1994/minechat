import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ForgotPasswordController extends GetxController {
  final emailCtrl = TextEditingController();
  final emailError = RxnString();

  /// Email validation logic
  void validateEmail(String value) {
    if (value.trim().isEmpty) {
      emailError.value = 'Email is required';
    } else if (!GetUtils.isEmail(value.trim())) {
      emailError.value = 'Enter a valid email address';
    } else {
      emailError.value = null;
    }
  }

  /// Submit logic (extend with Firebase)
  void submit() {
    validateEmail(emailCtrl.text);
    if (emailError.value == null) {
      // TODO: Add Firebase reset logic
      Get.snackbar(
        'Success',
        'Password reset link sent!',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green.shade100,
      );
    } else {
      Get.snackbar(
        'Error',
        emailError.value!,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.shade100,
      );
    }
  }

  @override
  void onClose() {
    emailCtrl.dispose();
    super.onClose();
  }
}
