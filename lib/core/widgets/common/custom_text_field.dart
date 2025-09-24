import 'package:flutter/material.dart';
import 'package:get/get.dart';

/// Reusable custom text field widget
class CustomTextField extends StatelessWidget {
  final TextEditingController controller;
  final String hintText;
  final String? errorText;
  final bool obscureText;
  final TextInputType keyboardType;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final int? maxLines;
  final int? maxLength;
  final VoidCallback? onTap;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;
  final bool enabled;
  final EdgeInsetsGeometry? contentPadding;
  final InputBorder? border;
  final InputBorder? focusedBorder;
  final InputBorder? errorBorder;
  final Color? fillColor;
  final bool filled;

  const CustomTextField({
    Key? key,
    required this.controller,
    required this.hintText,
    this.errorText,
    this.obscureText = false,
    this.keyboardType = TextInputType.text,
    this.prefixIcon,
    this.suffixIcon,
    this.maxLines = 1,
    this.maxLength,
    this.onTap,
    this.onChanged,
    this.onSubmitted,
    this.enabled = true,
    this.contentPadding,
    this.border,
    this.focusedBorder,
    this.errorBorder,
    this.fillColor,
    this.filled = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      obscureText: obscureText,
      keyboardType: keyboardType,
      maxLines: maxLines,
      maxLength: maxLength,
      onTap: onTap,
      onChanged: onChanged,
      onSubmitted: onSubmitted,
      enabled: enabled,
      decoration: InputDecoration(
        hintText: hintText,
        errorText: errorText,
        prefixIcon: prefixIcon,
        suffixIcon: suffixIcon,
        contentPadding: contentPadding ?? 
            const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        border: border ?? 
            OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
        focusedBorder: focusedBorder ?? 
            OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Colors.blue, width: 2),
            ),
        errorBorder: errorBorder ?? 
            OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Colors.red, width: 2),
            ),
        filled: filled,
        fillColor: fillColor ?? Colors.grey[50],
      ),
    );
  }
}

/// Specialized text field for forms with validation
class FormTextField extends StatelessWidget {
  final TextEditingController controller;
  final String hintText;
  final RxString errorText;
  final bool obscureText;
  final TextInputType keyboardType;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final int? maxLines;
  final int? maxLength;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;

  const FormTextField({
    Key? key,
    required this.controller,
    required this.hintText,
    required this.errorText,
    this.obscureText = false,
    this.keyboardType = TextInputType.text,
    this.prefixIcon,
    this.suffixIcon,
    this.maxLines = 1,
    this.maxLength,
    this.onChanged,
    this.onSubmitted,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Obx(() => CustomTextField(
      controller: controller,
      hintText: hintText,
      errorText: errorText.value.isEmpty ? null : errorText.value,
      obscureText: obscureText,
      keyboardType: keyboardType,
      prefixIcon: prefixIcon,
      suffixIcon: suffixIcon,
      maxLines: maxLines,
      maxLength: maxLength,
      onChanged: onChanged,
      onSubmitted: onSubmitted,
    ));
  }
}
