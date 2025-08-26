import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:minechat/controller/theme_controller/theme_controller.dart';
import 'package:minechat/core/utils/extensions/app_gradient/app_gradient_extension.dart';
import 'package:minechat/core/utils/helpers/app_responsive/app_responsive.dart';
import 'package:minechat/core/utils/helpers/app_spacing/app_spacing.dart';
import 'package:minechat/core/utils/helpers/app_styles/app_text_styles.dart';
import 'package:minechat/model/data/subscriptions/billing_cycle.dart';

class PlanToggle extends StatelessWidget {
  final BillingCycle value;
  final ValueChanged<BillingCycle> onChanged;

  const PlanToggle({super.key, required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    final themeController = Get.find<ThemeController>();
    final isDark = themeController.isDarkMode;
    final double height = 42;
    final radius =
        BorderRadius.circular(AppResponsive.radius(context, factor: 3));

    Widget pill(String label, BillingCycle cycle, {bool filled = false}) {
      return Expanded(
        child: InkWell(
          onTap: () => onChanged(cycle),
          borderRadius: radius,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 220),
            height: height,
            alignment: Alignment.center,
            decoration: filled
                ? BoxDecoration(
                    borderRadius: radius,
                  ).withAppGradient
                : BoxDecoration(
                    borderRadius: radius,
                  ),
            child: Text(
              label,
              style: AppTextStyles.bodyText(context).copyWith(
                  fontSize: AppResponsive.scaleSize(context, 16),
                  fontWeight: FontWeight.w400,
                  color: isDark
                      ? Color(0XFFFFFFFF)
                      : filled
                          ? Color(0XFFFFFFFF)
                          : Color(0XFF242423)),
            ),
          ),
        ),
      );
    }

    final isYearly = value == BillingCycle.yearly;

    return Padding(
      padding: AppSpacing.symmetric(context, h: 0.15, v: 0),
      child: Container(
        padding: const EdgeInsets.all(3),
        decoration: BoxDecoration(
            color: isDark ? Color(0XFF1D1D1D) : Color(0XFFFFFFFF),
            borderRadius: radius,
            border: Border.all(
                color: isDark
                    ? Color(0XFFFFFFFF).withValues(alpha: .12)
                    : Color(0XFFEBEDF0))),
        child: Row(
          children: [
            pill("Monthly", BillingCycle.monthly, filled: !isYearly),
            pill("Yearly", BillingCycle.yearly, filled: isYearly),
          ],
        ),
      ),
    );
  }
}
