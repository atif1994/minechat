import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:minechat/core/constants/app_assets/app_assets.dart';
import 'package:minechat/core/utils/extensions/app_gradient/app_gradient_extension.dart';
import 'package:minechat/core/utils/helpers/app_responsive/app_responsive.dart';

class AppBackground extends StatelessWidget {
  final Widget child;

  const AppBackground({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    final screenWidth = AppResponsive.screenWidth(context);

    return Container(
      decoration: BoxDecoration().withAppGradient,
      child: Stack(
        children: [
          // Upper Grid
          Align(
            alignment: Alignment.topCenter,
            child: ShaderMask(
              shaderCallback: (bounds) => const LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Colors.transparent, Colors.white],
              ).createShader(bounds),
              blendMode: BlendMode.dstIn,
              child: SvgPicture.asset(
                AppAssets.gridUpper,
                width: screenWidth,
                fit: BoxFit.cover,
              ),
            ),
          ),

          // Lower Grid
          Align(
            alignment: Alignment.bottomCenter,
            child: ShaderMask(
              shaderCallback: (bounds) => const LinearGradient(
                begin: Alignment.bottomCenter,
                end: Alignment.topCenter,
                colors: [Colors.transparent, Colors.white],
              ).createShader(bounds),
              blendMode: BlendMode.dstIn,
              child: SvgPicture.asset(
                AppAssets.gridLower,
                width: screenWidth,
                fit: BoxFit.cover,
              ),
            ),
          ),

          // ✅ Ensure child is drawn ABOVE ShaderMasks
          Positioned.fill(
            child: IgnorePointer(
              child: Center(child: child),
            ),
          ),
        ],
      ),
    );
  }
}
