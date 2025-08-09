import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:minechat/controller/otp_controller/otp_controller.dart';
import 'package:minechat/core/constants/app_texts/app_texts.dart';
import 'package:minechat/core/utils/helpers/app_responsive/app_responsive.dart';
import 'package:minechat/core/utils/helpers/app_spacing/app_spacing.dart';
import 'package:minechat/core/widgets/app_button/app_large_button.dart';
import 'package:minechat/core/widgets/app_button/app_action_button.dart';
import 'package:minechat/core/widgets/otp/otp_input_boxes.dart';
import 'package:minechat/core/widgets/otp/otp_timer.dart';
import 'package:minechat/core/widgets/otp/otp_header.dart';

class OtpScreen extends StatelessWidget {
  const OtpScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(OtpController());

    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
            color: Colors.black,
            size: AppResponsive.iconSize(context, factor: 1.5),
          ),
          onPressed: () => Get.back(),
        ),
      ),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              padding: AppSpacing.all(context, factor: 2),
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight),
                child: IntrinsicHeight(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      OtpHeader(
                        title: AppTexts.otpHeaderTitle,
                        subtitle: AppTexts.otpHeaderSubTitle,
                        email: controller.email,
                      ),
                      AppSpacing.vertical(context, 0.03),
                      const OtpInputBoxes(),
                      AppSpacing.vertical(context, 0.01),
                      Padding(
                        padding: AppSpacing.symmetric(context, h: 0.01, v: 0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const OtpTimer(),
                            AppActionButton(
                              label: AppTexts.otpPasteButton,
                              isPrimary: true,
                              onTap: () => controller.pasteFromClipboard(),
                            ),
                          ],
                        ),
                      ),
                      const Spacer(),
                      Padding(
                        padding: AppSpacing.symmetric(context, v: 0.05, h: 0),
                        child: Column(
                          children: [
                            Obx(() => AppLargeButton(
                                  label: controller.isVerifying.value
                                      ? 'Verifying...'
                                      : AppTexts.otpVerifyCodeButton,
                                  isEnabled: controller.isButtonEnabled.value &&
                                      !controller.isVerifying.value,
                                  isLoading: controller.isVerifying.value,
                                  onTap: controller.verifyOtp,
                                )),
                            AppSpacing.vertical(context, 0.015),
                            Center(
                              child: AppActionButton(
                                label: AppTexts.otpResendCodeButton,
                                onTap: controller.resendOtp,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
