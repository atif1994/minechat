import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:minechat/core/services/url_launcher_service.dart';
import 'package:minechat/core/utils/helpers/app_responsive/app_responsive.dart';
import 'package:minechat/core/utils/helpers/app_styles/app_text_styles.dart';
import 'package:minechat/core/utils/helpers/app_spacing/app_spacing.dart';
import 'package:minechat/core/utils/extensions/app_gradient/app_gradient_extension.dart';

class LoginFooter extends StatelessWidget {
  final String firstNormalText;
  final String firstGestureText;
  final String secondNormalText;
  final String secondGestureText;

  const LoginFooter(
      {super.key,
      required this.firstNormalText,
      required this.firstGestureText,
      required this.secondNormalText,
      required this.secondGestureText});

  @override
  Widget build(BuildContext context) {
    final base = AppTextStyles.bodyText(context).copyWith(
      fontSize: AppResponsive.scaleSize(context, 14),
      color: const Color(0xFF767C8C),
      fontWeight: FontWeight.w400,
    );

    return Padding(
      padding: AppSpacing.symmetric(context, h: 0.0, v: 0.0),
      child: Center(
        child: Wrap(
          alignment: WrapAlignment.center,
          runAlignment: WrapAlignment.center,
          children: [
            Text(firstNormalText, style: base),
            GestureDetector(
              onTap: () async {
                final bool launched = await UrlLauncherService.launchTermsAndConditions();
                if (!launched) {
                  // Show a simple snackbar instead of dialog
                  Get.snackbar(
                    'Cannot Open Link',
                    'Please copy this URL and open in your browser: https://www.minechat.ai/terms.html',
                    duration: const Duration(seconds: 5),
                    backgroundColor: Colors.orange,
                    colorText: Colors.white,
                  );
                }
              },
              child: Text(firstGestureText, style: base).withAppGradient(),
            ),
            Text(secondNormalText, style: base),
            GestureDetector(
              onTap: () async {
                final bool launched = await UrlLauncherService.launchPrivacyPolicy();
                if (!launched) {
                  // Show a simple snackbar instead of dialog
                  Get.snackbar(
                    'Cannot Open Link',
                    'Please copy this URL and open in your browser: https://www.minechat.ai/privacy.html',
                    duration: const Duration(seconds: 5),
                    backgroundColor: Colors.orange,
                    colorText: Colors.white,
                  );
                }
              },
              child: Text(secondGestureText, style: base).withAppGradient(),
            ),
          ],
        ),
      ),
    );
  }
}
