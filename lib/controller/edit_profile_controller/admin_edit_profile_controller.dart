import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:minechat/controller/login_controller/login_controller.dart';
import 'package:minechat/core/services/firebase_auth_service.dart';
import 'package:minechat/model/data/user_model.dart';
import 'package:minechat/model/repositories/user_repository.dart';

class AdminEditProfileController extends GetxController {
  final _auth = FirebaseAuthService();
  final _repo = UserRepository();

  final nameCtrl = TextEditingController();
  final positionCtrl = TextEditingController();
  final emailCtrl = TextEditingController();
  final passwordCtrl = TextEditingController(text: '************');

  final nameError = ''.obs;
  final positionError = ''.obs;

  final isLoading = false.obs;
  final isSaving = false.obs;
  final photoUrl = ''.obs;

  String get _uid => _auth.currentUser?.uid ?? '';

  Future<void> loadAdminProfile() async {
    if (_uid.isEmpty) return;
    try {
      isLoading.value = true;
      final base = await _repo.getUser(_uid);
      final adminData = await _repo.getAdminUser(_uid);

      photoUrl.value = base?.photoURL ?? '';
      nameCtrl.text = adminData?['name'] ?? base?.name ?? '';
      positionCtrl.text = adminData?['position'] ?? base?.position ?? '';
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

  bool _validateName(String v) {
    nameError.value = v.trim().isEmpty ? 'Required' : '';
    return nameError.value.isEmpty;
  }

  bool _validatePosition(String v) {
    positionError.value = v.trim().isEmpty ? 'Required' : '';
    return positionError.value.isEmpty;
  }

  Future<void> saveFields(
      {String? name, String? position, File? photoFile}) async {
    if (_uid.isEmpty) return;
    if ((name == null || name.trim().isEmpty) &&
        (position == null || position.trim().isEmpty) &&
        photoFile == null) {
      return;
    }

    if (name != null && !_validateName(name)) return;
    if (position != null && !_validatePosition(position)) return;

    try {
      isSaving.value = true;

      String? newPhotoUrl;
      if (photoFile != null) {
        newPhotoUrl = await _repo.uploadProfileImage(photoFile, _uid, 'admin');
      }

      if (name != null || newPhotoUrl != null) {
        await _auth.updateProfile(
          displayName: name ?? nameCtrl.text.trim(),
          photoURL: newPhotoUrl ?? photoUrl.value,
        );
      }

      final userUpdate = <String, dynamic>{};
      if (name != null) userUpdate['name'] = name.trim();
      if (position != null) userUpdate['position'] = position.trim();
      if (newPhotoUrl != null) userUpdate['photoURL'] = newPhotoUrl;
      if (userUpdate.isNotEmpty) {
        await _repo.updateUserProfile(_uid, userUpdate);
      }

      final adminUser = _repo.createAdminUser(
        uid: _uid,
        email: emailCtrl.text.trim(),
        name: name ?? nameCtrl.text.trim(),
        position: position ?? positionCtrl.text.trim(),
        photoURL: newPhotoUrl ?? photoUrl.value,
      );
      await _repo.saveAdminUser(adminUser);

      if (name != null) nameCtrl.text = name.trim();
      if (position != null) positionCtrl.text = position.trim();
      if (newPhotoUrl != null) photoUrl.value = newPhotoUrl;

      final loginController = Get.find<LoginController>();
      loginController.currentUser.value = (loginController.currentUser.value ??
              UserModel(uid: _uid, name: '', email: emailCtrl.text.trim()))
          .copyWith(
        name: nameCtrl.text.trim(),
        position: positionCtrl.text.trim(),
        photoURL: photoUrl.value,
        accountType: 'admin',
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

  Future<void> logout() async {
    try {
      await _auth.signOut();
      Get.find<LoginController>().currentUser.value = null;
      Get.offAllNamed('/onboarding');
    } catch (e) {
      Get.snackbar('Error', 'Failed to sign out: $e',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white);
    }
  }

  @override
  void onInit() {
    super.onInit();
    loadAdminProfile();
  }

  @override
  void onClose() {
    nameCtrl.dispose();
    positionCtrl.dispose();
    emailCtrl.dispose();
    passwordCtrl.dispose();
    super.onClose();
  }
}
