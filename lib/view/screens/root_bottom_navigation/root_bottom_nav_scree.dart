import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:minechat/controller/bottom_nav_controller/bottom_nav_controller.dart';
import 'package:minechat/core/constants/app_assets/app_assets.dart';
import 'package:minechat/core/constants/app_texts/app_texts.dart';
import 'package:minechat/core/widgets/app_bottom_nav_bar/app_bottom_nav_bar.dart';
import 'package:minechat/core/widgets/app_bottom_nav_bar/nav_item.dart';
import 'package:minechat/view/screens/dashboard/dashboard_screen.dart';

class RootBottomNavScreen extends StatelessWidget {
  RootBottomNavScreen({super.key});

  final BottomNavController ctrl =
      Get.put(BottomNavController(), permanent: true);

  // Replace these with your real pages
  final List<Widget> _pages = const [
    DashboardScreen(), // Home
    Placeholder(), // Chat
    Placeholder(), // Setup
    Placeholder(), // CRM
    Placeholder(), // Accounts
  ];

  // Supply your real asset paths here (SVG or PNG)
  static const _items = <AppNavItem>[
    AppNavItem(
      label: AppTexts.bottomNavBarHomeLabel,
      iconPath: AppAssets.bottomNavBarHome,
      activeIconPath: AppAssets.bottomNavBarActiveHome,
    ),
    AppNavItem(
      label: AppTexts.bottomNavBarChatLabel,
      iconPath: AppAssets.bottomNavBarChat,
      activeIconPath: AppAssets.bottomNavBarActiveChat,
    ),
    AppNavItem(
      label: AppTexts.bottomNavBarSetupLabel,
      iconPath: AppAssets.bottomNavBarSetup,
      activeIconPath: AppAssets.bottomNavBarActiveSetup,
    ),
    AppNavItem(
      label: AppTexts.bottomNavBarCRMLabel,
      iconPath: AppAssets.bottomNavBarCRM,
      activeIconPath: AppAssets.bottomNavBarActiveCRM,
    ),
    AppNavItem(
      label: AppTexts.bottomNavBarAccountsLabel,
      iconPath: AppAssets.bottomNavBarAccounts,
      activeIconPath: AppAssets.bottomNavBarActiveAccounts,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final index = ctrl.currentIndex.value;

      return Scaffold(
        // Optional: plug in your DashboardAppBar at the top pages[index]
        body: IndexedStack(
          index: index,
          children: _pages,
        ),
        bottomNavigationBar: AppBottomNavBar(
          items: _items,
          currentIndex: index,
          onTap: ctrl.changeTab,
        ),
        backgroundColor: const Color(0xFFFFFFFF),
      );
    });
  }
}
