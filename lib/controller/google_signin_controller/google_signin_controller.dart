import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../core/services/firebase_auth_service.dart';
import '../../model/repositories/user_repository.dart';
import '../../model/data/user_model.dart';

class GoogleSignInController extends GetxController {
  final FirebaseAuthService _authService = FirebaseAuthService();
  final UserRepository _userRepository = UserRepository();
  
  final RxBool isLoading = false.obs;
  final Rx<UserModel?> currentUser = Rx<UserModel?>(null);

  // Sign in with Google
  Future<void> signInWithGoogle() async {
    try {
      isLoading.value = true;
      
      final userCredential = await _authService.signInWithGoogle();
      
      if (userCredential != null) {
        final user = userCredential.user;
        if (user != null) {
          // Create user model
          final userModel = _userRepository.createUserFromFirebaseUser(user);
          
          // Save to Firestore
          await _userRepository.saveUser(userModel);
          
          // Update current user
          currentUser.value = userModel;
          
          Get.snackbar(
            'Success',
            'Welcome ${userModel.name}!',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: const Color(0xFF4CAF50),
            colorText: Colors.white,
          );
          

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
      Get.snackbar(
        'Error',
        'Failed to sign in with Google: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: const Color(0xFFF44336),
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
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
        backgroundColor: const Color(0xFF4CAF50),
        colorText: Colors.white,
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to sign out: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: const Color(0xFFF44336),
        colorText: Colors.white,
      );
    }
  }

  // Check if user is signed in
  bool get isSignedIn => currentUser.value != null;

  // Get current user name
  String get currentUserName => currentUser.value?.name ?? '';

  // Get current user email
  String get currentUserEmail => currentUser.value?.email ?? '';
}
