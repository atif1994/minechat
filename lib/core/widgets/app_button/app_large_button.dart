import 'package:flutter/material.dart';
import 'package:minechat/core/constants/app_colors/app_colors.dart';
import 'package:minechat/core/utils/extensions/app_gradient/app_gradient_extension.dart';
import 'package:minechat/core/utils/helpers/app_responsive/app_responsive.dart';
import 'package:minechat/core/utils/helpers/app_styles/app_text_styles.dart';

class AppLargeButton extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  final bool isEnabled;
  final bool isLoading;
  final bool useGradient;
  final Color? solidColor;
  final Color? borderColor;
  final Color? textColor;

  const AppLargeButton({
    super.key,
    required this.label,
    required this.onTap,
    this.isEnabled = true,
    this.isLoading = false,
    this.useGradient = true,
    this.solidColor,
    this.borderColor,
    this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    final double vPad = AppResponsive.scaleSize(context, 14);
    final double radius = AppResponsive.radius(context, factor: 1.2);
    final double loaderSize = AppResponsive.scaleSize(context, 18);
    final double gap = AppResponsive.scaleSize(context, 10);
    final double font = AppResponsive.scaleSize(context, 16);

    final bool buttonEnabled = isEnabled && !isLoading;

    final BoxDecoration baseDecoration = BoxDecoration(
      borderRadius: BorderRadius.circular(radius),
      color: useGradient ? null : (solidColor ?? Colors.white),
      border: borderColor != null ? Border.all(color: borderColor!) : null,
    );

    final decoration =
        useGradient ? baseDecoration.withAppGradient : baseDecoration;

    return SizedBox(
      width: double.infinity,
      child: InkWell(
        onTap: buttonEnabled ? onTap : null,
        borderRadius: BorderRadius.circular(radius),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          curve: Curves.easeOut,
          padding: EdgeInsets.symmetric(vertical: vPad),
          decoration: decoration,
          child: Center(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (isLoading) ...[
                  SizedBox(
                    width: loaderSize,
                    height: loaderSize,
                    child: const CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  ),
                  SizedBox(width: gap),
                ],
                Text(
                  label,
                  style: AppTextStyles.buttonText(context).copyWith(
                      fontSize: font,
                      fontWeight: FontWeight.w600,
                      color: AppColors.white),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
