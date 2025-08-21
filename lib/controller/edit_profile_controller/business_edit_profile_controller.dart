import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:minechat/controller/login_controller/login_controller.dart';
import 'package:minechat/core/services/firebase_auth_service.dart';
import 'package:minechat/model/data/user_model.dart';
import 'package:minechat/model/repositories/user_repository.dart';

class BusinessEditProfileController extends GetxController {
  final _auth = FirebaseAuthService();
  final _repo = UserRepository();

  // Text controllers
  final companyNameCtrl = TextEditingController();
  final phoneCtrl = TextEditingController();
  final emailCtrl = TextEditingController();
  final passwordCtrl = TextEditingController(text: '************');

  // Reactive state
  final isLoading = false.obs;
  final isSaving = false.obs;
  final photoUrl = ''.obs;

  // Field errors (reactive)
  final companyNameError = ''.obs;
  final phoneError = ''.obs;

  String get _uid => _auth.currentUser?.uid ?? '';

  @override
  void onInit() {
    super.onInit();
    loadBusinessProfile();
  }

  // ------------ LOAD ------------
  Future<void> loadBusinessProfile() async {
    if (_uid.isEmpty) return;
    try {
      isLoading.value = true;

      final base = await _repo.getUser(_uid);
      final business = await _repo.getBusinessAccount(_uid);

      // Prefer business photo, else fallback to users.photoURL
      photoUrl.value =
          (business?['photoURL'] as String?) ?? (base?.photoURL ?? '');

      companyNameCtrl.text =
          business?['companyName'] ?? base?.companyName ?? '';
      phoneCtrl.text = business?['phoneNumber'] ?? base?.phoneNumber ?? '';
      emailCtrl.text = base?.email ?? _auth.currentUser?.email ?? '';
    } catch (e) {
      Get.snackbar('Error', 'Failed to load profile: $e',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white);
    } finally {
      isLoading.value = false;
    }
  }

  // ------------ VALIDATE (per-field) ------------
  bool _validateCompany(String v) {
    companyNameError.value = v.trim().isEmpty ? 'Required' : '';
    return companyNameError.value.isEmpty;
  }

  bool _validatePhone(String v) {
    final t = v.trim();
    if (t.isEmpty) {
      phoneError.value = 'Required';
      return false;
    }
    final ok = RegExp(r'^\+?[\d\s\-\(\)]+$').hasMatch(t) && t.length >= 7;
    phoneError.value = ok ? '' : 'Enter a valid phone number';
    return ok;
  }

  // ------------ SAVE (granular + autosave) ------------
  Future<void> saveFields({
    String? companyName,
    String? phone,
    File? photoFile,
  }) async {
    if (_uid.isEmpty) return;

    // Skip if nothing changed
    if ((companyName == null || companyName.trim().isEmpty) &&
        (phone == null || phone.trim().isEmpty) &&
        photoFile == null) {
      return;
    }

    // Validate the fields provided
    if (companyName != null && !_validateCompany(companyName)) return;
    if (phone != null && !_validatePhone(phone)) return;

    try {
      isSaving.value = true;

      String? newPhotoUrl;
      if (photoFile != null) {
        newPhotoUrl =
            await _repo.uploadProfileImage(photoFile, _uid, 'business');
      }

      // Update FirebaseAuth profile (business name as displayName) / photo if changed
      if (companyName != null || newPhotoUrl != null) {
        await _auth.updateProfile(
          displayName: companyName ?? companyNameCtrl.text.trim(),
          photoURL: newPhotoUrl ?? photoUrl.value,
        );
      }

      // Update users/{uid}
      final userUpdate = <String, dynamic>{};
      if (companyName != null) userUpdate['companyName'] = companyName.trim();
      if (phone != null) userUpdate['phoneNumber'] = phone.trim();
      if (newPhotoUrl != null) userUpdate['photoURL'] = newPhotoUrl;
      if (userUpdate.isNotEmpty) {
        await _repo.updateUserProfile(_uid, userUpdate);
      }

      // Update business_accounts/{uid} (make sure repo writes photoURL)
      await _repo.saveBusinessAccount(
        _repo.createBusinessUser(
          uid: _uid,
          email: emailCtrl.text.trim(),
          companyName: companyName ?? companyNameCtrl.text.trim(),
          phoneNumber: phone ?? phoneCtrl.text.trim(),
          photoURL: newPhotoUrl ?? photoUrl.value,
        ),
      );

      // Reflect UI
      if (companyName != null) companyNameCtrl.text = companyName.trim();
      if (phone != null) phoneCtrl.text = phone.trim();
      if (newPhotoUrl != null) photoUrl.value = newPhotoUrl;

      // Reflect cached user in LoginController
      final loginController = Get.find<LoginController>();
      loginController.currentUser.value = (loginController.currentUser.value ??
              UserModel(uid: _uid, name: '', email: emailCtrl.text.trim()))
          .copyWith(
        name: companyNameCtrl.text.trim(),
        companyName: companyNameCtrl.text.trim(),
        phoneNumber: phoneCtrl.text.trim(),
        photoURL: photoUrl.value,
        accountType: 'business',
      );
    } catch (e) {
      Get.snackbar('Error', 'Failed to save: $e',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white);
    } finally {
      isSaving.value = false;
    }
  }

  // ------------ DELETE FLOW ------------
  // Step 1: Delete profile (Firestore + Storage)
  Future<void> deleteProfileData() async {
    try {
      isSaving.value = true;
      await _repo.deleteUserEverywhere(_uid);
      Get.snackbar('Deleted', 'Profile data removed.',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green,
          colorText: Colors.white);
    } catch (e) {
      Get.snackbar('Error', e.toString(),
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white);
    } finally {
      isSaving.value = false;
    }
  }

  // Step 2: Delete account (Firebase Auth)
  Future<void> deleteAuthAccount(String password) async {
    final email = _auth.currentUser?.email ?? '';
    if (email.isEmpty) throw 'No email on current user.';
    await _auth.reauthenticateWithPassword(email: email, password: password);
    await _auth.deleteAccount();
    Get.offAllNamed('/onboarding');
  }

  @override
  void onClose() {
    companyNameCtrl.dispose();
    phoneCtrl.dispose();
    emailCtrl.dispose();
    passwordCtrl.dispose();
    super.onClose();
  }
}
