import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:minechat/controller/signUp_controller/admin_signup_controller.dart';
import 'package:minechat/core/constants/app_assets/app_assets.dart';
import 'package:minechat/core/constants/app_colors/app_colors.dart';
import 'package:minechat/core/constants/app_texts/app_texts.dart';
import 'package:minechat/core/utils/helpers/app_spacing/app_spacing.dart';
import 'package:minechat/core/widgets/app_button/app_large_button.dart';
import 'package:minechat/core/widgets/signUp/signUp_profile_avatar_picker.dart';
import 'package:minechat/core/widgets/signUp/signUp_textfield.dart';
import 'package:minechat/core/widgets/signUp/signUp_header.dart';
import 'package:minechat/core/services/firebase_auth_service.dart';

class SignupAdminAccount extends StatelessWidget {
  const SignupAdminAccount({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(AdminSignupController());
    final authService = FirebaseAuthService();
    final isUserAuthenticated = authService.currentUser != null;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
            color: AppColors.black,
          ),
          onPressed: () => Get.back(),
        ),
      ),
      body: SingleChildScrollView(
        padding: AppSpacing.all(context, factor: 2),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SignupHeader(
              title: AppTexts.signupAdminHeaderTitle,
              subtitle: AppTexts.signupAdminHeaderSubTitle,
              avatar: Obx(() => SignupProfileAvatarPicker(
                    onImageSelected: (file) => controller.setProfileImage(file),
                    showError: controller.isImageMissing.value,
                  )),
            ),
            AppSpacing.vertical(context, 0.02),
            SignupTextField(
              label: AppTexts.signupAdminNameLabel,
              hintText: AppTexts.signupAdminNameHintText,
              prefixIcon: AppAssets.signupIconAdmin,
              controller: controller.adminNameCtrl,
              errorText: controller.adminNameError,
              // <-- pass RxString here
              onChanged: (val) => controller.validateAdminName(val),
            ),
            AppSpacing.vertical(context, 0.01),
            SignupTextField(
              label: AppTexts.signupAdminPositionLabel,
              hintText: AppTexts.signupAdminPositionHintText,
              prefixIcon: AppAssets.signupIconPosition,
              controller: controller.positionCtrl,
              errorText: controller.positionError,
              // <-- pass RxString here
              onChanged: (val) => controller.validatePosition(val),
            ),
            AppSpacing.vertical(context, 0.01),
            SignupTextField(
              label: AppTexts.signupEmailLabel,
              hintText: AppTexts.dummyEmailText,
              prefixIcon: AppAssets.signupIconEmail,
              controller: controller.emailCtrl,
              errorText: controller.emailError,
              // <-- pass RxString here
              onChanged: (val) => controller.validateEmail(val),
            ),
            AppSpacing.vertical(context, 0.01),
            Obx(
              () => SignupTextField(
                label: AppTexts.signupPasswordLabel,
                hintText: AppTexts.signupPasswordHintText,
                prefixIcon: AppAssets.signupIconPassword,
                controller: controller.passwordCtrl,
                errorText: controller.passwordError,
                // <-- RxString
                obscureText: !controller.isPasswordVisible.value,
                onChanged: (val) => controller.validatePassword(val),
                onSuffixTap: () => controller.togglePasswordVisibility(),
                suffixIcon: IconButton(
                  icon: Icon(
                    controller.isPasswordVisible.value
                        ? Iconsax.eye_slash
                        : Iconsax.eye,
                    color: Colors.black,
                  ),
                  onPressed: controller.togglePasswordVisibility,
                ),
              ),
            ),
            AppSpacing.vertical(context, 0.01),
            Obx(
              () => SignupTextField(
                label: AppTexts.signupConfirmPasswordLabel,
                hintText: AppTexts.signupConfirmPasswordHintText,
                prefixIcon: AppAssets.signupIconPassword,
                controller: controller.confirmPasswordCtrl,
                errorText: controller.confirmPasswordError,
                // <-- RxString
                obscureText: !controller.isConfirmPasswordVisible.value,
                onChanged: (val) => controller.validateConfirmPassword(val),
                onSuffixTap: () => controller.toggleConfirmPasswordVisibility(),
                suffixIcon: IconButton(
                  icon: Icon(
                    controller.isConfirmPasswordVisible.value
                        ? Iconsax.eye_slash
                        : Iconsax.eye,
                    color: Colors.black,
                  ),
                  onPressed: controller.toggleConfirmPasswordVisibility,
                ),
              ),
            ),
            AppSpacing.vertical(context, 0.02),
            Obx(
              () => AppLargeButton(
                label: controller.isLoading.value
                    ? 'Creating Account...'
                    : AppTexts.signupButton,
                onTap: () => controller.createAdminAccount(),
                isEnabled: !controller.isLoading.value,
                isLoading: controller.isLoading.value,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
