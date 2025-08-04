import 'package:flutter/material.dart';

class AppColors {
  // Brand colors (fixed)
  static const Color primary = Color(0xFF86174F);
  static const Color secondary = Color(0xffb73a4e);
  static const Color success = Colors.green;
  static const Color error = Colors.red;

  // Adaptive (use via ThemeData)
  static const Color white = Colors.white;
  static const Color black = Colors.black;
  static const Color grey = Colors.grey;

  // Light / Dark backgrounds (used in themes)
  static const Color backgroundLight = Colors.white;
  static const Color backgroundDark = Color(0xFF121212);

  static const Color primaryDark = Color(0xFF6B123E); // darker variant
}
