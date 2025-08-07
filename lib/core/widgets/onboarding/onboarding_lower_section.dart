import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:minechat/core/constants/app_assets/app_assets.dart';
import 'package:minechat/core/constants/app_colors/app_colors.dart';
import 'package:minechat/core/utils/extensions/app_gradient/app_gradient_extension.dart';
import 'package:minechat/core/widgets/app_button/app_button.dart';
import 'package:minechat/core/utils/helpers/app_responsive/app_responsive.dart';
import 'package:minechat/core/utils/helpers/app_spacing/app_spacing.dart';
import 'package:minechat/core/utils/helpers/app_styles/app_text_styles.dart';

class OnboardingLowerSection extends StatelessWidget {
  final String title;
  final String subtitle;
  final String footerText;

  // ✅ Primary button (Required for Google OR Login)
  final String? primaryButtonLabel;
  final VoidCallback? onPrimaryPressed;
  final String? primarySvgIcon;
  final bool isPrimaryLoading;

  // ✅ Secondary button (Optional for Signup)
  final String? secondaryButtonLabel;
  final VoidCallback? onSecondaryPressed;
  final bool isSecondaryLoading;

  const OnboardingLowerSection({
    super.key,
    required this.title,
    required this.subtitle,
    required this.footerText,
    this.primaryButtonLabel,
    this.onPrimaryPressed,
    this.primarySvgIcon,
    this.isPrimaryLoading = false,
    this.secondaryButtonLabel,
    this.onSecondaryPressed,
    this.isSecondaryLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(AppResponsive.radius(context, factor: 4)),
          topRight: Radius.circular(AppResponsive.radius(context, factor: 4)),
        ),
      ).withAppGradient,
      child: ClipRRect(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(AppResponsive.radius(context, factor: 4)),
          topRight: Radius.circular(AppResponsive.radius(context, factor: 4)),
        ),
        child: Stack(
          children: [
            Positioned.fill(
              child: SvgPicture.asset(
                AppAssets.gridPatternLower,
                fit: BoxFit.cover,
              ),
            ),
            Padding(
              padding: AppSpacing.all(context, factor: 2),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AppSpacing.vertical(context, 0.03),

                  // 🔤 Title
                  Text(
                    title,
                    textAlign: TextAlign.center,
                    style: AppTextStyles.heading(context).copyWith(
                      fontSize: AppResponsive.scaleSize(context, 24),
                      fontWeight: FontWeight.w600,
                      color: AppColors.white,
                    ),
                  ),

                  AppSpacing.vertical(context, 0.007),

                  // 🔤 Subtitle
                  Text(
                    subtitle,
                    textAlign: TextAlign.center,
                    style: AppTextStyles.bodyText(context).copyWith(
                      fontSize: AppResponsive.scaleSize(context, 14),
                      fontWeight: FontWeight.w400,
                      color: AppColors.white,
                    ),
                  ),

                  AppSpacing.vertical(context, 0.05),

                  // 🔘 Buttons
                  if (primaryButtonLabel != null &&
                      secondaryButtonLabel != null) ...[
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: AppSmallButton(
                            label: primaryButtonLabel!,
                            onPressed: onPrimaryPressed ?? () {},
                            isLoading: isPrimaryLoading,
                          ),
                        ),
                        AppSpacing.horizontal(context, 0.02),
                        Expanded(
                          child: AppSmallButton(
                            label: secondaryButtonLabel!,
                            onPressed: onSecondaryPressed ?? () {},
                            isLoading: isSecondaryLoading,
                          ),
                        ),
                      ],
                    )
                  ] else if (primaryButtonLabel != null) ...[
                    Center(
                      child: AppSmallButton(
                        label: primaryButtonLabel!,
                        width: double.infinity,
                        onPressed: onPrimaryPressed ?? () {},
                        svgIconPath: primarySvgIcon,
                        isLoading: isPrimaryLoading,
                      ),
                    )
                  ],

                  AppSpacing.vertical(context, 0.02),

                  // 🔻 Footer
                  Center(
                    child: Padding(
                      padding: AppSpacing.symmetric(context, h: 0.15, v: 0),
                      child: Text(
                        footerText,
                        textAlign: TextAlign.center,
                        style: AppTextStyles.poppinsRegular(context).copyWith(
                          color: Colors.white,
                          fontSize: AppResponsive.scaleSize(context, 12),
                        ),
                      ),
                    ),
                  ),

                  const Spacer(),

                  // ⬜ Bottom Indicator
                  Center(
                    child: Container(
                      width: AppResponsive.screenWidth(context) * 0.35,
                      height: AppResponsive.screenHeight(context) * 0.006,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(
                          AppResponsive.radius(context),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
