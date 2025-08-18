import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:minechat/core/constants/app_assets/app_assets.dart';
import 'package:minechat/core/utils/helpers/app_responsive/app_responsive.dart';
import 'package:minechat/core/utils/helpers/app_spacing/app_spacing.dart';

class DashboardRightArrowIcon extends StatelessWidget {
  final VoidCallback? onTapArrow;

  const DashboardRightArrowIcon({
    required this.onTapArrow,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final iconSize = AppResponsive.scaleSize(context, 6);

    return GestureDetector(
      onTap: onTapArrow,
      child: Container(
        width: iconSize * 3.2,
        height: iconSize * 3.2,
        decoration: BoxDecoration(
          color: const Color(0xFFF4F6FC),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Padding(
          padding: AppSpacing.all(context, factor: 0.6),
          child: SvgPicture.asset(
            AppAssets.dashboardArrowRightUp,
            height: iconSize,
            width: iconSize,
          ),
        ),
      ),
    );
  }
}
