import 'package:flutter/material.dart';

/// Reusable card widget with consistent styling
class CustomCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final Color? backgroundColor;
  final double? elevation;
  final BorderRadius? borderRadius;
  final Border? border;
  final VoidCallback? onTap;
  final bool isClickable;

  const CustomCard({
    Key? key,
    required this.child,
    this.padding,
    this.margin,
    this.backgroundColor,
    this.elevation,
    this.borderRadius,
    this.border,
    this.onTap,
    this.isClickable = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Widget card = Container(
      margin: margin ?? const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: backgroundColor ?? Colors.white,
        borderRadius: borderRadius ?? BorderRadius.circular(12),
        border: border,
        boxShadow: elevation != null ? [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: elevation!,
            offset: const Offset(0, 2),
          ),
        ] : null,
      ),
      child: Padding(
        padding: padding ?? const EdgeInsets.all(16),
        child: child,
      ),
    );

    if (isClickable || onTap != null) {
      return InkWell(
        onTap: onTap,
        borderRadius: borderRadius ?? BorderRadius.circular(12),
        child: card,
      );
    }

    return card;
  }
}

/// List item card for consistent list styling
class ListItemCard extends StatelessWidget {
  final Widget leading;
  final Widget title;
  final Widget? subtitle;
  final Widget? trailing;
  final VoidCallback? onTap;
  final EdgeInsetsGeometry? padding;
  final Color? backgroundColor;

  const ListItemCard({
    Key? key,
    required this.leading,
    required this.title,
    this.subtitle,
    this.trailing,
    this.onTap,
    this.padding,
    this.backgroundColor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return CustomCard(
      onTap: onTap,
      isClickable: onTap != null,
      backgroundColor: backgroundColor,
      padding: padding ?? const EdgeInsets.all(16),
      child: Row(
        children: [
          leading,
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                title,
                if (subtitle != null) ...[
                  const SizedBox(height: 4),
                  subtitle!,
                ],
              ],
            ),
          ),
          if (trailing != null) ...[
            const SizedBox(width: 12),
            trailing!,
          ],
        ],
      ),
    );
  }
}

/// Chat message card
class ChatMessageCard extends StatelessWidget {
  final String message;
  final String timestamp;
  final bool isFromUser;
  final bool isAI;
  final Widget? avatar;
  final Color? backgroundColor;
  final Color? textColor;

  const ChatMessageCard({
    Key? key,
    required this.message,
    required this.timestamp,
    required this.isFromUser,
    this.isAI = false,
    this.avatar,
    this.backgroundColor,
    this.textColor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisAlignment: isFromUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!isFromUser && avatar != null) ...[
            avatar!,
            const SizedBox(width: 8),
          ],
          
          Flexible(
            child: Column(
              crossAxisAlignment: isFromUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
              children: [
                Container(
                  constraints: BoxConstraints(
                    maxWidth: MediaQuery.of(context).size.width * 0.7,
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: backgroundColor ?? (isFromUser ? const Color(0xFFDCF8C6) : Colors.white),
                    borderRadius: BorderRadius.only(
                      topLeft: const Radius.circular(18),
                      topRight: const Radius.circular(18),
                      bottomLeft: Radius.circular(isFromUser ? 18 : 4),
                      bottomRight: Radius.circular(isFromUser ? 4 : 18),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 1,
                        offset: const Offset(0, 1),
                      ),
                    ],
                  ),
                  child: Text(
                    message,
                    style: TextStyle(
                      color: textColor ?? Colors.black87,
                      fontSize: 16,
                      height: 1.3,
                    ),
                  ),
                ),
                const SizedBox(height: 2),
                Padding(
                  padding: EdgeInsets.only(
                    right: isFromUser ? 8 : 0,
                    left: isFromUser ? 0 : 8,
                  ),
                  child: Text(
                    timestamp,
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 11,
                    ),
                  ),
                ),
              ],
            ),
          ),
          
          if (isFromUser && avatar != null) ...[
            const SizedBox(width: 8),
            avatar!,
          ],
        ],
      ),
    );
  }
}

/// Form section card
class FormSectionCard extends StatelessWidget {
  final String title;
  final Widget child;
  final Widget? action;
  final EdgeInsetsGeometry? padding;

  const FormSectionCard({
    Key? key,
    required this.title,
    required this.child,
    this.action,
    this.padding,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return CustomCard(
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
          child,
        ],
      ),
    );
  }
}
