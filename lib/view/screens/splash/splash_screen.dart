import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:minechat/core/widgets/animated_logo/animated_logo.dart';
import 'package:minechat/core/widgets/app_background/app_background.dart';
import 'package:minechat/view/screens/onboarding/onboarding_screen.dart';

import '../login/login_screen.dart';
import '../root_bottom_navigation/root_bottom_nav_scree.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AppBackground(
        child: AppAnimatedLogo(
          onAnimationEnd: () {
            Get.off(() =>  OnboardingScreen());
          },
        ),
      ),
    );
  }
}
