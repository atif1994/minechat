import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:minechat/controller/dashboard_controller/dashboard_controlller.dart';
import 'package:minechat/core/constants/app_assets/app_assets.dart';
import 'package:minechat/core/utils/helpers/app_responsive/app_responsive.dart';
import 'package:minechat/core/utils/helpers/app_spacing/app_spacing.dart';
import 'package:minechat/core/utils/helpers/app_styles/app_text_styles.dart';
import 'package:minechat/core/widgets/dashboard/gradient_progress_bar.dart';
import 'package:minechat/core/widgets/dashboard/human_ai_percentage.dart';
import 'package:minechat/core/widgets/dashboard/section_container.dart';

class MessagesSentCard extends StatelessWidget {
  const MessagesSentCard({super.key});

  @override
  Widget build(BuildContext context) {
    final c = Get.find<DashboardController>();
    final iconSize = AppResponsive.scaleSize(context, 6);

    return SectionContainer(
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
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF111827),
                    )),
              ),
              Container(
                width: iconSize * 3.2,
                height: iconSize * 3.2,
                decoration: BoxDecoration(
                  color: const Color(0xFFF4F6FC),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Padding(
                  padding: AppSpacing.all(context, factor: 0.6),
                  child: SvgPicture.asset(
                    AppAssets.dashboardArrowRightUp,
                    height: iconSize,
                    width: iconSize,
                  ),
                ),
              ),
            ],
          ),
          AppSpacing.vertical(context, 0.01),

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
                      HumanAIPercentage(
                          context: context,
                          label: 'Human',
                          percent: human,
                          isAI: false),
                      AppSpacing.vertical(context, 0.01),
                      GradientProgressBar(percent: human, useGradient: false),
                      AppSpacing.vertical(context, 0.01),
                      HumanAIPercentage(
                          context: context,
                          label: 'AI',
                          percent: ai,
                          isAI: true),
                      AppSpacing.vertical(context, 0.01),
                      GradientProgressBar(percent: 70, useGradient: true),
                    ],
                  ),
                ),
                SizedBox(width: AppResponsive.scaleSize(context, 12)),

                // RIGHT: donut
                SizedBox(
                  width: AppResponsive.scaleSize(context, 100),
                  height: AppResponsive.scaleSize(context, 100),
                  child: PieChart(
                    PieChartData(
                      sectionsSpace: 4,
                      centerSpaceRadius: AppResponsive.scaleSize(context, 28),
                      startDegreeOffset: -90,
                      sections: [
                        PieChartSectionData(
                          value: ai,
                          color: const Color(0xFFB01D47),
                          showTitle: false,
                          radius: AppResponsive.scaleSize(context, 14),
                        ),
                        PieChartSectionData(
                          value: human,
                          color: const Color(0xFFC7CBD1),
                          showTitle: false,
                          radius: AppResponsive.scaleSize(context, 14),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            );
          }),
        ],
      ),
    );
  }
}
