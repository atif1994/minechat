import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:minechat/core/constants/app_colors/app_colors.dart';
import 'package:minechat/core/utils/helpers/app_responsive/app_responsive.dart';
import 'package:minechat/core/utils/helpers/app_spacing/app_spacing.dart';
import 'package:minechat/core/utils/helpers/app_styles/app_text_styles.dart';

class SignupTextField extends StatelessWidget {
  final String label;
  final String hintText;
  final IconData prefixIcon;
  final Widget? suffixIcon;
  final TextEditingController controller;
  final RxString? errorText;
  final Function(String)? onChanged;
  final bool obscureText;
  final VoidCallback? onSuffixTap;

  const SignupTextField({
    super.key,
    required this.label,
    required this.hintText,
    required this.prefixIcon,
    this.suffixIcon,
    required this.controller,
    this.errorText,
    this.onChanged,
    this.obscureText = true,
    this.onSuffixTap,
  });

  @override
  Widget build(BuildContext context) {
    return Obx(() => Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label,
                style: AppTextStyles.bodyText(context)
                    .copyWith(fontSize: AppResponsive.scaleSize(context, 14))),
            AppSpacing.vertical(context, 0.005),
            TextField(
              controller: controller,
              onChanged: onChanged,
              obscureText: obscureText,
              decoration: InputDecoration(
                hintText: hintText,
                hintStyle: AppTextStyles.hintText(context),
                prefixIcon: Icon(prefixIcon, color: AppColors.black),
                suffixIcon: suffixIcon != null
                    ? GestureDetector(
                        onTap: onSuffixTap,
                        child: suffixIcon,
                      )
                    : null,
                filled: true,
                fillColor: AppColors.grey.withValues(alpha: 0.1),
                enabledBorder: OutlineInputBorder(
                  borderRadius:
                      BorderRadius.circular(AppResponsive.radius(context)),
                  borderSide: BorderSide(color: Colors.grey.shade300),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius:
                      BorderRadius.circular(AppResponsive.radius(context)),
                  borderSide:
                      const BorderSide(color: AppColors.primary, width: 1.5),
                ),
              ),
              style: AppTextStyles.bodyText(context).copyWith(
                fontSize: AppResponsive.scaleSize(context, 14),
              ),
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
