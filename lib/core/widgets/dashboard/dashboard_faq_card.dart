import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:minechat/controller/dashboard_controller/dashboard_controlller.dart';
import 'package:minechat/core/constants/app_assets/app_assets.dart';
import 'package:minechat/core/utils/helpers/app_responsive/app_responsive.dart';
import 'package:minechat/core/utils/helpers/app_spacing/app_spacing.dart';
import 'package:minechat/core/utils/helpers/app_styles/app_text_styles.dart';
import 'package:minechat/core/widgets/dashboard/dashboard_right_arrow_icon.dart';
import 'package:minechat/core/widgets/dashboard/dashboard_section_container.dart';

class DashboardFaqCard extends StatelessWidget {
  const DashboardFaqCard({super.key});

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
                child: Text('Frequently Asked Questions',
                    style: AppTextStyles.bodyText(context).copyWith(
                      fontSize: AppResponsive.scaleSize(context, 14),
                      fontWeight: FontWeight.w400,
                      color: const Color(0xFF0A0A0A),
                    )),
              ),
              DashboardRightArrowIcon(onTapArrow: () {})
            ],
          ),
          AppSpacing.vertical(context, 0.005),

          Obx(() {
            return Column(
              children: c.faqs
                  .map((f) => faqRow(context, f.question, f.count))
                  .toList(),
            );
          }),
        ],
      ),
    );
  }

  Widget faqRow(BuildContext context, String q, int count) {
    return Padding(
      padding: AppSpacing.symmetric(context, h: 0, v: 0.002),
      child: Row(
        children: [
          SvgPicture.asset(
            AppAssets.dashboardFaq,
            height: AppResponsive.scaleSize(context, 10),
            width: AppResponsive.scaleSize(context, 18),
            color: const Color(0xFF767C8C),
          ),
          AppSpacing.horizontal(context, 0.05),
          Expanded(
            child: Text(
              '$q($count)',
              style: AppTextStyles.bodyText(context).copyWith(
                fontSize: AppResponsive.scaleSize(context, 12),
                fontWeight: FontWeight.w400,
                color: const Color(0xFF767C8C),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
