import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:minechat/controller/login_controller/login_controller.dart';
import 'package:minechat/controller/theme_controller/theme_controller.dart';
import 'package:minechat/core/constants/app_colors/app_colors.dart';
import 'package:minechat/core/utils/helpers/app_responsive/app_responsive.dart';
import 'package:minechat/core/utils/helpers/app_spacing/app_spacing.dart';
import 'package:minechat/core/utils/helpers/app_styles/app_text_styles.dart';
import 'package:minechat/core/widgets/app_button/app_large_button.dart';

import 'package:minechat/core/services/firebase_auth_service.dart';
import 'package:minechat/core/widgets/edit_profile/edit_profile_avatar_picker.dart';
import 'package:minechat/core/widgets/edit_profile/edit_profile_textfield.dart';
import 'package:minechat/model/repositories/user_repository.dart';
import 'package:minechat/model/data/user_model.dart';

class BusinessEditProfileController extends GetxController {
  final _auth = FirebaseAuthService();
  final _repo = UserRepository();

  // Editable
  final businessNameCtrl = TextEditingController();
  final phoneCtrl = TextEditingController();

  // Read-only
  final emailCtrl = TextEditingController();
  final passwordCtrl = TextEditingController(text: '************');

  // Errors
  final businessNameError = ''.obs;
  final phoneError = ''.obs;

  // State
  final isLoading = false.obs;
  final isSaving = false.obs;
  final photoUrl = ''.obs;
  File? _newPhotoFile;

  String get _uid => _auth.currentUser?.uid ?? '';

  void setNewPhoto(File file) {
    _newPhotoFile = file;
  }

