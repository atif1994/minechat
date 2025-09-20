import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:minechat/core/constants/app_colors/app_colors.dart';
import 'package:minechat/core/utils/helpers/app_styles/app_text_styles.dart';
import 'package:minechat/core/widgets/signUp/signUp_textfield.dart';

class FormSection extends StatelessWidget {
  final String title;
  final List<CustomFormField> fields;
  final List<Widget> actionButtons;
  final bool isDark;

  const FormSection({
    super.key,
    required this.title,
    required this.fields,
    required this.actionButtons,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section Title
        Text(
          title,
          style: AppTextStyles.bodyText(context).copyWith(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: isDark ? AppColors.white : AppColors.secondary,
          ),
        ),
        const SizedBox(height: 16),

        // Form Fields
        ...fields.map((field) => Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: field.widget,
        )),

        const SizedBox(height: 16),

        // Action Buttons
        SizedBox(
          width: double.infinity,
          child: Row(
            children: actionButtons,
          ),
        ),
      ],
    );
  }
}

class CustomFormField {
  final Widget widget;
  final String? label;
  final String? hintText;
  final TextEditingController? controller;
  final String? errorText;
  final Function(String)? onChanged;

  const CustomFormField({
    required this.widget,
    this.label,
    this.hintText,
    this.controller,
    this.errorText,
    this.onChanged,
  });

  static CustomFormField textField({
    required String label,
    required String hintText,
    required TextEditingController controller,
    String? errorText,
    Function(String)? onChanged,
  }) {
    // Create RxString from String if errorText is provided
    final rxErrorText = errorText != null ? RxString(errorText) : null;
    
    return CustomFormField(
      widget: SignupTextField(
        label: label,
        hintText: hintText,
        controller: controller,
        errorText: rxErrorText,
        onChanged: onChanged,
      ),
      label: label,
      hintText: hintText,
      controller: controller,
      errorText: errorText,
      onChanged: onChanged,
    );
  }
}
