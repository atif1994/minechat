import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:minechat/controller/signUp_controller/signUp_controller.dart';
import 'package:minechat/core/constants/app_assets/app_assets.dart';
import 'package:minechat/core/constants/app_colors/app_colors.dart';
import 'package:minechat/core/constants/app_texts/app_texts.dart';
import 'package:minechat/core/utils/helpers/app_spacing/app_spacing.dart';
import 'package:minechat/core/widgets/app_button/app_large_button.dart';
import 'package:minechat/core/widgets/signUp/signUp_header.dart';
import 'package:minechat/core/widgets/signUp/signUp_profile_avatar_picker.dart';
import 'package:minechat/core/widgets/signUp/signUp_textfield.dart';
import 'package:minechat/view/screens/signUp/admin_user_form.dart';

class SignupBusinessAccount extends StatelessWidget {
  const SignupBusinessAccount({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(SignupController());

    return Scaffold(
      backgroundColor: AppColors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: AppSpacing.all(context, factor: 2),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AppSpacing.vertical(context, 0.03),
              SignupHeader(
                title: AppTexts.signupBusinessHeaderTitle,
                subtitle: AppTexts.signupBusinessHeaderSubTitle,
                avatar: const SignupProfileAvatarPicker(),
              ),
              AppSpacing.vertical(context, 0.02),
              SignupTextField(
                label: AppTexts.signupBusinessCompanyNameLabel,
                hintText: AppTexts.signupBusinessCompanyNameHintText,
                prefixIcon: AppAssets.signupIconCompany,
                controller: controller.companyNameCtrl,
                errorText: controller.companyNameError,
                onChanged: (val) => controller.validateCompanyName(val),
              ),
              AppSpacing.vertical(context, 0.01),
              SignupTextField(
                label: AppTexts.signupBusinessPhoneNumberLabel,
                hintText: AppTexts.signupBusinessPhoneNumberHintText,
                prefixIcon: AppAssets.signupIconPhone,
                keyboardType: TextInputType.phone,
                controller: controller.phoneCtrl,
                errorText: controller.phoneError,
                onChanged: (val) => controller.validatePhone(val),
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
                  Get.to(SignupAdminAccount());
                  // if (controller.validateBusinessForm()) {
                  //   Get.snackbar(
                  //       "Success", "Business account created successfully!");
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
