import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:minechat/controller/login_controller/login_controller.dart';
import 'package:minechat/controller/theme_controller/theme_controller.dart';
import 'package:minechat/core/utils/helpers/app_responsive/app_responsive.dart';
import 'package:minechat/core/utils/helpers/app_spacing/app_spacing.dart';
import 'package:minechat/core/utils/helpers/app_styles/app_text_styles.dart';
import 'package:minechat/core/widgets/app_button/app_large_button.dart';

import 'package:minechat/core/services/firebase_auth_service.dart';
import 'package:minechat/core/widgets/edit_profile/logout_alert_dialogue.dart';
import 'package:minechat/model/repositories/user_repository.dart';
import 'package:minechat/model/data/user_model.dart';

import 'package:minechat/core/widgets/edit_profile/edit_profile_avatar_picker.dart';
import 'package:minechat/core/widgets/edit_profile/edit_profile_textfield.dart';
import 'package:minechat/core/constants/app_assets/app_assets.dart';

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

class AdminEditProfileScreen extends StatelessWidget {
  const AdminEditProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final themeController = Get.find<ThemeController>();
    final c = Get.put(AdminEditProfileController());

    return Obx(() {
      final isDark = themeController.isDarkMode;
      final backColor = isDark ? Colors.white : const Color(0xFF222222);

      return Scaffold(
        backgroundColor:
            isDark ? const Color(0XFF0A0A0A) : const Color(0XFFF4F6FC),
        appBar: AppBar(
          backgroundColor: isDark ? const Color(0XFF0A0A0A) : Colors.white,
          elevation: 0,
          leading: BackButton(color: backColor),
          // <-- 1) back button icon color
          title: Text(
            'Edit profile',
            style: AppTextStyles.bodyText(context).copyWith(
              fontWeight: FontWeight.w600,
              fontSize: AppResponsive.scaleSize(context, 20),
            ),
          ),
        ),
        body: Obx(() {
          if (c.isLoading.value) {
            return const Center(child: CircularProgressIndicator());
          }

          return SingleChildScrollView(
            padding: AppSpacing.all(context, factor: 2),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AppSpacing.vertical(context, 0.01),
                Center(
                  child: Column(
                    children: [
                      Text(
                        'Profile',
                        style: AppTextStyles.bodyText(context).copyWith(
                          fontWeight: FontWeight.w700,
                          color: isDark ? Colors.white : Colors.black,
                          fontSize: AppResponsive.scaleSize(context, 12),
                        ),
                      ),
                      AppSpacing.vertical(context, 0.01),
                      EditProfileAvatarPicker(
                        initialImageUrl: c.photoUrl.value,
                        onImageSelected: (file) =>
                            c.saveFields(photoFile: file),
                        overlaySvgPath: AppAssets
                            .signupUploadImage, // <- swap to your camera svg
                      ),
                    ],
                  ),
                ),
                AppSpacing.vertical(context, 0.03),
                Text(
                  'User details',
                  style: AppTextStyles.bodyText(context).copyWith(
                    fontSize: AppResponsive.scaleSize(context, 16),
                    fontWeight: FontWeight.w500,
                    color: isDark ? Colors.white : const Color(0XFF222222),
                  ),
                ),
                AppSpacing.vertical(context, 0.01),
                EditProfileTextField(
                  label: 'Name',
                  controller: c.nameCtrl,
                  errorText: c.nameError,
                  onChanged: (_) => c.nameError.value = '',
                  onFocusLost: (val) => c.saveFields(name: val),
                ),
                AppSpacing.vertical(context, 0.015),
                EditProfileTextField(
                  label: 'Email',
                  controller: c.emailCtrl,
                  readOnly: true,
                ),
                AppSpacing.vertical(context, 0.015),
                EditProfileTextField(
                  label: 'Password',
                  controller: c.passwordCtrl,
                  readOnly: true,
                  obscureText: true,
                ),
                AppSpacing.vertical(context, 0.015),
                EditProfileTextField(
                  label: 'Position',
                  controller: c.positionCtrl,
                  errorText: c.positionError,
                  onChanged: (_) => c.positionError.value = '',
                  onFocusLost: (val) => c.saveFields(position: val),
                ),
                AppSpacing.vertical(context, 0.03),
                AppLargeButton(
                  label: c.isSaving.value ? 'Saving...' : 'Logout',
                  onTap: () {
                    LogoutAlertDialogue.show(
                      onConfirm: c.logout,
                      // Optional: tweak dim strength
                      barrier: Colors.black.withOpacity(0.55),
                    );
                  },
                  isEnabled: !c.isSaving.value,
                ),
                AppSpacing.vertical(context, 0.02),
              ],
            ),
          );
        }),
      );
    });
  }
}
