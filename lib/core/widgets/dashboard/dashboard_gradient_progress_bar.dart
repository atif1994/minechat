import 'package:flutter/material.dart';
import 'package:minechat/core/utils/extensions/app_gradient/app_gradient_extension.dart';
import 'package:minechat/core/utils/helpers/app_responsive/app_responsive.dart';

class DashboardProgressBar extends StatelessWidget {
  final double percent; // 0..100
  final bool useGradient; // false to use solid grey

  const DashboardProgressBar({
    super.key,
    required this.percent,
    this.useGradient = true,
  });

  @override
  Widget build(BuildContext context) {
    final height = AppResponsive.scaleSize(context, 6);
    final radius = BorderRadius.circular(999);

    return LayoutBuilder(builder: (context, constraints) {
      final maxWidth = constraints.maxWidth;
      final width = (percent.clamp(0, 100) / 100.0) * maxWidth;

      return Stack(
        children: [
          Container(
            height: height,
            decoration: BoxDecoration(
              color: const Color(0xFFCDD3DB),
              borderRadius: radius,
            ),
          ),
          AnimatedContainer(
            duration: const Duration(milliseconds: 250),
            height: height,
            width: width,
            decoration: BoxDecoration(
              borderRadius: radius,
              gradient: LinearGradient(
                  colors: [Color(0xFFB4B4B4), Color(0xFF565656)],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter),
            ).withAppGradientIf(useGradient),
          ),
        ],
      );
    });
  }
}

// Small helper on your gradient extension (optional):
extension _OptGradient on BoxDecoration {
  BoxDecoration withAppGradientIf(bool cond) =>
      cond ? copyWith().withAppGradient : this;
}
