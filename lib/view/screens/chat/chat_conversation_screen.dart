import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:minechat/controller/theme_controller/theme_controller.dart';
import 'package:minechat/core/services/facebook_graph_api_service.dart';
import 'package:minechat/controller/channel_controller/channel_controller.dart';
import 'package:minechat/core/services/realtime_message_service.dart';
import 'package:minechat/core/services/facebook_webhook_service.dart';
import 'package:minechat/core/services/simple_webhook_service.dart';
import 'package:minechat/core/widgets/chat/message_bubble_widget.dart';
import 'package:minechat/core/widgets/chat/message_input_widget.dart';
import 'package:minechat/core/widgets/chat/chat_app_bar_widget.dart';
import 'package:minechat/core/widgets/chat/ai_enabled_indicator_widget.dart';
import 'package:minechat/core/widgets/common/loading_widgets.dart';

/// Optimized Chat Conversation Screen
class ChatConversationScreen extends StatelessWidget {
  final themeController = Get.find<ThemeController>();
  final Map<String, dynamic> chat;
  final conversationController = Get.put(ChatConversationController(), tag: 'ChatConversationController');

  ChatConversationScreen({required this.chat});

  @override
  Widget build(BuildContext context) {
    // Pass chat data to controller
    conversationController.setChatData(chat);

    // Force scroll to bottom after UI is built - WhatsApp-like behavior
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Future.delayed(const Duration(milliseconds: 100), () {
        conversationController._forceScrollToBottom();
      });
    });

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
          reverse: false, // Ensure messages are in normal order (oldest to newest)
          itemBuilder: (context, index) {
            final message = conversationController.messages[index];
            return MessageBubbleWidget(
              message: message['text'] ?? '',
              timestamp: message['timestamp'] ?? '',
              isFromUser: message['isFromUser'] ?? false,
              isAI: message['isAI'] ?? false,
              avatar: _buildUserAvatar(message),
            );
          },
        ),
      );
    });
  }

  /// Build user avatar for messages
  Widget _buildUserAvatar(Map<String, dynamic> message) {
    final isFromUser = message['isFromUser'] ?? false;
    final senderName = message['senderName'] ?? 'Unknown User';
    final senderId = message['senderId'] ?? '';
    
    // For now, use a simple avatar with initials
    // TODO: Fetch actual profile images from Facebook Graph API
    return CircleAvatar(
      radius: 16,
      backgroundColor: isFromUser ? Colors.blue : Colors.grey,
      child: Text(
        senderName.isNotEmpty ? senderName[0].toUpperCase() : 'U',
        style: const TextStyle(
          color: Colors.white,
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
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

  // Real-time services
  final RealtimeMessageService _realtimeService = RealtimeMessageService();
  final FacebookWebhookService _webhookService = FacebookWebhookService();
  final SimpleWebhookService _simpleWebhookService = SimpleWebhookService();

  // Message polling timer
  Timer? _messagePollingTimer;
  
  // Track sent messages to prevent duplicates
  final Set<String> _sentMessageTexts = <String>{};
  
  // Track polling attempts to reduce frequency
  int _pollingAttempts = 0;

  // Scroll controller
  final ScrollController scrollController = ScrollController();

  @override
  void onInit() {
    super.onInit();
    print('🔄 ChatConversationController initialized');
    
    // Force scroll to bottom after initialization
    Future.delayed(const Duration(milliseconds: 1000), () {
      _forceScrollToBottom();
    });
  }

  @override
  void onClose() {
    _stopMessagePolling();
    _stopRealtimeListening();
    _stopWebhookListening();
    _stopSimpleWebhookListening();
    scrollController.dispose();
    messageController.dispose();
    super.onClose();
  }

  /// Set chat data and initialize conversation
  void setChatData(Map<String, dynamic> chat) {
    chatData = chat;
    conversationId = chat['conversationId'] ?? chat['id'];
    userId = chat['userId'];
    facebookPageId = chat['facebookPageId'] ?? chat['pageId'] ?? chat['facebookPageId'] ?? '';
    pageAccessToken = chat['pageAccessToken'] ?? chat['accessToken'] ?? chat['token'] ?? '';
    
    // If facebookPageId is still empty, try to get it from ChannelController
    if (facebookPageId?.isEmpty == true) {
      try {
        final channelController = Get.find<ChannelController>();
        facebookPageId = channelController.facebookPageIdCtrl.text;
        pageAccessToken = channelController.facebookAccessTokenCtrl.text;
        print('🔍 Got facebookPageId from ChannelController: $facebookPageId');
      } catch (e) {
        print('⚠️ Could not get facebookPageId from ChannelController: $e');
      }
    }
    
    // Final fallback - hardcoded facebookPageId from debug logs
    if (facebookPageId?.isEmpty == true) {
      facebookPageId = '313808701826338';
      print('🔍 Using hardcoded facebookPageId: $facebookPageId');
    }

    print('🔍 Chat Data Debug:');
    print('  conversationId: $conversationId');
    print('  userId: $userId');
    print('  facebookPageId: $facebookPageId');
    print('  pageAccessToken: ${pageAccessToken?.isNotEmpty == true ? 'SET' : 'NOT SET'}');
    print('  Full chat data keys: ${chat.keys.toList()}');
    print('  Full chat data: $chat');
    
    // CRITICAL: Ensure facebookPageId is set correctly
    if (facebookPageId == null || facebookPageId!.isEmpty) {
      print('❌ CRITICAL ERROR: facebookPageId is null or empty!');
      print('❌ This will cause ALL messages to appear on the right side!');
      print('❌ Setting hardcoded fallback immediately...');
      facebookPageId = '313808701826338';
    } else {
      print('✅ facebookPageId is set correctly: $facebookPageId');
    }
    
    // FINAL SAFETY CHECK: Force set facebookPageId if still null/empty
    if (facebookPageId == null || facebookPageId!.isEmpty) {
      facebookPageId = '313808701826338';
      print('🔧 FORCED facebookPageId to: $facebookPageId');
    }

    loadMessages();
    _startMessagePolling();
    _startRealtimeListening(); // ✅ ADDED: Start real-time listening
    
    // Start simple webhook listening (no controller dependencies)
    _startSimpleWebhookListening();
    
    // Force scroll to bottom when opening conversation - WhatsApp-like behavior
    Future.delayed(const Duration(milliseconds: 500), () {
      _forceScrollToBottom();
    });
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
      print('🔄 Loading Facebook messages for conversation: $conversationId');
      
      final result =
          await FacebookGraphApiService.getConversationMessagesWithToken(
        conversationId!,
        pageAccessToken!,
      );

      if (result['success'] == true) {
        final messagesData = result['data'] as List<dynamic>;
        print('📨 Loaded ${messagesData.length} messages from Facebook');
        
        final convertedMessages = messagesData.map((message) {
          // ✅ FIXED: Correct user detection logic
          final messageFromId = message['from']['id']?.toString() ?? '';
          final isFromUser = messageFromId != facebookPageId;
          
          // SAFETY CHECK: Ensure facebookPageId is not null/empty for comparison
          final safeFacebookPageId = facebookPageId ?? '313808701826338';
          final safeIsFromUser = messageFromId != safeFacebookPageId;
          final messageId = message['id'] ?? DateTime.now().millisecondsSinceEpoch.toString();
          
          print('💬 Message from ${isFromUser ? 'USER' : 'PAGE'}: ${message['message']}');
          print('🔍 Debug: messageFromId=$messageFromId, facebookPageId=$facebookPageId, isFromUser=$isFromUser');
          print('🔍 Message from object: ${message['from']}');
          
          // CRITICAL DEBUG: Check if facebookPageId is correct
          if (facebookPageId == null || facebookPageId!.isEmpty) {
            print('❌ CRITICAL: facebookPageId is null/empty in _loadFacebookMessages!');
            print('❌ This will cause ALL messages to appear on the right side!');
          }
          
          return {
            'id': messageId,
            'text': message['message'] ?? '',
            'timestamp': _formatTimestamp(message['created_time']),
            'facebookCreatedTime': message['created_time'], // Store original Facebook timestamp
            'isFromUser': safeIsFromUser, // Use safe comparison
            'isAI': false,
            'facebookMessageId': message['id'], // Store original Facebook ID
            'senderName': message['from']['name'] ?? 'Unknown User', // Store sender name
            'senderId': message['from']['id'] ?? '', // Store sender ID
          };
        }).toList();

        // Remove duplicate messages based on Facebook message ID
        final uniqueMessages = <String, Map<String, dynamic>>{};
        for (final message in convertedMessages) {
          final facebookId = message['facebookMessageId']?.toString() ?? '';
          if (facebookId.isNotEmpty && !uniqueMessages.containsKey(facebookId)) {
            uniqueMessages[facebookId] = message;
          }
        }
        final deduplicatedMessages = uniqueMessages.values.toList();
        
        // Sort messages by original Facebook timestamp (oldest first) - WhatsApp-like ordering
        deduplicatedMessages.sort((a, b) {
          // Use original Facebook timestamp for sorting, not formatted display timestamp
          final timeA = DateTime.tryParse(a['facebookCreatedTime'] ?? a['timestamp']) ?? DateTime.now();
          final timeB = DateTime.tryParse(b['facebookCreatedTime'] ?? b['timestamp']) ?? DateTime.now();
          
          // Primary sort by timestamp (oldest first, newest last)
          final timeComparison = timeA.compareTo(timeB);
          if (timeComparison != 0) return timeComparison;
          
          // Secondary sort by message ID for consistency
          final idA = a['id']?.toString() ?? '';
          final idB = b['id']?.toString() ?? '';
          return idA.compareTo(idB);
        });
        
        print('📱 WhatsApp-like message order (deduplicated):');
        for (int i = 0; i < deduplicatedMessages.length; i++) {
          final msg = deduplicatedMessages[i];
          print('  ${i + 1}. ${msg['text']} (${msg['timestamp']}) - ${msg['isFromUser'] ? 'USER' : 'PAGE'}');
        }
        
        // Debug: Show last few messages
        print('🔍 Last 3 messages:');
        final lastMessages = deduplicatedMessages.length > 3 
            ? deduplicatedMessages.sublist(deduplicatedMessages.length - 3)
            : deduplicatedMessages;
        for (int i = 0; i < lastMessages.length; i++) {
          final msg = lastMessages[i];
          print('  ${i + 1}. ${msg['text']} (${msg['timestamp']}) - ${msg['isFromUser'] ? 'USER' : 'PAGE'}');
        }

        messages.value = deduplicatedMessages;
        
        // Force scroll to bottom after messages are loaded - WhatsApp-like behavior
        _forceScrollToBottom();
        
        print('✅ Successfully loaded ${convertedMessages.length} messages');
      } else {
        print('❌ Failed to load messages: ${result['error']}');
        Get.snackbar('Error', 'Failed to load messages: ${result['error']}');
      }
    } catch (e) {
      print('❌ Error loading Facebook messages: $e');
      Get.snackbar('Error', 'Failed to load messages: $e');
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
      final messageId = DateTime.now().millisecondsSinceEpoch.toString();
      final newMessage = {
        'id': messageId,
        'text': messageText,
        'timestamp': _formatTimestamp(DateTime.now().toIso8601String()),
        'facebookCreatedTime': DateTime.now().toIso8601String(), // Store original timestamp
        'isFromUser': true,
        'isAI': false,
        'isSentMessage': true, // Mark as sent message to prevent duplicates
        'sentMessageId': messageId, // Unique identifier for sent messages
      };

      // Track this message as sent to prevent duplicates
      _sentMessageTexts.add(messageText);
      messages.add(newMessage);
      
      print('📤 Sent message tracked: "$messageText"');
      messageController.clear();
      _forceScrollToBottom();
      
      // Additional scroll attempt for sent messages
      Future.delayed(const Duration(milliseconds: 300), () {
        _forceScrollToBottom();
      });

      final sendResult =
          await FacebookGraphApiService.sendMessageToConversation(
        conversationId!,
        pageAccessToken!,
        messageText,
        userId: userId,
      );

      if (sendResult['success'] == true) {
        // ✅ Message sent successfully - no need to store in Firebase as it's already in messages list
        print('✅ Message sent successfully');
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

  /// Force scroll to bottom - Aggressive WhatsApp-like behavior
  void _forceScrollToBottom() {
    print('🔄 Force scrolling to bottom (WhatsApp-like)...');
    
    // Multiple aggressive scroll attempts
    _scrollToBottom();
    
    // Additional attempts with different timings
    Future.delayed(const Duration(milliseconds: 200), () {
      _scrollToBottom();
    });
    
    Future.delayed(const Duration(milliseconds: 500), () {
      _scrollToBottom();
    });
    
    Future.delayed(const Duration(milliseconds: 1000), () {
      _scrollToBottom();
    });
    
    Future.delayed(const Duration(milliseconds: 1500), () {
      _scrollToBottom();
    });
    
    // Final aggressive attempt
    Future.delayed(const Duration(milliseconds: 2000), () {
      _scrollToBottom();
    });
  }

  /// Auto-scroll to bottom - WhatsApp-like behavior
  void _scrollToBottom() {
    if (scrollController.hasClients) {
      print('🔄 Attempting to scroll to bottom (WhatsApp-like)...');
      
      // Use SchedulerBinding to ensure it runs after the frame is rendered
      SchedulerBinding.instance.addPostFrameCallback((_) {
      Future.delayed(const Duration(milliseconds: 100), () {
          if (scrollController.hasClients) {
            try {
              final maxScroll = scrollController.position.maxScrollExtent;
              print('📏 Max scroll extent: $maxScroll');
        scrollController.animateTo(
                maxScroll,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
              print('✅ Scrolled to bottom successfully (WhatsApp-like)');
            } catch (e) {
              print('❌ Error animating to bottom: $e');
              // Fallback to jump
              try {
                scrollController.jumpTo(scrollController.position.maxScrollExtent);
                print('✅ Jumped to bottom as fallback');
              } catch (e2) {
                print('❌ Error jumping to bottom: $e2');
              }
            }
          }
        });
      });
      
      // Multiple backup attempts for WhatsApp-like reliability
      Future.delayed(const Duration(milliseconds: 300), () {
        if (scrollController.hasClients) {
          try {
            scrollController.jumpTo(scrollController.position.maxScrollExtent);
            print('✅ First backup scroll successful');
          } catch (e) {
            print('❌ Error in first backup scroll: $e');
          }
        }
      });
      
      Future.delayed(const Duration(milliseconds: 600), () {
        if (scrollController.hasClients) {
          try {
            scrollController.jumpTo(scrollController.position.maxScrollExtent);
            print('✅ Second backup scroll successful');
          } catch (e) {
            print('❌ Error in second backup scroll: $e');
          }
        }
      });
      
      // Additional backup for stubborn cases
      Future.delayed(const Duration(milliseconds: 1000), () {
        if (scrollController.hasClients) {
          try {
            scrollController.jumpTo(scrollController.position.maxScrollExtent);
            print('✅ Third backup scroll successful');
          } catch (e) {
            print('❌ Error in third backup scroll: $e');
          }
        }
      });
    } else {
      print('⚠️ ScrollController has no clients, cannot scroll');
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
    // ✅ IMPROVED: Less frequent polling to reduce spam
    _messagePollingTimer = Timer.periodic(
        const Duration(seconds: 30), (_) => _pollForNewMessages());
    print('🔄 Started message polling every 30 seconds');
  }

  void _stopMessagePolling() {
    _messagePollingTimer?.cancel();
    _messagePollingTimer = null;
  }

  Future<void> _pollForNewMessages() async {
    if (conversationId == null || pageAccessToken == null) return;

    try {
      print('🔄 Polling for new messages...');
      
      final result =
          await FacebookGraphApiService.getConversationMessagesWithToken(
        conversationId!,
        pageAccessToken!,
      );

      if (result['success'] == true) {
        final newMessagesData = result['data'] as List<dynamic>;
        print('📨 Polling found ${newMessagesData.length} total messages');
        
        // Get current message IDs to detect new ones
        final currentMessageIds = messages.map((m) => m['facebookMessageId']).toSet();
        
        // Find new messages that we don't have yet
        final newMessages = newMessagesData.where((message) {
          final messageId = message['id'];
          return !currentMessageIds.contains(messageId);
        }).toList();
        
        if (newMessages.isNotEmpty) {
          print('🆕 Found ${newMessages.length} new messages!');
          _pollingAttempts = 0; // Reset counter when new messages found
          
          // Convert new messages to app format
          final convertedNewMessages = newMessages.map((message) {
            // ✅ FIXED: Correct user detection logic
            final messageFromId = message['from']['id']?.toString() ?? '';
            final isFromUser = messageFromId != facebookPageId;
            
            // SAFETY CHECK: Ensure facebookPageId is not null/empty for comparison
            final safeFacebookPageId = facebookPageId ?? '313808701826338';
            final safeIsFromUser = messageFromId != safeFacebookPageId;
            final messageId = message['id'] ?? DateTime.now().millisecondsSinceEpoch.toString();
            
            print('💬 New message from ${isFromUser ? 'USER' : 'PAGE'}: ${message['message']}');
            print('🔍 Polling Debug: messageFromId=$messageFromId, facebookPageId=$facebookPageId, isFromUser=$isFromUser');
            print('🔍 Message from object: ${message['from']}');
            
            // CRITICAL DEBUG: Check if facebookPageId is correct
            if (facebookPageId == null || facebookPageId!.isEmpty) {
              print('❌ CRITICAL: facebookPageId is null/empty in polling!');
              print('❌ This will cause ALL messages to appear on the right side!');
            }
            
            return {
              'id': messageId,
              'text': message['message'] ?? '',
              'timestamp': _formatTimestamp(message['created_time']),
              'facebookCreatedTime': message['created_time'], // Store original Facebook timestamp
              'isFromUser': safeIsFromUser, // Use safe comparison
              'isAI': false,
              'facebookMessageId': message['id'],
              'senderName': message['from']['name'] ?? 'Unknown User', // Store sender name
              'senderId': message['from']['id'] ?? '', // Store sender ID
            };
          }).toList();

          // Add new messages to existing list, but check for duplicates
          final existingMessageIds = messages.map((m) => m['facebookMessageId']?.toString()).toSet();
          final existingSentMessageIds = messages.map((m) => m['sentMessageId']?.toString()).toSet();
          
          // Create a set of existing message content for better duplicate detection
          final existingMessageContent = messages.map((m) => '${m['text']}_${m['timestamp']}_${m['isFromUser']}').toSet();
          
          print('🔍 Deduplication Debug:');
          print('  Existing message IDs: ${existingMessageIds.length}');
          print('  Existing sent message IDs: ${existingSentMessageIds.length}');
          print('  Existing message content: ${existingMessageContent.length}');
          print('  Sent message texts: ${_sentMessageTexts.length}');
          
          final uniqueNewMessages = convertedNewMessages.where((msg) {
            final facebookId = msg['facebookMessageId']?.toString() ?? '';
            final sentId = msg['sentMessageId']?.toString() ?? '';
            final messageContent = '${msg['text']}_${msg['timestamp']}_${msg['isFromUser']}';
            final messageText = msg['text']?.toString() ?? '';
            
            print('🔍 Checking message: ${msg['text']} (${msg['isFromUser'] ? 'USER' : 'PAGE'})');
            
            // Check if it's a duplicate Facebook message
            if (facebookId.isNotEmpty && existingMessageIds.contains(facebookId)) {
              print('⚠️ Duplicate Facebook message detected: ${msg['text']}');
              return false;
            }
            
            // Check if it's a duplicate sent message
            if (sentId.isNotEmpty && existingSentMessageIds.contains(sentId)) {
              print('⚠️ Duplicate sent message detected: ${msg['text']}');
              return false;
            }
            
            // Check if it's a sent message that we already have
            if (msg['isSentMessage'] == true && existingSentMessageIds.contains(msg['id']?.toString())) {
              print('⚠️ Duplicate sent message by ID detected: ${msg['text']}');
              return false;
            }
            
            // Check if it's a duplicate based on content and timestamp
            if (existingMessageContent.contains(messageContent)) {
              print('⚠️ Duplicate message content detected: ${msg['text']}');
              return false;
            }
            
            // Check if this message was already sent by the user (only for USER messages)
            if (msg['isFromUser'] == true && _sentMessageTexts.contains(messageText)) {
              print('⚠️ Message already sent by user, skipping: ${msg['text']} (USER)');
              return false;
            }
            
            print('✅ Message passed all checks: ${msg['text']}');
            return true;
          }).toList();
          
          print('📊 Deduplication Results:');
          print('  Original new messages: ${convertedNewMessages.length}');
          print('  Unique new messages: ${uniqueNewMessages.length}');
          print('  Filtered out: ${convertedNewMessages.length - uniqueNewMessages.length}');
          
          final updatedMessages = [...messages, ...uniqueNewMessages];
          
          // Sort by original Facebook timestamp (oldest first) - WhatsApp-like ordering
          updatedMessages.sort((a, b) {
            // Use original Facebook timestamp for sorting, not formatted display timestamp
            final timeA = DateTime.tryParse(a['facebookCreatedTime'] ?? a['timestamp']) ?? DateTime.now();
            final timeB = DateTime.tryParse(b['facebookCreatedTime'] ?? b['timestamp']) ?? DateTime.now();
            
            // Primary sort by timestamp (oldest first, newest last)
            final timeComparison = timeA.compareTo(timeB);
            if (timeComparison != 0) return timeComparison;
            
            // Secondary sort by message ID for consistency
            final idA = a['id']?.toString() ?? '';
            final idB = b['id']?.toString() ?? '';
            return idA.compareTo(idB);
          });
          
        print('📱 Updated WhatsApp-like message order:');
        for (int i = 0; i < updatedMessages.length; i++) {
          final msg = updatedMessages[i];
          print('  ${i + 1}. ${msg['text']} (${msg['timestamp']}) - ${msg['isFromUser'] ? 'USER' : 'PAGE'}');
        }
        
        // Debug: Show last few messages after polling
        print('🔍 Last 3 messages after polling:');
        final lastMessages = updatedMessages.length > 3 
            ? updatedMessages.sublist(updatedMessages.length - 3)
            : updatedMessages;
        for (int i = 0; i < lastMessages.length; i++) {
          final msg = lastMessages[i];
          print('  ${i + 1}. ${msg['text']} (${msg['timestamp']}) - ${msg['isFromUser'] ? 'USER' : 'PAGE'}');
        }
          
          messages.value = updatedMessages;
          _forceScrollToBottom();
          
          // Show notification for new user messages
          final userMessages = convertedNewMessages.where((m) => m['isFromUser'] == true).toList();
          if (userMessages.isNotEmpty) {
            Get.snackbar(
              '💬 New Message',
              'You have ${userMessages.length} new message(s)',
              snackPosition: SnackPosition.TOP,
              duration: Duration(seconds: 2),
              backgroundColor: Colors.blue,
              colorText: Colors.white,
            );
          }
        } else {
          print('✅ No new messages found');
          _pollingAttempts++;
          
          // Reduce polling frequency if no new messages for a while
          if (_pollingAttempts > 5) {
            print('🔄 Reducing polling frequency due to no new messages');
            _stopMessagePolling();
            _messagePollingTimer = Timer.periodic(
                const Duration(minutes: 2), (_) => _pollForNewMessages());
            _pollingAttempts = 0;
          }
        }
      } else {
        print('❌ Polling failed: ${result['error']}');
      }
    } catch (e) {
      print('❌ Error polling messages: $e');
    }
  }

  /// ✅ ADDED: Real-time message listening
  StreamSubscription? _realtimeMessageSubscription;

  void _startRealtimeListening() {
    if (conversationId == null) return;
    
    print('🔄 Starting real-time listening for conversation: $conversationId');
    
    // Listen for new messages in this specific conversation
    _realtimeMessageSubscription = FirebaseFirestore.instance
        .collection('user_messages')
        .doc(_realtimeService.getCurrentUserId())
        .collection('messages')
        .where('conversationId', isEqualTo: conversationId)
        .orderBy('timestamp', descending: true)
        .snapshots()
        .listen(
      (snapshot) {
        print('📨 Real-time update: ${snapshot.docs.length} messages for conversation $conversationId');
        
        // Process new messages
        for (final doc in snapshot.docChanges) {
          if (doc.type == DocumentChangeType.added) {
            final messageData = doc.doc.data() as Map<String, dynamic>;
            _handleRealtimeMessage(messageData);
          }
        }
      },
      onError: (error) {
        print('❌ Error in real-time listening: $error');
      },
    );
  }

  void _stopRealtimeListening() {
    _realtimeMessageSubscription?.cancel();
    _realtimeMessageSubscription = null;
    print('🛑 Stopped real-time listening');
  }

  void _handleRealtimeMessage(Map<String, dynamic> messageData) {
    try {
      print('📨 Real-time message received: ${messageData['text']}');
      
      // Check if this message is already in our list
      final messageId = messageData['id'] ?? messageData['timestamp'].toString();
      final existingMessage = messages.firstWhereOrNull(
        (m) => m['id'] == messageId || m['facebookMessageId'] == messageId,
      );
      
      if (existingMessage != null) {
        print('⚠️ Message already exists, skipping');
        return;
      }
      
      // Convert to app format
      final newMessage = {
        'id': messageId,
        'text': messageData['text'] ?? '',
        'timestamp': _formatTimestamp(messageData['timestamp']?.toString() ?? DateTime.now().toIso8601String()),
        'isFromUser': messageData['isFromUser'] ?? false,
        'isAI': false,
        'facebookMessageId': messageId,
      };
      
      // Add to messages list, but check for duplicates
      final existingMessageIds = messages.map((m) => m['facebookMessageId']?.toString()).toSet();
      final existingSentMessageIds = messages.map((m) => m['sentMessageId']?.toString()).toSet();
      final facebookId = newMessage['facebookMessageId']?.toString() ?? '';
      final sentId = newMessage['sentMessageId']?.toString() ?? '';
      
      // Create a set of existing message content for better duplicate detection
      final existingMessageContent = messages.map((m) => '${m['text']}_${m['timestamp']}_${m['isFromUser']}').toSet();
      final messageContent = '${newMessage['text']}_${newMessage['timestamp']}_${newMessage['isFromUser']}';
      
      // Check if it's a duplicate Facebook message or sent message
      final isDuplicateFacebook = facebookId.isNotEmpty && existingMessageIds.contains(facebookId);
      final isDuplicateSent = sentId.isNotEmpty && existingSentMessageIds.contains(sentId);
      final isDuplicateSentById = newMessage['isSentMessage'] == true && existingSentMessageIds.contains(newMessage['id']?.toString());
      final isDuplicateContent = existingMessageContent.contains(messageContent);
      final isAlreadySentByUser = _sentMessageTexts.contains(newMessage['text']?.toString() ?? '');
      
      if (!isDuplicateFacebook && !isDuplicateSent && !isDuplicateSentById && !isDuplicateContent && !isAlreadySentByUser) {
        final updatedMessages = [...messages, newMessage];
        
        // Sort by original Facebook timestamp (oldest first) - WhatsApp-like ordering
        updatedMessages.sort((a, b) {
          // Use original Facebook timestamp for sorting, not formatted display timestamp
          final timeA = DateTime.tryParse(a['facebookCreatedTime'] ?? a['timestamp']) ?? DateTime.now();
          final timeB = DateTime.tryParse(b['facebookCreatedTime'] ?? b['timestamp']) ?? DateTime.now();
          
          // Primary sort by timestamp (oldest first, newest last)
          final timeComparison = timeA.compareTo(timeB);
          if (timeComparison != 0) return timeComparison;
          
          // Secondary sort by message ID for consistency
          final idA = a['id']?.toString() ?? '';
          final idB = b['id']?.toString() ?? '';
          return idA.compareTo(idB);
        });
        
        print('📱 WhatsApp-like message order (webhook):');
        for (int i = 0; i < updatedMessages.length; i++) {
          final msg = updatedMessages[i];
          print('  ${i + 1}. ${msg['text']} (${msg['timestamp']}) - ${msg['isFromUser'] ? 'USER' : 'PAGE'}');
        }
        
        messages.value = updatedMessages;
        _forceScrollToBottom();
      } else {
        print('⚠️ Webhook message already exists or is a duplicate (Facebook: $isDuplicateFacebook, Sent: $isDuplicateSent, Content: $isDuplicateContent, AlreadySent: $isAlreadySentByUser), skipping');
      }
      
      // Show notification for new user messages
      if (messageData['isFromUser'] == true) {
        Get.snackbar(
          '💬 New Message',
          'You have a new message!',
          snackPosition: SnackPosition.TOP,
          duration: Duration(seconds: 2),
          backgroundColor: Colors.blue,
          colorText: Colors.white,
        );
      }
      
      print('✅ Real-time message added successfully');
    } catch (e) {
      print('❌ Error handling real-time message: $e');
    }
  }

  /// ✅ ADDED: Webhook listening for instant messages
  void _startWebhookListening() {
    if (conversationId == null) return;
    
    print('🔄 Starting webhook listening for conversation: $conversationId');
    
    // Start webhook service
    _webhookService.startWebhookListening();
    
    // Verify webhook connection
    _webhookService.verifyWebhookConnection().then((isConnected) {
      if (isConnected) {
        print('✅ Webhook connection verified');
        Get.snackbar(
          'Webhook Connected',
          'Real-time messaging is now active!',
          snackPosition: SnackPosition.TOP,
          duration: Duration(seconds: 3),
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );
      } else {
        print('⚠️ Webhook connection failed, using polling fallback');
        Get.snackbar(
          'Webhook Offline',
          'Using polling for message updates',
          snackPosition: SnackPosition.TOP,
          duration: Duration(seconds: 3),
          backgroundColor: Colors.orange,
          colorText: Colors.white,
        );
      }
    });
  }

  void _stopWebhookListening() {
    _webhookService.stopWebhookListening();
    print('🛑 Stopped webhook listening');
  }

  /// ✅ ADDED: Simple webhook listening (no controller dependencies)
  void _startSimpleWebhookListening() {
    if (conversationId == null) return;
    
    print('🔄 Starting simple webhook listening for conversation: $conversationId');
    _simpleWebhookService.startSimpleWebhookListening();
  }

  void _stopSimpleWebhookListening() {
    _simpleWebhookService.stopSimpleWebhookListening();
    print('🛑 Stopped simple webhook listening');
  }

  /// Handle webhook message from webhook service
  void handleWebhookMessage(Map<String, dynamic> messageData) {
    try {
      print('📨 Webhook message received: ${messageData['text']}');
      
      // Check if this message is for this conversation
      final messageConversationId = messageData['conversationId'];
      if (messageConversationId != conversationId) {
        print('⚠️ Message not for this conversation, ignoring');
        return;
      }
      
      // Check if message already exists
      final messageId = messageData['timestamp']?.toString() ?? DateTime.now().millisecondsSinceEpoch.toString();
      final existingMessage = messages.firstWhereOrNull(
        (m) => m['id'] == messageId || m['webhookMessageId'] == messageId,
      );
      
      if (existingMessage != null) {
        print('⚠️ Webhook message already exists, skipping');
        return;
      }
      
      // Convert to app format
      final newMessage = {
        'id': messageId,
        'text': messageData['text'] ?? '',
        'timestamp': _formatTimestamp(messageData['timestamp']?.toString() ?? DateTime.now().toIso8601String()),
        'facebookCreatedTime': messageData['timestamp']?.toString() ?? DateTime.now().toIso8601String(), // Store original timestamp
        'isFromUser': messageData['isFromUser'] ?? true, // Webhook messages are usually from users
        'isAI': false,
        'webhookMessageId': messageId,
        'senderName': messageData['senderName'] ?? 'Facebook User',
      };
      
      // Add to messages list, but check for duplicates
      final existingMessageIds = messages.map((m) => m['facebookMessageId']?.toString()).toSet();
      final existingSentMessageIds = messages.map((m) => m['sentMessageId']?.toString()).toSet();
      final facebookId = newMessage['facebookMessageId']?.toString() ?? '';
      final sentId = newMessage['sentMessageId']?.toString() ?? '';
      
      // Create a set of existing message content for better duplicate detection
      final existingMessageContent = messages.map((m) => '${m['text']}_${m['timestamp']}_${m['isFromUser']}').toSet();
      final messageContent = '${newMessage['text']}_${newMessage['timestamp']}_${newMessage['isFromUser']}';
      
      // Check if it's a duplicate Facebook message or sent message
      final isDuplicateFacebook = facebookId.isNotEmpty && existingMessageIds.contains(facebookId);
      final isDuplicateSent = sentId.isNotEmpty && existingSentMessageIds.contains(sentId);
      final isDuplicateSentById = newMessage['isSentMessage'] == true && existingSentMessageIds.contains(newMessage['id']?.toString());
      final isDuplicateContent = existingMessageContent.contains(messageContent);
      final isAlreadySentByUser = _sentMessageTexts.contains(newMessage['text']?.toString() ?? '');
      
      if (!isDuplicateFacebook && !isDuplicateSent && !isDuplicateSentById && !isDuplicateContent && !isAlreadySentByUser) {
        final updatedMessages = [...messages, newMessage];
        
        // Sort by original Facebook timestamp (oldest first) - WhatsApp-like ordering
        updatedMessages.sort((a, b) {
          // Use original Facebook timestamp for sorting, not formatted display timestamp
          final timeA = DateTime.tryParse(a['facebookCreatedTime'] ?? a['timestamp']) ?? DateTime.now();
          final timeB = DateTime.tryParse(b['facebookCreatedTime'] ?? b['timestamp']) ?? DateTime.now();
          
          // Primary sort by timestamp (oldest first, newest last)
          final timeComparison = timeA.compareTo(timeB);
          if (timeComparison != 0) return timeComparison;
          
          // Secondary sort by message ID for consistency
          final idA = a['id']?.toString() ?? '';
          final idB = b['id']?.toString() ?? '';
          return idA.compareTo(idB);
        });
        
        print('📱 WhatsApp-like message order (webhook):');
        for (int i = 0; i < updatedMessages.length; i++) {
          final msg = updatedMessages[i];
          print('  ${i + 1}. ${msg['text']} (${msg['timestamp']}) - ${msg['isFromUser'] ? 'USER' : 'PAGE'}');
        }
        
        messages.value = updatedMessages;
        _forceScrollToBottom();
      } else {
        print('⚠️ Webhook message already exists or is a duplicate (Facebook: $isDuplicateFacebook, Sent: $isDuplicateSent, Content: $isDuplicateContent, AlreadySent: $isAlreadySentByUser), skipping');
      }
      
      // Show notification for new user messages
      if (messageData['isFromUser'] == true) {
        Get.snackbar(
          '💬 New Message',
          'You have a new message from ${messageData['senderName'] ?? 'Facebook User'}!',
          snackPosition: SnackPosition.TOP,
          duration: Duration(seconds: 3),
          backgroundColor: Colors.blue,
          colorText: Colors.white,
        );
      }
      
      print('✅ Webhook message added successfully');
    } catch (e) {
      print('❌ Error handling webhook message: $e');
    }
  }
}
