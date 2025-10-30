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
import 'package:minechat/core/widgets/chat/chat_selection_app_bar.dart';
import 'package:minechat/core/widgets/chat/chat_more_options_dropdown.dart';
import 'package:minechat/core/router/app_routes.dart';

class ChatScreen extends StatefulWidget {
  ChatScreen({Key? key}) : super(key: key);

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  @override
  void initState() {
    super.initState();
    // Refresh chats when screen is opened
    WidgetsBinding.instance.addPostFrameCallback((_) {
      try {
        final chatController = Get.find<ChatController>();
        chatController.refreshChats();
        print('🔄 Chat screen opened - refreshing chats...');
      } catch (e) {
        print('⚠️ Error refreshing chats on screen open: $e');
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final themeController = Get.find<ThemeController>();
    
    // Safety check for ChatController
    if (!Get.isRegistered<ChatController>()) {
      print('⚠️ ChatController not registered yet, showing loading...');
      return Scaffold(
        backgroundColor: Color(0XFFF4F6FC),
        body: Center(
          child: CircularProgressIndicator(
            color: AppColors.primary,
          ),
        ),
      );
    }
    
    final chatController = Get.find<ChatController>();
    return Obx(
      () {
        final isDark = themeController.isDarkMode;
        return Scaffold(
          backgroundColor: isDark ? Color(0XFF0A0A0A) : Color(0XFFF4F6FC),
          appBar: chatController.isSelectionMode.value
              ? ChatSelectionAppBar(
                  chatController: chatController,
                  themeController: themeController,
                )
              : AppBar(
            title: Text(
              "Chat",
              style: AppTextStyles.bodyText(context).copyWith(
                  fontSize: AppResponsive.scaleSize(context, 20),
                  fontWeight: FontWeight.w600),
            ),
                  backgroundColor:
                      isDark ? Color(0XFF1D1D1D) : Color(0XFFFFFFFF),
            elevation: 0,
            actionsPadding: AppSpacing.symmetric(context, v: 0, h: 0.03),
            actions: [
              // Refresh button
              IconButton(
                onPressed: () {
                  chatController.refreshChats();
                  Get.snackbar(
                    'Refreshing...',
                    'Loading latest conversations...',
                    backgroundColor: Colors.blue,
                    colorText: Colors.white,
                    duration: Duration(seconds: 2),
                  );
                },
                icon: Icon(Icons.refresh),
                tooltip: 'Refresh chats',
              ),
              CreateNewChatButton(chatController: chatController),
            ],
          ),
          body: SafeArea(
            child: Stack(
              children: [
                Column(
              children: [
                    // Search Bar or Select All UI
                    if (chatController.isSelectionMode.value)
                      _buildSelectionModeUI(context, isDark)
                    else
                      ChatSearchBar(
                          isDark: isDark, chatController: chatController),

                // Filter Tabs
                _buildFilterTabs(context),

                // Chat List
                Expanded(
                  child: _buildChatList(context),
                    ),
                  ],
                ),

                // More Options Dropdown
                if (chatController.isSelectionMode.value)
                  ChatMoreOptionsDropdown(
                    chatController: chatController,
                    themeController: themeController,
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
          BoxDecoration(color: isDark ? Color(0XFF1D1D1D) : Color(0XFFFFFFFF)),
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
    final chatController = Get.find<ChatController>();
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
                ? isDark
                    ? Color(0XFF0A0A0A)
                    : Color(0XFFF4F6FC)
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
    final chatController = Get.find<ChatController>();
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
                child: CircularProgressIndicator(
                  color: AppColors.primary,
                ),
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
                  final String lastMessage = chat['lastMessage'] ?? '';
                  print('🔍 Chat Item Debug:');
                  print('  Contact: $contactName');
                  print('  Profile Image: $profileImageUrl');
                  print('  Last Message: $lastMessage');
                  print('  Platform: ${chat['platform']}');
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

  Widget _buildSelectionModeUI(BuildContext context, bool isDark) {
    final chatController = Get.find<ChatController>();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1D1D1D) : Colors.white,
        borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
          Obx(() => Checkbox(
                value: chatController.selectedChatsCount ==
                        chatController.filteredChatList.length &&
                    chatController.filteredChatList.isNotEmpty,
                onChanged: (value) {
                  if (value == true) {
                    chatController.selectAllChats();
                  } else {
                    chatController.selectedChats.clear();
                  }
                },
                activeColor: AppColors.primary,
              )),
          const SizedBox(width: 8),
          Text(
            'Select all',
            style: AppTextStyles.bodyText(context).copyWith(
              fontSize: AppResponsive.scaleSize(context, 14),
              color: isDark ? Colors.white : Colors.black87,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChatItem(Map<String, dynamic> chat, BuildContext context) {
    final chatController = Get.find<ChatController>();
    final themeController = Get.find<ThemeController>();
    final String chatId =
        (chat['id'] ?? chat['conversationId'] ?? '') as String;

    final String profileImageUrl = (chat['profileImageUrl'] as String?) ?? '';
    final String contactName = (chat['contactName'] as String?) ?? '';
    final String initial =
        contactName.isNotEmpty ? contactName[0].toUpperCase() : '?';

    // Build avatar based on chat type
    Widget avatarWidget;
    if (chat['type'] == 'group') {
      final members = chat['members'] as List<Map<String, dynamic>>? ?? [];
      avatarWidget = _buildGroupAvatar(members, context);
    } else {
      // Regular individual chat avatar
      avatarWidget = Stack(
        children: [
          CircleAvatar(
            radius: 24,
            backgroundImage: profileImageUrl.isNotEmpty
                ? NetworkImage(profileImageUrl)
                : null,
            backgroundColor: _getPlatformColor(chat['platform']),
            onBackgroundImageError: (exception, stackTrace) {
              print('❌ Failed to load profile image for $contactName: $exception');
            },
            child: profileImageUrl.isEmpty
                ? Text(
                    initial,
                    style: AppTextStyles.heading(context).copyWith(
                      color: Colors.white,
                    ),
                  )
                : null,
          ),
          // Add platform badge for Facebook chats
          if (chat['platform'] == 'Facebook')
            Positioned(
              bottom: 0,
              right: 0,
              child: Container(
                width: 16,
                height: 16,
                decoration: BoxDecoration(
                  color: Colors.blue,
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 2),
                ),
                child: Icon(
                  Icons.chat,
                  size: 10,
                  color: Colors.white,
                ),
              ),
            ),
        ],
      );
    }

    return GestureDetector(
      onTap: () {
        if (chatController.isSelectionMode.value) {
          chatController.toggleChatSelection(chatId);
        } else {
          chatController.markAsRead(chat['id']);
          // Check if it's a group chat
          if (chat['type'] == 'group') {
            Get.toNamed(AppRoutes.groupChat, arguments: chat);
          } else {
            Get.to(() => ChatConversationScreen(chat: chat));
          }
        }
      },
      onLongPress: () {
        if (!chatController.isSelectionMode.value) {
          chatController.enterSelectionMode();
          chatController.toggleChatSelection(chatId);
        }
      },
      child: Obx(
        () => Container(
          padding: const EdgeInsets.all(16).copyWith(left: 0, right: 0),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppResponsive.radius(context)),
            color: chatController.isSelectionMode.value &&
                    chatController.isChatSelected(chatId)
                ? (themeController.isDarkMode
                    ? const Color(0xFF2D2D2D)
                    : const Color(0xFFF0F0F0))
                : Colors.transparent,
          ),
          child: Row(
            children: [
              // Selection Checkbox or Profile Image
              if (chatController.isSelectionMode.value) ...[
                chatController.isChatSelected(chatId)
                    ? Container(
                        width: 48,
                        height: 48,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: Color(0xFFD9D9D9),
                        ),
                        child: const Icon(
                          Icons.check,
                          size: 24,
                          color: Colors.black,
                        ),
                      )
                    : avatarWidget,
              ] else ...[
                // Profile Image with Platform Badge (same avatar for non-selection mode)
                avatarWidget,
              ],

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
                            contactName,
                          style: AppTextStyles.bodyText(context),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 8),
                        Text(
                          chatController.getTimeDisplay(chat['timestamp']),
                          style: AppTextStyles.hintText(context),
                        ),
                    ],
                  ),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                            (chat['lastMessage'] as String?) ?? '',
                          style: AppTextStyles.hintText(context),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                        // Unused trailing space reserved for future message count if needed
                    ],
                  ),
                ],
              ),
            ),

            // Unread Badge
              if (((chat['unreadCount'] ?? 0) as int) > 0)
              Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.red,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                    (chat['unreadCount'] as int).toString(),
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
      ),
    );
  }

  Widget _buildCreateNewDropdown() {
    final chatController = Get.find<ChatController>();
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
    final chatController = Get.find<ChatController>();
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

  Widget _buildGroupAvatar(List<Map<String, dynamic>> members, BuildContext context) {
    if (members.isEmpty) {
      return CircleAvatar(
        radius: 24,
        backgroundColor: Colors.grey[400],
        child: Icon(
          Icons.group,
          color: Colors.white,
          size: 24,
        ),
      );
    }

    if (members.length == 1) {
      final member = members.first;
      final memberName = member['name'] ?? '';
      final memberImageUrl = member['profileImageUrl'] as String?;
      final initial = memberName.isNotEmpty ? memberName[0].toUpperCase() : '?';
      
      return CircleAvatar(
        radius: 24,
        backgroundImage: memberImageUrl != null && memberImageUrl.isNotEmpty
            ? NetworkImage(memberImageUrl)
            : null,
        backgroundColor: _getAvatarColor(memberName),
        child: memberImageUrl == null || memberImageUrl.isEmpty
            ? Text(
                initial,
                style: AppTextStyles.heading(context).copyWith(
                  color: Colors.white,
                ),
              )
            : null,
      );
    }

    // Multiple members - show overlapping avatars
    return SizedBox(
      width: 48,
      height: 48,
      child: Stack(
        children: [
          // First member (left)
          Positioned(
            left: 0,
            top: 0,
            child: CircleAvatar(
              radius: 20,
              backgroundColor: _getAvatarColor(members[0]['name'] ?? ''),
              child: Text(
                _getInitials(members[0]['name'] ?? ''),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          // Second member (right, overlapping)
          if (members.length > 1)
            Positioned(
              right: 0,
              bottom: 0,
              child: CircleAvatar(
                radius: 20,
                backgroundColor: _getAvatarColor(members[1]['name'] ?? ''),
                child: Text(
                  _getInitials(members[1]['name'] ?? ''),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  String _getInitials(String name) {
    if (name.isEmpty) return '?';
    final words = name.trim().split(' ');
    if (words.length == 1) {
      return words[0].substring(0, 1).toUpperCase();
    } else {
      final firstLetter = words[0].substring(0, 1).toUpperCase();
      final secondLetter = words[1].substring(0, 1).toUpperCase();
      return firstLetter + secondLetter;
    }
  }

  Color _getAvatarColor(String name) {
    final colors = [
      Colors.blue,
      Colors.green,
      Colors.orange,
      Colors.purple,
      Colors.teal,
      Colors.indigo,
      Colors.pink,
      Colors.cyan,
      Colors.red,
      Colors.amber,
      Colors.deepPurple,
      Colors.lightBlue,
    ];
    final hash = name.hashCode;
    return colors[hash.abs() % colors.length];
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
