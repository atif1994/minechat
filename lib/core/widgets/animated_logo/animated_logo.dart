import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:minechat/core/constants/app_assets/app_assets.dart';
import 'package:minechat/core/constants/app_colors/app_colors.dart';
import 'package:minechat/core/utils/helpers/app_responsive/app_responsive.dart';

class AppAnimatedLogo extends StatefulWidget {
  final VoidCallback onAnimationEnd;

  const AppAnimatedLogo({super.key, required this.onAnimationEnd});

  @override
  State<AppAnimatedLogo> createState() => _AppAnimatedLogoState();
}

class _AppAnimatedLogoState extends State<AppAnimatedLogo>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _positionAnimation;
  late Animation<double> _fadeInAnimation;
  late Animation<double> _fadeOutAnimation;
  bool _initialized = false;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    );

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final screenHeight = AppResponsive.screenHeight(context);

      // Fade in: 0.0 -> 0.3 of the animation
      _fadeInAnimation = CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.3, curve: Curves.easeIn),
      );

      // Fade out: 0.6 -> 1.0 of the animation
      _fadeOutAnimation = CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.6, 1.0, curve: Curves.easeOut),
      );

      // Position shift: starts at 0.4 until the end
      _positionAnimation = Tween<double>(
        begin: 0,
        end: -screenHeight * 0.2,
      ).animate(
        CurvedAnimation(
          parent: _controller,
          curve: const Interval(0.4, 1.0, curve: Curves.easeInOut),
        ),
      );

      _controller.forward();

      _controller.addStatusListener((status) {
        if (status == AnimationStatus.completed) {
          widget.onAnimationEnd();
        }
      });

      setState(() => _initialized = true);
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // final logo = SvgPicture.asset(
    //   AppAssets.logoMinechatWhite,
    //   height: AppResponsive.screenHeight(context) * 0.15,
    //   colorFilter: const ColorFilter.mode(AppColors.white, BlendMode.srcIn),
    // );
    final logo = Image.asset(
      AppAssets.dummyPngLogo,
      height: AppResponsive.screenHeight(context) * 0.15,
      color: AppColors.white,
    );
    if (!_initialized) {
      return logo;
    }

    return AnimatedBuilder(
      animation: _controller,
      child: logo,
      builder: (context, child) {
        final fadeValue = _fadeInAnimation.value > 0
            ? (_fadeInAnimation.value < 1
                ? _fadeInAnimation.value
                : 1 - _fadeOutAnimation.value)
            : 0;

        return Transform.translate(
          offset: Offset(0, _positionAnimation.value),
          child: Opacity(
            opacity: fadeValue.clamp(0.0, 1.0).toDouble(),
            child: child,
          ),
        );
      },
    );
  }
}
