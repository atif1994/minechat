import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:minechat/controller/edit_profile_controller/admin_edit_profile_controller.dart';
import 'package:minechat/controller/theme_controller/theme_controller.dart';
import 'package:minechat/core/utils/helpers/app_responsive/app_responsive.dart';
import 'package:minechat/core/utils/helpers/app_spacing/app_spacing.dart';
import 'package:minechat/core/utils/helpers/app_styles/app_text_styles.dart';
import 'package:minechat/core/widgets/app_button/app_large_button.dart';
import 'package:minechat/core/widgets/edit_profile/logout_alert_dialog.dart';
import 'package:minechat/core/widgets/edit_profile/edit_profile_avatar_picker.dart';
import 'package:minechat/core/widgets/edit_profile/edit_profile_textfield.dart';
import 'package:minechat/core/constants/app_assets/app_assets.dart';

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
                    LogoutAlertDialog.show(
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
