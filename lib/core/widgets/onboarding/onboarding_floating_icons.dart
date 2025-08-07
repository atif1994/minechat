import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:minechat/controller/theme_controller/theme_controller.dart';
import 'package:minechat/core/constants/app_assets/app_assets.dart';
import 'package:minechat/core/utils/helpers/app_responsive/app_responsive.dart';
import 'package:minechat/core/widgets/onboarding/onboarding_icon.dart';

class OnboardingFlotatingIcons extends StatelessWidget {
  const OnboardingFlotatingIcons({
    super.key,
    required this.context,
  });

  final BuildContext context;

  @override
  Widget build(BuildContext context) {
    final iconSize = (double size) => AppResponsive.scaleSize(context, size);

    return Stack(
      children: [
        Positioned(
          top: iconSize(40),
          left: iconSize(20),
          child: Obx(() {
            final controller = Get.find<ThemeController>();
            final iconPath = controller.isDarkMode
                ? AppAssets.darkMode
                : AppAssets.lightDart;

            return GestureDetector(
              onTap: controller.toggleTheme,
              child: SvgPicture.asset(
                iconPath,
                width: AppResponsive.iconSize(context, factor: 1.8),
                height: AppResponsive.iconSize(context, factor: 1.8),
                placeholderBuilder: (_) => const CircularProgressIndicator(),
              ),
            );
          }),
        ),
        // Floating social icons (positioned responsively)
        Positioned(
            top: iconSize(30),
            right: iconSize(20),
            child: OnboaringIcon(name: 'camera', size: 28)),
        Positioned(
            top: iconSize(100),
            left: iconSize(80),
            child: OnboaringIcon(name: 'messenger', size: 20)),
        Positioned(
            top: iconSize(110),
            right: iconSize(80),
            child: OnboaringIcon(name: 'slack', size: 20)),
        Positioned(
            top: iconSize(160),
            right: iconSize(120),
            child: OnboaringIcon(name: 'telegram', size: 20)),
        Positioned(
            top: iconSize(220),
            left: iconSize(25),
            child: OnboaringIcon(name: 'instagram', size: 30)),
        Positioned(
            top: iconSize(270),
            right: iconSize(25),
            child: OnboaringIcon(name: 'discord', size: 20)),
        Positioned(
            bottom: iconSize(100),
            left: 0,
            right: 0,
            child: OnboaringIcon(name: 'whatsapp', size: 28)),
        Positioned(
            bottom: iconSize(50),
            left: iconSize(70),
            child: OnboaringIcon(name: 'slack', size: 24)),
        Positioned(
            bottom: iconSize(50),
            right: iconSize(70),
            child: OnboaringIcon(name: 'viber', size: 24)),
      ],
    );
  }
}
