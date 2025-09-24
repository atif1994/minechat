import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:minechat/controller/theme_controller/theme_controller.dart';
import 'package:minechat/core/services/facebook_graph_api_service.dart';
import 'package:minechat/controller/channel_controller/channel_controller.dart';
import 'package:minechat/core/services/realtime_message_service.dart';
import 'package:minechat/core/widgets/chat/message_bubble_widget.dart';
import 'package:minechat/core/widgets/chat/message_input_widget.dart';
import 'package:minechat/core/widgets/chat/chat_app_bar_widget.dart';
import 'package:minechat/core/widgets/chat/ai_enabled_indicator_widget.dart';
import 'package:minechat/core/widgets/common/loading_widgets.dart';

/// Optimized Chat Conversation Screen
class ChatConversationScreen extends StatelessWidget {
  final themeController = Get.find<ThemeController>();
  final Map<String, dynamic> chat;
  final conversationController = Get.put(ChatConversationController());

  ChatConversationScreen({required this.chat});

  @override
  Widget build(BuildContext context) {
    // Pass chat data to controller
    conversationController.setChatData(chat);

    return Obx(
      () {
        final isDark = themeController.isDarkMode;
        return Scaffold(
          backgroundColor: isDark ? const Color(0XFF0A0A0A) : Colors.white,
          appBar: ChatAppBarWidget(
            contactName: chat['contactName'] ?? 'Unknown',
            profileImageUrl: chat['profileImageUrl'],
            onBackPressed: () => Get.back(),
            onProfileTap: () => Get.snackbar('Info', 'Viewing profile...'),
            onAITap: () => Get.snackbar('Info', 'AI Assistant toggled...'),
          ),
          body: Column(
            children: [
              // AI Enabled indicator
              AIEnabledIndicatorWidget(
                isEnabled: true,
                onTap: () => Get.snackbar('Info', 'AI settings...'),
              ),

              // Messages
              Expanded(
                child: _buildMessagesList(),
              ),

              // Message Input
              MessageInputWidget(
                messageController: conversationController.messageController,
                isSending: conversationController.isSending,
                onSendMessage: conversationController.sendMessage,
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildMessagesList() {
    return Obx(() {
      if (conversationController.isLoading.value) {
        return LoadingWidgets.list(message: 'Loading messages...');
      }

      if (conversationController.messages.isEmpty) {
        return EmptyStateWidget(
          icon: Icons.chat_bubble_outline,
          title: 'No messages yet',
          subtitle: 'Start a conversation by sending a message',
        );
      }

      final themeController = Get.find<ThemeController>();
      final isDark = themeController.isDarkMode;

      return Container(
        decoration: BoxDecoration(
          color: isDark ? const Color(0XFF0A0A0A) : Colors.white,
        ),
        child: ListView.builder(
          controller: conversationController.scrollController,
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          itemCount: conversationController.messages.length,
          itemBuilder: (context, index) {
            final message = conversationController.messages[index];
            return MessageBubbleWidget(
              message: message['text'] ?? '',
              timestamp: message['timestamp'] ?? '',
              isFromUser: message['isFromUser'] ?? false,
              isAI: message['isAI'] ?? false,
            );
          },
        ),
      );
    });
  }
}

/// Optimized Chat Conversation Controller
class ChatConversationController extends GetxController {
  final messageController = TextEditingController();
  var messages = <Map<String, dynamic>>[].obs;
  var isLoading = true.obs;
  var isSending = false.obs;

  // Facebook conversation data
  String? conversationId;
  String? userId;
  String? pageAccessToken;
  String? facebookPageId;
  Map<String, dynamic>? chatData;

  // Real-time service
  final RealtimeMessageService _realtimeService = RealtimeMessageService();

  // Message polling timer
  Timer? _messagePollingTimer;

  // Scroll controller
  final ScrollController scrollController = ScrollController();

  @override
  void onClose() {
    _stopMessagePolling();
    scrollController.dispose();
    messageController.dispose();
    super.onClose();
  }

  /// Set chat data and initialize conversation
  void setChatData(Map<String, dynamic> chat) {
    chatData = chat;
    conversationId = chat['conversationId'] ?? chat['id'];
    userId = chat['userId'];

    loadMessages();
    _startMessagePolling();
  }

  /// Load messages
  Future<void> loadMessages() async {
    if (conversationId == null) return;

    setLoading(true);
    try {
      final channelController = Get.find<ChannelController>();
      // Safely read pageId as String?
      facebookPageId = chatData?['pageId'] as String?;

      // Guard against null/empty pageId
      final pageId = facebookPageId;
      if (pageId == null || pageId.isEmpty) {
        setLoading(false);
        return;
      }

      // Now pass a non-null String
      pageAccessToken = await channelController.getPageAccessToken(pageId);

      if (pageAccessToken == null || pageAccessToken!.isEmpty) {
        setLoading(false);
        return;
      }

      await _loadFacebookMessages();
    } catch (e) {
      print('❌ Error loading messages: $e');
    } finally {
      setLoading(false);
    }
  }

  /// Load messages from Facebook Graph API
  Future<void> _loadFacebookMessages() async {
    try {
      final result =
          await FacebookGraphApiService.getConversationMessagesWithToken(
        conversationId!,
        pageAccessToken!,
      );

      if (result['success'] == true) {
        final messagesData = result['data'] as List<dynamic>;
        final convertedMessages = messagesData.map((message) {
          final isFromUser = message['from']['id'] == facebookPageId;
          return {
            'id': message['id'],
            'text': message['message'] ?? '',
            'timestamp': _formatTimestamp(message['created_time']),
            'isFromUser': isFromUser,
            'isAI': false,
          };
        }).toList();

        messages.value = convertedMessages;
        _scrollToBottom();
      } else {
        print('❌ Failed to load messages: ${result['error']}');
      }
    } catch (e) {
      print('❌ Error loading Facebook messages: $e');
    }
  }

  /// Send message
  Future<void> sendMessage() async {
    final messageText = messageController.text.trim();
    if (messageText.isEmpty) return;

    if (conversationId == null || pageAccessToken == null) {
      Get.snackbar('Error', 'Cannot send message: Missing conversation data');
      return;
    }

    setSending(true);

    try {
      final newMessage = {
        'id': DateTime.now().millisecondsSinceEpoch.toString(),
        'text': messageText,
        'timestamp': _formatTimestamp(DateTime.now().toIso8601String()),
        'isFromUser': true,
        'isAI': false,
      };

      messages.add(newMessage);
      messageController.clear();
      _scrollToBottom();

      final sendResult =
          await FacebookGraphApiService.sendMessageToConversation(
        conversationId!,
        pageAccessToken!,
        messageText,
        userId: userId,
      );

      if (sendResult['success'] == true) {
        _realtimeService.storeMessage(
          conversationId: conversationId!,
          messageText: messageText,
          isFromUser: true,
          platform: 'Facebook',
          senderId: userId,
          senderName: 'You',
        );
      } else {
        messages.remove(newMessage);
        messageController.text = messageText; // Restore
        Get.snackbar('Error', 'Failed to send: ${sendResult['error']}');
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to send message: $e');
    } finally {
      setSending(false);
    }
  }

  /// Auto-scroll
  void _scrollToBottom() {
    if (scrollController.hasClients) {
      Future.delayed(const Duration(milliseconds: 100), () {
        scrollController.animateTo(
          scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      });
    }
  }

  /// Format timestamp
  String _formatTimestamp(String timestamp) {
    try {
      final dateTime = DateTime.parse(timestamp);
      final now = DateTime.now();
      final difference = now.difference(dateTime);

      if (difference.inMinutes < 1) {
        return 'now';
      } else if (difference.inHours < 1) {
        return '${difference.inMinutes}m';
      } else if (difference.inDays < 1) {
        return '${difference.inHours}h';
      } else {
        return '${difference.inDays}d';
      }
    } catch (_) {
      return 'now';
    }
  }

  void setLoading(bool loading) => isLoading.value = loading;

  void setSending(bool sending) => isSending.value = sending;

  /// Polling
  void _startMessagePolling() {
    _messagePollingTimer?.cancel();
    _messagePollingTimer = Timer.periodic(
        const Duration(seconds: 10), (_) => _pollForNewMessages());
  }

  void _stopMessagePolling() {
    _messagePollingTimer?.cancel();
    _messagePollingTimer = null;
  }

  Future<void> _pollForNewMessages() async {
    if (conversationId == null || pageAccessToken == null) return;

    try {
      final result =
          await FacebookGraphApiService.getConversationMessagesWithToken(
        conversationId!,
        pageAccessToken!,
      );

      if (result['success'] == true) {
        final newMessagesData = result['data'] as List<dynamic>;
        if (newMessagesData.length > messages.length) {
          final convertedMessages = newMessagesData.map((message) {
            final isFromUser = message['from']['id'] == facebookPageId;
            return {
              'id': message['id'],
              'text': message['message'] ?? '',
              'timestamp': _formatTimestamp(message['created_time']),
              'isFromUser': isFromUser,
              'isAI': false,
            };
          }).toList();

          messages.value = convertedMessages;
          _scrollToBottom();
        }
      }
    } catch (e) {
      print('❌ Error polling messages: $e');
    }
  }
}
