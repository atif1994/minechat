import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:minechat/controller/login_controller/login_controller.dart';
import 'package:minechat/controller/theme_controller/theme_controller.dart';
import 'package:minechat/core/utils/helpers/app_responsive/app_responsive.dart';
import 'package:minechat/core/utils/helpers/app_spacing/app_spacing.dart';
import 'package:minechat/core/utils/helpers/app_styles/app_text_styles.dart';
import 'package:minechat/core/widgets/account/account_profile_image_avatar.dart';

class AccountProfileCard extends StatelessWidget {
  const AccountProfileCard({super.key});

  @override
  Widget build(BuildContext context) {
    final themeController = Get.find<ThemeController>();
    final loginController = Get.find<LoginController>();

    final isDark = themeController.isDarkMode;

    return Obx(() {
      final user = loginController.currentUser.value;
      final biz = loginController.businessAccount.value;

      // Prefer company info from /business_accounts; fallback to user fields
      final companyName =
          (biz?['companyName'] as String?)?.trim().isNotEmpty == true
              ? (biz?['companyName'] as String)
              : (user?.companyName?.trim().isNotEmpty == true
                  ? user!.companyName!
                  : null);

      final companyPhoto =
          (biz?['photoURL'] as String?)?.trim().isNotEmpty == true
              ? (biz?['photoURL'] as String)
              : (user?.photoURL ?? '');

      final displayName = companyName ?? 'Company';
      final profileUrl =
          companyPhoto; // may be empty → avatar handles placeholder
      final avatarSize = AppResponsive.radius(context, factor: 7);

      return Container(
        padding: AppSpacing.symmetric(context, h: 0.04, v: 0.02),
        decoration: BoxDecoration(
          color: isDark ? const Color(0XFF1D1D1D) : const Color(0XFFFFFFFF),
          borderRadius: BorderRadius.circular(
            AppResponsive.radius(context, factor: 2),
          ),
          border: Border.all(
            color: isDark ? const Color(0XFF1D1D1D) : const Color(0XFFEBEDF0),
          ),
        ),
        child: Row(
          children: [
            AccountProfileImageAvatar(
              imageUrl: profileUrl,
              size: avatarSize,
            ),
            AppSpacing.horizontal(context, 0.02),
            Expanded(
              child: Text(
                displayName,
                style: AppTextStyles.bodyText(context).copyWith(
                  fontSize: AppResponsive.scaleSize(context, 16),
                  fontWeight: FontWeight.w600,
                  color: isDark ? Colors.white : const Color(0XFF222222),
                ),
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
              ),
            ),
          ],
        ),
      );
    });
  }
}
