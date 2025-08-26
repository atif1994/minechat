import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:minechat/controller/theme_controller/theme_controller.dart';
import 'package:minechat/core/constants/app_colors/app_colors.dart';
import 'package:minechat/core/utils/helpers/app_responsive/app_responsive.dart';
import 'package:minechat/core/utils/helpers/app_spacing/app_spacing.dart';
import 'package:minechat/core/utils/helpers/app_styles/app_text_styles.dart';
import 'package:minechat/model/data/subscriptions/billing_cycle.dart';
import 'package:minechat/model/data/subscriptions/subscription_plan.dart';
import 'feature_row.dart';

class PlanCard extends StatelessWidget {
  final SubscriptionPlan plan;
  final BillingCycle cycle;
  final VoidCallback onPressed;

  const PlanCard({
    super.key,
    required this.plan,
    required this.cycle,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    final themeController = Get.find<ThemeController>();
    final isDark = themeController.isDarkMode;
    final borderColor = plan.highlighted
        ? AppColors.primary
        : isDark
            ? Color(0XFF1D1D1D)
            : Color(0XFFEBEDF0);

    final priceText = plan.price.text(cycle);
    final width = AppResponsive.screenWidth(context);

    return Container(
      width: width,
      padding: AppSpacing.all(context, factor: .8),
      decoration: BoxDecoration(
        color: isDark ? Color(0XFF1D1D1D) : Color(0XFFFFFFFF),
        borderRadius:
            BorderRadius.circular(AppResponsive.radius(context, factor: 1.2)),
        border:
            Border.all(color: borderColor, width: plan.highlighted ? 1.2 : 1),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).shadowColor.withOpacity(.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header row (Title + optional badge)
          Row(
            children: [
              Text(plan.title,
                  style: AppTextStyles.bodyText(context).copyWith(
                      fontSize: AppResponsive.scaleSize(context, 16),
                      fontWeight: FontWeight.w500)),
              AppSpacing.horizontal(context, 0.02),
              if (plan.badge != null)
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFEDF1),
                    borderRadius: BorderRadius.circular(999),
                    border: Border.all(color: const Color(0xFFFF507D)),
                  ),
                  child: Text(
                    plan.badge!,
                    style: Theme.of(context).textTheme.labelMedium!.copyWith(
                          color: const Color(0xFFB4234D),
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                ),
            ],
          ),
          AppSpacing.vertical(context, 0.008),

          // Price line
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                priceText,
                style: AppTextStyles.heading(context).copyWith(
                    fontSize: AppResponsive.scaleSize(context, 36),
                    fontWeight: FontWeight.w800),
              ),
              AppSpacing.horizontal(context, 0.02),
              Text(
                plan.per,
                style: AppTextStyles.bodyText(context).copyWith(
                    fontSize: AppResponsive.scaleSize(context, 16),
                    fontWeight: FontWeight.w500,
                    color: Color(0XFF767C8C)),
              ),
            ],
          ),

          AppSpacing.vertical(context, 0.008),
          Text(
            plan.subtitle,
            style: AppTextStyles.bodyText(context).copyWith(
              fontSize: AppResponsive.scaleSize(context, 18),
              fontWeight: FontWeight.w400,
              color: Color(0XFF767C8C),
            ),
          ),
          AppSpacing.vertical(context, 0.014),

          // CTA Button
          _CtaButton(
              style: plan.ctaStyle, text: plan.ctaText, onPressed: onPressed),
          AppSpacing.vertical(context, 0.012),

          // Features
          ...plan.features
              .map((f) => FeatureRow(
                    feature: f,
                    featureIconColor: plan.highlighted
                        ? AppColors.primary
                        : isDark
                            ? Color(0XFFFFFFFF)
                            : Color(0XFF0A0A0A),
                  ))
              .toList(),
        ],
      ),
    );
  }
}

class _CtaButton extends StatelessWidget {
  final PlanButtonStyle style;
  final String text;
  final VoidCallback onPressed;

  const _CtaButton(
      {required this.style, required this.text, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    final themeController = Get.find<ThemeController>();
    final isDark = themeController.isDarkMode;
    final radius = BorderRadius.circular(12);

    if (style == PlanButtonStyle.disabled) {
      return SizedBox(
        width: double.infinity,
        height: 44,
        child: ElevatedButton(
          onPressed: null,
          style: ElevatedButton.styleFrom(
            backgroundColor: isDark
                ? Color(0XFFEBEDF0).withValues(alpha: .008)
                : Color(0XFFEBEDF0),
            disabledForegroundColor: Theme.of(context).disabledColor,
            shape: RoundedRectangleBorder(borderRadius: radius),
          ),
          child: Text(
            text,
            style: AppTextStyles.buttonText(context).copyWith(
              fontSize: AppResponsive.scaleSize(context, 18),
              fontWeight: FontWeight.w400,
              color: isDark ? Color(0XFFF0F1F5) : Color(0XFF767C8C),
            ),
          ),
        ),
      );
    }

    if (style == PlanButtonStyle.black) {
      return SizedBox(
          width: double.infinity,
          height: 44,
          child: ElevatedButton(
            onPressed: onPressed,
            style: ElevatedButton.styleFrom(
              backgroundColor: isDark ? Color(0XFFFFFFFF) : Color(0XFF0A0A0A),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: radius),
              elevation: 0,
            ),
            child: Text(
              text,
              style: AppTextStyles.buttonText(context).copyWith(
                fontSize: AppResponsive.scaleSize(context, 18),
                fontWeight: FontWeight.w400,
                color: isDark ? Color(0XFF0A0A0A) : Color(0XFFFFFFFF),
              ),
            ),
          ));
    }

    // Gradient (Plus)
    return SizedBox(
      width: double.infinity,
      height: 44,
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              AppColors.primary,
              AppColors.secondary,
              AppColors.tertiary,
            ],
            begin: Alignment.centerRight,
            end: Alignment.centerLeft,
          ),
          borderRadius: radius,
        ),
        child: ElevatedButton(
          onPressed: onPressed,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.transparent,
            shadowColor: Colors.transparent,
            shape: RoundedRectangleBorder(borderRadius: radius),
          ),
          child: Text(
            text,
            style: AppTextStyles.buttonText(context).copyWith(
              fontSize: AppResponsive.scaleSize(context, 18),
              fontWeight: FontWeight.w600,
              color: Color(0XFFFFFFFF),
            ),
          ),
        ),
      ),
    );
  }
}
