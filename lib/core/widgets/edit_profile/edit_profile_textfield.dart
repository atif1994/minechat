import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:minechat/core/constants/app_colors/app_colors.dart';
import 'package:minechat/core/utils/helpers/app_responsive/app_responsive.dart';
import 'package:minechat/core/utils/helpers/app_spacing/app_spacing.dart';
import 'package:minechat/core/utils/helpers/app_styles/app_text_styles.dart';

/// Edit-profile text field that ALWAYS shows the inline label (top-left inside),
/// with value below it. Auto-saves on blur via onFocusLost.
/// Only the error line is reactive when an RxString is provided.
class EditProfileTextField extends StatefulWidget {
  final String label;
  final TextEditingController controller;
  final bool readOnly;
  final bool obscureText;
  final RxString? errorText;
  final TextInputType keyboardType;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onFocusLost;

  const EditProfileTextField({
    super.key,
    required this.label,
    required this.controller,
    this.readOnly = false,
    this.obscureText = false,
    this.errorText,
    this.keyboardType = TextInputType.text,
    this.onChanged,
    this.onFocusLost,
  });

  @override
  State<EditProfileTextField> createState() => _EditProfileTextFieldState();
}

class _EditProfileTextFieldState extends State<EditProfileTextField> {
  late final FocusNode _focusNode;
  late String _lastSaved;

  Color _borderColor(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return isDark ? const Color(0xFF3A3A3A) : const Color(0xFFEBEDF0);
  }

  Color _fillColor(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return isDark ? const Color(0XFF0A0A0A) : const Color(0xFFFAFBFD);
  }

  Color _labelColor(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return isDark ? const Color(0xFF8D98AF) : const Color(0xFF8D98AF);
  }

  @override
  void initState() {
    super.initState();
    _focusNode = FocusNode();
    _lastSaved = widget.controller.text;

    _focusNode.addListener(() {
      if (!_focusNode.hasFocus &&
          widget.onFocusLost != null &&
          !widget.readOnly) {
        final val = widget.controller.text.trim();
        if (val != _lastSaved) {
          _lastSaved = val;
          widget.onFocusLost!(val);
        }
      }
    });
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final radius = AppResponsive.radius(context);
    final vPad = AppResponsive.scaleSize(context, 12);
    final hPad = AppResponsive.scaleSize(context, 14);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Custom container mimicking your card field
        Container(
          decoration: BoxDecoration(
            color: _fillColor(context),
            borderRadius: BorderRadius.circular(radius),
            border: Border.all(color: _borderColor(context), width: 1),
          ),
          padding: EdgeInsets.symmetric(vertical: vPad, horizontal: hPad),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ALWAYS visible inline label
              Text(
                widget.label,
                style: AppTextStyles.bodyText(context).copyWith(
                  fontSize: AppResponsive.scaleSize(context, 12),
                  fontWeight: FontWeight.w500,
                  color: _labelColor(context),
                ),
              ),

              // Bare TextField (no Material borders), value text
              TextField(
                controller: widget.controller,
                focusNode: _focusNode,
                readOnly: widget.readOnly,
                obscureText: widget.obscureText,
                keyboardType: widget.keyboardType,
                onChanged: widget.onChanged,
                onSubmitted: widget.readOnly
                    ? null
                    : (val) {
                        if (widget.onFocusLost != null) {
                          final v = val.trim();
                          if (v != _lastSaved) {
                            _lastSaved = v;
                            widget.onFocusLost!(v);
                          }
                        }
                      },
                decoration: const InputDecoration(
                  isDense: true,
                  border: InputBorder.none,
                  enabledBorder: InputBorder.none,
                  focusedBorder: InputBorder.none,
                  // keep it clean; container handles the visuals
                ),
                style: AppTextStyles.bodyText(context).copyWith(
                  fontSize: AppResponsive.scaleSize(context, 14),
                  fontWeight: FontWeight.w600,
                ),
                cursorColor: AppColors.primary,
              ),
            ],
          ),
        ),

        // Reactive error line ONLY if an RxString was provided
        if (widget.errorText != null)
          Obx(() {
            final msg = widget.errorText!.value;
            if (msg.isEmpty) return const SizedBox.shrink();
            return Padding(
              padding: AppSpacing.symmetric(context, h: 0, v: 0.005),
              child: Text(
                msg,
                style: AppTextStyles.bodyText(context).copyWith(
                  fontSize: AppResponsive.scaleSize(context, 12),
                  color: AppColors.error,
                ),
              ),
            );
          }),
      ],
    );
  }
}
