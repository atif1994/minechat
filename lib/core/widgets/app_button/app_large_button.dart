import 'package:flutter/material.dart';
import 'package:minechat/core/utils/extensions/app_gradient/app_gradient_extension.dart';
import 'package:minechat/core/utils/helpers/app_responsive/app_responsive.dart';
import 'package:minechat/core/utils/helpers/app_styles/app_text_styles.dart';

class AppLargeButton extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  final bool isEnabled;
  final bool isLoading; // ✅ New

  const AppLargeButton({
    super.key,
    required this.label,
    required this.onTap,
    this.isEnabled = true,
    this.isLoading = false, // ✅ New
  });

  @override
  Widget build(BuildContext context) {
    final bool isButtonActive = isEnabled && !isLoading;

    return SizedBox(
      width: double.infinity,
      child: InkWell(
        onTap: isButtonActive ? onTap : null,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 14),
          decoration: isButtonActive
              ? BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                ).withAppGradient
              : BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  color: Color(0xffffffff),
                ),
          alignment: Alignment.center,
          child: isLoading
              ? Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      label,
                      style: AppTextStyles.buttonText(context).copyWith(
                        fontSize: AppResponsive.scaleSize(context, 16),
                        color: Colors.white,
                      ),
                    ),
                  ],
                )
              : Text(
                  label,
                  style: AppTextStyles.buttonText(context).copyWith(
                    fontSize: AppResponsive.scaleSize(context, 16),
                    color: isEnabled ? Colors.white : const Color(0xffa8aebf),
                    fontWeight: FontWeight.w600,
                  ),
                ),
        ),
      ),
    );
  }
}
