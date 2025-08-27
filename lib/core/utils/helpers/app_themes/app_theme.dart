import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:minechat/core/constants/app_colors/app_colors.dart';
import 'package:minechat/core/constants/app_fonts/app_fonts.dart';

class AppTheme {
  // Base text theme for light and dark
  static TextTheme _baseTextTheme(Color textColor) => TextTheme(
        headlineMedium: TextStyle(
          fontSize: 24,
          fontFamily: AppFonts.primaryFont,
          color: textColor,
        ),
        titleLarge: TextStyle(
          fontSize: 20,
          fontFamily: AppFonts.primaryFont,
          color: textColor,
        ),
        bodyLarge: TextStyle(
          fontSize: 16,
          fontFamily: AppFonts.primaryFont,
          color: textColor,
        ),
        bodyMedium: TextStyle(
          fontSize: 14,
          fontFamily: AppFonts.primaryFont,
          color: textColor.withOpacity(0.8),
        ),
        labelLarge: TextStyle(
          fontSize: 16,
          fontFamily: AppFonts.primaryFont,
          fontWeight: FontWeight.bold,
          color: Colors.white, // usually for buttons
        ),
      );

  static final lightTheme = ThemeData(
    brightness: Brightness.light,
    scaffoldBackgroundColor: const Color(0xFFF4F6FC),
    primaryColor: AppColors.primary,
    hintColor: AppColors.grey,
    textTheme: _baseTextTheme(AppColors.black),
    appBarTheme: const AppBarTheme(
      backgroundColor: Color(0xFFFFFFFF),
      elevation: 0,
      systemOverlayStyle: SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
        statusBarBrightness: Brightness.light,
      ),
    ),
    colorScheme: const ColorScheme.light(
      primary: AppColors.primary,
      secondary: AppColors.secondary,
      surface: AppColors.backgroundLight,
      error: AppColors.error,
      onPrimary: AppColors.white,
      onSecondary: AppColors.white,
      onSurface: AppColors.black,
      onError: AppColors.white,
    ),
  );

  static final darkTheme = ThemeData(
    brightness: Brightness.dark,
    scaffoldBackgroundColor: const Color(0xFF0A0A0A),
    primaryColor: AppColors.primaryDark,
    hintColor: AppColors.grey,
    textTheme: _baseTextTheme(AppColors.white),
    appBarTheme: const AppBarTheme(
      backgroundColor: Color(0xFF1D1D1D),
      elevation: 0,
      systemOverlayStyle: SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
        statusBarBrightness: Brightness.dark,
      ),
    ),
    colorScheme: const ColorScheme.dark(
      primary: AppColors.primaryDark,
      secondary: AppColors.secondary,
      surface: AppColors.backgroundDark,
      error: AppColors.error,
      onPrimary: AppColors.white,
      onSecondary: AppColors.white,
      onSurface: AppColors.white,
      onError: AppColors.white,
    ),
  );
}
