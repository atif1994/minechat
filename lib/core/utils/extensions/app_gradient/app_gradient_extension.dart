import 'package:flutter/material.dart';
import 'package:minechat/core/constants/app_colors/app_colors.dart';

extension AppGradientExtension on BoxDecoration {
  BoxDecoration get withAppGradient => copyWith(
        gradient: const LinearGradient(
          colors: [
            AppColors.primary,
            AppColors.secondary,
            AppColors.tertiary,
          ],
          begin: Alignment.bottomCenter,
          end: Alignment.topCenter,
        ),
      );
}

extension GradientText on Text {
  Widget withAppGradient() {
    return ShaderMask(
      shaderCallback: (bounds) => const LinearGradient(
        colors: [
          AppColors.primary,
          AppColors.secondary,
          AppColors.tertiary,
        ],
        begin: Alignment.bottomCenter,
        end: Alignment.topCenter,
      ).createShader(Rect.fromLTWH(0, 0, bounds.width, bounds.height)),
      blendMode: BlendMode.srcIn, // 🔹 Ensures gradient replaces text color
      child: Text(
        data ?? '', // copy text content
        style: style?.copyWith(color: Colors.white), // white acts as a mask
        textAlign: textAlign,
        maxLines: maxLines,
        overflow: overflow,
      ),
    );
  }
}
