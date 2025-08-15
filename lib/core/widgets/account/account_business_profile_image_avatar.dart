import 'package:flutter/material.dart';
import 'package:minechat/core/constants/app_assets/app_assets.dart';
import 'package:minechat/core/constants/app_colors/app_colors.dart';
import 'package:minechat/core/utils/helpers/app_responsive/app_responsive.dart';

class AccountProfileImageAvatar extends StatelessWidget {
  final double radiusFactor;
  final String? imagePath;
  final bool isNetworkImage;

  const AccountProfileImageAvatar({
    super.key,
    this.radiusFactor = 3.5,
    this.imagePath,
    this.isNetworkImage = false,
  });

  @override
  Widget build(BuildContext context) {
    final double radius = AppResponsive.radius(context, factor: radiusFactor);
    final double borderWidth = AppResponsive.scaleSize(context, 1.5);

    return Container(
      padding: EdgeInsets.all(borderWidth), // creates space for border
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          colors: [AppColors.primary, AppColors.secondary],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: CircleAvatar(
        radius: radius,
        backgroundColor: AppColors.white,
        backgroundImage: isNetworkImage
            ? NetworkImage(imagePath ?? '')
            : AssetImage(imagePath ?? AppAssets.minechatProfileAvatarLogoDummy)
                as ImageProvider,
      ),
    );
  }
}
