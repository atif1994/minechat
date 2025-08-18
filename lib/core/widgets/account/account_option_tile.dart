import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:minechat/controller/theme_controller/theme_controller.dart';
import 'package:minechat/core/constants/app_assets/app_assets.dart';
import 'package:minechat/core/utils/helpers/app_responsive/app_responsive.dart';
import 'package:minechat/core/utils/helpers/app_spacing/app_spacing.dart';
import 'package:minechat/core/utils/helpers/app_styles/app_text_styles.dart';
import 'package:minechat/core/widgets/account/account_profile_image_avatar.dart';

class AccountOptionTile extends StatelessWidget {
  final String title;
  final String? leadingSvgPath;
  final String? trailingSvgPath;
  final bool showProfileImage;
  final String? profileImageUrl;
  final VoidCallback onTap;

  const AccountOptionTile({
    super.key,
    required this.title,
    this.leadingSvgPath,
    this.trailingSvgPath,
    this.showProfileImage = false,
    this.profileImageUrl,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final themeController = Get.find<ThemeController>();
    final isDark = themeController.isDarkMode;

    return ListTile(
      tileColor: Colors.transparent,
      // tile color will inherit from parent
      leading: showProfileImage
          ? AccountProfileImageAvatar(
              imageUrl: '',
              size: AppResponsive.radius(context, factor: 5),
            )
          : (leadingSvgPath != null
              ? SvgPicture.asset(
                  leadingSvgPath!,
                  width: 24,
                  height: 24,
                  color: isDark ? Color(0XFFFFFFFF) : Color(0XFF222222),
                )
              : null),
      title: Text(
        title,
        style: AppTextStyles.bodyText(context).copyWith(
          fontSize: AppResponsive.scaleSize(context, 16),
          fontWeight: FontWeight.w600,
          color: isDark ? Color(0XFFFFFFFF) : Color(0XFF222222),
        ),
      ),
      trailing: trailingSvgPath != null
          ? SvgPicture.asset(
              trailingSvgPath!,
              width: 24,
              height: 24,
            )
          : null,
      onTap: onTap,
    );
  }
}
