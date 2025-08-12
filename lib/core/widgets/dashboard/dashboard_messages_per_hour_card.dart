import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:minechat/controller/dashboard_controller/dashboard_controlller.dart';
import 'package:minechat/core/utils/helpers/app_responsive/app_responsive.dart';
import 'package:minechat/core/utils/helpers/app_styles/app_text_styles.dart';
import 'package:minechat/core/widgets/dashboard/dashboard_right_arrow_icon.dart';
import 'package:minechat/core/widgets/dashboard/dashboard_section_container.dart';

class DashboardMessagesPerHourCard extends StatelessWidget {
  const DashboardMessagesPerHourCard({super.key});

  @override
  Widget build(BuildContext context) {
    final c = Get.find<DashboardController>();
    final iconSize = AppResponsive.scaleSize(context, 14);

    return DashboardSectionContainer(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title + external icon
          Row(
            children: [
              Expanded(
                child: Text('Message Received Per Hour',
                    style: AppTextStyles.bodyText(context).copyWith(
                      fontSize: AppResponsive.scaleSize(context, 14),
                      fontWeight: FontWeight.w400,
                      color: const Color(0xFF0A0A0A),
                    )),
              ),
              DashboardRightArrowIcon(onTapArrow: () {})
            ],
          ),
          SizedBox(height: AppResponsive.scaleSize(context, 12)),

          SizedBox(
            height: AppResponsive.scaleSize(context, 140),
            child: Obx(() {
              final spots = <FlSpot>[];
              for (var i = 0; i < c.hourly.length; i++) {
                spots.add(FlSpot(i.toDouble(), c.hourly[i].value));
              }

              return LineChart(
                LineChartData(
                  minY: 0,
                  gridData: FlGridData(show: false),
                  borderData: FlBorderData(show: false),
                  titlesData: FlTitlesData(
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 28,
                        interval: 5,
                        getTitlesWidget: (v, m) => Text(
                          v.toInt().toString(),
                          style: TextStyle(
                            fontSize: AppResponsive.scaleSize(context, 10),
                            color: const Color(0xFF9AA3AF),
                          ),
                        ),
                      ),
                    ),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 24,
                        interval: 1,
                        getTitlesWidget: (v, m) {
                          final i = v.toInt();
                          if (i >= 0 && i < c.hourly.length) {
                            return Text(
                              c.hourly[i].label,
                              style: TextStyle(
                                fontSize: AppResponsive.scaleSize(context, 10),
                                color: const Color(0xFF9AA3AF),
                              ),
                            );
                          }
                          return const SizedBox.shrink();
                        },
                      ),
                    ),
                    rightTitles:
                        AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    topTitles:
                        AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  ),
                  lineTouchData: LineTouchData(
                    handleBuiltInTouches: true,
                    touchTooltipData: LineTouchTooltipData(
                      getTooltipItems: (touched) => touched.map((e) {
                        final idx = e.spotIndex;
                        final label = c.hourly[idx].label;
                        final val = c.hourly[idx].value.toInt();
                        return LineTooltipItem('$val ($label)',
                            const TextStyle(color: Colors.white, fontSize: 12));
                      }).toList(),
                    ),
                  ),
                  lineBarsData: [
                    LineChartBarData(
                      isCurved: true,
                      barWidth: 3,
                      color: const Color(0xFF7A1E3B),
                      belowBarData: BarAreaData(
                        show: true,
                        gradient: LinearGradient(
                          colors: const [Color(0xFFB01D47), Color(0xFFB01D47)]
                              .map((c) => c.withOpacity(0.25))
                              .toList(),
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                        ),
                      ),
                      dotData: FlDotData(
                        show: true,
                      ),
                      spots: spots,
                    ),
                  ],
                ),
              );
            }),
          ),
        ],
      ),
    );
  }
}
