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
  var emailError = ''.obs;
  var passwordError = ''.obs;
  var isLoading = false.obs;
  var isPasswordVisible = false.obs;
  var currentUser = Rx<UserModel?>(null);

  // Validation methods
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
    } else {
      passwordError.value = '';
    }
  }

  // Toggle password visibility
  void togglePasswordVisibility() {
    isPasswordVisible.value = !isPasswordVisible.value;
  }

  // Login with email and password
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
        // Get user data from Firestore
        final userData = await _userRepository.getUser(userCredential.user!.uid);
        
        if (userData != null) {
          currentUser.value = userData;
          
          // Update last login
          await _userRepository.updateLastLogin(userCredential.user!.uid);

          Get.snackbar(
            'Success',
            'Welcome back, ${userData.name}!',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.green,
            colorText: Colors.white,
          );

          // Navigate to appropriate screen based on account type
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

  // Login with Google
  Future<void> loginWithGoogle() async {
    try {
      isLoading.value = true;

      final userCredential = await _authService.signInWithGoogle();
      
      if (userCredential != null) {
        final user = userCredential.user;
        if (user != null) {
          // Check if user exists in Firestore
          var userData = await _userRepository.getUser(user.uid);
          
          if (userData == null) {
            // Create new user from Google data
            userData = _userRepository.createUserFromFirebaseUser(user);
            await _userRepository.saveUser(userData);
            
            // Show success message and navigate to account type selection
            Get.snackbar(
              'Success',
              'Google Sign-In successful! Please complete your profile.',
              snackPosition: SnackPosition.BOTTOM,
              backgroundColor: Colors.green,
              colorText: Colors.white,
            );
            
            // Navigate to business account form for new users
            Get.to(() => BusinessAccountForm(email: user.email ?? ''));
          } else {
            // Existing user - update last login and navigate based on account type
            await _userRepository.updateLastLogin(user.uid);
            currentUser.value = userData;

            Get.snackbar(
              'Success',
              'Welcome back, ${userData.name}!',
              snackPosition: SnackPosition.BOTTOM,
              backgroundColor: Colors.green,
              colorText: Colors.white,
            );

                Get.to(() => BusinessAccountForm(email: user.email ?? ''));
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
      
      // Handle specific Google Sign-In errors
      if (e.toString().contains('ApiException: 10')) {
        errorMessage = 'Google Sign-In configuration error. Please check Firebase setup.';
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

  // Forgot password
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

  // Sign out
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
      Get.offAllNamed('/login');
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

  // Form validation
  bool _validateForm() {
    validateEmail(emailCtrl.text);
    validatePassword(passwordCtrl.text);

    return emailError.value.isEmpty && passwordError.value.isEmpty;
  }

  // Navigation based on account type
  void _navigateBasedOnAccountType(UserModel user) {
    if (user.isBusinessAccount) {
      // Business users go to login screen since home is deleted
      Get.offAllNamed('/login');
    } else if (user.isAdminAccount) {
      // Admin users go to login screen since home is deleted
      Get.offAllNamed('/login');
    } else {
      // Regular users go to login screen since home is deleted
      Get.offAllNamed('/login');
    }
  }

  // Validation helpers
  bool _isValidEmail(String email) {
    return RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email);
  }

  // Getters
  bool get isSignedIn => currentUser.value != null;
  String get currentUserName => currentUser.value?.name ?? '';
  String get currentUserEmail => currentUser.value?.email ?? '';

  @override
  void onClose() {
    emailCtrl.dispose();
    passwordCtrl.dispose();
    super.onClose();
  }
}
