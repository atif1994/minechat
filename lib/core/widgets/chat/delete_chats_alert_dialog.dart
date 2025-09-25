import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:minechat/core/utils/helpers/app_responsive/app_responsive.dart';
import 'package:minechat/core/utils/helpers/app_spacing/app_spacing.dart';
import 'package:minechat/core/utils/helpers/app_styles/app_text_styles.dart';
import 'package:minechat/core/widgets/app_button/app_large_button.dart';

class DeleteChatsAlertDialog extends StatelessWidget {
  final String title;
  final String message;
  final String cancelLabel;
  final String confirmLabel;
  final VoidCallback onConfirm;
  final VoidCallback? onCancel;

  const DeleteChatsAlertDialog({
    super.key,
    this.title = 'Delete Chats',
    this.message = 'Are you sure you want to delete the selected chats? This action cannot be undone.',
    this.cancelLabel = 'Cancel',
    this.confirmLabel = 'Delete',
    required this.onConfirm,
    this.onCancel,
  });

  /// ✅ One-liner to present the dialog with a GREY barrier.
  static Future<T?> show<T>({
    required VoidCallback onConfirm,
    VoidCallback? onCancel,
    String title = 'Delete Chats',
    String message = 'Are you sure you want to delete the selected chats? This action cannot be undone.',
    String cancelLabel = 'Cancel',
    String confirmLabel = 'Delete',
    Color barrier = const Color(0x00000040), // ~60% black
    bool barrierDismissible = true,
  }) {
    return Get.dialog<T>(
      DeleteChatsAlertDialog(
        onConfirm: onConfirm,
        onCancel: onCancel,
        title: title,
        message: message,
        cancelLabel: cancelLabel,
        confirmLabel: confirmLabel,
      ),
      barrierDismissible: barrierDismissible,
      barrierColor: barrier,
      // ← makes the background grey/dimmed
      transitionCurve: Curves.easeOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    final radius = AppResponsive.radius(context, factor: 1.2);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(radius),
      ),
      child: Padding(
        padding: AppSpacing.all(context, factor: 1.2),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              title,
              style: AppTextStyles.bodyText(context).copyWith(
                fontWeight: FontWeight.w600,
                fontSize: AppResponsive.scaleSize(context, 18),
              ),
            ),
            AppSpacing.vertical(context, 0.01),
            Text(
              message,
              textAlign: TextAlign.center,
              style: AppTextStyles.bodyText(context).copyWith(
                fontSize: AppResponsive.scaleSize(context, 14),
                fontWeight: FontWeight.w600,
                color:
                    isDark ? const Color(0xFFFFFFFF) : const Color(0xFF222222),
              ),
            ),
            AppSpacing.vertical(context, 0.02),
            Row(
              children: [
                Expanded(
                  child: AppLargeButton(
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
                ),
                AppSpacing.horizontal(context, 0.02),
                Expanded(
                  child: AppLargeButton(
                    label: confirmLabel,
                    onTap: () {
                      Get.back();
                      onConfirm();
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
