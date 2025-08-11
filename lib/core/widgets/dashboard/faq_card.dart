import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:minechat/controller/dashboard_controller/dashboard_controlller.dart';
import 'package:minechat/core/utils/helpers/app_responsive/app_responsive.dart';
import 'package:minechat/core/utils/helpers/app_styles/app_text_styles.dart';
import 'package:minechat/core/widgets/dashboard/section_container.dart';

class FaqCard extends StatelessWidget {
  const FaqCard({super.key});

  @override
  Widget build(BuildContext context) {
    final c = Get.find<DashboardController>();
    final iconSize = AppResponsive.scaleSize(context, 14);

    return SectionContainer(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title + external icon
          Row(
            children: [
              Expanded(
                child: Text('Frequently Asked Questions',
                    style: AppTextStyles.poppinsRegular(context).copyWith(
                      fontSize: AppResponsive.scaleSize(context, 13.5),
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF111827),
                    )),
              ),
              Container(
                width: iconSize * 1.6,
                height: iconSize * 1.6,
                decoration: BoxDecoration(
                  color: const Color(0xFFF3F6FC),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(Icons.north_east,
                    size: iconSize, color: const Color(0xFF9AA3AF)),
              ),
            ],
          ),
          SizedBox(height: AppResponsive.scaleSize(context, 10)),

          Obx(() {
            return Column(
              children: c.faqs
                  .map((f) => _faqRow(context, f.question, f.count))
                  .toList(),
            );
          }),
        ],
      ),
    );
  }

  Widget _faqRow(BuildContext context, String q, int count) {
    return Padding(
      padding:
          EdgeInsets.symmetric(vertical: AppResponsive.scaleSize(context, 6)),
      child: Row(
        children: [
          Icon(Icons.trending_up,
              size: AppResponsive.scaleSize(context, 16),
              color: const Color(0xFFB1B6BD)),
          SizedBox(width: AppResponsive.scaleSize(context, 10)),
          Expanded(
            child: Text(
              '$q($count)',
              style: AppTextStyles.poppinsRegular(context).copyWith(
                fontSize: AppResponsive.scaleSize(context, 12.5),
                color: const Color(0xFF4B5563),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
