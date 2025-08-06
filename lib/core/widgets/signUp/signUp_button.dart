import 'package:flutter/material.dart';
import 'package:minechat/core/utils/extensions/app_gradient/app_gradient_extension.dart';
import 'package:minechat/core/utils/helpers/app_responsive/app_responsive.dart';
import 'package:minechat/core/utils/helpers/app_styles/app_text_styles.dart';

class SignupButton extends StatelessWidget {
  final String label;
  final VoidCallback onTap;

  const SignupButton({
    super.key,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: InkWell(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
          ).withAppGradient,
          alignment: Alignment.center,
          child: Text(label,
              style: AppTextStyles.buttonText(context)
                  .copyWith(fontSize: AppResponsive.scaleSize(context, 16))),
        ),
      ),
    );
  }
}
