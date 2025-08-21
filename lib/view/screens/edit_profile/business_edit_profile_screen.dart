import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:minechat/controller/edit_profile_controller/business_edit_profile_controller.dart';
import 'package:minechat/controller/theme_controller/theme_controller.dart';
import 'package:minechat/core/utils/helpers/app_responsive/app_responsive.dart';
import 'package:minechat/core/utils/helpers/app_spacing/app_spacing.dart';
import 'package:minechat/core/utils/helpers/app_styles/app_text_styles.dart';
import 'package:minechat/core/widgets/app_button/app_large_button.dart';
import 'package:minechat/core/widgets/edit_profile/delete_account_alert_dialog.dart';
import 'package:minechat/core/widgets/edit_profile/delete_profile_alert_dialog.dart';
import 'package:minechat/core/widgets/edit_profile/edit_profile_avatar_picker.dart';
import 'package:minechat/core/widgets/edit_profile/edit_profile_textfield.dart';

import 'package:minechat/core/constants/app_assets/app_assets.dart';

class BusinessEditProfileScreen extends StatefulWidget {
  const BusinessEditProfileScreen({super.key});

  @override
  State<BusinessEditProfileScreen> createState() =>
      _BusinessEditProfileScreenState();
}

class _BusinessEditProfileScreenState extends State<BusinessEditProfileScreen> {
  @override
  Widget build(BuildContext context) {
    final themeController = Get.find<ThemeController>();
    final c = Get.put(BusinessEditProfileController());

    // Only wrap where Rx is read → avoids the “improper use of GetX/Obx” error.
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

                      // Avatar: auto-save on pick
                      EditProfileAvatarPicker(
                        initialImageUrl: c.photoUrl.value,
                        onImageSelected: (file) =>
                            c.saveFields(photoFile: file),
                        overlaySvgPath: AppAssets.signupUploadImage,
                      ),
                    ],
                  ),
                ),

                AppSpacing.vertical(context, 0.03),
                Text(
                  'Account details',
                  style: AppTextStyles.bodyText(context).copyWith(
                    fontSize: AppResponsive.scaleSize(context, 16),
                    fontWeight: FontWeight.w500,
                    color: isDark ? Colors.white : const Color(0XFF222222),
                  ),
                ),
                AppSpacing.vertical(context, 0.01),

                // Business name (autosave on blur)
                EditProfileTextField(
                  label: 'Business name',
                  controller: c.companyNameCtrl,
                  errorText: c.companyNameError,
                  onChanged: (_) => c.companyNameError.value = '',
                  onFocusLost: (val) => c.saveFields(companyName: val),
                ),
                AppSpacing.vertical(context, 0.015),

                // Email (read-only)
                EditProfileTextField(
                  label: 'Email',
                  controller: c.emailCtrl,
                  readOnly: true,
                ),
                AppSpacing.vertical(context, 0.015),

                // Password (read-only)
                EditProfileTextField(
                  label: 'Password',
                  controller: c.passwordCtrl,
                  readOnly: true,
                  obscureText: true,
                ),
                AppSpacing.vertical(context, 0.015),

                // Mobile number (autosave on blur)
                EditProfileTextField(
                  label: 'Mobile number',
                  controller: c.phoneCtrl,
                  errorText: c.phoneError,
                  onChanged: (_) => c.phoneError.value = '',
                  onFocusLost: (val) => c.saveFields(phone: val),
                  keyboardType: TextInputType.phone,
                ),

                AppSpacing.vertical(context, 0.03),

                // Delete button (2-step flow)
                Obx(() => AppLargeButton(
                      label: c.isSaving.value
                          ? 'Please wait...'
                          : 'Delete Account',
                      onTap: c.isSaving.value
                          ? () {}
                          : () {
                              // Step 1: Delete profile (Firestore + Storage)
                              DeleteProfileAlertDialog.show(
                                onConfirm: () async {
                                  await c.deleteProfileData();

                                  // Step 2: Ask for password to delete Auth user
                                  DeleteAccountDialog.show(
                                    onConfirm: (password) async {
                                      await c.deleteAuthAccount(password);
                                    },
                                  );
                                },
                              );
                            },
                      isEnabled: !c.isSaving.value,
                    )),

                AppSpacing.vertical(context, 0.02),
              ],
            ),
          );
        }),
      );
    });
  }
}
