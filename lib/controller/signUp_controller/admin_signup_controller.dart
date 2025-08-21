import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:minechat/core/services/firebase_auth_service.dart';
import 'package:minechat/core/services/otp_service/otp_service.dart';
import 'package:minechat/model/repositories/user_repository.dart';
import 'package:minechat/controller/login_controller/login_controller.dart';
import 'package:minechat/controller/auth_controller/auth_controller.dart';

class AdminSignupController extends GetxController {
  static AdminSignupController get to => Get.find();

  final FirebaseAuthService _authService = FirebaseAuthService();
  final UserRepository _userRepository = UserRepository();
  final _otp = OtpService();

  // Text controllers
  final adminNameCtrl = TextEditingController();
  final positionCtrl = TextEditingController();
  final emailCtrl = TextEditingController();
  final passwordCtrl = TextEditingController();
  final confirmPasswordCtrl = TextEditingController();

  // Error messages
  final adminNameError = ''.obs;
  final positionError = ''.obs;
  final emailError = ''.obs;
  final passwordError = ''.obs;
  final confirmPasswordError = ''.obs;

  // UI state
  final isPasswordVisible = false.obs;
  final isConfirmPasswordVisible = false.obs;
  final isLoading = false.obs;
  final isGoogleUser = false.obs;
  final profileImageUrl = ''.obs;
  var companyNameError = ''.obs;
  var phoneError = ''.obs;
  final companyNameCtrl = TextEditingController();
  final phoneCtrl = TextEditingController();
  var showPasswordFields = false.obs;

  File? _profileImageFile;
  RxBool isImageMissing = false.obs;

  @override
  void onInit() {
    super.onInit();

    // Clear previous form data once on init (optional)
    clearFormData();

    // Fill from passed arguments (email, password)
    final args = Get.arguments;
    if (args != null) {
      emailCtrl.text = args['email'] ?? '';
      passwordCtrl.text = args['password'] ?? '';
      confirmPasswordCtrl.text = args['password'] ?? '';
    }

    // Otherwise, if user is already logged in (Google or Firebase), prefill email
    final authUser = _authService.currentUser;
    if ((emailCtrl.text.isEmpty) &&
        authUser != null &&
        authUser.email != null) {
      emailCtrl.text = authUser.email!;
      isGoogleUser.value = true;
    }
    _checkForGoogleUser();
  }

  void setProfileImage(File image) {
    _profileImageFile = image;
    isImageMissing.value = false;
  }

  // Toggle visibility
  void togglePasswordVisibility() {
    isPasswordVisible.value = !isPasswordVisible.value;
  }

  void toggleConfirmPasswordVisibility() {
    isConfirmPasswordVisible.value = !isConfirmPasswordVisible.value;
  }

  void clearFormData() {
    companyNameCtrl.clear();
    phoneCtrl.clear();
    emailCtrl.clear();
    passwordCtrl.clear();
    confirmPasswordCtrl.clear();
    adminNameCtrl.clear();
    positionCtrl.clear();

    companyNameError.value = '';
    phoneError.value = '';
    emailError.value = '';
    passwordError.value = '';
    confirmPasswordError.value = '';
    adminNameError.value = '';
    positionError.value = '';

    isPasswordVisible.value = false;
    isConfirmPasswordVisible.value = false;
    isLoading.value = false;
    profileImageUrl.value = '';
    isGoogleUser.value = false;
    showPasswordFields.value = false;
  }

  // Google user autofill
  void _checkForGoogleUser() {
    final loginController = Get.find<LoginController>();
    final currentUser = loginController.currentUser.value;
    final currentFirebaseUser = _authService.currentUser;

    if (currentUser != null && currentUser.accountType == 'regular') {
      isGoogleUser.value = true;
      emailCtrl.text = currentUser.email;
      adminNameCtrl.text = currentUser.name;
      if (currentUser.photoURL != null) {
        profileImageUrl.value = currentUser.photoURL!;
      }
    } else if (currentFirebaseUser != null) {
      emailCtrl.text = currentFirebaseUser.email ?? '';
      isGoogleUser.value = true;
    }
  }

  // Validation methods
  void validateAdminName(String value) {
    if (value.trim().isEmpty) {
      adminNameError.value = 'Admin name is required';
    } else if (value.trim().length < 2) {
      adminNameError.value = 'Name must be at least 2 characters';
    } else {
      adminNameError.value = '';
    }
  }

  void validatePosition(String value) {
    if (value.trim().isEmpty) {
      positionError.value = 'Position is required';
    } else if (value.trim().length < 2) {
      positionError.value = 'Position must be at least 2 characters';
    } else {
      positionError.value = '';
    }
  }

