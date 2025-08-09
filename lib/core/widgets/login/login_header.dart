import 'package:flutter/material.dart';
import 'package:minechat/core/utils/helpers/app_styles/app_text_styles.dart';
import 'package:minechat/core/utils/helpers/app_responsive/app_responsive.dart';
import 'package:minechat/core/utils/helpers/app_spacing/app_spacing.dart';

class LoginHeader extends StatelessWidget {
  final String title;
  final String subtitle;

  const LoginHeader({
    super.key,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: AppTextStyles.heading(context).copyWith(
              fontSize: AppResponsive.scaleSize(context, 24),
              fontWeight: FontWeight.w700),
        ),
        AppSpacing.vertical(context, 0.006),
        Text(
          subtitle,
          style: AppTextStyles.bodyText(context).copyWith(
              fontSize: AppResponsive.scaleSize(context, 14),
              color: const Color(0xFF767C8C),
              fontWeight: FontWeight.w400),
        ),
      ],
    );
  }
}
