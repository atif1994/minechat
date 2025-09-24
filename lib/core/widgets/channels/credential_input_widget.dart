import 'package:flutter/material.dart';

/// Reusable Credential Input Widget - Reduces form duplication across channel widgets
class CredentialInputWidget extends StatelessWidget {
  final String label;
  final String hintText;
  final TextEditingController controller;
  final String? errorText;
  final bool isPassword;
  final bool isRequired;
  final Widget? suffixIcon;
  final VoidCallback? onSuffixTap;
  final String? Function(String?)? validator;

  const CredentialInputWidget({
    Key? key,
    required this.label,
    required this.hintText,
    required this.controller,
    this.errorText,
    this.isPassword = false,
    this.isRequired = true,
    this.suffixIcon,
    this.onSuffixTap,
    this.validator,
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
          validator: validator,
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
