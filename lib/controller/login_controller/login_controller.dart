import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:minechat/core/services/firebase_auth_service.dart';
import 'package:minechat/model/repositories/user_repository.dart';
import 'package:minechat/model/data/user_model.dart';

import '../../view/screens/signUp/business_account_form.dart';

class LoginController extends GetxController {
  final FirebaseAuthService _authService = FirebaseAuthService();
  final UserRepository _userRepository = UserRepository();

  // Controllers
  final emailCtrl = TextEditingController();
  final passwordCtrl = TextEditingController();

  // Reactive variables
  final emailError = ''.obs;
  final passwordError = ''.obs;
  final isLoading = false.obs;
  final isPasswordVisible = false.obs;
  final currentUser = Rx<UserModel?>(null);

  // ====== VALIDATION ======

  void validateEmail(String value) {
    final v = value.trim();

    if (v.isEmpty) {
      emailError.value = 'Email is required';
      return;
    }

    // RFC-ish, but pragmatic
    final basic = RegExp(r'^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$');
    final hasConsecutiveDots = v.contains('..');
    final parts = v.split('@');
    final domainOk = parts.length == 2 && parts[1].contains('.');

    if (!basic.hasMatch(v) || hasConsecutiveDots || !domainOk) {
      emailError.value = 'Enter a valid email address';
      return;
    }

    // Prevent disposable-looking extremes (optional; comment out if not desired)
    if (v.length > 254) {
      emailError.value = 'Email is too long';
      return;
    }

    emailError.value = '';
  }

  void validatePassword(String value) {
    final p = value;

    if (p.isEmpty) {
      passwordError.value = 'Password is required';
      return;
    }

    if (p.contains(' ')) {
      passwordError.value = 'Password cannot contain spaces';
      return;
    }

    final issues = <String>[];
    if (p.length < 8) issues.add('8+ chars');
    if (!RegExp(r'[A-Z]').hasMatch(p)) issues.add('1 uppercase');
    if (!RegExp(r'[a-z]').hasMatch(p)) issues.add('1 lowercase');
    if (!RegExp(r'[0-9]').hasMatch(p)) issues.add('1 number');
    if (!RegExp(r'[!@#\$%^&*()_\-+=\[\]{};:"\\|,.<>\/?`~]').hasMatch(p)) {
      issues.add('1 special char');
    }

    // Avoid using email as password
    if (emailCtrl.text.trim().isNotEmpty &&
        p.toLowerCase() == emailCtrl.text.trim().toLowerCase()) {
      passwordError.value = 'Password must not be the same as email';
      return;
    }

    // Block trivial/common passwords (very short list; extend if you like)
    const bad = {
      'password',
      '12345678',
      'qwerty123',
      '11111111',
      'letmein',
      'admin123'
    };
    if (bad.contains(p.toLowerCase())) {
      passwordError.value = 'Choose a less common password';
      return;
    }

    if (issues.isNotEmpty) {
      passwordError.value = 'Password needs: ${issues.join(', ')}';
      return;
    }

    passwordError.value = '';
  }

  // Toggle password visibility
  void togglePasswordVisibility() {
    isPasswordVisible.value = !isPasswordVisible.value;
  }

  // Computed: can submit?
  bool get canSubmit =>
      emailError.value.isEmpty &&
      passwordError.value.isEmpty &&
      emailCtrl.text.trim().isNotEmpty &&
      passwordCtrl.text.isNotEmpty &&
      !isLoading.value;

  // ====== AUTH FLOWS (same as yours) ======

  Future<void> loginWithEmailAndPassword() async {
    if (!_validateForm()) {
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

      final userCredential = await _authService.signInWithEmailAndPassword(
        email: emailCtrl.text.trim(),
        password: passwordCtrl.text.trim(),
      );

      if (userCredential.user != null) {
        final userData =
            await _userRepository.getUser(userCredential.user!.uid);

        if (userData != null) {
          currentUser.value = userData;
          await _userRepository.updateLastLogin(userCredential.user!.uid);

          Get.snackbar(
            'Success',
            'Welcome back, ${userData.name}!',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.green,
            colorText: Colors.white,
          );

          _navigateBasedOnAccountType(userData);
        } else {
          Get.snackbar(
            'Error',
            'User data not found',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.red,
            colorText: Colors.white,
          );
        }
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        e.toString(),
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> loginWithGoogle() async {
    try {
      isLoading.value = true;

      final userCredential = await _authService.signInWithGoogle();

      if (userCredential != null) {
        final user = userCredential.user;
        if (user != null) {
          var userData = await _userRepository.getUser(user.uid);

          if (userData == null) {
            userData = _userRepository.createUserFromFirebaseUser(user);
            await _userRepository.saveUser(userData);

            Get.snackbar(
              'Success',
              'Google Sign-In successful! Please complete your profile.',
              snackPosition: SnackPosition.BOTTOM,
              backgroundColor: Colors.green,
              colorText: Colors.white,
            );

            Get.to(() => SignupBusinessAccount(email: user.email ?? ''));
          } else {
            await _userRepository.updateLastLogin(user.uid);
            currentUser.value = userData;

            Get.snackbar(
              'Success',
              'Welcome back, ${userData.name}!',
              snackPosition: SnackPosition.BOTTOM,
              backgroundColor: Colors.green,
              colorText: Colors.white,
            );

            Get.to(() => SignupBusinessAccount(email: user.email ?? ''));
          }
        }
      } else {
        Get.snackbar(
          'Cancelled',
          'Sign in was cancelled',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: const Color(0xFFFF9800),
          colorText: Colors.white,
        );
      }
    } catch (e) {
      String errorMessage = 'Failed to sign in with Google';

      if (e.toString().contains('ApiException: 10')) {
        errorMessage =
            'Google Sign-In configuration error. Please check Firebase setup.';
      } else if (e.toString().contains('network_error')) {
        errorMessage = 'Network error. Please check your internet connection.';
      } else if (e.toString().contains('sign_in_canceled')) {
        errorMessage = 'Sign in was cancelled by user.';
      } else if (e.toString().contains('sign_in_failed')) {
        errorMessage = 'Google Sign-In failed. Please try again.';
      }

      Get.snackbar(
        'Error',
        errorMessage,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
        duration: const Duration(seconds: 5),
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> forgotPassword() async {
    if (emailCtrl.text.trim().isEmpty) {
      Get.snackbar(
        'Error',
        'Please enter your email address',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }

    try {
      await _authService.sendPasswordResetEmail(emailCtrl.text.trim());
      Get.snackbar(
        'Success',
        'Password reset email sent! Please check your inbox.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        e.toString(),
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  Future<void> signOut() async {
    try {
      await _authService.signOut();
      currentUser.value = null;
      Get.snackbar(
        'Success',
        'Signed out successfully',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
      Get.offAllNamed('/onboarding');
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to sign out: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  bool _validateForm() {
    validateEmail(emailCtrl.text);
    validatePassword(passwordCtrl.text);
    return emailError.value.isEmpty && passwordError.value.isEmpty;
  }

  void _navigateBasedOnAccountType(UserModel user) {
    // You currently direct all types to /login; keep your logic as-is.
    Get.offAllNamed('/dashboard');
  }

  @override
  void onClose() {
    emailCtrl.dispose();
    passwordCtrl.dispose();
    super.onClose();
  }
}
