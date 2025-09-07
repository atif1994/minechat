import 'package:flutter/material.dart';
import 'package:minechat/core/utils/extensions/app_gradient/app_gradient_extension.dart';
import 'package:minechat/core/constants/app_assets/app_assets.dart';

class AccountProfileImageAvatar extends StatelessWidget {
  final String imageUrl;
  final double size;

  const AccountProfileImageAvatar({
    super.key,
    required this.imageUrl,
    required this.size,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
      ).withAppGradient,
      child: Padding(
        padding: EdgeInsets.all(2),
        child: ClipOval(
          child: imageUrl.isNotEmpty
              ? Image.network(
                  imageUrl,
                  width: size,
                  height: size,
                  fit: BoxFit.cover,
                  loadingBuilder: (context, child, loadingProgress) {
                    if (loadingProgress == null) return child;
                    return SizedBox(
                      width: size,
                      height: size,
                      child: Center(
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                    );
                  },
                  errorBuilder: (context, error, stackTrace) {
                    return Image.asset(
                      AppAssets.blankAdminProfile,
                      width: size,
                      height: size,
                      fit: BoxFit.cover,
                    );
                  },
                )
              : Image.asset(
                  AppAssets.blankAdminProfile,
                  width: size,
                  height: size,
                  fit: BoxFit.cover,
                ),
        ),
      ),
    );
  }
}
