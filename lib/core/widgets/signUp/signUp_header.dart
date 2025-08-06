import 'package:flutter/material.dart';
import 'package:minechat/core/utils/helpers/app_responsive/app_responsive.dart';
import 'package:minechat/core/utils/helpers/app_spacing/app_spacing.dart';
import 'package:minechat/core/utils/helpers/app_styles/app_text_styles.dart';

class SignupHeader extends StatelessWidget {
  final String title;
  final String subtitle;
  final Widget avatar;

  const SignupHeader({
    super.key,
    required this.title,
    required this.subtitle,
    required this.avatar,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title,
            style: AppTextStyles.headline(context).copyWith(
                fontSize: AppResponsive.scaleSize(context, 24),
                fontWeight: FontWeight.bold)),
        AppSpacing.vertical(context, 0.01),
        Align(
          alignment: Alignment.center,
          child: Text(subtitle,
              style: AppTextStyles.bodyText(context).copyWith(
                  fontSize: AppResponsive.scaleSize(context, 18),
                  fontWeight: FontWeight.bold)),
        ),
        AppSpacing.vertical(context, 0.01),
        Align(alignment: Alignment.center, child: avatar),
      ],
    );
  }
}
