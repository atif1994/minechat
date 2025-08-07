import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:minechat/controller/signUp_controller/signUp_controller.dart';
import 'package:minechat/core/constants/app_texts/app_texts.dart';
import 'package:minechat/core/utils/helpers/app_spacing/app_spacing.dart';
import 'package:minechat/core/widgets/signUp/signUp_button.dart';
import 'package:minechat/core/widgets/signUp/signUp_header.dart';
import 'package:minechat/core/widgets/signUp/signUp_profile_avatar_picker.dart';
import 'package:minechat/core/widgets/signUp/signUp_textfield.dart';
import 'package:minechat/core/services/firebase_auth_service.dart';

import '../../../core/constants/app_colors/app_colors.dart';
import '../../../core/utils/helpers/app_responsive/app_responsive.dart';

class BusinessAccountForm extends StatelessWidget {
  final String email;

  const BusinessAccountForm({super.key, required this.email});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(SignupController());
    final authService = FirebaseAuthService();
    final isUserAuthenticated = authService.currentUser != null;
    
    // Clear form data and set email when form is opened
    WidgetsBinding.instance.addPostFrameCallback((_) {
      controller.clearFormData();
      if (email.isNotEmpty) {
        controller.emailCtrl.text = email;
        controller.isGoogleUser.value = true;
      } else if (isUserAuthenticated && authService.currentUser?.email != null) {
        controller.emailCtrl.text = authService.currentUser!.email!;
        controller.isGoogleUser.value = true;
      }
    });

    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Business Account'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Get.back(),
        ),
      ),
      body: SingleChildScrollView(
        padding: AppSpacing.all(context, factor: 2),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AppSpacing.vertical(context, 0.02),
            SignupHeader(
              title: AppTexts.signupBusinessHeaderTitle,
              subtitle: AppTexts.signupBusinessHeaderSubTitle,
              avatar: const SignupProfileAvatarPicker(),
            ),
            AppSpacing.vertical(context, 0.02),
            SignupTextField(
              label: AppTexts.signupBusinessCompanyNameLabel,
              hintText: AppTexts.signupBusinessCompanyNameHintText,
              prefixIcon: Iconsax.building,
              controller: controller.companyNameCtrl,
              errorText: controller.companyNameError,
              onChanged: (val) => controller.validateCompanyName(val),
            ),
            AppSpacing.vertical(context, 0.01),
            SignupTextField(
              label: AppTexts.signupBusinessPhoneNumberLabel,
              hintText: AppTexts.signupBusinessPhoneNumberHintText,
              prefixIcon: Iconsax.mobile,
              controller: controller.phoneCtrl,
              errorText: controller.phoneError,
              onChanged: (val) => controller.validatePhone(val),
            ),
            AppSpacing.vertical(context, 0.01),
            SignupTextField(
              label: AppTexts.signupEmailLabel,
              hintText: AppTexts.signupEmailHintText,
              prefixIcon: Iconsax.sms,
              controller: controller.emailCtrl,
              errorText: controller.emailError,
              onChanged: (val) => controller.validateEmail(val),
            ),
            AppSpacing.vertical(context, 0.01),
            Obx(
              () => SignupTextField(
                label: AppTexts.signupPasswordLabel,
                hintText: AppTexts.signupPasswordHintText,
                prefixIcon: Iconsax.lock,
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
                prefixIcon: Iconsax.lock,
                controller: controller.confirmPasswordCtrl,
                errorText: controller.confirmPasswordError,
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
              () => SignupButton(
                label: controller.isLoading.value 
                    ? 'Creating Account...' 
                    : AppTexts.signupButton,
                onTap: controller.isLoading.value 
                    ? null 
                    : () => controller.createBusinessAccount(),
                isLoading: controller.isLoading.value,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
