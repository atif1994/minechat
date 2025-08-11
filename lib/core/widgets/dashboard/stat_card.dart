import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:minechat/core/utils/helpers/app_responsive/app_responsive.dart';
import 'package:minechat/core/utils/helpers/app_spacing/app_spacing.dart';
import 'package:minechat/core/utils/helpers/app_styles/app_text_styles.dart';
import 'package:minechat/model/data/dashboard/stat_item.dart';

class StatCard extends StatelessWidget {
  final StatItem item;

  const StatCard({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
    final radius = AppResponsive.radius(context, factor: 1.1);
    final pad = AppResponsive.scaleSize(context, 8);
    final iconBox = AppResponsive.scaleSize(context, 36);
    final iconSize = AppResponsive.scaleSize(context, 18);

    // Parse "+18% from last week" → ("+18%", "from last week")
    final m = RegExp(r'([+\-]?\d+%)\s*(.*)$').firstMatch(item.deltaText.trim());
    final percentText = m?.group(1) ?? item.deltaText;
    final tailText = m?.group(2) ?? '';

    final Color positive = const Color(0xFF22C55E); // green
    final Color negative = const Color(0xFFE11D48); // red
    final Color subtle = const Color(0xFF9AA3AF); // grey

    return Container(
      padding: EdgeInsets.all(pad),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(radius),
        border: Border.all(color: const Color(0xFFE9EEF5)),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0A0A0A).withOpacity(0.03),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Row 1: icon chip + title
          Row(
            children: [
              Container(
                width: iconBox,
                height: iconBox,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: item.chipBgColor,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: SvgPicture.asset(
                  item.iconPath,
                  width: iconSize,
                  height: iconSize,
                  colorFilter: ColorFilter.mode(
                    item.chipIconColor,
                    BlendMode.srcIn,
                  ),
                ),
              ),
              AppSpacing.horizontal(context, 0.02),
              Expanded(
                child: Text(
                  item.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.bodyText(context).copyWith(
                    fontWeight: FontWeight.w600,
                    fontSize: AppResponsive.scaleSize(context, 14),
                    color: const Color(0xFF0A0A0A),
                  ),
                ),
              ),
            ],
          ),

          AppSpacing.vertical(context, 0.01),

          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Expanded(
                child: Text(
                  item.value, // e.g., "18 hours"
                  style: AppTextStyles.bodyText(context).copyWith(
                    fontSize: AppResponsive.scaleSize(context, 12),
                    fontWeight: FontWeight.w600,
                    color: Colors.black,
                    letterSpacing: 0.01,
                  ),
                ),
              ),
              RichText(
                text: TextSpan(
                  children: [
                    TextSpan(
                      text: percentText + ' ',
                      style: AppTextStyles.bodyText(context).copyWith(
                          fontWeight: FontWeight.w400,
                          fontSize: AppResponsive.scaleSize(context, 10),
                          color: item.isPositive ? positive : negative,
                          letterSpacing: 0.01),
                    ),
                    TextSpan(
                      text: tailText, // e.g., "from last week"
                      style: AppTextStyles.bodyText(context).copyWith(
                          fontSize: AppResponsive.scaleSize(context, 10),
                          fontWeight: FontWeight.w400,
                          color: subtle,
                          letterSpacing: 0.01),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
