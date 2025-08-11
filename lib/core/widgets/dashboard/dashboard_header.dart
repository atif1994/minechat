import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:minechat/controller/dashboard_controller/dashboard_controlller.dart';
import 'package:minechat/core/constants/app_assets/app_assets.dart';
import 'package:minechat/core/utils/helpers/app_spacing/app_spacing.dart';
import 'package:minechat/core/utils/helpers/app_styles/app_text_styles.dart';
import 'package:minechat/core/utils/helpers/app_responsive/app_responsive.dart';
import 'package:minechat/core/utils/extensions/app_gradient/app_gradient_extension.dart';

class DashboardHeader extends StatelessWidget {
  final VoidCallback? onDateTap;

  const DashboardHeader({super.key, this.onDateTap});

  @override
  Widget build(BuildContext context) {
    final c = Get.find<DashboardController>();

    final chipPad = EdgeInsets.symmetric(
      horizontal: AppResponsive.scaleSize(context, 10),
      vertical: AppResponsive.scaleSize(context, 6),
    );

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text('Dashboard',
            style: AppTextStyles.heading(context).copyWith(
              fontSize: AppResponsive.scaleSize(context, 20),
              fontWeight: FontWeight.w600,
              color: Colors.black,
            )),
        GestureDetector(
          onTap: onDateTap,
          child: Container(
            padding: chipPad,
            decoration: BoxDecoration(
              color: const Color(0xFFFFFFFF),
              borderRadius:
                  BorderRadius.circular(AppResponsive.radius(context)),
              border: Border.all(color: const Color(0xFFE9EEF1)),
            ),
            child: Row(
              children: [
                Obx(() => Text(
                      c.dateRange.value,
                      style: AppTextStyles.poppinsRegular(context).copyWith(
                        fontSize: AppResponsive.scaleSize(context, 12.5),
                        color: const Color(0xFF111827),
                        fontWeight: FontWeight.w600,
                      ),
                    )),
                AppSpacing.horizontal(context, 0.02),
                SvgPicture.asset(
                  AppAssets.dashboardCalendar,
                  width: AppResponsive.scaleSize(context, 16),
                  height: AppResponsive.scaleSize(context, 16),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
