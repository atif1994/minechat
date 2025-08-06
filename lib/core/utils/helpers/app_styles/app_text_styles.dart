import 'package:flutter/material.dart';
import 'package:minechat/core/constants/app_fonts/app_fonts.dart';

class AppTextStyles {
  static TextStyle headline(BuildContext context) => Theme.of(context)
      .textTheme
      .headlineSmall!
      .copyWith(fontFamily: AppFonts.primaryFont, fontWeight: FontWeight.w700);

  static TextStyle heading(BuildContext context) => Theme.of(context)
      .textTheme
      .titleLarge!
      .copyWith(fontFamily: AppFonts.primaryFont);

  static TextStyle bodyText(BuildContext context) => Theme.of(context)
      .textTheme
      .bodyLarge!
      .copyWith(fontFamily: AppFonts.primaryFont);

  static TextStyle hintText(BuildContext context) =>
      Theme.of(context).textTheme.bodyMedium!.copyWith(
            fontFamily: AppFonts.primaryFont,
            color: Theme.of(context).hintColor,
          );

  static TextStyle buttonText(BuildContext context) =>
      Theme.of(context).textTheme.labelMedium!.copyWith(
            fontFamily: AppFonts.primaryFont,
            color: Colors.white,
          );

  static TextStyle semiBoldHeading(BuildContext context) => TextStyle(
        fontFamily: AppFonts.primaryFont,
        fontWeight: FontWeight.w600, // 590 is closest to Semibold
        fontSize: 24.0,
        height: 30.0 / 24.0, // line-height: 30px / font-size: 24px
        letterSpacing: -0.12, // -0.5% of 24px = -0.12
      );

  static TextStyle poppinsRegular(BuildContext context) => TextStyle(
        fontFamily: AppFonts.poppinsFont,
        fontWeight: FontWeight.w400, // Regular
        fontSize: 14.0,
        height: 22.0 / 14.0, // line-height: 22px / font-size: 14px
        letterSpacing: 0.28, // 2% of 14px = 0.28
      );
}
