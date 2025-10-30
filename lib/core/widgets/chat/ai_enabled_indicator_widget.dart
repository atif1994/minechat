import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:minechat/controller/theme_controller/theme_controller.dart';
import 'package:minechat/core/constants/app_colors/app_colors.dart';
import 'package:minechat/core/utils/helpers/app_responsive/app_responsive.dart';
import 'package:minechat/core/utils/helpers/app_styles/app_text_styles.dart';

/// AI Enabled indicator widget for chat conversations
class AIEnabledIndicatorWidget extends StatelessWidget {
  final bool isEnabled;
  final VoidCallback? onTap;

  const AIEnabledIndicatorWidget({
    Key? key,
    this.isEnabled = false,  // FIXED: Default to false (disabled)
    this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (!isEnabled) return const SizedBox.shrink();
    final themeController = Get.find<ThemeController>();
    final isDark = themeController.isDarkMode;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 8),
      child: Center(
        child: GestureDetector(
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            decoration: BoxDecoration(
              color: isDark ? Color(0XFF1D1D1D) : Color(0XFFFFFFFF),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AppColors.primary, width: 1),
            ),
            child: Text(
              'AI Enabled',
              style: AppTextStyles.hintText(context).copyWith(
                  fontSize: AppResponsive.scaleSize(context, 12),
                  fontWeight: FontWeight.w200,
                  color: isDark ? AppColors.white : AppColors.primary),
            ),
          ),
        ),
      ),
    );
  }
}
