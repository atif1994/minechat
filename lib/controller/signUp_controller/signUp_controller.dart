import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:minechat/core/services/firebase_auth_service.dart';
import 'package:minechat/model/repositories/user_repository.dart';
import 'package:minechat/controller/login_controller/login_controller.dart';

class SignupController extends GetxController {
  static SignupController get to => Get.find();

  final FirebaseAuthService _authService = FirebaseAuthService();
  final UserRepository _userRepository = UserRepository();

  // Text controllers
  final companyNameCtrl = TextEditingController();
  final phoneCtrl = TextEditingController();
  final emailCtrl = TextEditingController();
  final passwordCtrl = TextEditingController();
  final confirmPasswordCtrl = TextEditingController();
  final adminNameCtrl = TextEditingController();
  final positionCtrl = TextEditingController();

  // Error messages
  var companyNameError = ''.obs;
  var phoneError = ''.obs;
  var emailError = ''.obs;
  var passwordError = ''.obs;
  var confirmPasswordError = ''.obs;
  var adminNameError = ''.obs;
  var positionError = ''.obs;

  // UI State
  var isPasswordVisible = false.obs;
  var isConfirmPasswordVisible = false.obs;
  var isLoading = false.obs;
  var profileImageUrl = ''.obs;
  var isGoogleUser = false.obs;
  var showPasswordFields = false.obs; // ✅ Added to show password in admin form

  @override
  void onInit() {
    super.onInit();
    _checkForGoogleUser();

    // ✅ If password was already filled in business step, show in admin form
    if (passwordCtrl.text.isNotEmpty && confirmPasswordCtrl.text.isNotEmpty) {
      showPasswordFields.value = true;
    }
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

  void _checkForGoogleUser() {
    final loginController = Get.find<LoginController>();
    final currentUser = loginController.currentUser.value;
    final currentFirebaseUser = _authService.currentUser;

    if (currentUser != null && currentUser.accountType == 'regular') {
      isGoogleUser.value = true;
      emailCtrl.text = currentUser.email;

      if (Get.arguments != null && Get.arguments['isBusiness'] == true) {
        companyNameCtrl.text = currentUser.name;
        if (currentUser.photoURL != null) {
          profileImageUrl.value = currentUser.photoURL!;
        }
      } else if (Get.arguments != null && Get.arguments['isAdmin'] == true) {
        adminNameCtrl.text = currentUser.name;
        if (currentUser.photoURL != null) {
          profileImageUrl.value = currentUser.photoURL!;
        }
      }
    } else if (currentFirebaseUser != null) {
      emailCtrl.text = currentFirebaseUser.email ?? '';
      isGoogleUser.value = true;
    }
  }

  // Field Validators
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

  void validatePassword(String value) {
    if (value.trim().isEmpty) {
      passwordError.value = "Password is required";
    } else if (!_isValidPassword(value.trim())) {
      passwordError.value = "Min 8 chars, include upper, lower, number & symbol";
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

  void validateAdminName(String value) {
    if (value.trim().isEmpty) {
      adminNameError.value = "Admin name is required";
    } else if (value.trim().length < 2) {
      adminNameError.value = "Name must be at least 2 characters";
    } else {
      adminNameError.value = '';
    }
  }

  void validatePosition(String value) {
    if (value.trim().isEmpty) {
      positionError.value = "Position is required";
    } else if (value.trim().length < 2) {
      positionError.value = "Position must be at least 2 characters";
    } else {
      positionError.value = '';
    }
  }

  // Full Form Validation
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

    if (showPasswordFields.value) {
      validatePassword(passwordCtrl.text);
      validateConfirmPassword(confirmPasswordCtrl.text);
    }

    return adminNameError.value.isEmpty &&
        positionError.value.isEmpty &&
        emailError.value.isEmpty &&
        (showPasswordFields.value
            ? passwordError.value.isEmpty &&
            confirmPasswordError.value.isEmpty
            : true);
  }

  void togglePasswordVisibility() {
    isPasswordVisible.value = !isPasswordVisible.value;
  }

  void toggleConfirmPasswordVisibility() {
    isConfirmPasswordVisible.value = !isConfirmPasswordVisible.value;
  }

  // Business Account Creation
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

      final currentFirebaseUser = _authService.currentUser;

      if (currentFirebaseUser != null) {
        final businessUser = _userRepository.createBusinessUser(
          uid: currentFirebaseUser.uid,
          email: emailCtrl.text.trim(),
          companyName: companyNameCtrl.text.trim(),
          phoneNumber: phoneCtrl.text.trim(),
          photoURL:
          profileImageUrl.value.isNotEmpty ? profileImageUrl.value : null,
        );

        await _authService.updateProfile(
          displayName: businessUser.companyName,
          photoURL: businessUser.photoURL,
        );

        await _userRepository.saveUser(businessUser);
        await _userRepository.saveBusinessAccount(businessUser);

        try {
          final loginController = Get.find<LoginController>();
          loginController.currentUser.value = businessUser;
        } catch (_) {}

        Get.snackbar(
          'Success',
          'Business account created successfully!',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );

        // ✅ Move to admin signup
        Get.offAllNamed('/admin-signup');
      } else {
        final userCredential = await _authService.signUpWithEmailAndPassword(
          email: emailCtrl.text.trim(),
          password: passwordCtrl.text.trim(),
        );

        if (userCredential.user != null) {
          final businessUser = _userRepository.createBusinessUser(
            uid: userCredential.user!.uid,
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
            'Business account created successfully! Please check your email for verification.',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.green,
            colorText: Colors.white,
          );

          // ✅ Move to admin signup
          Get.offAllNamed('/admin-signup');
        }
      }
    } catch (e) {
      _handleFirebaseErrors(e, 'Failed to create business account');
    } finally {
      isLoading.value = false;
    }
  }

