import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:minechat/core/constants/app_colors/app_colors.dart';
import 'package:minechat/core/utils/helpers/app_responsive/app_responsive.dart';
import 'package:minechat/core/utils/helpers/app_spacing/app_spacing.dart';
import 'package:minechat/core/utils/helpers/app_styles/app_text_styles.dart';

import '../../../controller/theme_controller/theme_controller.dart';

class SignupTextField extends StatelessWidget {
  final String? label;
  final String? labelText; // For backward compatibility
  final String? hintText;
  final String? prefixIcon;
  final Widget? suffixIcon;
  final TextEditingController controller;
  final RxString? errorText;
  final Function(String)? onChanged;
  final bool obscureText;
  final VoidCallback? onSuffixTap;
  final TextInputType keyboardType;

  const SignupTextField({
    super.key,
    this.label,
    this.labelText, // For backward compatibility
    this.hintText,
    this.prefixIcon,
    this.suffixIcon,
    required this.controller,
    this.errorText,
    this.onChanged,
    this.obscureText = false,
    this.onSuffixTap,
    this.keyboardType = TextInputType.text,
  });

  @override
  Widget build(BuildContext context) {
    final themeController = Get.find<ThemeController>();
    final isDark = themeController.isDarkMode;
    final displayLabel = label ?? labelText ?? '';
    
    return Obx(() => Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (displayLabel.isNotEmpty)
              Text(displayLabel,
                  style: AppTextStyles.bodyText(context).copyWith(
                      fontSize: AppResponsive.scaleSize(context, 14),
                      fontWeight: FontWeight.w500)),
            if (displayLabel.isNotEmpty)
              AppSpacing.vertical(context, 0.005),
            TextField(
              controller: controller,
              onChanged: onChanged,
              obscureText: obscureText,
              keyboardType: keyboardType,
              decoration: InputDecoration(
                hintText: hintText,
                hintStyle: AppTextStyles.hintText(context),
                prefixIcon: prefixIcon != null ? Padding(
                  padding: EdgeInsets.all(AppResponsive.scaleSize(context, 10)),
                  child: SvgPicture.asset(
                    prefixIcon!,
                    width: AppResponsive.iconSize(context),
                    height: AppResponsive.iconSize(context),
                    color: isDark ? Colors.white : Colors.black,
                  ),
                ) : null,
                suffixIcon: suffixIcon != null
                    ? GestureDetector(
                        onTap: onSuffixTap,
                        child: suffixIcon,
                      )
                    : null,
                filled: true,
                fillColor:isDark? AppColors.black:Color(0xfffafbfd),
                enabledBorder: OutlineInputBorder(
                  borderRadius:
                      BorderRadius.circular(AppResponsive.radius(context)),
                  borderSide: BorderSide(color: Colors.grey.shade300),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius:
                      BorderRadius.circular(AppResponsive.radius(context)),
                  borderSide:
                      const BorderSide(color: AppColors.primary, width: 2),
                ),
              ),
              style: AppTextStyles.bodyText(context).copyWith(
                  fontSize: AppResponsive.scaleSize(context, 14),
                  fontWeight: FontWeight.w500),
            ),
            if (errorText != null && errorText!.value.isNotEmpty)
              Padding(
                padding: AppSpacing.symmetric(context, h: 0, v: 0.005),
                child: Text(
                  errorText!.value,
                  style: AppTextStyles.bodyText(context).copyWith(
                      fontSize: AppResponsive.scaleSize(context, 12),
                      color: AppColors.error),
                ),
              ),
          ],
        ));
  }
}