  void validateEmail(String value) {
    if (value.trim().isEmpty) {
      emailError.value = 'Email is required';
    } else if (!_isValidEmail(value.trim())) {
      emailError.value = 'Invalid email format';
    } else {
      emailError.value = '';
    }
  }

  void validatePassword(String value) {
    if (value.trim().isEmpty) {
      passwordError.value = 'Password is required';
    } else if (!_isValidPassword(value.trim())) {
      passwordError.value = 'Must include upper, lower, digit, and symbol';
    } else {
      passwordError.value = '';
    }
  }

  void validateConfirmPassword(String value) {
    if (value.trim().isEmpty) {
      confirmPasswordError.value = 'Please confirm your password';
    } else if (value.trim() != passwordCtrl.text.trim()) {
      confirmPasswordError.value = 'Passwords do not match';
    } else {
      confirmPasswordError.value = '';
    }
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

  // Admin account creation
  // Admin account creation
  Future<void> createAdminAccount() async {
    if (!validateAdminForm()) {
      Get.snackbar(
        'Validation Error',
        'Please fix the errors in the form',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }

    if (_profileImageFile == null) {
      Get.snackbar(
        'Missing Profile Image',
        'Please select a profile image to continue.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.redAccent,
        colorText: Colors.white,
      );
      return;
    }

    try {
      isLoading.value = true;

      final currentUser = _authService.currentUser;
      if (currentUser == null) {
        throw Exception('No authenticated user found. Please sign in again.');
      }

      // Upload profile image
      final photoURL = await _userRepository.uploadProfileImage(
        _profileImageFile!,
        currentUser.uid,
        'admin',
      );

      // Build and save admin user
      final adminUser = _userRepository.createAdminUser(
        uid: currentUser.uid,
        email: currentUser.email ?? emailCtrl.text.trim(),
        name: adminNameCtrl.text.trim(),
        position: positionCtrl.text.trim(),
        photoURL: photoURL,
      );

      await _authService.updateProfile(
        displayName: adminUser.name,
        photoURL: adminUser.photoURL,
      );

      await _userRepository.saveUser(adminUser);
      await _userRepository.saveAdminUser(adminUser);

      // Reflect in LoginController
      final loginController = Get.find<LoginController>();
      loginController.currentUser.value = adminUser;

      // ➜ Send OTP via server callable (merged OtpService)
      final email = (currentUser.email ?? emailCtrl.text.trim()).trim();
      if (email.isEmpty) {
        throw Exception('No email available for OTP.');
      }

      await OtpService().sendOtp(email: email);

      // Success snackbar
      Get.snackbar(
        'Email sent',
        'We emailed a 6-digit code to $email.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green.shade100,
        colorText: Colors.black,
      );

      // Mark onboarding as completed and let AuthController handle navigation
      final authController = Get.find<AuthController>();
      authController.markOnboardingCompleted();
      // AuthController will automatically navigate to the appropriate screen
    } catch (e) {
      _handleFirebaseErrors(e, 'Failed to create admin account');
    } finally {
      isLoading.value = false;
    }
  }

  void setProfileImageUrl(String url) {
    profileImageUrl.value = url;
  }

  void _handleFirebaseErrors(dynamic e, String fallbackMessage) {
    String errorMessage = fallbackMessage;

    if (e.toString().contains('email-already-in-use')) {
      errorMessage =
          'An account with this email already exists. Please use a different email or try signing in.';
    } else if (e.toString().contains('weak-password')) {
      errorMessage = 'Password is too weak. Please use a stronger password';
    } else if (e.toString().contains('invalid-email')) {
      errorMessage = 'Please enter a valid email address';
    } else if (e.toString().contains('permission-denied')) {
      errorMessage = 'Database permission error. Please try again';
    }

    Get.snackbar(
      'Error',
      errorMessage,
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.red,
      colorText: Colors.white,
      duration: const Duration(seconds: 5),
    );
  }

  void clearAdminForm() {
    adminNameCtrl.clear();
    positionCtrl.clear();
    emailCtrl.clear();
    passwordCtrl.clear();
    confirmPasswordCtrl.clear();
    profileImageUrl.value = '';

    adminNameError.value = '';
    positionError.value = '';
    emailError.value = '';
    passwordError.value = '';
    confirmPasswordError.value = '';

    isPasswordVisible.value = false;
    isConfirmPasswordVisible.value = false;
  }

  // Validators
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
}
