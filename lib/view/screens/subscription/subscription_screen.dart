import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:minechat/controller/subscription_controller/subscription_controller.dart';
import 'package:minechat/controller/theme_controller/theme_controller.dart';
import 'package:minechat/core/constants/app_colors/app_colors.dart';
import 'package:minechat/core/utils/helpers/app_responsive/app_responsive.dart';
import 'package:minechat/core/utils/helpers/app_spacing/app_spacing.dart';
import 'package:minechat/core/utils/helpers/app_styles/app_text_styles.dart';
import 'package:minechat/core/widgets/subscription/plan_card.dart';
import 'package:minechat/core/widgets/subscription/plan_toggle.dart';
import 'package:minechat/model/data/subscriptions/billing_cycle.dart';

class SubscriptionScreen extends StatelessWidget {
  const SubscriptionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<SubscriptionController>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Subscription'),
        centerTitle: false,
      ),
      body: Obx(
        () => SingleChildScrollView(
          padding: AppSpacing.symmetric(context, h: 0.04, v: 0.02),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                  child: Text("Upgrade Your Plan",
                      style: AppTextStyles.headline(context).copyWith(
                          fontSize: AppResponsive.scaleSize(context, 24),
                          fontWeight: FontWeight.w600))),
              AppSpacing.vertical(context, 0.015),
              PlanToggle(
                value: controller.selectedCycle.value,
                onChanged: (BillingCycle v) => controller.toggleCycle(v),
              ),
              AppSpacing.vertical(context, 0.02),

              // Cards (stacked vertical like your screenshot)
              ...controller.plans.map(
                (plan) => Padding(
                  padding: EdgeInsets.only(
                    bottom: AppResponsive.isMobile(context) ? 16 : 20,
                  ),
                  child: PlanCard(
                    plan: plan,
                    cycle: controller.selectedCycle.value,
                    onPressed: () => controller.onSelectPlan(plan),
                  ),
                ),
              ),
              if (controller.isLoading.value)
                const Center(
                    child: Padding(
                  padding: EdgeInsets.all(16.0),
                  child: CircularProgressIndicator(),
                )),
            ],
          ),
        ),
      ),
    );
  }
}
