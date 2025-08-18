import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:minechat/core/constants/app_assets/app_assets.dart';
import 'package:minechat/core/constants/app_texts/app_texts.dart';
import 'package:minechat/core/utils/helpers/app_responsive/app_responsive.dart';
import 'package:minechat/core/utils/helpers/app_spacing/app_spacing.dart';
import 'package:minechat/core/widgets/app_button/app_large_button.dart';
import 'package:minechat/core/widgets/forgot_password/forgot_password_header.dart';
import 'package:minechat/core/widgets/signUp/signUp_textfield.dart';

// Controller
import 'package:minechat/controller/forgot_password/new_password_controller.dart';

class NewPasswordScreen extends StatelessWidget {
  const NewPasswordScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(NewPasswordController());

    return Scaffold(
      resizeToAvoidBottomInset: true,
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
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              padding: AppSpacing.all(context, factor: 2),
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight),
                child: IntrinsicHeight(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ForgotPasswordHeader(
                        title: AppTexts.forgotPasswordHeaderTitle,
                        subtitle: AppTexts.forgotPasswordHeaderSubTitle,
                      ),
                      AppSpacing.vertical(context, 0.03),
                      // New Password
                      Obx(() => SignupTextField(
                            label: 'New Password',
                            hintText: 'Enter new password',
                            prefixIcon: AppAssets.signupIconPassword,
                            controller: controller.passwordCtrl,
                            errorText: controller.passwordError,
                            obscureText: !controller.isPasswordVisible.value,
                            // 👈 bind
                            onChanged: controller.validatePassword,
                            suffixIcon: Icon(
                              controller.isPasswordVisible.value
                                  ? Iconsax.eye
                                  : Iconsax.eye_slash,
                            ),
                            onSuffixTap: controller.togglePasswordVisibility,
                            // 👈 tap handler
                            keyboardType: TextInputType.visiblePassword,
                          )),

                      AppSpacing.vertical(context, 0.02),

// Confirm Password
                      Obx(() => SignupTextField(
                            label: 'Confirm Password',
                            hintText: 'Re-enter new password',
                            prefixIcon: AppAssets.signupIconPassword,
                            controller: controller.confirmCtrl,
                            errorText: controller.confirmError,
                            obscureText: !controller.isConfirmVisible.value,
                            // 👈 bind
                            onChanged: controller.validateConfirm,
                            suffixIcon: Icon(
                              controller.isConfirmVisible.value
                                  ? Iconsax.eye
                                  : Iconsax.eye_slash,
                            ),
                            onSuffixTap: controller.toggleConfirmVisibility,
                            // 👈 tap handler
                            keyboardType: TextInputType.visiblePassword,
                          )),

                      const Spacer(),

                      Padding(
                        padding: AppSpacing.symmetric(context, v: 0.05, h: 0.0),
                        child: AppLargeButton(
                          label: AppTexts.newPasswordButton,
                          onTap: controller.submit,
                          // If your AppLargeButton supports loader flag:
                          isLoading: controller.isSaving.value,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
