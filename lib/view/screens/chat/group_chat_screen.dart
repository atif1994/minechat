import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:minechat/controller/chat_controller/chat_controller.dart';
import 'package:minechat/controller/theme_controller/theme_controller.dart';
import 'package:minechat/core/constants/app_colors/app_colors.dart';
import 'package:minechat/core/utils/helpers/app_responsive/app_responsive.dart';
import 'package:minechat/core/utils/helpers/app_styles/app_text_styles.dart';
import 'package:minechat/core/widgets/chat/group_creation_widgets.dart';

class GroupChatScreen extends StatefulWidget {
  final Map<String, dynamic> groupData;

  const GroupChatScreen({
    Key? key,
    required this.groupData,
  }) : super(key: key);

  @override
  State<GroupChatScreen> createState() => _GroupChatScreenState();
}

class _GroupChatScreenState extends State<GroupChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  
  late ChatController _chatController;
  late ThemeController _themeController;
  var messages = <Map<String, dynamic>>[].obs;
  var isTyping = false.obs;

  @override
  void initState() {
    super.initState();
    _chatController = Get.find<ChatController>();
    _themeController = Get.find<ThemeController>();
    _initializeGroupChat();
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _initializeGroupChat() {
    // Add initial status messages
    messages.addAll([
      {
        'id': 'status_1',
        'text': 'You created the group.',
        'type': 'system',
        'timestamp': DateTime.now().subtract(const Duration(minutes: 5)),
        'senderName': 'System',
      },
      {
        'id': 'status_2', 
        'text': 'You named the group ${widget.groupData['contactName'] ?? 'Unnamed Group'}.',
        'type': 'system',
        'timestamp': DateTime.now().subtract(const Duration(minutes: 4)),
        'senderName': 'System',
      },
    ]);
  }

  void _sendMessage() async {
    final messageText = _messageController.text.trim();
    if (messageText.isEmpty) return;

    try {
      // Show typing indicator
      isTyping.value = true;

      // Add user message immediately
      final userMessage = {
        'id': DateTime.now().millisecondsSinceEpoch.toString(),
        'message': messageText,
        'text': messageText,
        'type': 'user',
        'timestamp': DateTime.now().toIso8601String(),
        'senderName': 'You',
        'senderId': _chatController.getCurrentUserId(),
      };

      messages.add(userMessage);
      _messageController.clear();
      _scrollToBottom();

      // Update group chat in ChatController and Firestore
      await _chatController.updateGroupChat(widget.groupData['id'], userMessage);

      // Simulate AI response (in real app, this would call your AI service)
      await Future.delayed(const Duration(seconds: 1));

      // Add AI response
      final aiMessage = {
        'id': (DateTime.now().millisecondsSinceEpoch + 1).toString(),
        'message': 'Hello everyone! Thanks for creating the group. How can I help you today?',
        'text': 'Hello everyone! Thanks for creating the group. How can I help you today?',
        'type': 'ai',
        'timestamp': DateTime.now().toIso8601String(),
        'senderName': 'AI Assistant',
        'senderId': 'ai_assistant',
      };

      messages.add(aiMessage);
      _scrollToBottom();

      // Update group chat with AI message
      await _chatController.updateGroupChat(widget.groupData['id'], aiMessage);

    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to send message: $e',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isTyping.value = false;
    }
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = _themeController.isDarkMode;
    
    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0A0A0A) : const Color(0xFFF4F6FC),
      appBar: _buildAppBar(context, isDark),
      body: Column(
        children: [
          // Group Info Section
          _buildGroupInfoSection(context, isDark),
          
          // Messages List
          Expanded(
            child: Obx(() => ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.all(16),
              itemCount: messages.length + (isTyping.value ? 1 : 0),
              itemBuilder: (context, index) {
                if (index == messages.length && isTyping.value) {
                  return _buildTypingIndicator(context);
                }
                
                final message = messages[index];
                return _buildMessageBubble(context, message, isDark);
              },
            )),
          ),
          
          // Message Input
          _buildMessageInput(context, isDark),
        ],
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context, bool isDark) {
    final members = widget.groupData['members'] as List<Map<String, dynamic>>;
    
    return AppBar(
      backgroundColor: isDark ? const Color(0xFF1D1D1D) : Colors.white,
      elevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back, color: AppColors.primary),
        onPressed: () => Get.back(),
      ),
      title: Row(
        children: [
          // Group Avatar
          Container(
            width: 32,
            height: 32,
            child: GroupProfileAvatar(
              members: members.take(4).toList(),
              size: 32,
            ),
          ),
          const SizedBox(width: 8),
          
          // Group Name and Status
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.groupData['contactName'] ?? 'Unnamed Group',
                  style: AppTextStyles.bodyText(context).copyWith(
                    fontWeight: FontWeight.w600,
                    fontSize: AppResponsive.scaleSize(context, 16),
                  ),
                ),
                Text(
                  'Active now',
                  style: AppTextStyles.hintText(context).copyWith(
                    fontSize: AppResponsive.scaleSize(context, 12),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.call, color: AppColors.primary),
          onPressed: () {
            Get.snackbar('Call', 'Voice call feature coming soon');
          },
        ),
        IconButton(
          icon: const Icon(Icons.videocam, color: AppColors.primary),
          onPressed: () {
            Get.snackbar('Video Call', 'Video call feature coming soon');
          },
        ),
      ],
    );
  }

  Widget _buildGroupInfoSection(BuildContext context, bool isDark) {
    final members = widget.groupData['members'] as List<Map<String, dynamic>>;
    
    return Container(
      padding: const EdgeInsets.all(16),
      color: isDark ? const Color(0xFF1D1D1D) : Colors.white,
      child: Column(
        children: [
          // Group Profile
          GroupProfileAvatar(
            members: members,
            size: 120,
          ),
          const SizedBox(height: 16),
          
          // Group Name
          Text(
            widget.groupData['contactName'] ?? 'Unnamed Group',
            style: AppTextStyles.heading(context).copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          
          Text(
            'You created this group',
            style: AppTextStyles.hintText(context),
          ),
          const SizedBox(height: 20),
          
          // Group Actions
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildActionButton(
                context,
                Icons.person_add,
                'Add',
                () => Get.snackbar('Add Member', 'Add member feature coming soon'),
              ),
              _buildActionButton(
                context,
                Icons.edit,
                'Name',
                () => Get.snackbar('Edit Name', 'Edit name feature coming soon'),
              ),
              _buildActionButton(
                context,
                Icons.people,
                'Members',
                () => Get.snackbar('View Members', 'View members feature coming soon'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton(BuildContext context, IconData icon, String label, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              color: AppColors.primary,
              size: 24,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: AppTextStyles.hintText(context).copyWith(
              fontSize: AppResponsive.scaleSize(context, 12),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMessageBubble(BuildContext context, Map<String, dynamic> message, bool isDark) {
    final messageType = message['type'] as String;
    final isUser = messageType == 'user';
    final isSystem = messageType == 'system';
    
    if (isSystem) {
      return _buildSystemMessage(context, message);
    }
    
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisAlignment: isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        children: [
          if (!isUser) ...[
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: AppColors.primary,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.smart_toy,
                color: Colors.white,
                size: 16,
              ),
            ),
            const SizedBox(width: 8),
          ],
          
          Flexible(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: isUser 
                    ? AppColors.primary
                    : (isDark ? const Color(0xFF2D2D2D) : Colors.white),
                borderRadius: BorderRadius.circular(20),
                border: isUser 
                    ? null 
                    : Border.all(color: Colors.grey[300]!),
              ),
              child: Text(
                message['text'],
                style: AppTextStyles.bodyText(context).copyWith(
                  color: isUser ? Colors.white : null,
                ),
              ),
            ),
          ),
          
          if (isUser) ...[
            const SizedBox(width: 8),
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: AppColors.primary,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.person,
                color: Colors.white,
                size: 16,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildSystemMessage(BuildContext context, Map<String, dynamic> message) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Center(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.grey[200],
            borderRadius: BorderRadius.circular(16),
          ),
          child: Text(
            message['text'],
            style: AppTextStyles.hintText(context).copyWith(
              fontStyle: FontStyle.italic,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTypingIndicator(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: AppColors.primary,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.smart_toy,
              color: Colors.white,
              size: 16,
            ),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.grey[200],
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildTypingDot(0),
                const SizedBox(width: 4),
                _buildTypingDot(1),
                const SizedBox(width: 4),
                _buildTypingDot(2),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTypingDot(int index) {
    return TweenAnimationBuilder<double>(
      duration: const Duration(milliseconds: 600),
      tween: Tween(begin: 0.0, end: 1.0),
      builder: (context, value, child) {
        final delay = index * 0.2;
        final animationValue = (value - delay).clamp(0.0, 1.0);
        final opacity = (animationValue * 2 - 1).abs();
        
        return Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            color: Colors.grey[600]!.withOpacity(opacity),
            shape: BoxShape.circle,
          ),
        );
      },
    );
  }

  Widget _buildMessageInput(BuildContext context, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1D1D1D) : Colors.white,
        border: Border(
          top: BorderSide(color: Colors.grey[300]!),
        ),
      ),
      child: Row(
        children: [
          // Emoji Button
          IconButton(
            icon: const Icon(Icons.emoji_emotions_outlined, color: AppColors.primary),
            onPressed: () {
              Get.snackbar('Emoji', 'Emoji picker coming soon');
            },
          ),
          
          // Message Input
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF2D2D2D) : Colors.grey[100],
                borderRadius: BorderRadius.circular(24),
              ),
              child: TextField(
                controller: _messageController,
                decoration: const InputDecoration(
                  hintText: 'Send a message...',
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.zero,
                ),
                maxLines: null,
                onSubmitted: (_) => _sendMessage(),
              ),
            ),
          ),
          
          const SizedBox(width: 8),
          
          // GIF Button
          IconButton(
            icon: const Icon(Icons.gif, color: AppColors.primary),
            onPressed: () {
              Get.snackbar('GIF', 'GIF picker coming soon');
            },
          ),
          
          // Camera Button
          IconButton(
            icon: const Icon(Icons.camera_alt, color: AppColors.primary),
            onPressed: () {
              Get.snackbar('Camera', 'Camera feature coming soon');
            },
          ),
          
          // Send Button
          GestureDetector(
            onTap: _sendMessage,
            child: Container(
              width: 40,
              height: 40,
              decoration: const BoxDecoration(
                color: AppColors.primary,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.send,
                color: Colors.white,
                size: 20,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
