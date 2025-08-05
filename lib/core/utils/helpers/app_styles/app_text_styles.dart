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
}
