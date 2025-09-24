import 'package:flutter/material.dart';

/// Reusable Form Section Widget - Reduces form section duplication across screens
class FormSectionWidget extends StatelessWidget {
  final String title;
  final String? subtitle;
  final List<Widget> children;
  final bool isExpanded;
  final bool isRequired;
  final Widget? headerAction;
  final VoidCallback? onTap;
  final EdgeInsetsGeometry? padding;

  const FormSectionWidget({
    Key? key,
    required this.title,
    this.subtitle,
    required this.children,
    this.isExpanded = true,
    this.isRequired = false,
    this.headerAction,
    this.onTap,
    this.padding,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[300]!),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          InkWell(
            onTap: onTap,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(12),
              topRight: Radius.circular(12),
            ),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey[50],
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(12),
                  topRight: Radius.circular(12),
                ),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              title,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: Colors.black87,
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
                        if (subtitle != null) ...[
                          const SizedBox(height: 4),
                          Text(
                            subtitle!,
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  if (headerAction != null) headerAction!,
                ],
              ),
            ),
          ),
          
          // Content
          if (isExpanded)
            Padding(
              padding: padding ?? const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: children,
              ),
            ),
        ],
      ),
    );
  }
}

/// Reusable Form Field Widget - Reduces form field duplication
class FormFieldWidget extends StatelessWidget {
  final String label;
  final String hintText;
  final TextEditingController controller;
  final String? errorText;
  final bool isRequired;
  final bool isPassword;
  final TextInputType? keyboardType;
  final int? maxLines;
  final Widget? suffixIcon;
  final VoidCallback? onSuffixTap;
  final String? Function(String?)? validator;
  final VoidCallback? onTap;
  final bool readOnly;

  const FormFieldWidget({
    Key? key,
    required this.label,
    required this.hintText,
    required this.controller,
    this.errorText,
    this.isRequired = false,
    this.isPassword = false,
    this.keyboardType,
    this.maxLines = 1,
    this.suffixIcon,
    this.onSuffixTap,
    this.validator,
    this.onTap,
    this.readOnly = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Label
        Row(
          children: [
            Text(
              label,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Colors.black87,
              ),
            ),
            if (isRequired) ...[
              const SizedBox(width: 4),
              const Text(
                '*',
                style: TextStyle(
                  color: Colors.red,
                  fontSize: 14,
                ),
              ),
            ],
          ],
        ),
        const SizedBox(height: 8),
        
        // Input Field
        TextFormField(
          controller: controller,
          obscureText: isPassword,
          keyboardType: keyboardType,
          maxLines: maxLines,
          validator: validator,
          onTap: onTap,
          readOnly: readOnly,
          decoration: InputDecoration(
            hintText: hintText,
            hintStyle: TextStyle(
              color: Colors.grey[500],
              fontSize: 14,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Colors.blue, width: 2),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Colors.red),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Colors.red, width: 2),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 12,
            ),
            suffixIcon: suffixIcon != null
                ? GestureDetector(
                    onTap: onSuffixTap,
                    child: suffixIcon,
                  )
                : null,
          ),
        ),
        
        // Error Text
        if (errorText != null && errorText!.isNotEmpty) ...[
          const SizedBox(height: 4),
          Text(
            errorText!,
            style: const TextStyle(
              color: Colors.red,
              fontSize: 12,
            ),
          ),
        ],
      ],
    );
  }
}
