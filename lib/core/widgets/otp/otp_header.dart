import 'package:flutter/material.dart';
import 'package:minechat/core/utils/helpers/app_responsive/app_responsive.dart';
import 'package:minechat/core/utils/helpers/app_styles/app_text_styles.dart';
import 'package:minechat/core/utils/helpers/app_spacing/app_spacing.dart';

class OtpHeader extends StatelessWidget {
  final String title;
  final String subtitle;
  final String email;

  const OtpHeader({
    super.key,
    required this.title,
    required this.subtitle,
    required this.email,
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
            fontWeight: FontWeight.w700,
          ),
        ),
        AppSpacing.vertical(context, 0.01),
        Text(
          subtitle,
          style: AppTextStyles.bodyText(context).copyWith(
              fontSize: AppResponsive.scaleSize(context, 14),
              fontWeight: FontWeight.w400,
              color: Color(0xff767c8c)),
        ),
        Text(
          email,
          style: AppTextStyles.bodyText(context).copyWith(
              fontWeight: FontWeight.w600,
              fontSize: AppResponsive.scaleSize(context, 14)),
        ),
      ],
    );
  }
}
