import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:minechat/controller/login_controller/login_controller.dart';
import 'package:minechat/controller/theme_controller/theme_controller.dart';
import 'package:minechat/core/constants/app_assets/app_assets.dart';
import 'package:minechat/core/constants/app_texts/app_texts.dart';
import 'package:minechat/core/widgets/onboarding/onboarding_lower_section.dart';
import 'package:minechat/core/widgets/onboarding/onboarding_upper_section.dart';

class OnboardingGoogleScreen extends StatelessWidget {
  const OnboardingGoogleScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final loginController = Get.put(LoginController());
    final themeController = Get.find<ThemeController>();

    return Obx(() {
      final isDark = themeController.isDarkMode;

      SystemChrome.setSystemUIOverlayStyle(
        isDark
            ? const SystemUiOverlayStyle(
                statusBarColor: Colors.transparent,
                statusBarIconBrightness: Brightness.light,
                statusBarBrightness: Brightness.dark,
              )
            : const SystemUiOverlayStyle(
                statusBarColor: Colors.white,
                statusBarIconBrightness: Brightness.dark,
                statusBarBrightness: Brightness.light,
              ),
      );

      return Scaffold(
        resizeToAvoidBottomInset: false,
        body: SafeArea(
          child: Column(
            children: [
              OnboardingUpperSection(isDark: isDark),
              Expanded(
                child: OnboardingLowerSection(
                  title: AppTexts.onboardingTitle,
                  subtitle: AppTexts.onboardingSubTitle,
                  footerText: AppTexts.onboardingGoogleFooter,
                  primaryButtonLabel: "Continue with Google",
                  primarySvgIcon: AppAssets.googleIcon,
                  isPrimaryLoading: loginController.isLoading.value,
                  onPrimaryPressed: loginController.isLoading.value
                      ? null
                      : () => loginController.loginWithGoogle(),
                ),
              )
            ],
          ),
        ),
      );
    });
  }
}
