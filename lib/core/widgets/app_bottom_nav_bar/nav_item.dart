import 'package:flutter/foundation.dart';

/// Data model for a bottom nav item. Supports SVG/PNG paths.
/// If [activeIconPath] is null, the widget tints the base icon for active state.
@immutable
class AppNavItem {
  final String label;
  final String iconPath;        // inactive icon
  final String? activeIconPath; // optional active icon

  const AppNavItem({
    required this.label,
    required this.iconPath,
    this.activeIconPath,
  });
}
