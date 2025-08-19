import 'package:flutter/material.dart';

class AppColors {
  // Brand colors (fixed)
  static const Color primary = Color(0xFF87174F);
  static const Color secondary = Color(0xffab2856);
  static const Color tertiary = Color(0xffb73a4e);
  static const Color success = Colors.green;
  static const Color error = Colors.red;
  static const Color gray = Color(0xFFF4F6FC);


  // Adaptive (use via ThemeData)
  static const Color white = Colors.white;
  static const Color black = Colors.black;
  static const Color grey = Colors.grey;
  static const Color g1 = Color(0xFFFFFFFF); // pure white
  static const Color g2 = Color(0xFFF4F6FC); // light gray
  static const Color g3 = Color(0xFFE0E0E0); // medium gray
  static const Color g4 = Color(0xFF9E9E9E); // darker gray
  static const Color g5 = Color(0xFF212121); // almost black
  // Light / Dark backgrounds (used in themes)
  static const Color backgroundLight = Colors.white;
  static const Color backgroundDark = Color(0xFF0A0A0A);


  static const Color primaryDark = Color(0xFF6B123E); // darker variant
}
