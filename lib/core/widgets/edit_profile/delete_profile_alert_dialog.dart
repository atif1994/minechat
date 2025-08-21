import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:minechat/core/utils/helpers/app_responsive/app_responsive.dart';
import 'package:minechat/core/utils/helpers/app_spacing/app_spacing.dart';
import 'package:minechat/core/utils/helpers/app_styles/app_text_styles.dart';
import 'package:minechat/core/widgets/app_button/app_large_button.dart';
import 'package:minechat/core/constants/app_assets/app_assets.dart';

class DeleteProfileAlertDialog extends StatelessWidget {
  final VoidCallback onConfirm;
  final VoidCallback? onCancel;
  final String title;
  final String message;
  final String confirmLabel;
  final String cancelLabel;

  const DeleteProfileAlertDialog({
    super.key,
    required this.onConfirm,
    this.onCancel,
    this.title = 'Delete profile?',
    this.message =
        'Deleting your profile will remove all of your business data.',
    this.confirmLabel = 'Delete',
    this.cancelLabel = 'Cancel',
  });

  static Future<T?> show<T>({
    required VoidCallback onConfirm,
    VoidCallback? onCancel,
    String title = 'Delete profile?',
    String message =
        'Deleting your profile will remove all of your business data.',
    String confirmLabel = 'Delete',
    String cancelLabel = 'Cancel',
    Color barrier = const Color(0x99000000),
    bool barrierDismissible = true,
  }) {
    return Get.dialog<T>(
      DeleteProfileAlertDialog(
        onConfirm: onConfirm,
        onCancel: onCancel,
        title: title,
        message: message,
        confirmLabel: confirmLabel,
        cancelLabel: cancelLabel,
      ),
      barrierColor: barrier,
      barrierDismissible: barrierDismissible,
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final iconPath = isDark
        ? AppAssets.accountDeleteProfileDark
        : AppAssets.accountDeleteProfileLight;

    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius:
            BorderRadius.circular(AppResponsive.radius(context, factor: 2)),
      ),
      child: Padding(
        padding: AppSpacing.all(context, factor: 2),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SvgPicture.asset(iconPath,
                width: AppResponsive.scaleSize(context, 80),
                height: AppResponsive.scaleSize(context, 80)),
            AppSpacing.vertical(context, 0.012),
            Text(
              title,
              style: AppTextStyles.bodyText(context).copyWith(
                fontWeight: FontWeight.w600,
                fontSize: AppResponsive.scaleSize(context, 18),
              ),
            ),
            AppSpacing.vertical(context, 0.006),
            Text(
              message,
              textAlign: TextAlign.center,
              style: AppTextStyles.bodyText(context).copyWith(
                fontSize: AppResponsive.scaleSize(context, 14),
                color: isDark ? Colors.white70 : const Color(0xFF767C8C),
                fontWeight: FontWeight.w400,
              ),
            ),
            AppSpacing.vertical(context, 0.02),
            AppLargeButton(
              label: confirmLabel,
              onTap: () {
                Get.back();
                onConfirm();
              },
            ),
            AppSpacing.vertical(context, 0.012),
            AppLargeButton(
              label: cancelLabel,
              onTap: () {
                Get.back();
                onCancel?.call();
              },
              useGradient: false,
              solidColor: isDark ? Color(0XFF1D1D1D) : Color(0XFFFFFFFF),
              borderColor: isDark
                  ? Color(0XFFFFFF1F).withValues(alpha: 0.12)
                  : Color(0XFFF0F1F5),
              textColor: isDark ? Color(0xFFFFFFFF) : Color(0xFF0A0A0A),
            ),
          ],
        ),
      ),
    );
  }
}
