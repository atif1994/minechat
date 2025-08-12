import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:minechat/controller/dashboard_controller/dashboard_controlller.dart';
import 'package:minechat/core/utils/helpers/app_responsive/app_responsive.dart';
import 'dashboard_stat_card.dart';

class DashboardStatGrid extends StatelessWidget {
  const DashboardStatGrid({super.key});

  @override
  Widget build(BuildContext context) {
    final c = Get.find<DashboardController>();
    final gap = AppResponsive.scaleSize(context, 10);

    return Obx(() {
      return GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: c.stats.length,
        padding: EdgeInsets.zero,
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          mainAxisSpacing: gap,
          crossAxisSpacing: gap,
          childAspectRatio: 1.9,
        ),
        itemBuilder: (_, i) => DashboardStatCard(item: c.stats[i]),
      );
    });
  }
}
