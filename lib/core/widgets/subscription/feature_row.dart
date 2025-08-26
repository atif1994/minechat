import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:minechat/controller/theme_controller/theme_controller.dart';
import 'package:minechat/core/constants/app_assets/app_assets.dart';
import 'package:minechat/model/data/subscriptions/plan_feature.dart';

class FeatureRow extends StatelessWidget {
  final PlanFeature feature;
  final Color featureIconColor;

  const FeatureRow(
      {super.key, required this.feature, required this.featureIconColor});

  @override
  Widget build(BuildContext context) {
    final text = feature.label.isEmpty ? null : feature.label;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SvgPicture.asset(
            AppAssets.subscriptionFeatureTick,
            color: featureIconColor,
          ),
          const SizedBox(width: 10),
          if (text != null)
            Expanded(
              child: Text(
                text,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ),
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
