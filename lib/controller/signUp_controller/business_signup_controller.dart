import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:minechat/controller/login_controller/login_controller.dart';
import 'package:minechat/core/services/firebase_auth_service.dart';
import 'package:minechat/model/repositories/user_repository.dart';

class BusinessSignupController extends GetxController {
  static BusinessSignupController get to => Get.find();

  final companyNameCtrl = TextEditingController();
  final phoneCtrl = TextEditingController();
  final emailCtrl = TextEditingController();
  final passwordCtrl = TextEditingController();
  final confirmPasswordCtrl = TextEditingController();

  final companyNameError = ''.obs;
  final phoneError = ''.obs;
  final emailError = ''.obs;
  final passwordError = ''.obs;
  final confirmPasswordError = ''.obs;

  final isLoading = false.obs;
  final profileImageUrl = ''.obs;
  final isGoogleUser =
      false.obs; // if user logged in with Google (readonly mode)

  final isPasswordVisible = false.obs;
  final isConfirmPasswordVisible = false.obs;

  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  final FirebaseAuthService _authService = FirebaseAuthService();
  final UserRepository _userRepository = UserRepository();

  bool _isInitialized = false;

  @override
  void onInit() {
    super.onInit();
    _checkForGoogleUser();
  }

  void initFormOnce({String? emailFromRoute, String? firebaseEmail}) {
    if (_isInitialized) return;

    clearBusinessForm();

    if ((emailFromRoute ?? '').isNotEmpty) {
      emailCtrl.text = emailFromRoute!;
      isGoogleUser.value = true;
    } else if ((firebaseEmail ?? '').isNotEmpty) {
      emailCtrl.text = firebaseEmail!;
      isGoogleUser.value = true;
    }

    _isInitialized = true;
  }

  void validateCompanyName(String value) {
    if (value.trim().isEmpty) {
      companyNameError.value = "Company name is required";
    } else if (value.trim().length < 2) {
      companyNameError.value = "Company name must be at least 2 characters";
    } else {
      companyNameError.value = '';
    }
  }

  void validatePhone(String value) {
    if (value.trim().isEmpty) {
      phoneError.value = "Phone number is required";
    } else if (!_isValidPhone(value.trim())) {
      phoneError.value = "Enter a valid phone number";
    } else {
      phoneError.value = '';
    }
  }

  void validateEmail(String value) {
    if (value.trim().isEmpty) {
      emailError.value = "Email is required";
    } else if (!_isValidEmail(value.trim())) {
      emailError.value = "Enter a valid email address";
    } else {
      emailError.value = '';
    }
  }

  void togglePasswordVisibility() {
    isPasswordVisible.value = !isPasswordVisible.value;
  }

  void toggleConfirmPasswordVisibility() {
    isConfirmPasswordVisible.value = !isConfirmPasswordVisible.value;
  }

  void validatePassword(String value) {
    if (value.trim().isEmpty) {
      passwordError.value = "Password is required";
    } else if (!_isValidPassword(value.trim())) {
      passwordError.value =
          "Min 8 chars, include upper, lower, number & symbol";
    } else {
      passwordError.value = '';
    }
  }

  void validateConfirmPassword(String value) {
    if (value.trim().isEmpty) {
      confirmPasswordError.value = "Please confirm your password";
    } else if (value.trim() != passwordCtrl.text.trim()) {
      confirmPasswordError.value = "Passwords do not match";
    } else {
      confirmPasswordError.value = '';
    }
  }

  bool validateBusinessForm() {
    validateCompanyName(companyNameCtrl.text);
    validatePhone(phoneCtrl.text);
    validateEmail(emailCtrl.text);

    // Only validate password fields if NOT Google user
    if (!isGoogleUser.value) {
      validatePassword(passwordCtrl.text);
      validateConfirmPassword(confirmPasswordCtrl.text);
    }

    return companyNameError.value.isEmpty &&
        phoneError.value.isEmpty &&
        emailError.value.isEmpty &&
        (isGoogleUser.value ||
            (passwordError.value.isEmpty &&
                confirmPasswordError.value.isEmpty));
  }

