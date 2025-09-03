import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:minechat/controller/theme_controller/theme_controller.dart';
import 'package:minechat/core/utils/extensions/app_gradient/app_gradient_extension.dart';
import '../../constants/app_colors/app_colors.dart';

class TwoButtonsRow extends StatelessWidget {
  final RxBool isSaving;
  final VoidCallback onSave;

  final String secondLabel;
  final String secondIcon;
  final VoidCallback onSecondTap;

  const TwoButtonsRow({
    super.key,
    required this.isSaving,
    required this.onSave,
    required this.secondLabel,
    required this.secondIcon,
    required this.onSecondTap,
  });

  @override
  Widget build(BuildContext context) {
    final themeController = Get.find<ThemeController>();
    final isDark = themeController.isDarkMode;
    return Row(
      children: [
        // Save Button
        Expanded(
          child: Container(
            height: 48,
            decoration: BoxDecoration(
              border: Border.all(color: AppColors.primary),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Obx(() => TextButton(
                  onPressed: isSaving.value ? null : onSave,
                  child: isSaving.value
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : Text(
                          'Save',
                          style: TextStyle(
                            color: isDark ? AppColors.white : AppColors.primary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                )),
          ),
        ),
        const SizedBox(width: 12),
        // Second Button
        Expanded(
          child: Container(
            height: 48,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
            ).withAppGradient,
            child: TextButton.icon(
              onPressed: onSecondTap,
              icon: SvgPicture.asset(
                secondIcon,
                width: 20,
                height: 20,
                colorFilter:
                    const ColorFilter.mode(Colors.white, BlendMode.srcIn),
              ),
              label: Text(
                secondLabel,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
