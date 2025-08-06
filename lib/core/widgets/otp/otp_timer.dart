import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:minechat/controller/otp_controller/otp_controller.dart';
import 'package:minechat/core/utils/helpers/app_responsive/app_responsive.dart';
import 'package:minechat/core/utils/helpers/app_styles/app_text_styles.dart';

class OtpTimer extends StatelessWidget {
  const OtpTimer({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<OtpController>();
    return Obx(() => Text(
          controller.formattedTime,
          style: AppTextStyles.bodyText(context).copyWith(
              fontSize: AppResponsive.scaleSize(context, 16),
              fontWeight: FontWeight.w600),
        ));
  }
}
