import 'package:flutter/material.dart';
import 'package:get/get.dart';

class SignupController extends GetxController {
  // Controllers
  final companyNameCtrl = TextEditingController();
  final phoneCtrl = TextEditingController();
  final emailCtrl = TextEditingController();
  final passwordCtrl = TextEditingController();
  final confirmPasswordCtrl = TextEditingController();
  final adminNameCtrl = TextEditingController();
  final positionCtrl = TextEditingController();

  // Reactive error messages
  var companyNameError = ''.obs;
  var phoneError = ''.obs;
  var emailError = ''.obs;
  var passwordError = ''.obs;
  var confirmPasswordError = ''.obs;
  var adminNameError = ''.obs;
  var positionError = ''.obs;

  var isPasswordVisible = false.obs;
  var isConfirmPasswordVisible = false.obs;

  // 🔹 Live field validators
  void validateCompanyName(String value) {
    if (value.trim().isEmpty) {
      companyNameError.value = "Company name is required";
    } else {
      companyNameError.value = '';
    }
  }

  void validatePhone(String value) {
    if (value.trim().isEmpty) {
      phoneError.value = "Phone number is required";
    } else {
      phoneError.value = '';
    }
  }

  void validateEmail(String value) {
    if (!_isValidEmail(value.trim())) {
      emailError.value = "Enter a valid email address";
    } else {
      emailError.value = '';
    }
  }

  void validatePassword(String value) {
    if (!_isValidPassword(value.trim())) {
      passwordError.value =
          "Min 8 chars, include upper, lower, number & symbol";
    } else {
      passwordError.value = '';
    }
  }

  void validateConfirmPassword(String value) {
    if (value.trim() != passwordCtrl.text.trim()) {
      confirmPasswordError.value = "Passwords do not match";
    } else {
      confirmPasswordError.value = '';
    }
  }

  void validateAdminName(String value) {
    if (value.trim().isEmpty) {
      adminNameError.value = "Admin name is required";
    } else {
      adminNameError.value = '';
    }
  }

  void validatePosition(String value) {
    if (value.trim().isEmpty) {
      positionError.value = "Position is required";
    } else {
      positionError.value = '';
    }
  }

  // Full form validation (for submit button)
  bool validateBusinessForm() {
    validateCompanyName(companyNameCtrl.text);
    validatePhone(phoneCtrl.text);
    validateEmail(emailCtrl.text);
    validatePassword(passwordCtrl.text);
    validateConfirmPassword(confirmPasswordCtrl.text);

    return companyNameError.value.isEmpty &&
        phoneError.value.isEmpty &&
        emailError.value.isEmpty &&
        passwordError.value.isEmpty &&
        confirmPasswordError.value.isEmpty;
  }

  bool validateAdminForm() {
    validateAdminName(adminNameCtrl.text);
    validatePosition(positionCtrl.text);
    validateEmail(emailCtrl.text);
    validatePassword(passwordCtrl.text);
    validateConfirmPassword(confirmPasswordCtrl.text);

    return adminNameError.value.isEmpty &&
        positionError.value.isEmpty &&
        emailError.value.isEmpty &&
        passwordError.value.isEmpty &&
        confirmPasswordError.value.isEmpty;
  }

  void togglePasswordVisibility() {
    isPasswordVisible.value = !isPasswordVisible.value;
  }

  void toggleConfirmPasswordVisibility() {
    isConfirmPasswordVisible.value = !isConfirmPasswordVisible.value;
  }

  bool _isValidEmail(String email) {
    final regex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    return regex.hasMatch(email);
  }

  bool _isValidPassword(String password) {
    final regex =
        RegExp(r'^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[@$!%*?&]).{8,}$');
    return regex.hasMatch(password);
  }
}
