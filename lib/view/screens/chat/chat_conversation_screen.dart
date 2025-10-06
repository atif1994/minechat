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
import 'package:minechat/controller/ai_assistant_controller/ai_assistant_controller.dart';
import 'package:minechat/core/services/openai_service.dart';

/// Optimized Chat Conversation Screen with AI Integration
class ChatConversationScreen extends StatelessWidget {
  final themeController = Get.find<ThemeController>();
  final Map<String, dynamic> chat;
  final conversationController = Get.put(ChatConversationController(), tag: 'ChatConversationController');
  final aiAssistantController = Get.find<AIAssistantController>();

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
          backgroundColor: isDark ? Color(0XFF0A0A0A) : Color(0XFFF4F6FC),
          appBar: ChatAppBarWidget(
            contactName: chat['contactName'] ?? 'Unknown',
            profileImageUrl: chat['profileImageUrl'],
            onBackPressed: () => Get.back(),
            onProfileTap: () => Get.snackbar('Info', 'Viewing profile...'),
            onAITap: () => conversationController.toggleAIResponse(),
          ),
          body: Column(
            children: [
              // AI Enabled indicator with toggle functionality
              AIEnabledIndicatorWidget(
                isEnabled: conversationController.isAIEnabled.value,
                onTap: () => conversationController.toggleAIResponse(),
              ),

              // AI Response Mode indicator
              if (conversationController.isAIEnabled.value)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  color: Colors.blue.withOpacity(0.1),
                  child: Row(
                    children: [
                      Icon(Icons.smart_toy, color: Colors.blue, size: 16),
                      const SizedBox(width: 8),
                      Text(
                        'AI Assistant is responding automatically',
                        style: TextStyle(
                          color: Colors.blue[700],
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),

              // Messages
              Expanded(
                child: _buildMessagesList(),
              ),

              // Message Input - conditionally show based on AI status
              Obx(() {
                if (conversationController.isAIEnabled.value) {
                  // Show AI status when enabled
                  return Container(
                    padding: EdgeInsets.all(16),
                    margin: EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: themeController.isDarkMode 
                          ? Colors.green.withOpacity(0.1) 
                          : Colors.green.withOpacity(0.05),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: Colors.green.withOpacity(0.3),
                        width: 1,
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.smart_toy, color: Colors.green, size: 20),
                        SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'AI Assistant is responding automatically',
                            style: TextStyle(
                              color: Colors.green,
                              fontWeight: FontWeight.w500,
                              fontSize: 14,
                            ),
                          ),
                        ),
                        Switch(
                          value: conversationController.isAIEnabled.value,
                          onChanged: (value) {
                            conversationController.toggleAI(value);
                          },
                          activeColor: Colors.green,
                        ),
                      ],
                    ),
                  );
                } else {
                  // Show normal message input when AI is disabled
                  return MessageInputWidget(
                    messageController: conversationController.messageController,
                    isSending: conversationController.isSending,
                    onSendMessage: conversationController.sendMessage,
                  );
                }
              }),
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
          color: isDark ? Color(0XFF0A0A0A) : Color(0XFFF4F6FC),
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
              isPending: message['isPending'] ?? false,
              error: message['error'],
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
    
    print('🔍 Avatar Debug: isFromUser=$isFromUser, senderName=$senderName, senderId=$senderId');
    print('🔍 Message Source: ${isFromUser ? 'CLIENT' : 'FACEBOOK PAGE'}');
    
    // Handle generic or truncated names with better display names
    String displayName = senderName;
    if (senderName == 'Unknown User' || senderName == 'Facebook User' || senderName.length < 3) {
      if (isFromUser) {
        // For user messages, show a more descriptive name
        displayName = senderId.isNotEmpty ? 'Customer' : 'User';
      } else {
        // For page/business messages, show Facebook page name
        displayName = 'Facebook Page';
      }
    }
    
    // CORRECTED: Show proper names based on message source
    if (isFromUser) {
      // For client/user messages: Show actual client name if available
      if (senderName != 'Unknown User' && senderName != 'Facebook User' && senderName.length > 2) {
        displayName = senderName; // Show real client name like "Atif Ali"
      } else {
        displayName = 'Customer'; // Fallback for user messages
      }
    } else {
      // For Facebook Page messages: Always show as Facebook Page
      displayName = 'Facebook Page';
    }
    
    print('🔍 Final Display Name: $displayName');
    
    // Try to get user profile image from Facebook
    String? profileImageUrl;
    
