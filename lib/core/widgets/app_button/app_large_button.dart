import 'package:flutter/material.dart';
import 'package:minechat/core/utils/extensions/app_gradient/app_gradient_extension.dart';
import 'package:minechat/core/utils/helpers/app_responsive/app_responsive.dart';
import 'package:minechat/core/utils/helpers/app_styles/app_text_styles.dart';

class AppLargeButton extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  final bool isEnabled;
  final bool isLoading;

  const AppLargeButton({
    super.key,
    required this.label,
    required this.onTap,
    this.isEnabled = true,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    // ✅ Responsive metrics
    final double vPad = AppResponsive.scaleSize(context, 14);
    final double radius = AppResponsive.radius(context, factor: 1.2);
    final double loaderSize = AppResponsive.scaleSize(context, 18);
    final double gap = AppResponsive.scaleSize(context, 10);
    final double font = AppResponsive.scaleSize(context, 16);

    // ✅ Keep enable/disable logic
    final bool buttonEnabled = isEnabled && !isLoading;

    // Keep gradient visible while loading so spinner/text are readable
    final bool showGradient = buttonEnabled || isLoading;

    return SizedBox(
      width: double.infinity,
      child: InkWell(
        onTap: buttonEnabled ? onTap : null,
        borderRadius: BorderRadius.circular(radius),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          curve: Curves.easeOut,
          padding: EdgeInsets.symmetric(vertical: vPad),
          decoration: showGradient
              ? BoxDecoration(
                  borderRadius: BorderRadius.circular(radius),
                ).withAppGradient
              : BoxDecoration(
                  borderRadius: BorderRadius.circular(radius),
                ),
          child: Center(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // ✅ Spinner on the LEFT when loading
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
                    color: (buttonEnabled || isLoading)
                        ? Colors.white
                        : const Color(0xffa8aebf),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
