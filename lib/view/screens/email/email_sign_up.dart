import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:minechat/controller/theme_controller/theme_controller.dart';
import 'package:minechat/controller/google_signin_controller/google_signin_controller.dart';
import 'package:minechat/core/constants/app_assets/app_assets.dart';
import 'package:minechat/core/constants/app_colors/app_colors.dart';
import 'package:minechat/core/widgets/google_signin_button/google_signin_button.dart';
import '../../../core/utils/helpers/app_styles/app_text_styles.dart';

class EmailSignUp extends StatelessWidget {
  const EmailSignUp({super.key});

  @override
  Widget build(BuildContext context) {
    // Initialize the Google Sign-In controller
    Get.put(GoogleSignInController());
    
    return Obx(() {
      final themeController = Get.find<ThemeController>();
      final isDark = themeController.isDarkMode;

      return Scaffold(
        resizeToAvoidBottomInset: false,
        body: SafeArea(
          child: Column(
            children: [
              _buildUpperSection(isDark),
              Expanded(child: _buildLowerSection(context)),
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
            child: Image.asset(AppAssets.minechatLogoDummy),
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

        // Social Icons (static)
        Positioned(top: 30, right: 20, child: _socialIcon('camera', 28, isDark)),
        Positioned(top: 100, left: 80, child: _socialIcon('messenger', 20, isDark)),
        Positioned(top: 110, right: 80, child: _socialIcon('slack', 20, isDark)),
        Positioned(top: 160, right: 120, child: _socialIcon('telegram', 20, isDark)),
        Positioned(top: 220, left: 25, child: _socialIcon('instagram', 30, isDark)),
        Positioned(top: 270, right: 25, child: _socialIcon('discord', 20, isDark)),
        Positioned(bottom: 100, left: 0, right: 0, child: _socialIcon('whatsapp', 28, isDark)),
        Positioned(bottom: 50, left: 70, child: _socialIcon('slack', 24, isDark)),
        Positioned(bottom: 50, right: 70, child: _socialIcon('viber', 24, isDark)),
      ],
    );
  }

  Widget _socialIcon(String name, double size, bool isDark) {
    final iconPath = AppAssets.getSocialIcon(name, isDark);
    return SvgPicture.asset(
      iconPath,
      width: size,
      height: size,
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
    );
  }

  Widget _buildLowerSection(BuildContext context) {
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
            Container(
              padding: const EdgeInsets.all(30).copyWith(top: 25, bottom: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Build, customize, and deploy\nyour AI chat assistants today!",
                    style: AppTextStyles.semiBoldHeading(context).copyWith(fontSize: 20, color: Colors.white),
                  ),
                  const SizedBox(height: 6),
                  Column(
                    children: [
                      Text(
                        "No coding needed. Launch your smart",
                        style: AppTextStyles.poppinsRegular(context).copyWith(color: Colors.white),
                        textAlign: TextAlign.center,
                      ),
                      Text(
                        "AI assistant in minutes.",
                        style: AppTextStyles.poppinsRegular(context).copyWith(color: Colors.white),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  const GoogleSignInButton(),
                  const SizedBox(height: 20),
                  Center(
                    child: Text(
                      "By continuing, you agree to Minechat AI\nTerms & Conditions and Privacy Policy",
                      style: AppTextStyles.poppinsRegular(context).copyWith(color: Colors.white, fontSize: 10),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Center(
                    child: Container(
                      width: 130,
                      height: 5,
                      decoration: BoxDecoration(
                        color: AppColors.white,
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
}

class GridPainter extends CustomPainter {
  final Color color;
  final double spacing;

  GridPainter({required this.color, this.spacing = 40.0});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 0.5;
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
