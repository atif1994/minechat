import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../constants/app_colors/app_colors.dart';


class TwoButtonsRow extends StatelessWidget {
  final RxBool isSaving;
  final VoidCallback onSave;

  final String secondLabel;
  final IconData secondIcon;
  final VoidCallback onSecondTap;

  const TwoButtonsRow({
    Key? key,
    required this.isSaving,
    required this.onSave,
    required this.secondLabel,
    required this.secondIcon,
    required this.onSecondTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
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
                  : const Text(
                'Save',
                style: TextStyle(
                  color: AppColors.primary,
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
              color: AppColors.primary,
              borderRadius: BorderRadius.circular(12),
            ),
            child: TextButton.icon(
              onPressed: onSecondTap,
              icon: Icon(secondIcon, color: Colors.white, size: 20),
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
