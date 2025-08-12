import 'package:flutter/material.dart';
import 'package:minechat/core/utils/helpers/app_responsive/app_responsive.dart';
import 'package:minechat/core/utils/helpers/app_spacing/app_spacing.dart';

class DashboardSectionContainer extends StatelessWidget {
  final Widget child;

  const DashboardSectionContainer({
    super.key,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    final radius = AppResponsive.radius(context, factor: 1.2);
    return Container(
      constraints: BoxConstraints(
        minHeight: AppResponsive.scaleSize(context, 88),
      ),
      decoration: BoxDecoration(
        color: Color(0xFFFFFFFF),
        borderRadius: BorderRadius.circular(radius),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0A0A0A).withOpacity(0.03),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(color: const Color(0xFFE9EEF1)),
      ),
      padding: AppSpacing.symmetric(context, h: 0.04, v: 0.01),
      child: child,
    );
  }
}
