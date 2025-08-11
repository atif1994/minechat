import 'package:flutter/material.dart';
import 'package:minechat/core/constants/app_colors/app_colors.dart';
import 'package:minechat/core/utils/helpers/app_responsive/app_responsive.dart';
import 'package:minechat/core/utils/helpers/app_styles/app_text_styles.dart';

class HumanAIPercentage extends StatelessWidget {
  const HumanAIPercentage({
    super.key,
    required this.context,
    required this.label,
    required this.percent,
    required this.isAI,
  });

  final BuildContext context;
  final String label;
  final double percent;
  final bool isAI;

  @override
  Widget build(BuildContext context) {
    final boxSide = AppResponsive.scaleSize(context, 18);
    return Row(
      children: [
        Container(
          width: boxSide,
          height: boxSide,
          decoration: BoxDecoration(
            color: isAI ? const Color(0xFFB01D47) : const Color(0xFFB1B6BD),
            borderRadius: BorderRadius.circular(6),
            gradient: isAI
                ? LinearGradient(
                    colors: [
                      AppColors.primary,
                      AppColors.secondary,
                      AppColors.tertiary,
                    ],
                    begin: Alignment.bottomCenter,
                    end: Alignment.topCenter,
                  )
                : const LinearGradient(
                    colors: [Color(0xFFCACACA), Color(0xFF797979)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
          ),
        ),
        SizedBox(width: AppResponsive.scaleSize(context, 10)),
        Expanded(
          child: Text(label,
              style: AppTextStyles.bodyText(context).copyWith(
                fontSize: AppResponsive.scaleSize(context, 12),
                color: const Color(0xFF767C8C),
                fontWeight: FontWeight.w400,
              )),
        ),
        Text('${percent.toStringAsFixed(0)}%',
            style: AppTextStyles.bodyText(context).copyWith(
              fontSize: AppResponsive.scaleSize(context, 14),
              color: const Color(0xFF000000),
              fontWeight: FontWeight.w700,
            )),
      ],
    );
  }
}
