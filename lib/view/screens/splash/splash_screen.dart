import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:minechat/core/widgets/animated_logo/animated_logo.dart';
import 'package:minechat/core/widgets/app_background/app_background.dart';
import 'package:minechat/controller/auth_controller/auth_controller.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Initialize auth controller
    final authController = Get.find<AuthController>();

    return Scaffold(
      body: AppBackground(
        child: AppAnimatedLogo(
          onAnimationEnd: () {
            // Check authentication state and navigate accordingly
            authController.checkAuthState();
          },
        ),
      ),
    );
  }
}
