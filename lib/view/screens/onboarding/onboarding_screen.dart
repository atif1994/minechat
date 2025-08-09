import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:minechat/controller/theme_controller/theme_controller.dart';
import 'package:minechat/core/constants/app_texts/app_texts.dart';
import 'package:minechat/core/widgets/onboarding/onboarding_lower_section.dart';
import 'package:minechat/core/widgets/onboarding/onboarding_upper_section.dart';
import 'package:minechat/view/screens/login/login_screen.dart';
import 'package:minechat/view/screens/onboarding/onboarding_google_screen.dart';

class OnboardingScreen extends StatelessWidget {
  const OnboardingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final themeController = Get.find<ThemeController>();
      final isDark = themeController.isDarkMode;

      // ✅ Set status bar style based on theme
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
              // ✅ Upper section with responsive height
              OnboardingUpperSection(isDark: isDark),

              // ✅ Lower section expanded
              Expanded(
                  child: OnboardingLowerSection(
                title: AppTexts.onboardingTitle,
                subtitle: AppTexts.onboardingSubTitle,
                footerText: AppTexts.onboardingFooter,
                primaryButtonLabel: "Login",
                onPrimaryPressed: () => Get.to(() => LoginScreen()),
                secondaryButtonLabel: "Signup",
                onSecondaryPressed: () =>
                    Get.to(() => const OnboardingGoogleScreen()),
              )),
            ],
          ),
        ),
      );
    });
  }
}
