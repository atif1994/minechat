import 'package:flutter/material.dart';
import 'package:minechat/core/utils/helpers/app_responsive/app_responsive.dart';
import 'nav_item.dart';
import 'nav_item_tile.dart';

/// Pixel-perfect bottom navigation bar that supports image icons (SVG/PNG).
class AppBottomNavBar extends StatelessWidget {
  final List<AppNavItem> items;
  final int currentIndex;
  final ValueChanged<int> onTap;

  // Style overrides
  final double? height;
  final Color inactiveColor;
  final Color backgroundColor;
  final bool safeArea;

  const AppBottomNavBar({
    super.key,
    required this.items,
    required this.currentIndex,
    required this.onTap,
    this.height,
    this.inactiveColor = const Color(0xFFB9C0CC),
    this.backgroundColor = Colors.white,
    this.safeArea = true,
  }) : assert(items.length >= 2);

  @override
  Widget build(BuildContext context) {
    final barHeight = height ?? AppResponsive.scaleSize(context, 60);
    final iconSize = AppResponsive.scaleSize(context, 24);
    final gap = AppResponsive.scaleSize(context, 2);

    Widget bar = Container(
      height: barHeight,
      decoration: BoxDecoration(
        color: backgroundColor,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: List.generate(items.length, (i) {
          final item = items[i];
          return NavItemTile(
            item: item,
            active: i == currentIndex,
            onTap: () => onTap(i),
            iconSize: iconSize,
            gap: gap,
            inactiveColor: inactiveColor,
          );
        }),
      ),
    );

    return safeArea ? SafeArea(top: false, child: bar) : bar;
  }
}
