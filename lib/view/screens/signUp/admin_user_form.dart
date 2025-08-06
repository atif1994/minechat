import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:minechat/controller/signUp_controller/signUp_controller.dart';
import 'package:minechat/core/constants/app_assets/app_assets.dart';
import 'package:minechat/core/constants/app_texts/app_texts.dart';
import 'package:minechat/core/utils/helpers/app_responsive/app_responsive.dart';
import 'package:minechat/core/utils/helpers/app_spacing/app_spacing.dart';
import 'package:minechat/core/widgets/app_button/app_large_button.dart';
import 'package:minechat/core/widgets/signUp/signUp_profile_avatar_picker.dart';
import 'package:minechat/core/widgets/signUp/signUp_textfield.dart';
import 'package:minechat/view/screens/otp/otp_screen.dart';
import '../../../core/widgets/signup/signup_header.dart';

class SignupAdminAccount extends StatelessWidget {
  const SignupAdminAccount({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(SignupController());

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
            color: Colors.black,
            size: AppResponsive.iconSize(context, factor: 1.5),
          ),
          onPressed: () => Get.back(),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: AppSpacing.symmetric(context, v: 0, h: 0.04),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // AppSpacing.vertical(context, 0.03),
              SignupHeader(
                title: AppTexts.signupAdminHeaderTitle,
                subtitle: AppTexts.signupAdminHeaderSubTitle,
                avatar: const SignupProfileAvatarPicker(),
              ),
              AppSpacing.vertical(context, 0.02),
              SignupTextField(
                label: AppTexts.signupAdminNameLabel,
                hintText: AppTexts.signupAdminNameHintText,
                prefixIcon: AppAssets.signupIconAdmin,
                controller: controller.adminNameCtrl,
                errorText: controller.adminNameError,
                onChanged: (val) => controller.validateAdminName(val),
              ),
              AppSpacing.vertical(context, 0.01),
              SignupTextField(
                label: AppTexts.signupAdminPositionLabel,
                hintText: AppTexts.signupAdminPositionHintText,
                prefixIcon: AppAssets.signupIconPosition,
                controller: controller.positionCtrl,
                errorText: controller.positionError,
                onChanged: (val) => controller.validatePosition(val),
              ),
              AppSpacing.vertical(context, 0.01),
              SignupTextField(
                label: AppTexts.signupEmailLabel,
                hintText: AppTexts.dummyEmailText,
                prefixIcon: AppAssets.signupIconEmail,
                controller: controller.emailCtrl,
                errorText: controller.emailError,
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
                  obscureText: !controller.isConfirmPasswordVisible.value,
                  onChanged: (val) => controller.validateConfirmPassword(val),
                  onSuffixTap: () =>
                      controller.toggleConfirmPasswordVisibility(),
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
              AppSpacing.vertical(context, 0.02),
              AppLargeButton(
                label: AppTexts.signupButton,
                onTap: () {
                  Get.to(OtpScreen());
                  // if (controller.validateAdminForm()) {
                  //   Get.snackbar(
                  //       "Success", "Admin user profile created successfully!");
                  // }
                },
              )
            ],
          ),
        ),
      ),
    );
  }
}
