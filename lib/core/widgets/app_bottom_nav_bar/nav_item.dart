import 'package:flutter/widgets.dart';

/// If [iconBuilder] is provided, it takes precedence over icon paths.
@immutable
class AppNavItem {
  final String label;

  // Static asset icons (SVG/PNG)
  final String? iconPath; // inactive icon
  final String? activeIconPath; // optional active icon

  // Dynamic icon (e.g., profile bubble). Receives [active].
  final Widget Function(bool active)? iconBuilder;

  const AppNavItem({
    required this.label,
    this.iconPath,
    this.activeIconPath,
    this.iconBuilder,
  }) : assert(
          iconPath != null || iconBuilder != null,
          'Provide either iconPath or iconBuilder',
        );
}
