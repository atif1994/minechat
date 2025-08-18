import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:minechat/controller/dashboard_controller/dashboard_controlller.dart';
import 'package:minechat/core/utils/helpers/app_responsive/app_responsive.dart';
import 'package:minechat/core/utils/helpers/app_spacing/app_spacing.dart';
import 'package:minechat/core/utils/helpers/app_styles/app_text_styles.dart';
import 'package:minechat/core/widgets/dashboard/dashboard_gradient_progress_bar.dart';
import 'package:minechat/core/widgets/dashboard/dashboard_human_ai_percentage.dart';
import 'package:minechat/core/widgets/dashboard/dashboard_pie_chart.dart';
import 'package:minechat/core/widgets/dashboard/dashboard_right_arrow_icon.dart';
import 'package:minechat/core/widgets/dashboard/dashboard_section_container.dart';

class DashboardMessagesSentCard extends StatelessWidget {
  const DashboardMessagesSentCard({super.key});

  @override
  Widget build(BuildContext context) {
    final c = Get.find<DashboardController>();

    return DashboardSectionContainer(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title + external icon
          Row(
            children: [
              Expanded(
                child: Text('Messages Sent',
                    style: AppTextStyles.bodyText(context).copyWith(
                      fontSize: AppResponsive.scaleSize(context, 14),
                      fontWeight: FontWeight.w400,
                      color: const Color(0xFF0A0A0A),
                    )),
              ),
              DashboardRightArrowIcon(onTapArrow: () {}),
            ],
          ),
          AppSpacing.vertical(context, 0.005),

          // Left legend + bars vs right donut
          Obx(() {
            final human = c.humanPercent.value;
            final ai = c.aiPercent;

            return Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // LEFT: legend & bars
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      DashboardHumanAIPercentage(
                          context: context,
                          label: 'Human',
                          percent: human,
                          isAI: false),
                      AppSpacing.vertical(context, 0.01),
                      DashboardProgressBar(percent: human, useGradient: false),
                      AppSpacing.vertical(context, 0.01),
                      DashboardHumanAIPercentage(
                          context: context,
                          label: 'AI',
                          percent: ai,
                          isAI: true),
                      AppSpacing.vertical(context, 0.01),
                      DashboardProgressBar(percent: 70, useGradient: true),
                    ],
                  ),
                ),
                AppSpacing.horizontal(context, 0.1),

                // RIGHT: PieChart
                DashboardPieChart(
                  aiValue: ai,
                  humanValue: human,
                )
              ],
            );
          }),
        ],
      ),
    );
  }
}
