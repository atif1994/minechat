import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:minechat/core/utils/helpers/app_responsive/app_responsive.dart';
import 'package:minechat/core/utils/helpers/app_styles/app_text_styles.dart';

class AppSmallButton extends StatelessWidget {
  final String label;
  final VoidCallback onPressed;
  final double? width;
  final double? height;
  final String? svgIconPath;
  final bool isLoading;

  const AppSmallButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.width,
    this.height,
    this.svgIconPath,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    final double buttonWidth =
        width ?? AppResponsive.screenWidth(context) * 0.45;
    final double buttonHeight =
        height ?? AppResponsive.screenHeight(context) * 0.05;

    return GestureDetector(
      onTap: isLoading ? null : onPressed,
      child: Container(
        width: buttonWidth,
        height: buttonHeight,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(buttonHeight / 2), // pill shape
        ),
        alignment: Alignment.center,
        child: isLoading
            ? SizedBox(
                width: buttonHeight * 0.5,
                height: buttonHeight * 0.5,
                child: const CircularProgressIndicator(strokeWidth: 2),
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (svgIconPath != null) ...[
                    SvgPicture.asset(
                      svgIconPath!,
                      width: AppResponsive.iconSize(context, factor: 1.2),
                      height: AppResponsive.iconSize(context, factor: 1.2),
                    ),
                    const SizedBox(width: 8),
                  ],
                  Text(
                    label,
                    style: AppTextStyles.bodyText(context).copyWith(
                        color: Colors.black,
                        fontWeight: FontWeight.w500,
                        fontSize: AppResponsive.scaleSize(context, 16)),
                  ),
                ],
              ),
      ),
    );
  }
}
