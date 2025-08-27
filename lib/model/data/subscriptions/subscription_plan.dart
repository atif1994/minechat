import 'dart:ui';

import 'package:minechat/model/data/subscriptions/plan_label_link.dart';
import 'plan_feature.dart';
import 'billing_cycle.dart';

class PlanPrice {
  final String monthly;
  final String yearly;

  const PlanPrice({required this.monthly, required this.yearly});

  String text(BillingCycle cycle) =>
      cycle == BillingCycle.monthly ? monthly : yearly;
}

enum PlanButtonStyle { gradient, black, disabled }

class SubscriptionPlan {
  final String id;
  final String title;
  final String subtitle;
  final PlanPrice price;
  final String per;
  final List<PlanFeature> features;

  final List<PlanLabelLink> labelLinks;
  final Color? linkTextColor;

  final String ctaText;
  final PlanButtonStyle ctaStyle;
  final bool highlighted;
  final String? badge;

  final String? monthlyPriceId;
  final String? yearlyPriceId;

  const SubscriptionPlan({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.price,
    required this.per,
    required this.features,
    required this.ctaText,
    required this.ctaStyle,
    this.highlighted = false,
    this.badge,
    this.monthlyPriceId,
    this.yearlyPriceId,
    List<PlanLabelLink>? labelLinks,
    this.linkTextColor,
  }) : labelLinks = labelLinks ?? const [];
}