  // ---- LOAD ----
  Future<void> loadBusinessProfile() async {
    if (_uid.isEmpty) return;
    try {
      isLoading.value = true;

      final base = await _repo.getUser(_uid);
      final bizData = await _repo.getBusinessAccount(_uid);

      photoUrl.value = base?.photoURL ?? '';
      businessNameCtrl.text =
          bizData?['companyName'] ?? base?.companyName ?? base?.name ?? '';
      phoneCtrl.text = bizData?['phoneNumber'] ?? base?.phoneNumber ?? '';
      emailCtrl.text = base?.email ?? _auth.currentUser?.email ?? '';
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to load profile: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }

  // ---- VALIDATE ----
  bool _validate() {
    businessNameError.value =
        businessNameCtrl.text.trim().isEmpty ? 'Required' : '';
    final phone = phoneCtrl.text.trim();
    phoneError.value = phone.isEmpty
        ? 'Required'
        : (!RegExp(r'^\+?[\d\s\-\(\)]+$').hasMatch(phone) || phone.length < 7)
            ? 'Enter a valid phone'
            : '';
    return businessNameError.value.isEmpty && phoneError.value.isEmpty;
  }

  // ---- SAVE ----
  Future<void> saveBusinessProfile() async {
    if (_uid.isEmpty) return;
    if (!_validate()) return;

    try {
      isSaving.value = true;

      // Upload new photo if selected
      String? newPhotoUrl;
      if (_newPhotoFile != null) {
        newPhotoUrl =
            await _repo.uploadProfileImage(_newPhotoFile!, _uid, 'business');
      }

      // Update Auth display
      await _auth.updateProfile(
        displayName: businessNameCtrl.text.trim(),
        photoURL: newPhotoUrl ?? photoUrl.value,
      );

      // Update users/{uid}
      final userUpdate = <String, dynamic>{
        'name': businessNameCtrl.text.trim(),
        'companyName': businessNameCtrl.text.trim(),
        'phoneNumber': phoneCtrl.text.trim(),
      };
      if (newPhotoUrl != null) userUpdate['photoURL'] = newPhotoUrl;
      await _repo.updateUserProfile(_uid, userUpdate);

      // Update business_accounts/{uid} (merge)
      final bizUser = _repo.createBusinessUser(
        uid: _uid,
        email: emailCtrl.text.trim(),
        companyName: businessNameCtrl.text.trim(),
        phoneNumber: phoneCtrl.text.trim(),
        photoURL: newPhotoUrl ?? photoUrl.value,
      );
      await _repo.saveBusinessAccount(bizUser);

      // Reflect in LoginController
      final loginController = Get.find<LoginController>();
      loginController.currentUser.value = (loginController.currentUser.value ??
              UserModel(
                uid: _uid,
                name: '',
                email: emailCtrl.text.trim(),
              ))
          .copyWith(
        name: businessNameCtrl.text.trim(),
        companyName: businessNameCtrl.text.trim(),
        phoneNumber: phoneCtrl.text.trim(),
        photoURL: newPhotoUrl ?? photoUrl.value,
        accountType: 'business',
      );

      if (newPhotoUrl != null) photoUrl.value = newPhotoUrl;

      Get.snackbar(
        'Saved',
        'Profile updated successfully',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to save profile: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isSaving.value = false;
    }
  }

  // ---- DELETE ACCOUNT (Auth only; extend to Firestore if you want soft-delete) ----
  Future<void> deleteAccount() async {
    try {
      await _auth.deleteAccount();
      final loginController = Get.find<LoginController>();
      loginController.currentUser.value = null;
      Get.offAllNamed('/onboarding');
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to delete account: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  @override
  void onInit() {
    super.onInit();
    loadBusinessProfile();
  }

  @override
  void onClose() {
    businessNameCtrl.dispose();
    phoneCtrl.dispose();
    emailCtrl.dispose();
    passwordCtrl.dispose();
    super.onClose();
  }
}

class BusinessEditProfileScreen extends StatelessWidget {
  const BusinessEditProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final themeController = Get.find<ThemeController>();
    final c = Get.put(BusinessEditProfileController());

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          'Edit profile',
          style: AppTextStyles.bodyText(context)
              .copyWith(fontWeight: FontWeight.w600),
        ),
        elevation: 0,
        backgroundColor: Colors.transparent,
        foregroundColor: AppColors.black,
        actions: [
          Obx(() => TextButton(
                onPressed: c.isSaving.value ? null : c.saveBusinessProfile,
                child: c.isSaving.value
                    ? SizedBox(
                        width: AppResponsive.scaleSize(context, 16),
                        height: AppResponsive.scaleSize(context, 16),
                        child: const CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('Save'),
              )),
          AppSpacing.horizontal(context, 0.02),
        ],
      ),
      body: Obx(() {
        if (c.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }
        final isDark = themeController.isDarkMode;

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
                        fontWeight: FontWeight.w600,
                        color: isDark ? Colors.white : Colors.black,
                      ),
                    ),
                    AppSpacing.vertical(context, 0.01),
                    EditProfileAvatarPicker(
                      initialImageUrl: c.photoUrl.value,
                      onImageSelected: c.setNewPhoto,
                    ),
                  ],
                ),
              ),
              AppSpacing.vertical(context, 0.03),
              Text(
                'Account details',
                style: AppTextStyles.bodyText(context).copyWith(
                  fontSize: AppResponsive.scaleSize(context, 16),
                  fontWeight: FontWeight.w600,
                  color: isDark ? Colors.white : Colors.black,
                ),
              ),
              AppSpacing.vertical(context, 0.01),
              EditProfileTextField(
                label: 'Business name',
                controller: c.businessNameCtrl,
                errorText: c.businessNameError,
                onChanged: (_) => c.businessNameError.value = '',
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
                label: 'Mobile number',
                controller: c.phoneCtrl,
                keyboardType: TextInputType.phone,
                errorText: c.phoneError,
                onChanged: (_) => c.phoneError.value = '',
              ),
              AppSpacing.vertical(context, 0.03),
              Obx(() => AppLargeButton(
                    label: c.isLoading.value ? '...' : 'Delete account',
                    onTap: c.deleteAccount,
                    isEnabled: !c.isLoading.value && !c.isSaving.value,
                    isLoading: false,
                  )),
              AppSpacing.vertical(context, 0.02),
            ],
          ),
        );
      }),
    );
  }
}
