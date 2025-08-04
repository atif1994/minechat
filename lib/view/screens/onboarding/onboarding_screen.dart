import 'package:flutter/material.dart';
import 'package:minechat/core/utils/helpers/app_spacing/app_spacing.dart';
import 'package:minechat/core/utils/helpers/app_styles/app_text_styles.dart';

class OnboardingScreen extends StatelessWidget {
  const OnboardingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: AppSpacing.symmetric(context, h: 20, v: 20),
          child: Text("Welcome!", style: AppTextStyles.headline(context)),
        ),
      ),
    );
  }
}
