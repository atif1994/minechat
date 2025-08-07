import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:minechat/controller/otp_controller/otp_controller.dart';
import 'package:minechat/core/constants/app_colors/app_colors.dart';
import 'package:minechat/core/utils/extensions/app_gradient/app_gradient_extension.dart';
import 'package:minechat/core/utils/helpers/app_responsive/app_responsive.dart';
import 'package:minechat/core/utils/helpers/app_spacing/app_spacing.dart';
import 'package:minechat/core/utils/helpers/app_styles/app_text_styles.dart';

class OtpInputBoxes extends StatelessWidget {
  const OtpInputBoxes({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<OtpController>();

    return Obx(() => Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: List.generate(6, (index) {
            final value = controller.otp[index];
            final focusNode = controller.focusNodes[index];
            final textController = controller.textControllers[index];

            return Container(
              padding: AppSpacing.padding(context)*0.15,
              decoration: focusNode.hasFocus
                  ? BoxDecoration(
                      borderRadius:
                          BorderRadius.circular(AppResponsive.radius(context)),
                    ).withAppGradient
                  : BoxDecoration(
                      border:
                          Border.all(color: Color(0xffebedf0), width: 0.5),
                      borderRadius:
                          BorderRadius.circular(AppResponsive.radius(context)),
                    ),
              child: Container(
                width: AppResponsive.screenWidth(context) * 0.13,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius:
                      BorderRadius.circular(AppResponsive.radius(context)),
                ),
                child: RawKeyboardListener(
                  focusNode: FocusNode(),
                  onKey: (event) {
                    if (event is RawKeyDownEvent &&
                        event.logicalKey == LogicalKeyboardKey.backspace) {
                      controller.handleBackspace(index);
                    }
                  },
                  child: TextField(
                    focusNode: focusNode,
                    controller: textController,
                    keyboardType: TextInputType.number,
                    textAlign: TextAlign.center,
                    maxLength: 1,
                    onChanged: (val) {
                      if (val.isNotEmpty) {
                        controller.onOtpChanged(index, val);
                        if (index < 5) {
                          controller.focusNodes[index + 1].requestFocus();
                        } else {
                          FocusScope.of(context).unfocus();
                        }
                      } else {
                        controller.onOtpChanged(index, "");
                      }
                    },
                    style: AppTextStyles.headline(context).copyWith(
                      fontSize: AppResponsive.scaleSize(context, 24),
                      fontWeight: FontWeight.w600,
                      color: AppColors.black,
                    ),
                    decoration: InputDecoration(
                      counterText: "",
                      hintText: value.isEmpty ? "0" : "",
                      hintStyle: AppTextStyles.bodyText(context).copyWith(
                        color: Colors.grey,
                        fontWeight: FontWeight.w500,
                        fontSize: AppResponsive.scaleSize(context, 22),
                      ),
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.zero,
                    ),
                  ),
                ),
              ),
            );
          }),
        ));
  }
}
