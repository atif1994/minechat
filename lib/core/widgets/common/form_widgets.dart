import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'custom_text_field.dart';
import 'custom_button.dart';

/// Form section widget
class FormSection extends StatelessWidget {
  final String title;
  final List<Widget> children;
  final Widget? action;
  final EdgeInsetsGeometry? padding;

  const FormSection({
    Key? key,
    required this.title,
    required this.children,
    this.action,
    this.padding,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding ?? const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
              if (action != null) action!,
            ],
          ),
          const SizedBox(height: 16),
          ...children,
        ],
      ),
    );
  }
}

/// Form field with label and validation
class FormField extends StatelessWidget {
  final String label;
  final String hintText;
  final TextEditingController controller;
  final RxString errorText;
  final bool isRequired;
  final bool obscureText;
  final TextInputType keyboardType;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final int? maxLines;
  final int? maxLength;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;

  const FormField({
    Key? key,
    required this.label,
    required this.hintText,
    required this.controller,
    required this.errorText,
    this.isRequired = false,
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              label,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
            if (isRequired) ...[
              const SizedBox(width: 4),
              const Text(
                '*',
                style: TextStyle(
                  color: Colors.red,
                  fontSize: 16,
                ),
              ),
            ],
          ],
        ),
        const SizedBox(height: 8),
        FormTextField(
          controller: controller,
          hintText: hintText,
          errorText: errorText,
          obscureText: obscureText,
          keyboardType: keyboardType,
          prefixIcon: prefixIcon,
          suffixIcon: suffixIcon,
          maxLines: maxLines,
          maxLength: maxLength,
          onChanged: onChanged,
          onSubmitted: onSubmitted,
        ),
      ],
    );
  }
}

/// Form actions widget
class FormActions extends StatelessWidget {
  final String primaryButtonText;
  final VoidCallback? onPrimaryPressed;
  final String? secondaryButtonText;
  final VoidCallback? onSecondaryPressed;
  final RxBool isLoading;
  final bool isPrimaryEnabled;
  final bool isSecondaryEnabled;
  final Widget? customAction;

  const FormActions({
    Key? key,
    required this.primaryButtonText,
    this.onPrimaryPressed,
    this.secondaryButtonText,
    this.onSecondaryPressed,
    required this.isLoading,
    this.isPrimaryEnabled = true,
    this.isSecondaryEnabled = true,
    this.customAction,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        if (secondaryButtonText != null && onSecondaryPressed != null)
          Expanded(
            child: FormButton(
              text: secondaryButtonText!,
              isLoading: false.obs,
              onPressed: isSecondaryEnabled ? onSecondaryPressed : null,
              isOutlined: true,
            ),
          ),
        if (secondaryButtonText != null && onSecondaryPressed != null)
          const SizedBox(width: 16),
        Expanded(
          child: FormButton(
            text: primaryButtonText,
            isLoading: isLoading,
            onPressed: isPrimaryEnabled ? onPrimaryPressed : null,
          ),
        ),
        if (customAction != null) ...[
          const SizedBox(width: 16),
          customAction!,
        ],
      ],
    );
  }
}

/// File upload widget
class FileUploadWidget extends StatelessWidget {
  final String label;
  final String? selectedFileName;
  final VoidCallback? onTap;
  final RxBool isUploading;
  final String? hintText;
  final IconData? icon;

  const FileUploadWidget({
    Key? key,
    required this.label,
    this.selectedFileName,
    this.onTap,
    required this.isUploading,
    this.hintText,
    this.icon,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        Obx(() => InkWell(
          onTap: isUploading.value ? null : onTap,
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              border: Border.all(
                color: selectedFileName != null ? Colors.green : Colors.grey[300]!,
                width: 2,
              ),
              borderRadius: BorderRadius.circular(12),
              color: selectedFileName != null ? Colors.green[50] : Colors.grey[50],
            ),
            child: Row(
              children: [
                Icon(
                  icon ?? Icons.upload_file,
                  color: selectedFileName != null ? Colors.green : Colors.grey[600],
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        selectedFileName ?? hintText ?? 'Tap to upload file',
                        style: TextStyle(
                          color: selectedFileName != null ? Colors.green[700] : Colors.grey[600],
                          fontWeight: selectedFileName != null ? FontWeight.w500 : FontWeight.normal,
                        ),
                      ),
                      if (isUploading.value) ...[
                        const SizedBox(height: 4),
                        const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                if (selectedFileName != null)
                  Icon(
                    Icons.check_circle,
                    color: Colors.green,
                    size: 20,
                  ),
              ],
            ),
          ),
        )),
      ],
    );
  }
}

/// Dropdown form field
class DropdownFormField<T> extends StatelessWidget {
  final String label;
  final T? value;
  final List<T> items;
  final String Function(T) itemBuilder;
  final ValueChanged<T?>? onChanged;
  final bool isRequired;
  final String? hintText;

  const DropdownFormField({
    Key? key,
    required this.label,
    this.value,
    required this.items,
    required this.itemBuilder,
    this.onChanged,
    this.isRequired = false,
    this.hintText,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              label,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
            if (isRequired) ...[
              const SizedBox(width: 4),
              const Text(
                '*',
                style: TextStyle(
                  color: Colors.red,
                  fontSize: 16,
                ),
              ),
            ],
          ],
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey[300]!),
            borderRadius: BorderRadius.circular(12),
            color: Colors.grey[50],
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<T>(
              value: value,
              items: items.map((T item) {
                return DropdownMenuItem<T>(
                  value: item,
                  child: Text(itemBuilder(item)),
                );
              }).toList(),
              onChanged: onChanged,
              hint: hintText != null ? Text(hintText!) : null,
              isExpanded: true,
            ),
          ),
        ),
      ],
    );
  }
}
