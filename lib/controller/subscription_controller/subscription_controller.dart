import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:minechat/core/services/subscription_service/suscription_service.dart';
import 'package:minechat/model/data/subscriptions/billing_cycle.dart';
import 'package:minechat/model/data/subscriptions/plan_feature.dart';
import 'package:minechat/model/data/subscriptions/subscription_plan.dart';

class SubscriptionController extends GetxController {
  final selectedCycle = BillingCycle.yearly.obs; // default matches screenshot
  final plans = <SubscriptionPlan>[].obs;
  final isLoading = false.obs;

  final _service = const SubscriptionService();

  @override
  void onInit() {
    super.onInit();
    _seedPlans();
  }

  void toggleCycle(BillingCycle cycle) {
    selectedCycle.value = cycle;
    update();
  }

  Future<void> onSelectPlan(SubscriptionPlan plan) async {
    if (plan.ctaStyle == PlanButtonStyle.disabled) return;
    isLoading.value = true;
    try {
      await _service.startCheckout(plan: plan, cycle: selectedCycle.value);
    } finally {
      isLoading.value = false;
    }
  }

  void onHelpTap() {
    _service.openBillingPortal(); // Placeholder target for "billing help"
  }

  void _seedPlans() {
    // Shared features list (all checks as seen in screenshots)
    List<PlanFeature> baseFeatures() => const [
          PlanFeature(label: "Everything in Plus", included: true),
          PlanFeature(
              label: "Unlimited access to advanced voice", included: true),
          PlanFeature(label: "Extended access to Sora video", included: true),
          PlanFeature(
              label: "Unlimited access to advanced voice", included: true),
        ];

    plans.assignAll([
      SubscriptionPlan(
        id: "free",
        title: "Pro",
        // matches screenshot label (Pro $0)
        subtitle:
            "Get the best of Minechat.ai with the highest level of access",
        price: const PlanPrice(monthly: "\$0", yearly: "\$0"),
        per: "USD/month",
        features: [
          ...baseFeatures(),
          PlanFeature(
            label: "Have an existing plan? See",
            linkText: "billing help",
            onTap: onHelpTap,
          ),
        ],
        ctaText: "Get Free",
        ctaStyle: PlanButtonStyle.disabled,
      ),
      SubscriptionPlan(
        id: "plus",
        title: "Plus",
        subtitle:
            "Just getting started? Our launch kit includes everything you need –",
        price: const PlanPrice(monthly: "\$99", yearly: "\$990"),
        per: "USD/month",
        features: [
          ...baseFeatures(),
          PlanFeature(
            label: "",
            linkText: "Limits apply",
            onTap: () {},
          ),
        ],
        ctaText: "Get Plus",
        ctaStyle: PlanButtonStyle.gradient,
        highlighted: true,
        badge: "Popular",
        monthlyPriceId: "price_plus_monthly",
        // to be replaced
        yearlyPriceId: "price_plus_yearly",
      ),
      SubscriptionPlan(
        id: "pro",
        title: "Pro",
        subtitle:
            "Get the best of Minechat.ai with the highest level of access",
        price: const PlanPrice(monthly: "\$200", yearly: "\$2000"),
        per: "USD/month",
        features: [
          ...baseFeatures(),
          PlanFeature(
            label: "Have an existing plan? See",
            linkText: "billing help",
            onTap: onHelpTap,
          ),
        ],
        ctaText: "Get Pro",
        ctaStyle: PlanButtonStyle.black,
        monthlyPriceId: "price_pro_monthly",
        // to be replaced
        yearlyPriceId: "price_pro_yearly",
      ),
    ]);
  }
}
