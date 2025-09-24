import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:minechat/controller/theme_controller/theme_controller.dart';
import 'package:minechat/core/constants/app_colors/app_colors.dart';
import 'package:minechat/core/utils/helpers/app_responsive/app_responsive.dart';
import 'package:minechat/core/utils/helpers/app_styles/app_text_styles.dart';

/// Reusable message bubble widget for chat conversations
class MessageBubbleWidget extends StatelessWidget {
  final String message;
  final String timestamp;
  final bool isFromUser;
  final bool isAI;
  final Widget? avatar;

  const MessageBubbleWidget({
    Key? key,
    required this.message,
    required this.timestamp,
    required this.isFromUser,
    this.isAI = false,
    this.avatar,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final themeController = Get.find<ThemeController>();
    final isDark = themeController.isDarkMode;
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisAlignment:
            isFromUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Avatar only for incoming messages (left side)
          if (!isFromUser) ...[
            avatar ?? _buildDefaultAvatar(),
            const SizedBox(width: 8),
          ],

          // Message bubble
          Flexible(
            child: Column(
              crossAxisAlignment: isFromUser
                  ? CrossAxisAlignment.end
                  : CrossAxisAlignment.start,
              children: [
                Container(
                  constraints: BoxConstraints(
                    maxWidth: MediaQuery.of(context).size.width * 0.7,
                  ),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: isFromUser
                        ? isDark
                            ? const Color(0XFF1D1D1D)
                            : const Color(0xFFE1E1EB)
                        : isDark
                            ? const Color(0XFF454545)
                            : const Color(0xFFFFFFFF),
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(
                          isFromUser ? AppResponsive.radius(context) : 0),
                      topRight: Radius.circular(
                          isFromUser ? 0 : AppResponsive.radius(context)),
                      bottomLeft:
                          Radius.circular(AppResponsive.radius(context)),
                      bottomRight:
                          Radius.circular(AppResponsive.radius(context)),
                    ),
                  ),
                  child: Text(
                    message,
                    style: AppTextStyles.bodyText(context).copyWith(
                        fontSize: AppResponsive.scaleSize(context, 14),
                        fontWeight: FontWeight.w400,
                        height: 1.3),
                  ),
                ),
                const SizedBox(height: 2),
                Padding(
                  padding: EdgeInsets.only(
                    left: isFromUser ? 8 : 0,
                    right: isFromUser ? 0 : 8,
                  ),
                  child: Text(timestamp,
                      style: AppTextStyles.hintText(context).copyWith(
                          fontSize: AppResponsive.scaleSize(context, 12),
                          fontWeight: FontWeight.w400,
                          color: Color(0XFFA8AEBF))),
                ),
              ],
            ),
          ),

          // Avatar only for outgoing messages (right side)
          if (isFromUser) ...[
            const SizedBox(width: 8),
            avatar ?? _buildDefaultAvatar(),
          ],
        ],
      ),
    );
  }

  Widget _buildDefaultAvatar() {
    return CircleAvatar(
      radius: 16,
      backgroundColor: AppColors.primary,
      child: Icon(
        isAI ? Icons.smart_toy : Icons.person,
        color: Colors.white,
        size: 16,
      ),
    );
  }
}
