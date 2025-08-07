import 'package:flutter/material.dart';
import 'package:minechat/core/constants/app_assets/app_assets.dart';
import 'package:minechat/core/utils/helpers/app_responsive/app_responsive.dart';
import 'package:minechat/core/widgets/onboarding/onboarding_floating_icons.dart';
import 'package:minechat/core/widgets/onboarding/onboarding_grid_pattern.dart';

class OnboardingUpperSection extends StatelessWidget {
  final bool isDark;

  const OnboardingUpperSection({
    super.key,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: AppResponsive.screenHeight(context) * 0.55, // ✅ responsive height
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF0A0A0A) : Colors.white,
      ),
      child: Stack(
        children: [
          CustomPaint(
            painter: OnBoardingGridPattern(
              color: isDark
                  ? Colors.white.withOpacity(0.08)
                  : Colors.black.withOpacity(0.15),
              spacing: AppResponsive.scaleSize(context, isDark ? 50.0 : 40.0),
            ),
            size: Size.infinite,
          ),
          OnboardingFlotatingIcons(context: context),
          Center(
            child: Image.asset(
              AppAssets.minechatLogoDummy,
              width: AppResponsive.screenWidth(context) * 0.4, // ✅ logo scaling
            ),
          ),
        ],
      ),
    );
  }
}