  // Admin Account Creation
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

    try {
      isLoading.value = true;

      final currentFirebaseUser = _authService.currentUser;

      if (currentFirebaseUser != null) {
        final adminUser = _userRepository.createAdminUser(
          uid: currentFirebaseUser.uid,
          email: emailCtrl.text.trim(),
          name: adminNameCtrl.text.trim(),
          position: positionCtrl.text.trim(),
          photoURL:
          profileImageUrl.value.isNotEmpty ? profileImageUrl.value : null,
        );

        await _authService.updateProfile(
          displayName: adminUser.name,
          photoURL: adminUser.photoURL,
        );

        await _userRepository.saveUser(adminUser);
        await _userRepository.saveAdminUser(adminUser);

        try {
          final loginController = Get.find<LoginController>();
          loginController.currentUser.value = adminUser;
        } catch (_) {}

        Get.snackbar(
          'Success',
          'Admin account created successfully!',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );

        Get.offAllNamed('/login');
      } else {
        final userCredential = await _authService.signUpWithEmailAndPassword(
          email: emailCtrl.text.trim(),
          password: passwordCtrl.text.trim(),
        );

        if (userCredential.user != null) {
          final adminUser = _userRepository.createAdminUser(
            uid: userCredential.user!.uid,
            email: emailCtrl.text.trim(),
            name: adminNameCtrl.text.trim(),
            position: positionCtrl.text.trim(),
            photoURL:
            profileImageUrl.value.isNotEmpty ? profileImageUrl.value : null,
          );

          await _userRepository.saveUser(adminUser);
          await _userRepository.saveAdminUser(adminUser);

          await _authService.updateProfile(
            displayName: adminUser.name,
            photoURL: adminUser.photoURL,
          );

          Get.snackbar(
            'Success',
            'Admin account created successfully! Please check your email for verification.',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.green,
            colorText: Colors.white,
          );

          Get.offAllNamed('/login');
        }
      }
    } catch (e) {
      _handleFirebaseErrors(e, 'Failed to create admin account');
    } finally {
      isLoading.value = false;
    }
  }

  // Handle Firebase Errors
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

  void setProfileImageUrl(String url) {
    profileImageUrl.value = url;
  }

  // Helper validators
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

}
