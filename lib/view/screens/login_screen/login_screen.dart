import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:minechat/core/constants/app_colors/app_colors.dart';
import 'package:minechat/core/constants/app_assets/app_assets.dart';
import 'package:minechat/core/constants/app_texts/app_texts.dart';
import 'package:minechat/core/widgets/app_background/app_background.dart';
import 'package:minechat/core/widgets/app_button/app_button.dart';
import 'package:minechat/controller/theme_controller/theme_controller.dart';
import 'package:minechat/view/screens/signUp/signUp_screen.dart';

import '../../../core/utils/helpers/app_styles/app_text_styles.dart';

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:minechat/core/constants/app_assets/app_assets.dart';
import 'package:minechat/core/constants/app_colors/app_colors.dart';
import 'package:minechat/core/constants/app_texts/app_texts.dart';
import 'package:minechat/core/widgets/app_button/app_button.dart';
import 'package:minechat/controller/theme_controller/theme_controller.dart';
import '../../../core/utils/helpers/app_styles/app_text_styles.dart';

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:minechat/core/constants/app_colors/app_colors.dart';
import 'package:minechat/core/constants/app_assets/app_assets.dart';
import 'package:minechat/core/constants/app_texts/app_texts.dart';
import 'package:minechat/core/widgets/app_button/app_button.dart';
import 'package:minechat/controller/theme_controller/theme_controller.dart';
import '../../../core/utils/helpers/app_styles/app_text_styles.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> with TickerProviderStateMixin {
  late AnimationController _logoController;
  late AnimationController _iconController;
  late Animation<double> _logoAnimation;
  late Animation<double> _iconAnimation;

  @override
  void initState() {
    super.initState();
    _logoController = AnimationController(vsync: this, duration: const Duration(seconds: 2));
    _iconController = AnimationController(vsync: this, duration: const Duration(seconds: 3));

    _logoAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(CurvedAnimation(
      parent: _logoController,
      curve: Curves.easeInOut,
    ));

    _iconAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(CurvedAnimation(
      parent: _iconController,
      curve: Curves.easeInOut,
    ));

    _logoController.forward();
    _iconController.forward();
  }

  @override
  void dispose() {
    _logoController.dispose();
    _iconController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final themeController = Get.find<ThemeController>();
      final isDark = themeController.isDarkMode;

      return Scaffold(
        resizeToAvoidBottomInset: false,
        body: SafeArea(
          child: Column(
            children: [
              _buildUpperSection(isDark),
              Expanded(child: _buildLowerSection(isDark)),
            ],
          ),
        ),
      );
    });
  }

  Widget _buildUpperSection(bool isDark) {
    return Container(
      height: 450,
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF0A0A0A) : Colors.white,
      ),
      child: Stack(
        children: [
          _buildGridPattern(isDark),
          _buildFloatingIcons(isDark),
          Center(
            child: AnimatedBuilder(
              animation: _logoAnimation,
              builder: (context, child) {
                return Transform.scale(
                  scale: _logoAnimation.value,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Image.asset(AppAssets.minechatLogoDummy),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGridPattern(bool isDark) {
    return CustomPaint(
      painter: GridPainter(
        color: isDark ? Colors.white.withOpacity(0.08) : Colors.black.withOpacity(0.15),
        spacing: isDark ? 50.0 : 40.0,
      ),
      size: Size.infinite,
    );
  }

  Widget _buildFloatingIcons(bool isDark) {
    return AnimatedBuilder(
      animation: _iconAnimation,
      builder: (context, child) {
        return Stack(
          children: [

            Positioned(
              top: 40,
              left: 20,
              child: Obx(() {
                final themeController = Get.find<ThemeController>();
                final isDark = themeController.isDarkMode;
                final iconPath = isDark ? AppAssets.darkMode : AppAssets.lightDart;

                return GestureDetector(
                  onTap: () => themeController.toggleTheme(),
                  child: SvgPicture.asset(
                    iconPath,
                    width: 32,
                    height: 32,
                    placeholderBuilder: (context) => const CircularProgressIndicator(),
                  ),
                );
              }),
            ),

            Positioned(top: 30, right: 20, child: _iconWithOffset('camera', 28, isDark, Offset(0, 8))),
            Positioned(top: 100, left: 80, child: _iconWithOffset('messenger', 20, isDark, Offset(0, 8))),
            Positioned(top: 110, right: 80, child: _iconWithOffset('slack', 20, isDark, Offset(0, -6))),
            Positioned(top: 160, right: 120, child: _iconWithOffset('telegram', 20, isDark, Offset(0, -6))),
            Positioned(top: 220, left: 25, child: _iconWithOffset('instagram', 30, isDark, Offset(-4, 0))),
            Positioned(top: 270, right: 25, child: _iconWithOffset('discord', 20, isDark, Offset(4, 0))),
            Positioned(bottom: 140, left: 0, right: 0, child: _iconWithOffset('whatsapp', 28, isDark, Offset(0, -8))),
            Positioned(bottom: 100, left: 70, child: _iconWithOffset('slack', 24, isDark, Offset(0, 10))),
            Positioned(bottom: 100, right: 70, child: _iconWithOffset('viber', 24, isDark, Offset(0, 6))),
          ],
        );
      },
    );
  }

  Widget _iconWithOffset(String name, double size, bool isDark, Offset offset) {
    String iconPath = AppAssets.getSocialIcon(name, isDark);
    return Transform.translate(
      offset: offset * _iconAnimation.value,
      child: SvgPicture.asset(
        iconPath,
        width: size,
        height: size,
        // ❗️ Removed colorFilter so original icon colors show
        placeholderBuilder: (context) => Container(
          width: size,
          height: size,
          color: Colors.red.withOpacity(0.3),
          child: Center(
            child: Text(
              'Err',
              style: TextStyle(fontSize: size * 0.3, color: Colors.red),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLowerSection(bool isDark) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius: const BorderRadius.only(topLeft: Radius.circular(30), topRight: Radius.circular(30)),
      ),
      child: ClipRRect(
        borderRadius: const BorderRadius.only(topLeft: Radius.circular(30), topRight: Radius.circular(30)),
        child: Stack(
          children: [
            Positioned.fill(
              child: Container(
                color: AppColors.primary,
                child: Stack(
                  children: [
                    Positioned(
                      top: 0,
                      left: 0,
                      right: 0,
                      height: 300,
                      child: SvgPicture.asset(AppAssets.gridPatternLower, fit: BoxFit.cover),
                    ),
                  ],
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.all(30).copyWith(top: 25, bottom: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    AppTexts.signUpText,
                    style: AppTextStyles.semiBoldHeading(context).copyWith(fontSize: 20, color: Colors.white),
                  ),
                  const SizedBox(height: 6),
                  Column(
                    children: [
                      Text(
                        AppTexts.signUpNoCodeText,
                        style: AppTextStyles.poppinsRegular(context).copyWith(color: Colors.white),
                        textAlign: TextAlign.center,
                      ),
                      Text(
                        AppTexts.signUpNoCodeText1,
                        style: AppTextStyles.poppinsRegular(context).copyWith(color: Colors.white),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                  const SizedBox(height: 25),
                  Row(
                    children: [
                      Expanded(child: AppButtonStyles.secondary(text: 'Login', height: 40, onPressed: _onLoginPressed)),
                      const SizedBox(width: 8),
                      Expanded(child: AppButtonStyles.secondary(text: 'Signup', height: 40, onPressed: (){
                        Get.to(SignupScreen(isBusiness: true));
                      })),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Center(
                    child: Text(
                      AppTexts.signUpVersionText,
                      style: AppTextStyles.poppinsRegular(context).copyWith(color: Colors.white, fontSize: 10),
                    ),
                  ),
                  const SizedBox(height: 25),
                  Center(
                    child: Container(
                      width: 130,
                      height: 5,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _onLoginPressed() {
    Get.snackbar('Login', 'Login functionality coming soon!', snackPosition: SnackPosition.BOTTOM);
  }

  void _onSignUpPressed() {
    Get.snackbar('Sign Up', 'Sign up functionality coming soon!', snackPosition: SnackPosition.BOTTOM);
  }
}

class GridPainter extends CustomPainter {
  final Color color;
  final double spacing;

  GridPainter({required this.color, this.spacing = 40.0});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = color..strokeWidth = 0.5;
    for (double x = 0; x < size.width; x += spacing) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }
    for (double y = 0; y < size.height; y += spacing) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}


