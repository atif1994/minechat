import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:minechat/controller/bottom_nav_controller/bottom_nav_controller.dart';
import 'package:minechat/controller/login_controller/login_controller.dart';
import 'package:minechat/controller/theme_controller/theme_controller.dart';
import 'package:minechat/core/constants/app_assets/app_assets.dart';
import 'package:minechat/core/constants/app_texts/app_texts.dart';
import 'package:minechat/core/utils/helpers/app_responsive/app_responsive.dart';
import 'package:minechat/core/widgets/app_bottom_nav_bar/app_bottom_nav_bar.dart';
import 'package:minechat/core/widgets/app_bottom_nav_bar/nav_item.dart';
import 'package:minechat/view/screens/account/account_screen.dart';
import 'package:minechat/view/screens/dashboard/dashboard_screen.dart';
import '../setup/set_up.dart';

class RootBottomNavScreen extends StatelessWidget {
  RootBottomNavScreen({super.key});

  final BottomNavController ctrl =
      Get.put(BottomNavController(), permanent: true);

  final List<Widget> _pages = const [
    DashboardScreen(),
    Placeholder(),
    AIAssistantSetupScreen(),
    Placeholder(),
    AccountScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    final themeController = Get.find<ThemeController>();

    return Obx(() {
      final index = ctrl.currentIndex.value;
      final isDark = themeController.isDarkMode;

      // Build items each frame (cheap), last one uses dynamic icon
      final items = <AppNavItem>[
        const AppNavItem(
          label: AppTexts.bottomNavBarHomeLabel,
          activeIconPath: AppAssets.bottomNavBarActiveHome,
          iconPath: AppAssets.bottomNavBarHome,
        ),
        const AppNavItem(
          label: AppTexts.bottomNavBarChatLabel,
          iconPath: AppAssets.bottomNavBarChat,
          activeIconPath: AppAssets.bottomNavBarActiveChat,
        ),
        const AppNavItem(
          label: AppTexts.bottomNavBarSetupLabel,
          iconPath: AppAssets.bottomNavBarSetup,
          activeIconPath: AppAssets.bottomNavBarActiveSetup,
        ),
        const AppNavItem(
          label: AppTexts.bottomNavBarCRMLabel,
          iconPath: AppAssets.bottomNavBarCRM,
          activeIconPath: AppAssets.bottomNavBarActiveCRM,
        ),
        // 👇 Dynamic Accounts tab
        AppNavItem(
          label: AppTexts.bottomNavBarAccountsLabel,
          iconBuilder: (active) => _ProfileTabIcon(active: active),
        ),
      ];

      return Scaffold(
        body: IndexedStack(index: index, children: _pages),
        bottomNavigationBar: AppBottomNavBar(
          items: items,
          currentIndex: index,
          onTap: ctrl.changeTab,
        ),
        backgroundColor:
            isDark ? const Color(0XFF1D1D1D) : const Color(0xFFFFFFFF),
      );
    });
  }
}

class _ProfileTabIcon extends StatelessWidget {
  final bool active;

  const _ProfileTabIcon({required this.active});

  @override
  Widget build(BuildContext context) {
    final login = Get.find<LoginController>(); // needs import
    final size = AppResponsive.scaleSize(context, 24);

    return Obx(() {
      final url = login.currentUser.value?.photoURL ?? '';
      final borderColor =
          active ? const Color(0xFFB01D47) : const Color(0xFFB9C0CC);

      Widget avatar;
      if (url.isNotEmpty) {
        avatar = ClipOval(
          child: Image.network(
            url,
            width: size,
            height: size,
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) => _fallback(size),
          ),
        );
      } else {
        avatar = _fallback(size);
      }

      return Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: borderColor, width: active ? 2 : 1),
        ),
        child: avatar,
      );
    });
  }

  Widget _fallback(double size) => Icon(
        Icons.person,
        size: size * 0.85,
        color: const Color(0xFFB9C0CC),
      );
}