    if (isFromUser && senderId.isNotEmpty) {
      // For user messages, try to get Facebook profile picture
      profileImageUrl = 'https://graph.facebook.com/$senderId/picture?type=normal';
    } else if (!isFromUser) {
      // For page messages, use a default business avatar or page picture
      profileImageUrl = null; // Will use initials
    }
    
    // If we have a profile image URL, try to display it
    if (profileImageUrl != null) {
      return CircleAvatar(
        radius: 16,
        backgroundColor: Colors.grey[300],
        backgroundImage: NetworkImage(profileImageUrl),
        onBackgroundImageError: (exception, stackTrace) {
          print('❌ Failed to load profile image: $exception');
        },
        child: null, // Let the background image show
      );
    }
    
    // Fallback to initials if no image or image failed to load
    final initials = _getInitials(displayName);
    final avatarColor = _getAvatarColor(displayName, isFromUser);
    
    return CircleAvatar(
      radius: 16,
      backgroundColor: avatarColor,
      child: Text(
        initials,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
  
  String _getInitials(String name) {
    if (name.isEmpty) return '?';
    
    final words = name.trim().split(' ').where((word) => word.isNotEmpty).toList();
    if (words.isEmpty) return '?';
    
    if (words.length == 1) {
      return words[0][0].toUpperCase();
    } else {
      return '${words[0][0]}${words[1][0]}'.toUpperCase();
    }
  }

  Color _getAvatarColor(String name, bool isFromUser) {
    if (name.isEmpty) return isFromUser ? Colors.blue : Colors.grey;
    
    // Generate a hash from the name for consistent colors
    int hash = 0;
    for (int i = 0; i < name.length; i++) {
      hash = name.codeUnitAt(i) + ((hash << 5) - hash);
    }
    
    // Use absolute value and modulo to get a consistent color
    final colorIndex = hash.abs() % 8;
    
    // Professional color palette
    final colors = [
      const Color(0xFF3B82F6), // Blue
      const Color(0xFF10B981), // Green  
      const Color(0xFFF59E0B), // Amber
      const Color(0xFFEF4444), // Red
      const Color(0xFF8B5CF6), // Purple
      const Color(0xFF06B6D4), // Cyan
      const Color(0xFFF97316), // Orange
      const Color(0xFF84CC16), // Lime
    ];
    
    return colors[colorIndex];
  }
}

/// Enhanced Chat Conversation Controller with AI Integration
class ChatConversationController extends GetxController {
  final messageController = TextEditingController();
  var messages = <Map<String, dynamic>>[].obs;
  var isLoading = true.obs;
  var isSending = false.obs;

  // AI Integration
  var isAIEnabled = false.obs;
  var isAIResponding = false.obs;
  final aiAssistantController = Get.find<AIAssistantController>();

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
  
  // Track AI responses to prevent duplicates
  final Set<String> _aiRespondedToMessages = <String>{};
  final Set<String> _aiResponseTexts = <String>{};
  
  // Debounce mechanism to prevent rapid-fire AI responses
  Timer? _aiResponseDebounceTimer;
  final Map<String, DateTime> _lastAIResponseTime = <String, DateTime>{};
  
  // CRITICAL: Global message tracking to prevent ALL duplicates
  final Set<String> _allMessageIds = <String>{};
  final Set<String> _allMessageContent = <String>{};
  final Map<String, String> _messageContentToId = <String, String>{};

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
    _aiResponseDebounceTimer?.cancel();
    scrollController.dispose();
    messageController.dispose();
    super.onClose();
  }

  /// Set chat data and initialize conversation
  void setChatData(Map<String, dynamic> chat) {
    // CRITICAL FIX: Stop existing listeners before starting new ones
    print('🔄 Setting chat data - stopping existing listeners first');
    _stopRealtimeListening();
    _stopWebhookListening();
    _stopSimpleWebhookListening();
    _stopMessagePolling();
    
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
          final safeFacebookPageId = facebookPageId ?? '313808701826338';
          
          // CRITICAL FIX: Correct logic for determining if message is from user
          // If messageFromId equals facebookPageId, it's from the PAGE (business)
          // If messageFromId does NOT equal facebookPageId, it's from the USER
          final isFromUser = messageFromId != safeFacebookPageId;
          final messageId = message['id'] ?? DateTime.now().millisecondsSinceEpoch.toString();
          
          print('💬 Message from ${isFromUser ? 'USER' : 'PAGE'}: ${message['message']}');
          print('🔍 Debug: messageFromId=$messageFromId, facebookPageId=$safeFacebookPageId, isFromUser=$isFromUser');
          print('🔍 Message from object: ${message['from']}');
          print('🔍 Sender name: ${message['from']['name']}');
          print('🔍 Sender ID: ${message['from']['id']}');
          
          // CRITICAL DEBUG: Check if facebookPageId is correct
          if (facebookPageId == null || facebookPageId!.isEmpty) {
            print('❌ CRITICAL: facebookPageId is null/empty in _loadFacebookMessages!');
            print('❌ This will cause ALL messages to appear on the right side!');
          }
          
          // Use contact name from chat data for user messages, Facebook page name for page messages
          String senderName;
          if (isFromUser) {
            // For user messages, use the contact name from chat data
            senderName = chatData?['contactName'] ?? 'Unknown User';
            print('🔍 Using contact name for user message: $senderName');
          } else {
            // For page messages, use the Facebook page name
            senderName = message['from']['name'] ?? 'Facebook Page';
            print('🔍 Using Facebook page name for page message: $senderName');
          }
          
          return {
            'id': messageId,
            'text': message['message'] ?? '',
            'timestamp': _formatTimestamp(message['created_time']),
            'facebookCreatedTime': message['created_time'], // Store original Facebook timestamp
            'isFromUser': isFromUser, // Use corrected logic
            'isAI': false,
            'facebookMessageId': message['id'], // Store original Facebook ID
            'senderName': senderName, // Use correct sender name based on message source
            'senderId': message['from']['id'] ?? '', // Store sender ID
          };
        }).toList();

