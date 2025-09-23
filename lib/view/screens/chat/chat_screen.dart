import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:minechat/controller/chat_controller/chat_controller.dart';
import 'package:minechat/controller/theme_controller/theme_controller.dart';
import 'package:minechat/core/constants/app_assets/app_assets.dart';
import 'package:minechat/core/constants/app_colors/app_colors.dart';
import 'package:minechat/core/utils/extensions/app_gradient/app_gradient_extension.dart';
import 'package:minechat/core/utils/helpers/app_responsive/app_responsive.dart';
import 'package:minechat/core/utils/helpers/app_spacing/app_spacing.dart';
import 'package:minechat/core/utils/helpers/app_styles/app_text_styles.dart';
import 'package:minechat/view/screens/chat/chat_conversation_screen.dart';

class ChatScreen extends StatelessWidget {
  final chatController = Get.find<ChatController>();

  @override
  Widget build(BuildContext context) {
    final themeController = Get.find<ThemeController>();
    return Obx(
      () {
        final isDark = themeController.isDarkMode;
        return Scaffold(
          backgroundColor: isDark ? Color(0XFF0A0A0A) : Color(0XFFF4F6FC),
          appBar: AppBar(
            title: Text(
              "Chat",
              style: AppTextStyles.bodyText(context).copyWith(
                  fontSize: AppResponsive.scaleSize(context, 20),
                  fontWeight: FontWeight.w600),
            ),
            backgroundColor: isDark ? Color(0XFF1D1D1D) : Color(0XFFFFFFFF),
            elevation: 0,
            actionsPadding: AppSpacing.symmetric(context, v: 0, h: 0.03),
            actions: [
              CreateNewChatButton(chatController: chatController),
            ],
          ),
          body: SafeArea(
            child: Column(
              children: [
                // Search Bar
                ChatSearchBar(isDark: isDark, chatController: chatController),

                // Filter Tabs
                _buildFilterTabs(context),

                // Chat List
                Expanded(
                  child: _buildChatList(context),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildFilterTabs(BuildContext context) {
    final themeController = Get.find<ThemeController>();
    final isDark = themeController.isDarkMode;
    return Container(
      margin: const EdgeInsets.only(top: 8),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration:
          BoxDecoration(color: isDark
              ? Color(0XFF1D1D1D)
              : Color(0XFFFFFFFF)),
      child: Row(
        children: [
          _buildFilterTab('Inbox', context),
          const SizedBox(width: 16),
          _buildFilterTab('Unread', context),
          const SizedBox(width: 16),
          _buildFilterTab('Groups', context),
          const SizedBox(width: 16),
          _buildFilterTab('Filter', context),
        ],
      ),
    );
  }

  Widget _buildFilterTab(String title, BuildContext context) {
    final themeController = Get.find<ThemeController>();
    final isDark = themeController.isDarkMode;
    return Obx(() {
      final isSelected = chatController.selectedFilter.value == title;
      return GestureDetector(
        onTap: () {
          if (title == 'Filter') {
            chatController.toggleFilterDropdown();
          } else {
            chatController.selectFilter(title);
          }
        },
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: isSelected
                ? isDark ? Color(0XFF0A0A0A) : Color(0XFFF4F6FC)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(AppResponsive.radius(context)),
          ),
          child: Text(
            title,
            style: TextStyle(
              fontSize: 14,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
            ),
          ),
        ),
      );
    });
  }

  Widget _buildChatList(BuildContext context) {
    final themeController = Get.find<ThemeController>();
    final isDark = themeController.isDarkMode;
    return Container(
      decoration:
          BoxDecoration(color: isDark ? Color(0XFF1D1D1D) : Color(0XFFFFFFFF)),
      child: Stack(
        children: [
          // Chat List
          Obx(() {
            if (chatController.isLoading.value) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            }

            if (chatController.filteredChatList.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.chat_bubble_outline,
                      size: 64,
                      color: Colors.grey[400],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'No chats found',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey[600],
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Connect your Facebook page to see real conversations',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[500],
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                  ],
                ),
              );
            }

            return RefreshIndicator(
              onRefresh: () => chatController.refreshChats(),
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: chatController.filteredChatList.length,
                itemBuilder: (context, index) {
                  final chat = chatController.filteredChatList[index];
                  final String contactName =
                      chat['contactName'] ?? 'Unknown User';
                  final String profileImageUrl = chat['profileImageUrl'] ?? '';
                  print(contactName);
                  print(profileImageUrl);
                  return _buildChatItem(chat, context);
                },
              ),
            );
          }),

          // Create New Dropdown
          Positioned(
            top: 0,
            right: 16,
            child: Obx(() => chatController.isCreateNewDropdownOpen.value
                ? _buildCreateNewDropdown()
                : const SizedBox.shrink()),
          ),

          // Filter Dropdown
          Positioned(
            top: 0,
            right: 16,
            child: Obx(() => chatController.isFilterDropdownOpen.value
                ? _buildFilterDropdown()
                : const SizedBox.shrink()),
          ),
        ],
      ),
    );
  }

  Widget _buildChatItem(Map<String, dynamic> chat, BuildContext context) {
    return GestureDetector(
      onTap: () {
        chatController.markAsRead(chat['id']);
        Get.to(() => ChatConversationScreen(chat: chat));
      },
      child: Container(
        padding: const EdgeInsets.only(top: 16, bottom: 16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(AppResponsive.radius(context)),
        ),
        child: Row(
          children: [
            // Profile Image with Platform Badge
            Stack(
              children: [
                CircleAvatar(
                  radius: 24,
                  backgroundImage: chat['profileImageUrl']?.isNotEmpty == true
                      ? NetworkImage(chat['profileImageUrl'])
                      : null,
                  backgroundColor: _getPlatformColor(chat['platform']),
                  child: chat['profileImageUrl']?.isEmpty != false
                      ? Text(
                          chat['contactName']?[0]?.toUpperCase() ?? '?',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        )
                      : null,
                ),
              ],
            ),
            const SizedBox(width: 12),

            // Chat Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          chat['contactName'],
                          style: AppTextStyles.bodyText(context),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(chatController.getTimeDisplay(chat['timestamp']),
                          style: AppTextStyles.hintText(context)),
                    ],
                  ),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          chat['lastMessage'] ?? '',
                          style: AppTextStyles.hintText(context),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      // Message count is now included in lastMessage field
                    ],
                  ),
                ],
              ),
            ),

            // Unread Badge
            if (chat['unreadCount'] > 0)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.red,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  chat['unreadCount'].toString(),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildCreateNewDropdown() {
    final opts = chatController.createNewOptions;
    final themeController = Get.find<ThemeController>();
    final isDark = themeController.isDarkMode;
    return Container(
      margin: const EdgeInsets.only(top: 8),
      decoration: BoxDecoration(
        color: isDark ? Color(0XFF0A0A0A) : Color(0XFFF4F6FC),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: opts.map((o) {
          final disabled = !(o['enabled'] as bool);
          return GestureDetector(
            onTap: disabled
                ? null
                : () => chatController.onCreateNewOptionTap(o['key']),
            child: Container(
              width: 220,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Text(
                o['label'],
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildFilterDropdown() {
    final themeController = Get.find<ThemeController>();
    final isDark = themeController.isDarkMode;
    return Container(
      margin: const EdgeInsets.only(top: 8),
      decoration: BoxDecoration(
        color: isDark ? Color(0XFF0A0A0A) : Color(0XFFF4F6FC),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: chatController.filterOptions.map((option) {
          return GestureDetector(
            onTap: () => chatController.applyDateFilter(option),
            child: Container(
              width: 150,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Text(
                option,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Color _getPlatformColor(String? platform) {
    switch (platform?.toLowerCase()) {
      case 'messenger':
        return const Color(0xFF0084FF);
      case 'instagram':
        return const Color(0xFFE1306C);
      case 'whatsapp':
        return const Color(0xFF25D366);
      case 'telegram':
        return const Color(0xFF0088CC);
      case 'website':
        return const Color(0xFF2196F3);
      case 'slack':
        return const Color(0xFF4A154B);
      case 'discord':
        return const Color(0xFF5865F2);
      case 'viber':
        return const Color(0xFF665CAC);
      default:
        return Colors.grey[600] ?? Colors.grey;
    }
  }
}

class CreateNewChatButton extends StatelessWidget {
  const CreateNewChatButton({
    super.key,
    required this.chatController,
  });

  final ChatController chatController;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => chatController.toggleCreateNewDropdown(),
      child: Container(
        padding: AppSpacing.symmetric(context, h: 0.03, v: 0.007),
        decoration: BoxDecoration(
          borderRadius:
              BorderRadius.circular(AppResponsive.radius(context)), // full pill
        ).withAppGradient,
        child: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.add, color: Colors.white, size: 18),
            SizedBox(width: 8),
            Text(
              'Create New',
              style: TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.w600,
                letterSpacing: .2,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ChatSearchBar extends StatelessWidget {
  const ChatSearchBar({
    super.key,
    required this.isDark,
    required this.chatController,
  });

  final bool isDark;
  final ChatController chatController;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: isDark ? Color(0XFF1D1D1D) : Color(0XFFFFFFFF),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.search,
                    color: Colors.grey[600],
                    size: 25,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextField(
                      onChanged: (value) => chatController.searchChats(value),
                      decoration: InputDecoration(
                        hintText: 'Search',
                        hintStyle: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 14,
                        ),
                        border: InputBorder.none,
                        isDense: true,
                        contentPadding: EdgeInsets.zero,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 8),
          Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(
                color: isDark ? Color(0XFF1D1D1D) : Color(0XFFFFFFFF),
                borderRadius: BorderRadius.circular(8),
              ),
              child: SvgPicture.asset(AppAssets.socialMessengerLight)),
        ],
      ),
    );
  }
}
