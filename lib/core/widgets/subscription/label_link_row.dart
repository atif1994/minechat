import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:minechat/controller/theme_controller/theme_controller.dart';
import 'package:minechat/core/constants/app_colors/app_colors.dart';
import 'package:minechat/core/utils/helpers/app_responsive/app_responsive.dart';
import 'package:minechat/core/utils/helpers/app_spacing/app_spacing.dart';
import 'package:minechat/core/utils/helpers/app_styles/app_text_styles.dart';

class LabelLinkRow extends StatelessWidget {
  final String label;
  final String linkText;
  final Color? linkColor;
  final VoidCallback? onTap;

  const LabelLinkRow({
    super.key,
    this.label = "",
    required this.linkText,
    this.linkColor,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final themeController = Get.find<ThemeController>();
    final isDark = themeController.isDarkMode;
    final Color linkTextColor = isDark
        ? linkColor ?? Color(0XFFFFFFFF)
        : linkColor ?? Color(0XFF0A0A0A);
    return Padding(
      padding: AppSpacing.symmetric(context, h: 0, v: 0.005),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          if (label.trim().isNotEmpty)
            InkWell(
              onTap: onTap,
              child: Text(
                label,
                style: AppTextStyles.bodyText(context).copyWith(
                    fontSize: AppResponsive.scaleSize(context, 14),
                    fontWeight: FontWeight.w400,
                    color: Color(0XFF767C8C)),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          if (label.trim().isNotEmpty) const SizedBox(width: 6),
          InkWell(
            onTap: onTap,
            child: Text(
              linkText,
              style: AppTextStyles.bodyText(context).copyWith(
                  fontSize: AppResponsive.scaleSize(context, 14),
                  fontWeight: FontWeight.w400,
                  decoration: TextDecoration.underline,
                  decorationColor: linkTextColor,
                  color: linkTextColor),
            ),
          ),
        ],
      ),
    );
  }
}
