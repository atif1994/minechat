import 'package:flutter/material.dart';
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
              onTap: () {
                // TODO: open T&C page
              },
              child: Text(firstGestureText, style: base).withAppGradient(),
            ),
            Text(secondNormalText, style: base),
            GestureDetector(
              onTap: () {
                // TODO: open Privacy Policy page
              },
              child: Text(secondGestureText, style: base).withAppGradient(),
            ),
          ],
        ),
      ),
    );
  }
}
