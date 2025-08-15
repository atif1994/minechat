import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:minechat/controller/theme_controller/theme_controller.dart';
import 'package:minechat/core/constants/app_assets/app_assets.dart';
import 'package:minechat/core/constants/app_colors/app_colors.dart';
import 'package:minechat/core/utils/extensions/app_gradient/app_gradient_extension.dart';
import 'package:minechat/core/utils/helpers/app_responsive/app_responsive.dart';
import 'package:minechat/core/utils/helpers/app_spacing/app_spacing.dart';
import 'package:minechat/core/utils/helpers/app_styles/app_text_styles.dart';
import 'package:minechat/core/widgets/account/account_business_profile_image_avatar.dart';

class AccountProfileCard extends StatelessWidget {
  const AccountProfileCard({super.key});

  @override
  Widget build(BuildContext context) {
    final themeController = Get.find<ThemeController>();
    final isDark = themeController.isDarkMode;
    return Container(
      padding: AppSpacing.symmetric(context, h: 0.04, v: 0.02),
      decoration: BoxDecoration(
          color: isDark ? Color(0XFF1D1D1D) : Color(0XFFFFFFFF),
          borderRadius:
              BorderRadius.circular(AppResponsive.radius(context, factor: 2)),
          border: Border.all(
              color: isDark ? Color(0XFF1D1D1D) : Color(0XFFEBEDF0))),
      child: Row(
        children: [
          AccountProfileImageAvatar(
            imagePath: AppAssets.minechatProfileAvatarLogoDummy,
          ),
          AppSpacing.horizontal(context, 0.02),
          Expanded(
            child: Text(
              "Shahzaib Ahmed Designs LLC",
              style: AppTextStyles.bodyText(context).copyWith(
                  fontSize: AppResponsive.scaleSize(context, 16),
                  fontWeight: FontWeight.w600,
                  color: isDark ? Color(0XFFFFFFFF) : Color(0XFF222222)),
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
            ),
          ),
        ],
      ),
    );
  }
}
