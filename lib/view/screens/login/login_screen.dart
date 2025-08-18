import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:minechat/controller/login_controller/login_controller.dart';
import 'package:minechat/core/constants/app_assets/app_assets.dart';
import 'package:minechat/core/constants/app_texts/app_texts.dart';
import 'package:minechat/core/utils/helpers/app_spacing/app_spacing.dart';
import 'package:minechat/core/widgets/app_button/app_large_button.dart';
import 'package:minechat/core/widgets/app_button/app_action_button.dart';
import 'package:minechat/core/widgets/login/login_footer.dart';
import 'package:minechat/core/widgets/login/login_header.dart';
import 'package:minechat/core/widgets/signUp/signUp_textfield.dart';
import 'package:minechat/view/screens/forgot_password/forgot_password_screen.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(LoginController());

    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: const BackButton(color: Colors.black),
      ),
      backgroundColor: Colors.white,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final bottomInset = MediaQuery.of(context).viewInsets.bottom;

            return SingleChildScrollView(
              keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
              // ✅
              padding: AppSpacing.all(context, factor: 2).copyWith(top: 0),
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight),
                child: IntrinsicHeight(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const LoginHeader(
                        title: AppTexts.loginHeaderTitle,
                        subtitle: AppTexts.loginHeaderSubTitle,
                      ),
                      AppSpacing.vertical(context, 0.03),

                      // Email
                      SignupTextField(
                        label: AppTexts.signupEmailLabel,
                        hintText: AppTexts.dummyEmailText,
                        prefixIcon: AppAssets.signupIconEmail,
                        controller: controller.emailCtrl,
                        errorText: controller.emailError,
                        keyboardType: TextInputType.emailAddress,
                        onChanged: controller.validateEmail,
                      ),
                      AppSpacing.vertical(context, 0.02),

                      // Password
                      Obx(() => SignupTextField(
                            label: AppTexts.signupPasswordLabel,
                            hintText: AppTexts.signupPasswordHintText,
                            prefixIcon: AppAssets.signupIconPassword,
                            controller: controller.passwordCtrl,
                            errorText: controller.passwordError,
                            obscureText: !controller.isPasswordVisible.value,
                            onChanged: controller.validatePassword,
                            suffixIcon: Icon(
                              controller.isPasswordVisible.value
                                  ? Iconsax.eye
                                  : Iconsax.eye_slash,
                            ),
                            onSuffixTap: controller.togglePasswordVisibility,
                            keyboardType: TextInputType.visiblePassword,
                          )),
                      AppSpacing.vertical(context, 0.012),

                      // Forgot password
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          AppActionButton(
                              label: AppTexts.loginForgotPasswordText,
                              isPrimary: true,
                              onTap: () => Get.to(ForgotPasswordScreen())),
                        ],
                      ),

                      const Spacer(),

                      AnimatedPadding(
                        duration: const Duration(milliseconds: 200),
                        curve: Curves.easeOut,
                        padding: EdgeInsets.only(
                          bottom: bottomInset > 0
                              ? bottomInset * 0.6
                              : 20, // ✅ lift above keyboard
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Obx(() => AppLargeButton(
                                  label: controller.isLoading.value
                                      ? 'Logging in...'
                                      : AppTexts.loginButton,
                                  isLoading: controller.isLoading.value,
                                  onTap: controller.loginWithEmailAndPassword,
                                )),
                            AppSpacing.vertical(context, 0.015),
                            const LoginFooter(
                              firstNormalText:
                                  AppTexts.loginFooterFirstNormalText,
                              firstGestureText:
                                  AppTexts.loginFooterFirstGestureText,
                              secondNormalText:
                                  AppTexts.loginFooterSecondNormalText,
                              secondGestureText:
                                  AppTexts.loginFooterSecondGestureText,
                            ),
                          ],
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