  Future<void> createBusinessAccount() async {
    if (!validateBusinessForm()) {
      Get.snackbar(
        'Validation Error',
        'Please fix the errors in the form',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }

    try {
      isLoading.value = true;

      final user = _firebaseAuth.currentUser;

      if (user == null) {
        throw Exception('No user is currently signed in');
      }

      // Link email & password to existing Google account
      final credential = EmailAuthProvider.credential(
        email: emailCtrl.text.trim(),
        password: passwordCtrl.text.trim(),
      );

      await user.linkWithCredential(credential);

      // ✅ Print email and password after linking
      print('✅ New user created and linked with credentials:');
      print('📧 Email: ${emailCtrl.text.trim()}');
      print('🔑 Password: ${passwordCtrl.text.trim()}');

      // Create business user in Firestore
      final businessUser = _userRepository.createBusinessUser(
        uid: user.uid,
        email: emailCtrl.text.trim(),
        companyName: companyNameCtrl.text.trim(),
        phoneNumber: phoneCtrl.text.trim(),
        photoURL:
            profileImageUrl.value.isNotEmpty ? profileImageUrl.value : null,
      );

      await _userRepository.saveUser(businessUser);
      await _userRepository.saveBusinessAccount(businessUser);

      await _authService.updateProfile(
        displayName: businessUser.companyName,
        photoURL: businessUser.photoURL,
      );

      Get.snackbar(
        'Success',
        'Business account created and email/password linked!',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );

      Get.offAllNamed('/admin-signup', arguments: {
        'email': emailCtrl.text.trim(),
        'password': passwordCtrl.text.trim(),
      });
    } catch (e) {
      _handleFirebaseErrors(e, 'Failed to create business account');
    } finally {
      isLoading.value = false;
    }
  }

  void _checkForGoogleUser() {
    final loginController = Get.find<LoginController>();
    final currentUser = loginController.currentUser.value;
    final currentFirebaseUser = _firebaseAuth.currentUser;

    // If user is logged in with Google, pre-fill email & company name and disable password
    if (currentUser != null && currentUser.accountType == 'google') {
      isGoogleUser.value = true;
      emailCtrl.text = currentUser.email;
      companyNameCtrl.text = currentUser.name;
      if (currentUser.photoURL != null) {
        profileImageUrl.value = currentUser.photoURL!;
      }

      // Optionally disable password fields in UI based on isGoogleUser flag
    } else if (currentFirebaseUser != null &&
        currentFirebaseUser.providerData
            .any((p) => p.providerId == 'google.com')) {
      isGoogleUser.value = true;
      emailCtrl.text = currentFirebaseUser.email ?? '';
      // Set other fields if needed
    }
  }

  void clearBusinessForm() {
    companyNameCtrl.clear();
    phoneCtrl.clear();
    emailCtrl.clear();
    passwordCtrl.clear();
    confirmPasswordCtrl.clear();

    companyNameError.value = '';
    phoneError.value = '';
    emailError.value = '';
    passwordError.value = '';
    confirmPasswordError.value = '';

    isLoading.value = false;
    profileImageUrl.value = '';
    isGoogleUser.value = false;
  }

  bool _isValidEmail(String email) {
    return RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email);
  }

  bool _isValidPassword(String password) {
    return password.length >= 8 &&
        RegExp(r'[A-Z]').hasMatch(password) &&
        RegExp(r'[a-z]').hasMatch(password) &&
        RegExp(r'[0-9]').hasMatch(password) &&
        RegExp(r'[!@#$%^&*(),.?":{}|<>]').hasMatch(password);
  }

  bool _isValidPhone(String phone) {
    return RegExp(r'^\+?[\d\s\-\(\)]+$').hasMatch(phone) && phone.length >= 10;
  }

  void _handleFirebaseErrors(dynamic e, String fallbackMessage) {
    String errorMessage = fallbackMessage;
    final errorStr = e.toString();

    if (errorStr.contains('email-already-in-use')) {
      errorMessage = 'An account with this email already exists.';
    } else if (errorStr.contains('weak-password')) {
      errorMessage = 'Password is too weak.';
    } else if (errorStr.contains('invalid-email')) {
      errorMessage = 'Invalid email format.';
    } else if (errorStr.contains('permission-denied')) {
      errorMessage = 'Database permission error.';
    }

    Get.snackbar(
      'Error',
      errorMessage,
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.red,
      colorText: Colors.white,
    );
  }
}
