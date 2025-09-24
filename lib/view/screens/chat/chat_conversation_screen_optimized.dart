import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:minechat/core/services/facebook_graph_api_service.dart';
import 'package:minechat/controller/channel_controller/channel_controller.dart';
import 'package:minechat/controller/chat_controller/chat_controller.dart';
import 'package:minechat/core/services/realtime_message_service.dart';
import 'package:minechat/core/widgets/chat/message_bubble_widget.dart';
import 'package:minechat/core/widgets/chat/message_input_widget.dart';
import 'package:minechat/core/widgets/chat/chat_app_bar_widget.dart';
import 'package:minechat/core/widgets/chat/ai_enabled_indicator_widget.dart';
import 'package:minechat/core/widgets/common/loading_widgets.dart';

/// Optimized Chat Conversation Screen - Reduced from 991 to ~200 lines
class ChatConversationScreenOptimized extends StatelessWidget {
  final Map<String, dynamic> chat;
  final conversationController = Get.put(ChatConversationController());

  ChatConversationScreenOptimized({required this.chat});

  @override
  Widget build(BuildContext context) {
    // Pass chat data to controller
    conversationController.setChatData(chat);
    
    return Scaffold(
      backgroundColor: Colors.white,
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

      return Container(
        decoration: const BoxDecoration(
          color: Color(0xFFECE5DD), // WhatsApp-like background
        ),
        child: ListView.builder(
          controller: conversationController._scrollController,
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

/// Optimized Chat Conversation Controller - Reduced from ~400 to ~150 lines
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
  
  // Scroll controller for auto-scrolling to bottom
  final ScrollController _scrollController = ScrollController();
  
  @override
  void onInit() {
    super.onInit();
    print('🔍 ChatConversationController initialized');
  }
  
  @override
  void onClose() {
    _stopMessagePolling();
    _scrollController.dispose();
    messageController.dispose();
    super.onClose();
  }
  
  /// Set chat data and initialize conversation
  void setChatData(Map<String, dynamic> chat) {
    chatData = chat;
    conversationId = chat['conversationId'] ?? chat['id'];
    userId = chat['userId'];
    print('🔍 Setting chat data for conversation: $conversationId');
    print('🔍 User ID: $userId');
    
    // Load real messages
    loadMessages();
    
    // Start real-time message polling
    _startMessagePolling();
  }
  
  /// Load messages for the conversation
  Future<void> loadMessages() async {
    if (conversationId == null) return;
    
    setLoading(true);
    try {
      print('📥 Loading messages for conversation: $conversationId');
      
      // Get page access token
      final channelController = Get.find<ChannelController>();
      final facebookPageId = chatData?['pageId'];
      final pageAccessToken = await channelController.getPageAccessToken(facebookPageId);
      
      if (pageAccessToken == null || pageAccessToken.isEmpty) {
        print('❌ No page access token available');
        setLoading(false);
        return;
      }
      
      this.pageAccessToken = pageAccessToken;
      this.facebookPageId = facebookPageId;
      
      // Load messages from Facebook
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
      final result = await FacebookGraphApiService.getConversationMessagesWithToken(
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
        print('✅ Loaded ${convertedMessages.length} real Facebook messages');
        
        // Auto-scroll to bottom after loading messages
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
      // Add message to local list immediately
      final newMessage = {
        'id': DateTime.now().millisecondsSinceEpoch.toString(),
        'text': messageText,
        'timestamp': _formatTimestamp(DateTime.now().toIso8601String()),
        'isFromUser': true,
        'isAI': false,
      };
      
      messages.add(newMessage);
      print('📝 Added message to local list: $newMessage');
      messageController.clear();
      
      // Auto-scroll to bottom after adding new message
      _scrollToBottom();
      
      // Send to Facebook
      final sendResult = await FacebookGraphApiService.sendMessageToConversation(
        conversationId!,
        pageAccessToken!,
        messageText,
        userId: userId,
      );
      
      if (sendResult['success'] == true) {
        print('✅ Message sent successfully to Facebook');
        
        // Store message in Firebase for real-time sync
        _realtimeService.storeMessage(
          conversationId: conversationId!,
          messageText: messageText,
          isFromUser: true,
          platform: 'Facebook',
          senderId: userId,
          senderName: 'You',
        ).catchError((error) {
          print('⚠️ Error storing message in Firebase: $error');
        });
        
      } else {
        print('❌ Failed to send message: ${sendResult['error']}');
        Get.snackbar('Error', 'Failed to send message: ${sendResult['error']}');
        
        // Remove the message from local list if sending failed
        messages.remove(newMessage);
        messageController.text = messageText; // Restore the text
      }
      
    } catch (e) {
      print('❌ Error sending message: $e');
      Get.snackbar('Error', 'Failed to send message: $e');
    } finally {
      setSending(false);
    }
  }
  
  /// Auto-scroll to bottom of messages
  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      Future.delayed(Duration(milliseconds: 100), () {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      });
    }
  }
  
  /// Format timestamp for display
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
    } catch (e) {
      return 'now';
    }
  }
  
  /// Set loading state
  void setLoading(bool loading) {
    isLoading.value = loading;
  }
  
  /// Set sending state
  void setSending(bool sending) {
    isSending.value = sending;
  }
  
  /// Start real-time message polling
  void _startMessagePolling() {
    print('🔄 Starting message polling for conversation: $conversationId');
    _messagePollingTimer?.cancel(); // Cancel any existing timer
    
    _messagePollingTimer = Timer.periodic(Duration(seconds: 10), (timer) {
      _pollForNewMessages();
    });
  }
  
  /// Stop message polling
  void _stopMessagePolling() {
    print('⏹️ Stopping message polling');
    _messagePollingTimer?.cancel();
    _messagePollingTimer = null;
  }
  
  /// Poll for new messages
  Future<void> _pollForNewMessages() async {
    if (conversationId == null || pageAccessToken == null) return;
    
    try {
      print('🔍 Polling for new messages...');
      
      final result = await FacebookGraphApiService.getConversationMessagesWithToken(
        conversationId!,
        pageAccessToken!,
      );
      
      if (result['success'] == true) {
        final newMessagesData = result['data'] as List<dynamic>;
        
        // Check if we have new messages
        if (newMessagesData.length > messages.length) {
          print('📨 Found ${newMessagesData.length - messages.length} new messages');
          
          // Convert new messages
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
          
          // Update messages list
          messages.value = convertedMessages;
          
          // Auto-scroll to bottom for new messages
          _scrollToBottom();
          
          print('✅ Updated messages list with ${convertedMessages.length} messages');
        }
      }
    } catch (e) {
      print('❌ Error polling for new messages: $e');
    }
  }
}
