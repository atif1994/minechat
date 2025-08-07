import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:minechat/core/constants/app_assets/app_assets.dart';
import 'package:minechat/controller/theme_controller/theme_controller.dart';
import 'package:minechat/core/utils/helpers/app_responsive/app_responsive.dart';

class OnboaringIcon extends StatelessWidget {
  final String name;
  final double size;

  const OnboaringIcon({
    super.key,
    required this.name,
    required this.size,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Get.find<ThemeController>().isDarkMode;
    final iconPath = AppAssets.getSocialIcon(name, isDark);

    final scaledSize = AppResponsive.scaleSize(context, size);

    return SvgPicture.asset(
      iconPath,
      width: scaledSize,
      height: scaledSize,
      placeholderBuilder: (_) => Container(
        width: scaledSize,
        height: scaledSize,
        color: Colors.red.withOpacity(0.3),
        child: Center(
          child: Text(
            'Err',
            style: TextStyle(
              fontSize: AppResponsive.scaleSize(context, size * 0.3),
              color: Colors.red,
            ),
          ),
        ),
      ),
    );
  }
}
