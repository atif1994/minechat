import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:minechat/controller/chat_controller/chat_controller.dart';
import 'package:minechat/controller/theme_controller/theme_controller.dart';
import 'package:minechat/core/utils/helpers/app_responsive/app_responsive.dart';
import 'package:minechat/core/utils/helpers/app_styles/app_text_styles.dart';
import 'package:minechat/core/widgets/chat/delete_chats_alert_dialog.dart';

class ChatSelectionAppBar extends StatelessWidget implements PreferredSizeWidget {
  final ChatController chatController;
  final ThemeController themeController;

  const ChatSelectionAppBar({
    super.key,
    required this.chatController,
    required this.themeController,
  });

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final isDark = themeController.isDarkMode;
      final selectedCount = chatController.selectedChatsCount;
      
      return AppBar(
        backgroundColor: isDark ? const Color(0xFF1D1D1D) : Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
            color: isDark ? Colors.white : Colors.black,
          ),
          onPressed: () => chatController.exitSelectionMode(),
        ),
        title: Text(
          '$selectedCount Selected',
          style: AppTextStyles.bodyText(context).copyWith(
            fontSize: AppResponsive.scaleSize(context, 18),
            fontWeight: FontWeight.w600,
            color: isDark ? Colors.white : Colors.black,
          ),
        ),
        actions: [
          // Delete button
          IconButton(
            icon: Icon(
              Icons.delete_outline,
              color: isDark ? Colors.white : Colors.black,
            ),
            onPressed: selectedCount > 0 
                ? () => _showDeleteConfirmation(context, chatController)
                : null,
          ),
          // More options button
          IconButton(
            icon: Icon(
              Icons.more_vert,
              color: isDark ? Colors.white : Colors.black,
            ),
            onPressed: () => chatController.toggleMoreOptionsDropdown(),
          ),
          const SizedBox(width: 8),
        ],
      );
    });
  }

  void _showDeleteConfirmation(BuildContext context, ChatController controller) {
    DeleteChatsAlertDialog.show(
      onConfirm: () => controller.deleteSelectedChats(),
      title: 'Delete Chats',
      message: 'Are you sure you want to delete ${controller.selectedChatsCount} chat(s)? This action cannot be undone.',
      confirmLabel: 'Delete',
      cancelLabel: 'Cancel',
      barrier: Colors.black.withOpacity(0.55),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
