import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:minechat/controller/theme_controller/theme_controller.dart';
import 'package:minechat/core/constants/app_colors/app_colors.dart';
import 'package:minechat/core/utils/extensions/app_gradient/app_gradient_extension.dart';
import 'package:minechat/core/utils/helpers/app_responsive/app_responsive.dart';
import 'package:minechat/core/utils/helpers/app_spacing/app_spacing.dart';

class AppThemeToggleButton extends StatelessWidget {
  const AppThemeToggleButton({super.key});

  @override
  Widget build(BuildContext context) {
    final themeController = Get.find<ThemeController>();
    const duration = Duration(milliseconds: 400);

    return Obx(() {
      final isDark = themeController.isDarkMode;

      return GestureDetector(
        onTap: themeController.toggleTheme,
        child: AnimatedContainer(
          duration: duration,
          padding: AppSpacing.symmetric(context, v: 0.002, h: 0.01),
          decoration: BoxDecoration(
              color: isDark ? Color(0XFFFFFFFF).withValues(alpha: .08) : null,
              borderRadius: BorderRadius.circular(30),
              border: Border.all(
                  color: isDark ? Color(0XFFFFFFFF).withValues(alpha: .08) : Color(0XFFEBEDF0))),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // ☀️ Light Icon
              AnimatedContainer(
                duration: duration,
                width: 28,
                height: 28,
                decoration: isDark
                    ? BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: null,
                        color: Colors.transparent)
                    : BoxDecoration(
                        shape: BoxShape.circle,
                        color: null,
                      ).withAppGradient,
                child: Center(
                    child: Icon(
                  Iconsax.sun_1,
                  color: AppColors.white,
                  size: AppResponsive.scaleSize(context, 16),
                )),
              ),

              // 🌙 Dark Icon
              AnimatedContainer(
                duration: duration,
                width: 28,
                height: 28,
                decoration: isDark
                    ? BoxDecoration(
                        shape: BoxShape.circle,
                        color: null,
                      ).withAppGradient
                    : BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: null,
                        color: Colors.transparent),
                child: Center(
                    child: Icon(
                  Iconsax.moon,
                  color: isDark ? Colors.white : Color(0XFFA8AEBF),
                  size: AppResponsive.scaleSize(context, 16),
                )),
              ),
            ],
          ),
        ),
      );
    });
  }
}
