import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:minechat/core/services/reset_password/reset_password_service.dart';

class NewPasswordController extends GetxController {
  // Passed from OtpScreen via: Get.offNamed('/new-password', arguments: {'email':..., 'resetToken':...})
  late final String email;
  late final String resetToken;

  // Text controllers
  final passwordCtrl = TextEditingController();
  final confirmCtrl = TextEditingController();

  // Reactive errors (to match your SignupTextField usage style)
  final RxString passwordError = ''.obs;
  final RxString confirmError = ''.obs;

  final isPasswordVisible = false.obs;
  final isConfirmVisible = false.obs;

  // Loading state for button (if supported by AppLargeButton)
  final isSaving = false.obs;

  @override
  void onInit() {
    super.onInit();
    email = (Get.arguments?['email'] as String?) ?? '';
    resetToken = (Get.arguments?['resetToken'] as String?) ?? '';
  }

  void validatePassword(String value) {
    final v = value.trim();
    if (v.length < 8) {
      passwordError.value = 'Minimum 8 characters required';
    } else {
      passwordError.value = '';
    }
  }

  void validateConfirm(String value) {
    final v = value.trim();
    if (v != passwordCtrl.text.trim()) {
      confirmError.value = 'Passwords do not match';
    } else {
      confirmError.value = '';
    }
  }

  void togglePasswordVisibility() => isPasswordVisible.toggle();

  void toggleConfirmVisibility() => isConfirmVisible.toggle();

  Future<void> submit() async {
    // Trigger validations
    validatePassword(passwordCtrl.text);
    validateConfirm(confirmCtrl.text);

    if (passwordError.value.isNotEmpty || confirmError.value.isNotEmpty) {
      return;
    }

    if (email.isEmpty || resetToken.isEmpty) {
      Get.snackbar('Error', 'Missing reset session. Please restart the flow.');
      return;
    }

    try {
      isSaving.value = true;

      await ResetPasswordService().resetPasswordWithSession(
        email: email,
        newPassword: passwordCtrl.text.trim(),
        resetToken: resetToken,
      );

      Get.snackbar('Success', 'Password has been reset. Please log in.');
      Get.offAllNamed('/login');
    } catch (e) {
      Get.snackbar('Failed', e.toString(), snackPosition: SnackPosition.BOTTOM);
    } finally {
      isSaving.value = false;
    }
  }

  @override
  void onClose() {
    passwordCtrl.dispose();
    confirmCtrl.dispose();
    super.onClose();
  }
}
