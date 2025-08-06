import 'package:flutter/material.dart';
import 'package:minechat/core/constants/app_colors/app_colors.dart';

class AppButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final Color? backgroundColor;
  final Color? textColor;
  final double? width;
  final double? height;
  final double? borderRadius;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final Widget? icon;
  final bool isLoading;
  final bool isEnabled;
  final TextStyle? textStyle;
  final List<BoxShadow>? boxShadow;
  final Border? border;
  final Gradient? gradient;

  const AppButton({
    super.key,
    required this.text,
    this.onPressed,
    this.backgroundColor,
    this.textColor,
    this.width,
    this.height = 40,
    this.borderRadius = 20,
    this.padding,
    this.margin,
    this.icon,
    this.isLoading = false,
    this.isEnabled = true,
    this.textStyle,
    this.boxShadow,
    this.border,
    this.gradient,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Container(
      width: width,
      height: height,
      margin: margin,
      decoration: BoxDecoration(
        color: gradient == null ? (backgroundColor ?? Theme.of(context).primaryColor) : null,
        gradient: gradient,
        borderRadius: BorderRadius.circular(borderRadius!),
        boxShadow: boxShadow ?? [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
        border: border,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: isEnabled && !isLoading ? onPressed : null,
          borderRadius: BorderRadius.circular(borderRadius!),
          child: Container(
            padding: padding ?? const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Center(
              child: isLoading
                  ? SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          textColor ?? (isDark ? Colors.white : Colors.black),
                        ),
                      ),
                    )
                  : Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (icon != null) ...[
                          icon!,
                          const SizedBox(width: 8),
                        ],
                        Flexible(
                          child: Text(
                            text,
                            style: textStyle ??
                                TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: textColor ?? (isDark ? Colors.white : Colors.black),
                                  fontFamily: 'SF Pro Text',
                                ),
                            textAlign: TextAlign.center,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
            ),
          ),
        ),
      ),
    );
  }
}

// Predefined button styles
class AppButtonStyles {
  static AppButton primary({
    required String text,
    required VoidCallback? onPressed,
    double? width,
    double? height,
    Widget? icon,
    bool isLoading = false,
    bool isEnabled = true,
    EdgeInsetsGeometry? margin,
  }) {
    return AppButton(
      text: text,
      onPressed: onPressed,
      backgroundColor: const Color(0xFF86174F),
      textColor: Colors.white,
      width: width,
      height: height,
      icon: icon,
      isLoading: isLoading,
      isEnabled: isEnabled,
      margin: margin,
    );
  }

  static AppButton secondary({
    required String text,
    required VoidCallback? onPressed,
    double? width,
    double? height,
    Widget? icon,
    bool isLoading = false,
    bool isEnabled = true,
    EdgeInsetsGeometry? margin,
  }) {
    return AppButton(
      text: text,
      onPressed: onPressed,
      backgroundColor: Colors.white,
      textColor: AppColors.black,
      width: width,
      height: height,
      icon: icon,
      isLoading: isLoading,
      isEnabled: isEnabled,
      margin: margin,
    );
  }

  static AppButton gradient({
    required String text,
    required VoidCallback? onPressed,
    double? width,
    double? height,
    Widget? icon,
    bool isLoading = false,
    bool isEnabled = true,
    EdgeInsetsGeometry? margin,
  }) {
    return AppButton(
      text: text,
      onPressed: onPressed,
      gradient: const LinearGradient(
        colors: [Color(0xFF86174F), Color(0xFFB73A4E)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      textColor: Colors.white,
      width: width,
      height: height,
      icon: icon,
      isLoading: isLoading,
      isEnabled: isEnabled,
      margin: margin,
    );
  }

  static AppButton outline({
    required String text,
    required VoidCallback? onPressed,
    Color? borderColor,
    Color? textColor,
    double? width,
    double? height,
    Widget? icon,
    bool isLoading = false,
    bool isEnabled = true,
    EdgeInsetsGeometry? margin,
  }) {
    return AppButton(
      text: text,
      onPressed: onPressed,
      backgroundColor: Colors.transparent,
      textColor: textColor ?? const Color(0xFF86174F),
      border: Border.all(
        color: borderColor ?? const Color(0xFF86174F),
        width: 1.5,
      ),
      width: width,
      height: height,
      icon: icon,
      isLoading: isLoading,
      isEnabled: isEnabled,
      margin: margin,
    );
  }
} 