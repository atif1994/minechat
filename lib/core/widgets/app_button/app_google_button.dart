import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:minechat/core/constants/app_assets/app_assets.dart';
import 'package:minechat/core/utils/helpers/app_responsive/app_responsive.dart';
import 'package:minechat/core/utils/helpers/app_styles/app_text_styles.dart';

class AppGoogleButton extends StatelessWidget {
  final String label;
  final VoidCallback? onTap;
  final bool isEnabled;
  final bool isLoading;

  const AppGoogleButton({
    super.key,
    required this.label,
    required this.onTap,
    this.isEnabled = true,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    final double vPad = AppResponsive.scaleSize(context, 14);
    final double radius = AppResponsive.radius(context, factor: 1.2);
    final double loaderSize = AppResponsive.scaleSize(context, 18);
    final double gap = AppResponsive.scaleSize(context, 10);
    final double font = AppResponsive.scaleSize(context, 16);
    final double iconSize = AppResponsive.scaleSize(context, 20);

    final bool buttonEnabled = isEnabled && !isLoading;

    return SizedBox(
      width: double.infinity,
      child: InkWell(
        onTap: buttonEnabled ? onTap : null,
        borderRadius: BorderRadius.circular(radius),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          curve: Curves.easeOut,
          padding: EdgeInsets.symmetric(vertical: vPad),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(radius),
            color: Colors.white,
            border: Border.all(
              color: Colors.grey.shade300,
              width: 1.0,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.1),
                spreadRadius: 0,
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
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
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.grey),
                    ),
                  ),
                  SizedBox(width: gap),
                ] else ...[
                  SvgPicture.asset(
                    AppAssets.googleIcon,
                    width: iconSize,
                    height: iconSize,
                  ),
                  SizedBox(width: gap),
                ],
                Text(
                  label,
                  style: AppTextStyles.buttonText(context).copyWith(
                    fontSize: font,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey.shade700,
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
