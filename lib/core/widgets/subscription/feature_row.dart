import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:minechat/core/constants/app_assets/app_assets.dart';
import 'package:minechat/core/utils/helpers/app_responsive/app_responsive.dart';
import 'package:minechat/core/utils/helpers/app_spacing/app_spacing.dart';
import 'package:minechat/core/utils/helpers/app_styles/app_text_styles.dart';
import 'package:minechat/model/data/subscriptions/plan_feature.dart';

class FeatureRow extends StatelessWidget {
  final PlanFeature feature;
  final Color featureIconColor;

  const FeatureRow({
    super.key,
    required this.feature,
    required this.featureIconColor,
  });

  @override
  Widget build(BuildContext context) {
    final String? text = feature.label.trim().isEmpty ? null : feature.label;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // tick icon
          SvgPicture.asset(
            AppAssets.subscriptionFeatureTick,
            colorFilter: ColorFilter.mode(featureIconColor, BlendMode.srcIn),
          ),
          AppSpacing.horizontal(context, 0.03),

          if (text != null)
            Expanded(
              child: Text(
                text,
                style: AppTextStyles.bodyText(context).copyWith(
                    fontSize: AppResponsive.scaleSize(context, 14),
                    fontWeight: FontWeight.w400,
                    color: Color(0XFF767C8C)),
              ),
            ),

          // optional trailing link on the same line
          if (feature.linkText != null)
            InkWell(
              onTap: feature.onTap,
              child: Text(
                feature.linkText!,
                style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                      color: Theme.of(context).colorScheme.primary,
                      decoration: TextDecoration.underline,
                    ),
              ),
            ),
        ],
      ),
    );
  }
}
