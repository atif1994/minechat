import 'package:flutter/material.dart';
import 'package:minechat/core/utils/extensions/app_gradient/app_gradient_extension.dart';
import 'package:minechat/core/utils/helpers/app_responsive/app_responsive.dart';
import 'package:minechat/core/utils/helpers/app_styles/app_text_styles.dart';

class AppLargeButton extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  final bool isEnabled;

  const AppLargeButton({
    super.key,
    required this.label,
    required this.onTap,
    this.isEnabled = true,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: InkWell(
        onTap: isEnabled ? onTap : null,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 14),
          decoration: isEnabled
              ? BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                ).withAppGradient
              : BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  color: Color(0xffffffff),
                ),
          alignment: Alignment.center,
          child: Text(
            label,
            style: AppTextStyles.buttonText(context).copyWith(
              fontSize: AppResponsive.scaleSize(context, 16),
              color: isEnabled ? Color(0xffffffff) : Color(0xffa8aebf),
              fontWeight: FontWeight.w600
            ),
          ),
        ),
      ),
    );
  }
}
