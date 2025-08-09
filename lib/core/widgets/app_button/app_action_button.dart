import 'package:flutter/material.dart';
import 'package:minechat/core/utils/helpers/app_responsive/app_responsive.dart';
import 'package:minechat/core/utils/helpers/app_styles/app_text_styles.dart';
import 'package:minechat/core/utils/extensions/app_gradient/app_gradient_extension.dart';

class AppActionButton extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  final bool isPrimary;

  const AppActionButton({
    super.key,
    required this.label,
    required this.onTap,
    this.isPrimary = false,
  });

  @override
  Widget build(BuildContext context) {
    final text = Text(
      label,
      style: AppTextStyles.bodyText(context).copyWith(
          color: Colors.black,
          fontWeight: FontWeight.w600,
          fontSize: AppResponsive.scaleSize(context, 16)),
    );

    return GestureDetector(
      onTap: onTap,
      child: isPrimary ? text.withAppGradient() : text,
    );
  }
}
