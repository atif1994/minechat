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
