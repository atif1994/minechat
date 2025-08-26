import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:minechat/controller/edit_profile_controller/admin_edit_profile_controller.dart';
import 'package:minechat/controller/login_controller/login_controller.dart';
import 'package:minechat/controller/theme_controller/theme_controller.dart';
import 'package:minechat/core/constants/app_assets/app_assets.dart';
import 'package:minechat/core/utils/helpers/app_responsive/app_responsive.dart';
import 'package:minechat/core/utils/helpers/app_spacing/app_spacing.dart';
import 'package:minechat/core/widgets/account/account_app_bar.dart';
import 'package:minechat/core/widgets/account/account_option_tile.dart';
import 'package:minechat/core/widgets/account/account_profile_card.dart';
import 'package:minechat/core/widgets/edit_profile/logout_alert_dialog.dart';
import 'package:minechat/view/screens/edit_profile/admin_edit_profile_screen.dart';

class AccountScreen extends StatelessWidget {
  const AccountScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final themeController = Get.find<ThemeController>();
    final c = Get.put(AdminEditProfileController());
    final login = Get.find<LoginController>();
    login.hydrateFromAuthIfNeeded();

    return Obx(() {
      final isDark = themeController.isDarkMode;
      return Scaffold(
        backgroundColor: isDark ? Color(0XFF0A0A0A) : Color(0XFFF4F6FC),
        appBar: const AccountAppBar(title: 'Account'),
        body: SafeArea(
          child: Padding(
            padding: AppSpacing.all(context, factor: 2),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AppSpacing.vertical(context, 0.03),
                const AccountProfileCard(),
                AppSpacing.vertical(context, 0.02),

                // REACTIVE THEME SWITCH HANDLING
                Obx(() {
                  final isDark = themeController.isDarkMode;
                  return Container(
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xFF1D1D1D) : Colors.white,
                      borderRadius: BorderRadius.circular(
                        AppResponsive.radius(context, factor: 2),
                      ),
                      boxShadow: [
                        if (!isDark)
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 10,
                            offset: const Offset(0, 2),
                          ),
                      ],
                    ),
                    child: Container(
                      decoration: BoxDecoration(
                        color: isDark ? const Color(0xFF1D1D1D) : Colors.white,
                        borderRadius: BorderRadius.circular(
                          AppResponsive.radius(context, factor: 2),
                        ),
                        border: Border.all(
                          color: isDark
                              ? const Color(0xFF1D1D1D)
                              : const Color(0xFFEBEDF0),
                        ),
                      ),
                      child: Column(
                        children: [
                          // Obx(() {
                          //   final user = loginController.currentUser.value;
                          //   return AccountOptionTile(
                          //     title: 'Manage User Profiles',
                          //     showProfileImage: true,
                          //     profileImageUrl: user?.photoURL ?? '',
                          //     trailingSvgPath: AppAssets.accountArrowRight,
                          //     onTap: () {},
                          //   );
                          // }),
                          AccountOptionTile(
                            title: 'Edit User Profile',
                            leadingSvgPath: AppAssets.accountEditUserProfile,
                            trailingSvgPath: AppAssets.accountArrowRight,
                            onTap: () =>
                                Get.to(() => const AdminEditProfileScreen()),
                            // Get.to(() => const BusinessEditProfileScreen()),
                          ),
                          Divider(
                            thickness: 0.8,
                            height: 0,
                            color: isDark
                                ? const Color(0xFF3A3A3A)
                                : const Color(0xFFEBEDF0),
                          ),
                          AccountOptionTile(
                            title: 'Terms & Conditions',
                            leadingSvgPath: AppAssets.signupIconPassword,
                            trailingSvgPath: AppAssets.accountArrowRight,
                            onTap: () {},
                          ),
                          AccountOptionTile(
                            title: 'Contact Us',
                            leadingSvgPath: AppAssets.accountContactUs,
                            trailingSvgPath: AppAssets.accountArrowRight,
                            onTap: () {},
                          ),
                          AccountOptionTile(
                            title: 'Upgrade Subscription',
                            leadingSvgPath: AppAssets.accountSubscription,
                            trailingSvgPath: AppAssets.accountArrowRight,
                            onTap: () {},
                          ),
                          AccountOptionTile(
                            title: 'Logout',
                            leadingSvgPath: AppAssets.accountLogout,
                            onTap: () {
                              LogoutAlertDialog.show(
                                onConfirm: c.logout,
                                // Optional: tweak dim strength
                                barrier: Colors.black.withOpacity(0.55),
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                  );
                }),
              ],
            ),
          ),
        ),
      );
    });
  }
}
