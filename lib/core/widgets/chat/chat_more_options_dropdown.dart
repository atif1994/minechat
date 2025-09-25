import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:minechat/controller/chat_controller/chat_controller.dart';
import 'package:minechat/controller/theme_controller/theme_controller.dart';
import 'package:minechat/core/utils/helpers/app_responsive/app_responsive.dart';
import 'package:minechat/core/utils/helpers/app_styles/app_text_styles.dart';

class ChatMoreOptionsDropdown extends StatelessWidget {
  final ChatController chatController;
  final ThemeController themeController;

  const ChatMoreOptionsDropdown({
    super.key,
    required this.chatController,
    required this.themeController,
  });

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (!chatController.isMoreOptionsDropdownOpen.value) {
        return const SizedBox.shrink();
      }

      final isDark = themeController.isDarkMode;
      
      return Positioned(
        top: kToolbarHeight + MediaQuery.of(context).padding.top + 8,
        right: 16,
        child: Material(
          color: Colors.transparent,
          child: Container(
            width: AppResponsive.scaleSize(context, 200),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF2D2D2D) : Colors.white,
              borderRadius: BorderRadius.circular(8),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildOptionItem(
                  context,
                  'Create a group',
                  Icons.group_add,
                  () => chatController.handleMoreOptionsAction('create_group'),
                  isDark,
                ),
                _buildOptionItem(
                  context,
                  'Send a group message',
                  Icons.message,
                  () => chatController.handleMoreOptionsAction('send_group_message'),
                  isDark,
                ),
                _buildOptionItem(
                  context,
                  'Mark as read',
                  Icons.mark_email_read,
                  () => chatController.handleMoreOptionsAction('mark_as_read'),
                  isDark,
                ),
                _buildOptionItem(
                  context,
                  'Move to another group',
                  Icons.move_to_inbox,
                  () => chatController.handleMoreOptionsAction('move_to_another_group'),
                  isDark,
                ),
              ],
            ),
          ),
        ),
      );
    });
  }

  Widget _buildOptionItem(
    BuildContext context,
    String title,
    IconData icon,
    VoidCallback onTap,
    bool isDark,
  ) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.symmetric(
          horizontal: AppResponsive.scaleSize(context, 16),
          vertical: AppResponsive.scaleSize(context, 12),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              size: AppResponsive.scaleSize(context, 20),
              color: isDark ? Colors.white : Colors.black87,
            ),
            SizedBox(width: AppResponsive.scaleSize(context, 12)),
            Expanded(
              child: Text(
                title,
                style: AppTextStyles.bodyText(context).copyWith(
                  fontSize: AppResponsive.scaleSize(context, 14),
                  color: isDark ? Colors.white : Colors.black87,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
