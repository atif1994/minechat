// core/widgets/dialogs/delete_account_password_dialogue.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:iconsax/iconsax.dart';
import 'package:minechat/core/constants/app_assets/app_assets.dart';
import 'package:minechat/core/utils/helpers/app_responsive/app_responsive.dart';
import 'package:minechat/core/utils/helpers/app_spacing/app_spacing.dart';
import 'package:minechat/core/utils/helpers/app_styles/app_text_styles.dart';
import 'package:minechat/core/widgets/app_button/app_large_button.dart';

class DeleteAccountDialog extends StatefulWidget {
  final Future<void> Function(String password) onConfirm;
  final VoidCallback? onCancel;
  final String title;
  final String passwordLabel;

  const DeleteAccountDialog({
    super.key,
    required this.onConfirm,
    this.onCancel,
    this.title = 'Delete Account',
    this.passwordLabel = 'Password',
  });

  static Future<T?> show<T>({
    required Future<void> Function(String password) onConfirm,
    VoidCallback? onCancel,
    String title = 'Delete Account',
    String passwordLabel = 'Password',
    Color barrier = const Color(0x99000000),
    bool barrierDismissible = true,
  }) {
    return Get.dialog<T>(
      DeleteAccountDialog(
        onConfirm: onConfirm,
        onCancel: onCancel,
        title: title,
        passwordLabel: passwordLabel,
      ),
      barrierColor: barrier,
      barrierDismissible: barrierDismissible,
    );
  }

  @override
  State<DeleteAccountDialog> createState() => _DeleteAccountDialogState();
}

class _DeleteAccountDialogState extends State<DeleteAccountDialog> {
  final _passwordCtrl = TextEditingController();
  final _show = false.obs;
  final _loading = false.obs;
  String? _error;

  @override
  void dispose() {
    _passwordCtrl.dispose();
    _show.close();
    _loading.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final radius = AppResponsive.radius(context, factor: 2);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Dialog(
      shape:
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(radius)),
      child: Padding(
        padding: AppSpacing.all(context, factor: 2),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(widget.title,
                style: AppTextStyles.bodyText(context).copyWith(
                  fontWeight: FontWeight.w600,
                  fontSize: AppResponsive.scaleSize(context, 18),
                )),
            AppSpacing.vertical(context, 0.012),
            Text(widget.passwordLabel,
                style: AppTextStyles.bodyText(context).copyWith(
                  fontWeight: FontWeight.w500,
                  fontSize: AppResponsive.scaleSize(context, 14),
                )),
            AppSpacing.vertical(context, 0.006),
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(radius),
                border: Border.all(color: const Color(0xFFE5E7EB)),
                color: Theme.of(context).brightness == Brightness.dark
                    ? const Color(0xFF0A0A0A)
                    : const Color(0xFFFAFBFD),
              ),
              padding: EdgeInsets.symmetric(
                horizontal: AppResponsive.scaleSize(context, 12),
                vertical: AppResponsive.scaleSize(context, 4),
              ),
              child: Row(
                children: [
                  SvgPicture.asset(
                    AppAssets.signupIconPassword, // your lock icon
                    width: AppResponsive.scaleSize(context, 24),
                    height: AppResponsive.scaleSize(context, 24),
                    color: isDark ? Color(0XFFFFFFFF) : Color(0XFF222222),
                  ),
                  AppSpacing.horizontal(context, 0.02),
                  Expanded(
                    child: Obx(() => TextField(
                          controller: _passwordCtrl,
                          obscureText: !_show.value,
                          enableSuggestions: false,
                          autocorrect: false,
                          decoration: const InputDecoration(
                            isDense: true,
                            border: InputBorder.none,
                          ),
                        )),
                  ),
                  Obx(() => IconButton(
                        onPressed: () => _show.value = !_show.value,
                        icon: Icon(
                          _show.value ? Iconsax.eye : Iconsax.eye_slash,
                          color: isDark ? Color(0XFFFFFFFF) : Color(0XFF222222),
                        ),
                      )),
                ],
              ),
            ),
            if (_error != null) ...[
              AppSpacing.vertical(context, 0.006),
              Text(
                _error!,
                style: AppTextStyles.bodyText(context).copyWith(
                  color: Colors.red,
                  fontSize: AppResponsive.scaleSize(context, 12),
                ),
              ),
            ],
            AppSpacing.vertical(context, 0.02),
            Obx(() => AppLargeButton(
                  label: _loading.value ? 'Deleting...' : 'Delete',
                  onTap: () async {
                    final pwd = _passwordCtrl.text.trim();
                    if (pwd.isEmpty) {
                      setState(() => _error = 'Password required');
                      return;
                    }
                    _error = null;
                    _loading.value = true;
                    try {
                      await widget.onConfirm(pwd);
                    } catch (e) {
                      setState(() => _error = e.toString());
                    } finally {
                      _loading.value = false;
                    }
                  },
                )),
            AppSpacing.vertical(context, 0.012),
            AppLargeButton(
              label: 'Cancel',
              onTap: () {
                Get.back();
                widget.onCancel?.call();
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
