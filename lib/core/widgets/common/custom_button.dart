import 'package:flutter/material.dart';
import 'package:get/get.dart';

/// Reusable custom button widget
class CustomButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final bool isLoading;
  final bool isOutlined;
  final Color? backgroundColor;
  final Color? textColor;
  final Color? borderColor;
  final double? width;
  final double? height;
  final EdgeInsetsGeometry? padding;
  final BorderRadius? borderRadius;
  final Widget? icon;
  final double? fontSize;
  final FontWeight? fontWeight;

  const CustomButton({
    Key? key,
    required this.text,
    this.onPressed,
    this.isLoading = false,
    this.isOutlined = false,
    this.backgroundColor,
    this.textColor,
    this.borderColor,
    this.width,
    this.height,
    this.padding,
    this.borderRadius,
    this.icon,
    this.fontSize,
    this.fontWeight,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return SizedBox(
      width: width,
      height: height ?? 48,
      child: isOutlined ? _buildOutlinedButton(theme) : _buildFilledButton(theme),
    );
  }

  Widget _buildFilledButton(ThemeData theme) {
    return ElevatedButton(
      onPressed: isLoading ? null : onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: backgroundColor ?? theme.primaryColor,
        foregroundColor: textColor ?? Colors.white,
        padding: padding ?? const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: borderRadius ?? BorderRadius.circular(12),
        ),
        elevation: 2,
      ),
      child: _buildButtonContent(),
    );
  }

  Widget _buildOutlinedButton(ThemeData theme) {
    return OutlinedButton(
      onPressed: isLoading ? null : onPressed,
      style: OutlinedButton.styleFrom(
        foregroundColor: textColor ?? theme.primaryColor,
        side: BorderSide(
          color: borderColor ?? theme.primaryColor,
          width: 1.5,
        ),
        padding: padding ?? const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: borderRadius ?? BorderRadius.circular(12),
        ),
      ),
      child: _buildButtonContent(),
    );
  }

  Widget _buildButtonContent() {
    if (isLoading) {
      return const SizedBox(
        width: 20,
        height: 20,
        child: CircularProgressIndicator(
          strokeWidth: 2,
          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
        ),
      );
    }

    if (icon != null) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          icon!,
          const SizedBox(width: 8),
          Text(
            text,
            style: TextStyle(
              fontSize: fontSize ?? 16,
              fontWeight: fontWeight ?? FontWeight.w600,
            ),
          ),
        ],
      );
    }

    return Text(
      text,
      style: TextStyle(
        fontSize: fontSize ?? 16,
        fontWeight: fontWeight ?? FontWeight.w600,
      ),
    );
  }
}

/// Specialized button for forms
class FormButton extends StatelessWidget {
  final String text;
  final RxBool isLoading;
  final VoidCallback? onPressed;
  final bool isOutlined;
  final Color? backgroundColor;
  final Color? textColor;
  final Widget? icon;

  const FormButton({
    Key? key,
    required this.text,
    required this.isLoading,
    this.onPressed,
    this.isOutlined = false,
    this.backgroundColor,
    this.textColor,
    this.icon,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Obx(() => CustomButton(
      text: text,
      onPressed: onPressed,
      isLoading: isLoading.value,
      isOutlined: isOutlined,
      backgroundColor: backgroundColor,
      textColor: textColor,
      icon: icon,
    ));
  }
}

/// Icon button with consistent styling
class CustomIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onPressed;
  final Color? iconColor;
  final Color? backgroundColor;
  final double? size;
  final String? tooltip;

  const CustomIconButton({
    Key? key,
    required this.icon,
    this.onPressed,
    this.iconColor,
    this.backgroundColor,
    this.size,
    this.tooltip,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: onPressed,
      icon: Icon(
        icon,
        color: iconColor,
        size: size,
      ),
      style: IconButton.styleFrom(
        backgroundColor: backgroundColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
      tooltip: tooltip,
    );
  }
}
