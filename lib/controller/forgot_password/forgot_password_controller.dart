import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ForgotPasswordController extends GetxController {
  final emailCtrl = TextEditingController();
  final RxString emailError = ''.obs; // ✅ RxString instead of just String

  void validateEmail(String value) {
    if (value.trim().isEmpty) {
      emailError.value = 'Email is required';
    } else if (!GetUtils.isEmail(value.trim())) {
      emailError.value = 'Enter a valid email address';
    } else {
      emailError.value = ''; // ✅ No error
    }
  }

  void submit() {
    validateEmail(emailCtrl.text);
    if (emailError.value.isEmpty) {
      Get.snackbar(
        'Success',
        'Password reset link sent!',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green.shade100,
        colorText: Colors.black,
      );
    } else {
      Get.snackbar(
        'Error',
        emailError.value,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.shade100,
        colorText: Colors.black,
      );
    }
  }

  @override
  void onClose() {
    emailCtrl.dispose();
    super.onClose();
  }
}