        // Enhanced deduplication: Remove duplicate messages based on multiple criteria
        final uniqueMessages = <String, Map<String, dynamic>>{};
        final seenContent = <String>{};
        final seenTimestamps = <String>{};
        
        for (final message in convertedMessages) {
          final facebookId = message['facebookMessageId']?.toString() ?? '';
          final content = message['text']?.toString() ?? '';
          final timestamp = message['facebookCreatedTime']?.toString() ?? message['timestamp']?.toString() ?? '';
          final isFromUser = message['isFromUser'] ?? false;
          
          // Create a unique key combining multiple factors
          final messageKey = '${facebookId}_${content}_${timestamp}_${isFromUser}';
          final contentKey = '${content}_${timestamp}_${isFromUser}';
          
          // Only add if we haven't seen this exact message before
          if (facebookId.isNotEmpty && 
              !uniqueMessages.containsKey(facebookId) && 
              !seenContent.contains(contentKey) &&
              !seenTimestamps.contains(timestamp)) {
            uniqueMessages[facebookId] = message;
            seenContent.add(contentKey);
            seenTimestamps.add(timestamp);
            print('✅ Added unique message: $content (ID: $facebookId)');
          } else {
            print('❌ Skipped duplicate message: $content (ID: $facebookId, Key: $messageKey)');
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

  /// Toggle AI Response Mode
  void toggleAIResponse() {
    isAIEnabled.value = !isAIEnabled.value;
    
    if (isAIEnabled.value) {
      Get.snackbar(
        'AI Enabled',
        'AI Assistant will respond automatically to incoming messages',
        backgroundColor: Colors.green,
        colorText: Colors.white,
        duration: Duration(seconds: 3),
      );
    } else {
      Get.snackbar(
        'AI Disabled',
        'You will respond manually to messages',
        backgroundColor: Colors.orange,
        colorText: Colors.white,
        duration: Duration(seconds: 3),
      );
    }
  }

  /// Toggle AI with specific value
  void toggleAI(bool enabled) {
    isAIEnabled.value = enabled;
    
    if (enabled) {
      Get.snackbar(
        'AI Enabled',
        'AI Assistant will respond automatically to incoming messages',
        backgroundColor: Colors.green,
        colorText: Colors.white,
        duration: Duration(seconds: 3),
      );
    } else {
      Get.snackbar(
        'AI Disabled',
        'You will respond manually to messages',
        backgroundColor: Colors.orange,
        colorText: Colors.white,
        duration: Duration(seconds: 3),
      );
    }
  }

  /// Send message with AI integration
  Future<void> sendMessage() async {
    final messageText = messageController.text.trim();
    if (messageText.isEmpty) return;

    if (conversationId == null || pageAccessToken == null) {
      Get.snackbar('Error', 'Cannot send message: Missing conversation data');
      return;
    }
    
    // Additional validation for Facebook messaging
    if (userId == null || userId!.isEmpty) {
      Get.snackbar('Error', 'Cannot send message: Missing user ID for Facebook messaging');
      return;
    }
    
    print('🔍 Message send validation:');
    print('  Conversation ID: $conversationId');
    print('  User ID: $userId');
    print('  Token length: ${pageAccessToken?.length ?? 0}');

    setSending(true);

    try {
      final messageId = DateTime.now().millisecondsSinceEpoch.toString();
      final newMessage = {
        'id': messageId,
        'text': messageText,
        'timestamp': _formatTimestamp(DateTime.now().toIso8601String()),
        'facebookCreatedTime': DateTime.now().toIso8601String(),
        'isFromUser': false, // FIXED: Messages sent from app should appear on Facebook page side (left)
        'isAI': false,
        'isSentMessage': true,
        'sentMessageId': messageId,
        'senderName': 'Facebook Page', // Use Facebook page name for sent messages
        'senderId': facebookPageId ?? '', // Use Facebook page ID
      };

      // Track this message as sent to prevent duplicates
      _sentMessageTexts.add(messageText);
      
      print('📤 Attempting to send message to Facebook: "$messageText"');
      print('📤 Conversation ID: $conversationId');
      print('📤 User ID: $userId');
      print('📤 Token available: ${pageAccessToken?.isNotEmpty == true}');

      final sendResult =
          await FacebookGraphApiService.sendMessageToConversation(
        conversationId!,
        pageAccessToken!,
        messageText,
        userId: userId,
        messageTag: "UPDATE", // Use UPDATE tag to bypass 24-hour restriction
      );

      print('📤 Send result: $sendResult');

      if (sendResult['success'] == true) {
        print('✅ Message sent successfully to Facebook');
        // Add to tracking system BEFORE adding to chat
        _isMessageDuplicate(newMessage); // This will add it to tracking
        // Only add to local chat after successful Facebook send
        messages.add(newMessage);
        messageController.clear();
        _forceScrollToBottom();
        
        // Additional scroll attempt for sent messages
        Future.delayed(const Duration(milliseconds: 300), () {
          _forceScrollToBottom();
        });
      } else {
        print('❌ Failed to send message to Facebook: ${sendResult['error']}');
        messageController.text = messageText; // Restore
        
        // Check if it's a specific Facebook API error
        final errorMessage = sendResult['error']?.toString() ?? 'Unknown error';
        String userMessage = 'Message not sent to Facebook';
        
        if (errorMessage.contains('outside the allowed window')) {
          userMessage = 'Message outside Facebook messaging window (24h limit)';
        } else if (errorMessage.contains('Unable to send message due to Facebook\'s 24-hour messaging policy')) {
          userMessage = 'This conversation is too old. Please ask the user to send a new message first.';
        } else if (errorMessage.contains('Invalid OAuth')) {
          userMessage = 'Facebook access token expired or invalid';
        } else if (errorMessage.contains('recipient')) {
          userMessage = 'Invalid recipient ID for Facebook messaging';
        }
        
        Get.snackbar(
          'Send Failed', 
          '$userMessage: $errorMessage',
          backgroundColor: Colors.red,
          colorText: Colors.white,
          duration: Duration(seconds: 8),
        );
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to send message: $e');
    } finally {
      setSending(false);
    }
  }

  /// Generate AI Response for incoming messages
  Future<void> generateAIResponse(String userMessage) async {
    print('🤖 generateAIResponse called with: $userMessage');
    print('🤖 isAIEnabled: ${isAIEnabled.value}');
    print('🤖 isAIResponding: ${isAIResponding.value}');
    
    if (!isAIEnabled.value || isAIResponding.value) {
      print('⚠️ AI response blocked - isAIEnabled: ${isAIEnabled.value}, isAIResponding: ${isAIResponding.value}');
      return;
    }

    // CRITICAL FIX: Prevent duplicate AI responses with more robust checking
    final messageHash = userMessage.trim().toLowerCase();
    if (_aiRespondedToMessages.contains(messageHash)) {
      print('⚠️ AI already responded to this message, skipping: $userMessage');
      return;
    }

    // ADDITIONAL FIX: Check if we're already processing this message
    if (isAIResponding.value) {
      print('⚠️ AI is already responding, skipping duplicate request: $userMessage');
      return;
    }

    // DEBOUNCE FIX: Prevent rapid-fire responses to the same message
    final now = DateTime.now();
    if (_lastAIResponseTime.containsKey(messageHash)) {
      final lastResponse = _lastAIResponseTime[messageHash]!;
      if (now.difference(lastResponse).inSeconds < 5) {
        print('⚠️ AI response too recent, debouncing: $userMessage');
        return;
      }
    }

    try {
      isAIResponding.value = true;
      print('🤖 Generating AI response for: $userMessage');

      // Get AI assistant configuration
      final assistant = aiAssistantController.currentAIAssistant.value;
      if (assistant == null) {
        print('⚠️ No AI assistant configured');
        return;
      }

      // Generate AI response using OpenAI service
      // CRITICAL FIX: Detect if this is a Facebook conversation
      // Improved logic: Only detect Facebook if we have clear Facebook indicators
      final isFacebookConversation = conversationId != null && 
          (conversationId!.startsWith('t_') || 
           (chatData?['platform'] == 'Facebook' && chatData?['facebookPageId'] != null));
      
      // DETAILED DEBUG: Print all context detection details
      print('🔍 CONTEXT DETECTION DEBUG:');
      print('  conversationId: $conversationId');
      print('  conversationId starts with t_: ${conversationId?.startsWith('t_')}');
      print('  chatData platform: ${chatData?['platform']}');
      print('  chatData facebookPageId: ${chatData?['facebookPageId']}');
      print('  isFacebookConversation: $isFacebookConversation');
      print('🔍 Conversation context: ${isFacebookConversation ? 'Facebook Chat' : 'App Interface'}');
      
      final aiResponse = await OpenAIService.generateResponseWithKnowledge(
        userMessage: userMessage,
        assistantName: assistant.name,
        introMessage: assistant.introMessage,
        shortDescription: assistant.shortDescription,
        aiGuidelines: assistant.aiGuidelines,
        responseLength: assistant.responseLength,
        businessInfo: aiAssistantController.businessInfo.value,
        productsServices: aiAssistantController.productsServices,
        faqs: aiAssistantController.faqs,
        isFacebookChat: isFacebookConversation, // Detect Facebook context
      );

      print('🤖 AI Response: $aiResponse');

      // CRITICAL FIX: Check if we already sent this exact response
      if (_aiResponseTexts.contains(aiResponse.trim())) {
        print('⚠️ AI response already sent, skipping duplicate');
        return;
      }

      // Mark this message as responded to and track the response BEFORE sending
      _aiRespondedToMessages.add(messageHash);
      _aiResponseTexts.add(aiResponse.trim());
      _lastAIResponseTime[messageHash] = now;

      // Send AI response as a message
      await _sendAIMessage(aiResponse);

    } catch (e) {
      print('❌ Error generating AI response: $e');
    } finally {
      isAIResponding.value = false;
    }
  }

  /// Send AI-generated message
  Future<void> _sendAIMessage(String aiResponse) async {
    try {
      final messageId = DateTime.now().millisecondsSinceEpoch.toString();
      final aiMessage = {
        'id': messageId,
        'text': aiResponse,
        'timestamp': _formatTimestamp(DateTime.now().toIso8601String()),
        'facebookCreatedTime': DateTime.now().toIso8601String(),
        'isFromUser': false,
        'isAI': true,
        'isAIMessage': true,
        'aiMessageId': messageId,
      };

      // Add AI message to the conversation immediately for better UX
      messages.add(aiMessage);
      _forceScrollToBottom();

      // Try to send AI response via Facebook API with proper error handling
      try {
        final sendResult = await FacebookGraphApiService.sendMessageToConversation(
          conversationId!,
          pageAccessToken!,
          aiResponse,
          userId: userId,
          messageTag: "UPDATE", // Use UPDATE tag to bypass 24-hour restriction
        );

        if (sendResult['success'] == true) {
          print('✅ AI message sent successfully');
          // Update message with Facebook response
          final facebookResponse = sendResult['data'];
          if (facebookResponse != null && facebookResponse['id'] != null) {
            aiMessage['facebookMessageId'] = facebookResponse['id'];
          }
        } else {
          print('❌ Failed to send AI message: ${sendResult['error']}');
          // Check if it's a window policy error
          if (sendResult['error']?.toString().contains('outside the allowed window') == true) {
            print('⚠️ Facebook API window restriction - keeping message locally');
            aiMessage['isPending'] = true;
            aiMessage['error'] = 'Message outside Facebook API window';
            Get.snackbar(
              'AI Response', 
              'AI responded but message is outside Facebook API window. Response saved locally.',
              backgroundColor: Colors.orange,
              colorText: Colors.white,
              duration: Duration(seconds: 4),
            );
          } else {
            // Keep the message locally but mark it as pending
            aiMessage['isPending'] = true;
            aiMessage['error'] = 'Facebook API error: ${sendResult['error']}';
            Get.snackbar(
              'AI Response', 
              'AI responded but Facebook API is unavailable. Response saved locally.',
              backgroundColor: Colors.orange,
              colorText: Colors.white,
              duration: Duration(seconds: 4),
            );
          }
        }
      } catch (apiError) {
        print('❌ Facebook API error: $apiError');
        // Keep the message locally but mark it as pending
        aiMessage['isPending'] = true;
        aiMessage['error'] = 'Facebook API error: $apiError';
        Get.snackbar(
          'AI Response', 
          'AI responded but Facebook API is unavailable. Response saved locally.',
          backgroundColor: Colors.orange,
          colorText: Colors.white,
          duration: Duration(seconds: 4),
        );
      }

    } catch (e) {
      print('❌ Error sending AI message: $e');
      Get.snackbar('AI Error', 'Failed to send AI response: $e');
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

  /// Clean up old AI response tracking to prevent memory buildup
  void _cleanupOldAIResponses() {
    final now = DateTime.now();
    final keysToRemove = <String>[];
    
    for (final entry in _lastAIResponseTime.entries) {
      if (now.difference(entry.value).inMinutes > 30) {
        keysToRemove.add(entry.key);
      }
    }
    
    for (final key in keysToRemove) {
      _lastAIResponseTime.remove(key);
      _aiRespondedToMessages.remove(key);
    }
    
    // Also clean up old response texts (keep only last 50)
    if (_aiResponseTexts.length > 50) {
      final textsList = _aiResponseTexts.toList();
      _aiResponseTexts.clear();
      _aiResponseTexts.addAll(textsList.take(50));
    }
    
    print('🧹 Cleaned up ${keysToRemove.length} old AI responses');
  }

  /// CRITICAL: Comprehensive message deduplication
  bool _isMessageDuplicate(Map<String, dynamic> message) {
    final messageId = message['id']?.toString() ?? '';
    final facebookId = message['facebookMessageId']?.toString() ?? '';
    final content = message['text']?.toString() ?? '';
    final timestamp = message['timestamp']?.toString() ?? '';
    final isFromUser = message['isFromUser'] ?? false;
    
    print('🔍 DEDUPLICATION CHECK: "$content" (${isFromUser ? 'USER' : 'PAGE'})');
    print('  Message ID: $messageId');
    print('  Facebook ID: $facebookId');
    print('  Timestamp: $timestamp');
    
    // Create unique identifiers
    final contentKey = '${content}_${timestamp}_${isFromUser}';
    final idKey = messageId.isNotEmpty ? messageId : facebookId;
    
    // Check if we've seen this exact message before
    if (_allMessageIds.contains(idKey)) {
      print('⚠️ DUPLICATE: Message ID already exists: $idKey');
      return true;
    }
    
    if (_allMessageContent.contains(contentKey)) {
      print('⚠️ DUPLICATE: Message content already exists: $contentKey');
      return true;
    }
    
    // Check if this content matches any existing message
    if (_messageContentToId.containsKey(content) && _messageContentToId[content] != idKey) {
      print('⚠️ DUPLICATE: Message content matches existing message: $content');
      return true;
    }
    
    // CRITICAL: Check if this exact content already exists in current messages
    final existingMessage = messages.any((m) => 
      m['text'] == content && 
      m['isFromUser'] == isFromUser
    );
    
    if (existingMessage) {
      print('⚠️ DUPLICATE: Message content already exists in current messages: $content');
      return true;
    }
    
    // Add to tracking sets
    if (idKey.isNotEmpty) _allMessageIds.add(idKey);
    _allMessageContent.add(contentKey);
    _messageContentToId[content] = idKey;
    
    return false;
  }

  /// Polling
  void _startMessagePolling() {
    _messagePollingTimer?.cancel();
    // ✅ IMPROVED: Less frequent polling to reduce spam
    _messagePollingTimer = Timer.periodic(
        const Duration(seconds: 30), (_) {
          _pollForNewMessages();
          _cleanupOldAIResponses(); // Clean up old AI responses periodically
        });
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
            final safeFacebookPageId = facebookPageId ?? '313808701826338';
            
            // CRITICAL FIX: Correct logic for determining if message is from user
            // If messageFromId equals facebookPageId, it's from the PAGE (business)
            // If messageFromId does NOT equal facebookPageId, it's from the USER
            final isFromUser = messageFromId != safeFacebookPageId;
            final messageId = message['id'] ?? DateTime.now().millisecondsSinceEpoch.toString();
            
            print('💬 New message from ${isFromUser ? 'USER' : 'PAGE'}: ${message['message']}');
            print('🔍 Polling Debug: messageFromId=$messageFromId, facebookPageId=$safeFacebookPageId, isFromUser=$isFromUser');
            print('🔍 Message from object: ${message['from']}');
            
            // CRITICAL DEBUG: Check if facebookPageId is correct
            if (facebookPageId == null || facebookPageId!.isEmpty) {
              print('❌ CRITICAL: facebookPageId is null/empty in polling!');
              print('❌ This will cause ALL messages to appear on the right side!');
            }
            
            // Enhanced AI message detection - check multiple criteria
            final messageText = message['message'] ?? '';
            final isAIGenerated = messages.any((m) => 
              m['text'] == messageText && 
              m['isAI'] == true && 
              m['isAIMessage'] == true
            );
            
            // Additional check: if this message is from the page and we have a similar AI message recently
            final isRecentAIMessage = !isFromUser && messages.any((m) => 
              m['text'] == messageText && 
              m['isAI'] == true && 
              m['isAIMessage'] == true &&
              DateTime.now().difference(DateTime.tryParse(m['facebookCreatedTime'] ?? m['timestamp'] ?? '') ?? DateTime.now()).inMinutes < 5
            );
            
            final finalIsAIGenerated = isAIGenerated || isRecentAIMessage;
            
            // Use contact name from chat data for user messages, Facebook page name for page messages
            String senderName;
            if (isFromUser) {
              // For user messages, use the contact name from chat data
              senderName = chatData?['contactName'] ?? 'Unknown User';
              print('🔍 Polling: Using contact name for user message: $senderName');
            } else {
              // For page messages, use the Facebook page name
              senderName = message['from']['name'] ?? 'Facebook Page';
              print('🔍 Polling: Using Facebook page name for page message: $senderName');
            }
            
            return {
              'id': messageId,
              'text': message['message'] ?? '',
              'timestamp': _formatTimestamp(message['created_time']),
              'facebookCreatedTime': message['created_time'], // Store original Facebook timestamp
              'isFromUser': isFromUser, // Use corrected logic
              'isAI': finalIsAIGenerated, // Mark as AI if it's an AI-generated message
              'isAIMessage': finalIsAIGenerated, // Additional AI flag
              'facebookMessageId': message['id'],
              'senderName': senderName, // Use correct sender name based on message source
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
          
          // Use comprehensive deduplication
          final uniqueNewMessages = convertedNewMessages.where((msg) {
            print('🔍 POLLING: Checking message: ${msg['text']} (${msg['isFromUser'] ? 'USER' : 'PAGE'})');
            
            // Use the comprehensive deduplication method
            if (_isMessageDuplicate(msg)) {
              print('⚠️ POLLING: Message is duplicate, skipping: ${msg['text']}');
              return false;
            }
            
            print('✅ POLLING: Message is unique: ${msg['text']}');
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
          
          // Show notification for new user messages and trigger AI response if enabled
          final userMessages = convertedNewMessages.where((m) => m['isFromUser'] == true).toList();
          if (userMessages.isNotEmpty) {
            // Show notification
            Get.snackbar(
              '💬 New Message',
              'You have ${userMessages.length} new message(s)',
              snackPosition: SnackPosition.TOP,
              duration: Duration(seconds: 2),
              backgroundColor: Colors.blue,
              colorText: Colors.white,
            );

            // Trigger AI response if AI is enabled - FIXED: Prevent multiple responses
            print('🔍 POLLING AI CHECK: isAIEnabled=${isAIEnabled.value}, userMessages=${userMessages.length}');
            if (isAIEnabled.value && userMessages.isNotEmpty) {
              final latestUserMessage = userMessages.first;
              final messageText = latestUserMessage['text']?.toString() ?? '';
              print('🔍 POLLING: Latest user message: $messageText');
              if (messageText.isNotEmpty) {
                // CRITICAL FIX: Check if we already responded to this message
                final messageHash = messageText.trim().toLowerCase();
                if (!_aiRespondedToMessages.contains(messageHash)) {
                  print('🤖 AI is enabled, generating response for: $messageText');
                  // Add a small delay to make it feel more natural
                  Future.delayed(Duration(seconds: 2), () {
                    generateAIResponse(messageText);
                  });
                } else {
                  print('⚠️ AI already responded to this message, skipping: $messageText');
                }
              }
            } else {
              print('⚠️ POLLING: AI not enabled or no user messages');
            }
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
      
      // Enhanced duplicate checking for real-time messages
      final messageId = messageData['id'] ?? messageData['timestamp'].toString();
      final content = messageData['text']?.toString() ?? '';
      final timestamp = messageData['timestamp']?.toString() ?? '';
      final isFromUser = messageData['isFromUser'] ?? false;
      
      // Enhanced duplicate checking for real-time messages
      final existingMessage = messages.firstWhereOrNull((m) => 
        m['id'] == messageId || 
        m['facebookMessageId'] == messageId ||
        (m['text'] == content && m['timestamp'] == timestamp && m['isFromUser'] == isFromUser)
      );
      
      // Special check for AI messages - if this content matches an existing AI message, skip it
      final isAIMessage = messages.any((m) => 
        m['text'] == content && 
        m['isAI'] == true && 
        m['isAIMessage'] == true
      );
      
      if (existingMessage != null || isAIMessage) {
        print('⚠️ Message already exists or is AI message, skipping: $content');
        return;
      }
      
      // Use contact name from chat data for user messages, Facebook page name for page messages
      String senderName;
      if (isFromUser) {
        // For user messages, use the contact name from chat data
        senderName = chatData?['contactName'] ?? 'Unknown User';
        print('🔍 Real-time: Using contact name for user message: $senderName');
      } else {
        // For page messages, use the Facebook page name
        senderName = messageData['senderName'] ?? 'Facebook Page';
        print('🔍 Real-time: Using Facebook page name for page message: $senderName');
      }
      
      // Convert to app format
      final newMessage = {
        'id': messageId,
        'text': messageData['text'] ?? '',
        'timestamp': _formatTimestamp(messageData['timestamp']?.toString() ?? DateTime.now().toIso8601String()),
        'isFromUser': isFromUser,
        'isAI': false,
        'facebookMessageId': messageId,
        'senderName': senderName, // Use correct sender name based on message source
        'senderId': messageData['senderId'] ?? '', // Store sender ID
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
      
      // Show notification for new user messages and trigger AI response if enabled
      if (messageData['isFromUser'] == true) {
        Get.snackbar(
          '💬 New Message',
          'You have a new message!',
          snackPosition: SnackPosition.TOP,
          duration: Duration(seconds: 2),
          backgroundColor: Colors.blue,
          colorText: Colors.white,
        );

        // Trigger AI response if AI is enabled - FIXED: Prevent duplicate responses
        print('🔍 REALTIME AI CHECK: isAIEnabled=${isAIEnabled.value}');
        if (isAIEnabled.value) {
          final messageText = messageData['text']?.toString() ?? '';
          print('🔍 REALTIME: Message text: $messageText');
          if (messageText.isNotEmpty) {
            // CRITICAL FIX: Check if we already responded to this message
            final messageHash = messageText.trim().toLowerCase();
            if (!_aiRespondedToMessages.contains(messageHash)) {
              print('🤖 AI is enabled, generating response for real-time message: $messageText');
              // Add a small delay to make it feel more natural
              Future.delayed(Duration(seconds: 2), () {
                generateAIResponse(messageText);
              });
            } else {
              print('⚠️ AI already responded to this real-time message, skipping: $messageText');
            }
          }
        } else {
          print('⚠️ REALTIME: AI not enabled');
        }
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
      
      // Show notification for new user messages and trigger AI response if enabled
      if (messageData['isFromUser'] == true) {
        Get.snackbar(
          '💬 New Message',
          'You have a new message from ${messageData['senderName'] ?? 'Facebook User'}!',
          snackPosition: SnackPosition.TOP,
          duration: Duration(seconds: 3),
          backgroundColor: Colors.blue,
          colorText: Colors.white,
        );

        // Trigger AI response if AI is enabled
        if (isAIEnabled.value) {
          final messageText = messageData['text']?.toString() ?? '';
          if (messageText.isNotEmpty) {
            print('🤖 AI is enabled, generating response for webhook message: $messageText');
            // Add a small delay to make it feel more natural
            Future.delayed(Duration(seconds: 2), () {
              generateAIResponse(messageText);
            });
          }
        }
      }
      
      print('✅ Webhook message added successfully');
    } catch (e) {
      print('❌ Error handling webhook message: $e');
    }
  }
}
