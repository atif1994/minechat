import 'plan_feature.dart';
import 'billing_cycle.dart';

class PlanPrice {
  final String monthly; // display-ready, e.g., "$99"
  final String yearly; // display-ready, e.g., "$990"
  const PlanPrice({required this.monthly, required this.yearly});

  String text(BillingCycle cycle) =>
      cycle == BillingCycle.monthly ? monthly : yearly;
}

enum PlanButtonStyle { gradient, black, disabled }

class SubscriptionPlan {
  final String id; // local id (also map to Stripe price later)
  final String title; // "Free" | "Plus" | "Pro"
  final String subtitle; // short blurb under price
  final PlanPrice price;
  final String per; // "/month" or "/year"
  final List<PlanFeature> features;

  final String ctaText; // "Get Free" | "Get Plus" | "Get Pro"
  final PlanButtonStyle ctaStyle;
  final bool highlighted; // red border for Plus "Popular"
  final String? badge; // "Popular"

  // Backend placeholders (to be filled when wiring Firebase/Stripe)
  final String? monthlyPriceId; // Stripe price id for monthly
  final String? yearlyPriceId; // Stripe price id for yearly

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
  });
}
