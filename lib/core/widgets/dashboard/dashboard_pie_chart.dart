import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:minechat/core/constants/app_colors/app_colors.dart';
import 'package:minechat/core/utils/helpers/app_responsive/app_responsive.dart';

class DashboardPieChart extends StatelessWidget {
  final double aiValue;
  final double humanValue;

  const DashboardPieChart({
    super.key,
    required this.aiValue,
    required this.humanValue,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: AppResponsive.scaleSize(context, 100),
      height: AppResponsive.scaleSize(context, 100),
      child: PieChart(
        PieChartData(
          sectionsSpace: 0,
          centerSpaceRadius: AppResponsive.scaleSize(context, 28),
          startDegreeOffset: -90,
          sections: [
            PieChartSectionData(
              value: aiValue,
              showTitle: false,
              radius: AppResponsive.radius(context, factor: 2),
              gradient: LinearGradient(
                colors: const [
                  AppColors.primary,
                  AppColors.secondary,
                  AppColors.tertiary,
                ],
                begin: Alignment.bottomCenter,
                end: Alignment.topCenter,
              ),
            ),
            PieChartSectionData(
              value: humanValue,
              showTitle: false,
              radius: AppResponsive.radius(context, factor: 2),
              gradient: LinearGradient(
                colors: const [Color(0XFFCACACA), Color(0XFF797979)],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
