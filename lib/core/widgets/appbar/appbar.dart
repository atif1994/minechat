import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../constants/app_colors/app_colors.dart';
import '../../utils/helpers/app_styles/app_text_styles.dart';


class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final bool showBack;

  const CustomAppBar({
    Key? key,
    required this.title,
    this.showBack = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: Text(
        title,
        style: AppTextStyles.heading(context).copyWith(color: AppColors.black),
      ),
      backgroundColor: AppColors.g1,
      elevation: 0,
      leading: showBack
          ? IconButton(
        icon: Icon(Icons.arrow_back, color: AppColors.black),
        onPressed: () => Get.back(),
      )
          : null,
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
