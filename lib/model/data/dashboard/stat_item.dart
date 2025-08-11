import 'dart:ui';

import 'package:flutter/foundation.dart';

@immutable
class StatItem {
  final String title;
  final String value; // display-ready: e.g., "18 hours", "24", "1,684"
  final bool isPositive; // green if true, red if false
  final String deltaText; // e.g., "+18% from last week"
  final String iconPath;
  final Color chipBgColor;
  final Color chipIconColor;

  const StatItem({
    required this.title,
    required this.value,
    required this.isPositive,
    required this.deltaText,
    required this.iconPath,
    this.chipBgColor = const Color(0xFFEFFBF3),
    this.chipIconColor = const Color(0xFF22C55E),
  });
}
