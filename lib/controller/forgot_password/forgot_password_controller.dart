import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:minechat/core/services/otp_service/otp_service.dart';

class ForgotPasswordController extends GetxController {
  final emailCtrl = TextEditingController();
  final RxString emailError = ''.obs;
  final _otp = OtpService();

  void validateEmail(String value) {
    final v = value.trim();
    if (v.isEmpty) {
      emailError.value = 'Email is required';
    } else if (!GetUtils.isEmail(v)) {
      emailError.value = 'Enter a valid email address';
    } else {
      emailError.value = '';
    }
  }

  Future<void> submit() async {
    validateEmail(emailCtrl.text);
    if (emailError.value.isNotEmpty) {
      Get.snackbar('Error', emailError.value,
          snackPosition: SnackPosition.BOTTOM);
      return;
    }
    try {
      final email = emailCtrl.text.trim();
      await _otp.sendOtp(email: email);

      Get.snackbar(
        'Email sent',
        'We emailed a 6-digit code to $email.',
        snackPosition: SnackPosition.BOTTOM,
      );

      Get.toNamed('/otp', arguments: {
        'email': email,
        'purpose': 'forgot',
        'skipInitialSend': true,
      });
    } catch (e) {
      Get.snackbar('Failed', e.toString(), snackPosition: SnackPosition.BOTTOM);
    }
  }

  @override
  void onClose() {
    emailCtrl.dispose();
    super.onClose();
  }
}
