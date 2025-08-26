import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:minechat/core/utils/helpers/app_responsive/app_responsive.dart';
import 'package:minechat/core/utils/helpers/app_styles/app_text_styles.dart';
import 'package:minechat/core/utils/extensions/app_gradient/app_gradient_extension.dart';
import 'nav_item.dart';

/// A single bottom-nav tile that renders an [AppNavItem].
class NavItemTile extends StatelessWidget {
  final AppNavItem item;
  final bool active;
  final VoidCallback onTap;
  final double iconSize;
  final double gap;
  final Color inactiveColor;

  const NavItemTile({
    super.key,
    required this.item,
    required this.active,
    required this.onTap,
    required this.iconSize,
    required this.gap,
    required this.inactiveColor,
  });

  bool get _hasBuilder => item.iconBuilder != null;

  bool get _isSvg => (item.iconPath ?? '').toLowerCase().endsWith('.svg');

  @override
  Widget build(BuildContext context) {
    final labelStyle = AppTextStyles.bodyText(context).copyWith(
      fontSize: AppResponsive.scaleSize(context, 10),
      color: active ? Colors.black : inactiveColor,
      fontWeight: FontWeight.w600,
      letterSpacing: 0.5,
    );

    final Widget icon = _buildIcon();

    final Widget label = active
        ? Text(item.label, style: labelStyle).withAppGradient()
        : Text(item.label, style: labelStyle);

    return Expanded(
      child: InkResponse(
        onTap: onTap,
        radius: iconSize * 1.6,
        highlightShape: BoxShape.rectangle,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            icon,
            SizedBox(height: gap),
            label,
          ],
        ),
      ),
    );
  }

  Widget _buildIcon() {
    if (_hasBuilder) {
      return item.iconBuilder!(active); // ← dynamic icon
    }
    final path = active && item.activeIconPath != null
        ? item.activeIconPath!
        : (item.iconPath ?? '');

    if (_isSvg) {
      final tint = (active && item.activeIconPath == null)
          ? const ColorFilter.mode(Color(0xFFB01D47), BlendMode.srcIn)
          : (active
              ? null
              : const ColorFilter.mode(Color(0xFFB9C0CC), BlendMode.srcIn));

      return SvgPicture.asset(
        path,
        width: iconSize,
        height: iconSize,
        colorFilter: tint,
      );
    } else {
      return Image.asset(
        path,
        width: iconSize,
        height: iconSize,
        color: (active && item.activeIconPath == null)
            ? const Color(0xFFB01D47)
            : (active ? null : const Color(0xFFB9C0CC)),
      );
    }
  }
}
