import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:minechat/controller/theme_controller/theme_controller.dart';
import 'package:minechat/core/utils/helpers/app_responsive/app_responsive.dart';
import 'package:minechat/core/utils/helpers/app_spacing/app_spacing.dart';
import 'package:minechat/core/utils/helpers/app_styles/app_text_styles.dart';
import 'package:minechat/core/widgets/app_button/app_theme_toggle_button.dart';

class AccountAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;

  const AccountAppBar({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    final themeController = Get.find<ThemeController>();
    final isDark = themeController.isDarkMode;
    return AppBar(
      title: Text(
        title,
        style: AppTextStyles.bodyText(context).copyWith(
            fontSize: AppResponsive.scaleSize(context, 20),
            fontWeight: FontWeight.w600),
      ),
      backgroundColor: isDark ? Color(0XFF1D1D1D) : Color(0XFFFFFFFF),
      elevation: 0,
      actionsPadding: AppSpacing.symmetric(context, v: 0, h: 0.03),
      actions: const [AppThemeToggleButton()],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
