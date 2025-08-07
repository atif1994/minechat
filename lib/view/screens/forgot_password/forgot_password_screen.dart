import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:minechat/core/constants/app_assets/app_assets.dart';
import 'package:minechat/core/constants/app_texts/app_texts.dart';
import 'package:minechat/core/utils/helpers/app_responsive/app_responsive.dart';
import 'package:minechat/core/utils/helpers/app_spacing/app_spacing.dart';
import 'package:minechat/core/widgets/app_button/app_large_button.dart';
import 'package:minechat/core/widgets/forgot_password/forgot_password_header.dart';
import 'package:minechat/core/widgets/signUp/signUp_textfield.dart';

// ... (your existing imports)
import 'package:minechat/controller/forgot_password/forgot_password_controller.dart';

class ForgotPasswordScreen extends StatelessWidget {
  const ForgotPasswordScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(ForgotPasswordController());

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
                      ForgotPasswordHeader(
                        title: AppTexts.forgotPasswordHeaderTitle,
                        subtitle: AppTexts.forgotPasswordHeaderSubTitle,
                      ),
                      AppSpacing.vertical(context, 0.03),
                      SignupTextField(
                        label: AppTexts.signupEmailLabel,
                        hintText: AppTexts.dummyEmailText,
                        prefixIcon: AppAssets.signupIconEmail,
                        controller: controller.emailCtrl,
                        errorText: controller.emailError,
                        onChanged: controller.validateEmail,
                      ),
                      const Spacer(),
                      Padding(
                        padding: AppSpacing.symmetric(context, v: 0.05, h: 0),
                        child: AppLargeButton(
                          label: AppTexts.forgotPasswordButton,
                          onTap: controller.submit,
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
