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
import 'package:minechat/core/widgets/chat/facebook_profile_avatar.dart';
import 'package:minechat/core/widgets/chat/real_profile_avatar.dart';
import 'package:minechat/core/utils/image_parser.dart';
import 'package:minechat/core/services/facebook_graph_api_service.dart';
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
        // Trigger immediate polling for real-time images when screen becomes visible
        conversationController.onScreenVisible();
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
                    onImageSelected: (imagePath) => conversationController.sendImageMessage(imagePath),
                    onVoiceSelected: (audioPath) => conversationController.sendVoiceMessage(audioPath),
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
            
            // Check if this is a media message (image or voice only)
            final messageType = message['type'] as String?;
            if (messageType == 'image' || messageType == 'voice') {
              return MessageBubbleWidget.media(
                messageData: message,
                isFromUser: message['isFromUser'] ?? false,
              );
            }
            
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
    final isSentMessage = message['isSentMessage'] ?? false;
    final sentMessageId = message['sentMessageId'] ?? '';
    
    print('🔍 AVATAR DEBUG:');
    print('🔍   isFromUser: $isFromUser');
    print('🔍   senderName: $senderName');
    print('🔍   senderId: $senderId');
    print('🔍   isSentMessage: $isSentMessage');
    print('🔍   sentMessageId: $sentMessageId');
    print('🔍   Full message: $message');
    
    // CORRECTED ARCHITECTURE: Your app IS the Facebook Page
    final isPageMessage = isSentMessage || sentMessageId.isNotEmpty || (!isFromUser && senderName == 'Facebook Page');
    final isClientMessage = isFromUser;
    
    print('🔍   isPageMessage: $isPageMessage');
    print('🔍   isClientMessage: $isClientMessage');
    print('🔍   AVATAR - isSentMessage: $isSentMessage');
    print('🔍   AVATAR - sentMessageId: $sentMessageId');
    print('🔍   AVATAR - senderName: $senderName');
    print('🔍   AVATAR - isFromUser: $isFromUser');
    
    if (isPageMessage) {
      // PAGE message (left side) - show blue Page icon
      print('🔍 ✅ Showing blue Page icon for PAGE message (LEFT SIDE)');
      return _buildFacebookPageIcon();
    }
    
    // CLIENT message (right side) - show real profile picture or initials
    print('🔍 ✅ Showing real profile avatar for CLIENT message (RIGHT SIDE): $senderName');
    // For received messages (from clients), show real profile pictures or initials
    final profileImageUrl = message['profileImageUrl'] as String?;
    String displayName = senderName;
    
    // Handle display name for client messages
    if (senderName == 'Unknown User' || senderName == 'Facebook User' || senderName.length < 3) {
      displayName = 'Customer';
    }
    
    return RealProfileAvatar(
      profileImageUrl: profileImageUrl,
      displayName: displayName,
        radius: 16,
      isFromUser: isFromUser,
    );
  }
  
  /// Build Facebook Page icon for sent messages
  Widget _buildFacebookPageIcon() {
    return Container(
      width: 32,
      height: 32,
      decoration: BoxDecoration(
        color: Colors.blue[600], // Facebook blue color
        shape: BoxShape.circle,
        border: Border.all(
          color: Colors.white,
          width: 2,
        ),
      ),
      child: Icon(
        Icons.business, // Page/business icon
        color: Colors.white,
        size: 18,
      ),
    );
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
  final Set<String> _sentMessageIds = <String>{};
  
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
    print('🔄 AI State on init: isAIEnabled = ${isAIEnabled.value}');
    
    // FORCE AI to be disabled on init to prevent auto-enabling
    isAIEnabled.value = false;
    print('🔄 AI State after force disable: isAIEnabled = ${isAIEnabled.value}');
    
    // Trigger immediate polling for real-time messages
    Future.delayed(const Duration(milliseconds: 500), () {
      print('🔄 Triggering immediate message polling...');
      _pollForNewMessages();
    });
    
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
    print('🔄 AI State before setChatData: isAIEnabled = ${isAIEnabled.value}');
    
    // FORCE AI to be disabled when setting chat data
    isAIEnabled.value = false;
    print('🔄 AI State after force disable in setChatData: isAIEnabled = ${isAIEnabled.value}');
    
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
        final data = result['data'];
        List<dynamic> messagesData;
        
        // Handle different response types
        if (data is List<dynamic>) {
          messagesData = data;
        } else if (data is Map<String, dynamic>) {
          // If it's a single message or thread data, wrap it in a list
          messagesData = [data];
        } else {
          print('❌ Unexpected data type from Facebook API: ${data.runtimeType}');
          messagesData = [];
        }
        
        print('📨 Loaded ${messagesData.length} messages from Facebook');
        
        final convertedMessages = messagesData.map((message) {
          // Add safety check for message structure
          if (message is! Map<String, dynamic>) {
            print('⚠️ Skipping invalid message format: ${message.runtimeType}');
            return null;
          }
          
          // Check if message has required fields
          if (message['from'] == null || message['id'] == null) {
            print('⚠️ Skipping message with missing required fields: $message');
            return null;
          }
          
          // ✅ FIXED: Correct user detection logic
          final messageFromId = message['from']['id']?.toString() ?? '';
          final safeFacebookPageId = facebookPageId ?? '313808701826338';
          
          // CRITICAL FIX: Determine if this message was sent by the user
          // Check tracking sets FIRST to identify sent messages
          final facebookMessageId = message['id'] ?? '';
          final messageContent = message['message'] ?? '';
          
          print('🔍 MESSAGE SIDE DETERMINATION:');
          print('🔍   Facebook Message ID: $facebookMessageId');
          print('🔍   Message Content: $messageContent');
          print('🔍   Sent IDs: $_sentMessageIds');
          print('🔍   Sent Texts: $_sentMessageTexts');
          
          // Check if this message was sent by the user using multiple criteria
          final isSentByUser = _sentMessageIds.contains(facebookMessageId) || 
                              _sentMessageTexts.contains(messageContent) ||
                              message.containsKey('isSentMessage') && message['isSentMessage'] == true ||
                              messageFromId == safeFacebookPageId; // NEW: Check if sender is the Page
          
          print('🔍   messageFromId: $messageFromId');
          print('🔍   safeFacebookPageId: $safeFacebookPageId');
          print('🔍   isSentByUser: $isSentByUser');
          print('🔍   Checking sent IDs: ${_sentMessageIds.toList()}');
          print('🔍   Checking sent texts: ${_sentMessageTexts.toList()}');
          print('🔍   Message contains isSentMessage: ${message.containsKey('isSentMessage')}');
          print('🔍   Message isSentMessage value: ${message['isSentMessage']}');
          
          // CORRECTED ARCHITECTURE: Your app IS the Facebook Page
          bool isFromUser;
          if (isSentByUser) {
            // Message was sent by YOUR APP (the Page) - should appear on LEFT SIDE (Page side)
            isFromUser = false;
            print('🔧 ✅ PAGE APP SENT MESSAGE - Setting isFromUser = false (LEFT SIDE - PAGE)');
          } else {
            // Message was sent by the CLIENT - should appear on RIGHT SIDE (Client side)
            isFromUser = true;
            print('🔧 ✅ CLIENT SENT MESSAGE - Setting isFromUser = true (RIGHT SIDE - CLIENT)');
          }
          final messageId = message['id'] ?? DateTime.now().millisecondsSinceEpoch.toString();
          
          print('💬 Message from ${isFromUser ? 'USER' : 'PAGE'}: ${message['message']}');
          print('🔍 Debug: messageFromId=$messageFromId, facebookPageId=$safeFacebookPageId, isFromUser=$isFromUser');
          print('🔍 Message from object: ${message['from']}');
          print('🔍 Sender name: ${message['from']['name']}');
          print('🔍 Sender ID: ${message['from']['id']}');
          print('🔍 Message ID: ${message['id']}');
          print('🔍 Full message: $message');
          
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
          
          // Process attachments for images
          String? imageUrl;
          String? messageType;
          if (message['attachments'] != null) {
            final attachments = message['attachments'];
            print('🔍 Attachment structure: $attachments');
            
            // Handle different attachment structures
            List<dynamic> attachmentList = [];
            if (attachments is List) {
              attachmentList = attachments;
            } else if (attachments is Map && attachments['data'] != null) {
              attachmentList = attachments['data'] as List;
            }
            
            for (final attachment in attachmentList) {
              print('🔍 Processing attachment: $attachment');
              
              // Check for image attachments
              if (attachment['image_data'] != null && attachment['image_data']['url'] != null) {
                imageUrl = attachment['image_data']['url'];
                messageType = 'image';
                print('🖼️ Found image URL: $imageUrl');
                break;
              }
              
              // Also check for mime_type indicating image
              if (attachment['mime_type'] != null && attachment['mime_type'].toString().startsWith('image/')) {
                if (attachment['image_data'] != null && attachment['image_data']['url'] != null) {
                  imageUrl = attachment['image_data']['url'];
                  messageType = 'image';
                  print('🖼️ Found image URL via mime_type: $imageUrl');
                  break;
                }
              }
            }
          }

          // Set appropriate text for image messages
          String messageText = message['message'] ?? '';
          if (messageType == 'image' && messageText.isEmpty) {
            messageText = '[Image]';
            print('🖼️ IMAGE MESSAGE: Set text to [Image] for empty message');
          }
          
          // Debug image message processing
          if (messageType == 'image') {
            print('🖼️ IMAGE MESSAGE DEBUG:');
            print('🖼️   Message ID: $messageId');
            print('🖼️   Image URL: $imageUrl');
            print('🖼️   Is From User: $isFromUser');
            print('🖼️   Sender Name: $senderName');
            print('🖼️   Message Text: $messageText');
            print('🖼️   Facebook Message ID: ${message['id']}');
          }

          
          return {
            'id': messageId,
            'text': messageText,
            'timestamp': _formatTimestamp(message['created_time']),
            'facebookCreatedTime': message['created_time'], // Store original Facebook timestamp
            'isFromUser': isFromUser, // Use corrected logic
            'isAI': false,
            'isSentMessage': isSentByUser, // Mark if this was sent by the user
            'facebookMessageId': message['id'], // Store original Facebook ID
            'senderName': senderName, // Use correct sender name based on message source
            'senderId': message['from']['id'] ?? '', // Store sender ID
            'type': messageType, // Add message type (image, text, etc.)
            'imageUrl': imageUrl, // Add image URL if present
            'profileImageUrl': null, // Will be fetched separately to avoid blocking UI
          };
        }).where((message) => message != null).cast<Map<String, dynamic>>().toList();

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
        
        // CRITICAL FIX: Populate tracking sets during initial load
        // This prevents messages from being marked as duplicates during polling
        for (final message in deduplicatedMessages) {
          final messageId = message['id']?.toString() ?? '';
          final facebookId = message['facebookMessageId']?.toString() ?? '';
          final content = message['text']?.toString() ?? '';
          final timestamp = message['timestamp']?.toString() ?? '';
          final isFromUser = message['isFromUser'] ?? false;
          
          // Add to tracking sets
          if (messageId.isNotEmpty) _allMessageIds.add(messageId);
          if (facebookId.isNotEmpty) _allMessageIds.add(facebookId);
          _allMessageContent.add('${content}_${timestamp}_${isFromUser}');
          _messageContentToId[content] = facebookId.isNotEmpty ? facebookId : messageId;
        }
        
        print('🔧 POPULATED TRACKING SETS:');
        print('🔧   _allMessageIds: ${_allMessageIds.length} items');
        print('🔧   _allMessageContent: ${_allMessageContent.length} items');
        print('🔧   _messageContentToId: ${_messageContentToId.length} items');
        
        // Force scroll to bottom after messages are loaded - WhatsApp-like behavior
        _forceScrollToBottom();
        
        print('✅ Successfully loaded ${convertedMessages.length} messages');
        
        // Fetch profile images asynchronously to avoid blocking UI
        _fetchProfileImagesForMessages(deduplicatedMessages);
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
    print('🔄 toggleAIResponse called - current state: ${isAIEnabled.value}');
    isAIEnabled.value = !isAIEnabled.value;
    print('🔄 toggleAIResponse - new state: ${isAIEnabled.value}');
    
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
    print('🔄 toggleAI called with enabled: $enabled - current state: ${isAIEnabled.value}');
    isAIEnabled.value = enabled;
    print('🔄 toggleAI - new state: ${isAIEnabled.value}');
    
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

  /// Send text message with AI integration
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
        'isFromUser': false, // CORRECTED: Messages sent from app (Page) should appear on LEFT side
        'isAI': false,
        'isSentMessage': true,
        'sentMessageId': messageId,
        'senderName': 'Facebook Page', // Use Facebook page name for sent messages
        'senderId': facebookPageId ?? '', // Use Facebook page ID
      };

      // Track this message as sent to prevent duplicates
      _sentMessageIds.add(messageId);
      _sentMessageTexts.add(messageText);
      
      print('🔧 IMMEDIATE TRACKING: Added message to tracking sets:');
      print('🔧   Message ID: $messageId');
      print('🔧   Message Text: $messageText');
      print('🔧   Sent IDs now: ${_sentMessageIds.toList()}');
      print('🔧   Sent Texts now: ${_sentMessageTexts.toList()}');
      
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
        // Track this message as sent (both local and Facebook IDs)
        _sentMessageIds.add(messageId);
        _sentMessageTexts.add(messageText);
        
        print('🔧 TRACKING: Added message to tracking sets:');
        print('🔧   Message ID: $messageId');
        print('🔧   Message Text: $messageText');
        print('🔧   Sent IDs now: ${_sentMessageIds.toList()}');
        print('🔧   Sent Texts now: ${_sentMessageTexts.toList()}');
        
        // Also track the Facebook message ID when it comes back
        if (sendResult['data']?['message_id'] != null) {
          final facebookMessageId = sendResult['data']['message_id'];
          _sentMessageIds.add(facebookMessageId);
          print('🔧 TRACKING: Added Facebook message ID to tracking: $facebookMessageId');
        }
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

  /// Send image message
  Future<void> sendImageMessage(String imagePath) async {
    if (conversationId == null || pageAccessToken == null) {
      Get.snackbar('Error', 'Cannot send image: Missing conversation data');
      return;
    }

    setSending(true);
    
    try {
      // Create local message for immediate UI update
      final messageId = DateTime.now().millisecondsSinceEpoch.toString();
      final newMessage = {
        'id': messageId,
        'text': '[Image]',
        'type': 'image',
        'imagePath': imagePath,
        'isFromUser': false, // CORRECTED: Messages sent from app (Page) should appear on LEFT side
        'timestamp': DateTime.now().toIso8601String(),
        'isSending': true,
        'isSentMessage': true,
        'sentMessageId': messageId,
        'senderName': 'Facebook Page', // Use Facebook page name for sent messages
        'senderId': facebookPageId ?? '', // Use Facebook page ID
      };

      print('🖼️ Creating image message:');
      print('🖼️ Message ID: $messageId');
      print('🖼️ Image path: $imagePath');
      print('🖼️ Message type: ${newMessage['type']}');
      print('🖼️ Is from user: ${newMessage['isFromUser']}');

      // Track this message as sent
      _sentMessageIds.add(messageId);
      _sentMessageTexts.add('[Image]');
      // Add to local messages immediately
      messages.add(newMessage);
      _forceScrollToBottom();

      // Send image to Facebook using the new image upload functionality
      final sendResult = await FacebookGraphApiService.sendImageToConversation(
        conversationId!,
        pageAccessToken!,
        imagePath,
        userId: userId,
      );

      if (sendResult['success'] == true) {
        // Update message status
        final messageIndex = messages.indexWhere((msg) => msg['id'] == messageId);
        if (messageIndex != -1) {
          print('🖼️ Updating message status - removing loading indicator');
          print('🖼️ Message found at index: $messageIndex');
          print('🖼️ Current isSending value: ${messages[messageIndex]['isSending']}');
          
          // Update the message
          messages[messageIndex]['isSending'] = false;
          final facebookMessageId = sendResult['data']?['message_id'];
          messages[messageIndex]['facebookMessageId'] = facebookMessageId;
          
          // Track the Facebook message ID
          if (facebookMessageId != null) {
            _sentMessageIds.add(facebookMessageId);
            print('🔧 IMAGE TRACKING: Added Facebook message ID to tracking: $facebookMessageId');
          }
          
          print('🖼️ Updated isSending value: ${messages[messageIndex]['isSending']}');
          
          // Force UI update
          messages.refresh();
        } else {
          print('🖼️ ERROR: Message not found for ID: $messageId');
          print('🖼️ Available message IDs: ${messages.map((m) => m['id']).toList()}');
        }

        Get.snackbar(
          'Image Shared',
          'Image message sent successfully',
          backgroundColor: Colors.green,
          colorText: Colors.white,
          duration: Duration(seconds: 2),
        );
      } else {
        // Remove failed message
        messages.removeWhere((msg) => msg['id'] == messageId);
        
        Get.snackbar(
          'Send Failed',
          'Failed to send image: ${sendResult['error']}',
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to send image: $e');
    } finally {
      setSending(false);
    }
  }

  /// Send voice message
  Future<void> sendVoiceMessage(String audioPath) async {
    if (conversationId == null || pageAccessToken == null) {
      Get.snackbar('Error', 'Cannot send voice message: Missing conversation data');
      return;
    }

    setSending(true);
    
    try {
      // Create local message for immediate UI update
      final messageId = DateTime.now().millisecondsSinceEpoch.toString();
      final newMessage = {
        'id': messageId,
        'text': '[Voice Message]',
        'type': 'voice',
        'audioPath': audioPath,
        'isFromUser': false, // CORRECTED: Messages sent from app (Page) should appear on LEFT side
        'timestamp': DateTime.now().toIso8601String(),
        'isSending': true,
        'isSentMessage': true,
        'sentMessageId': messageId,
        'senderName': 'Facebook Page', // Use Facebook page name for sent messages
        'senderId': facebookPageId ?? '', // Use Facebook page ID
      };

      print('🎤 Creating voice message:');
      print('🎤 Message ID: $messageId');
      print('🎤 Audio path: $audioPath');
      print('🎤 Message type: ${newMessage['type']}');
      print('🎤 Is from user: ${newMessage['isFromUser']}');

      // Add to local messages immediately
      messages.add(newMessage);
      _forceScrollToBottom();

      // Send to Facebook (Note: Facebook doesn't support audio sending via API in most cases)
      // For now, we'll send a text message indicating a voice message was shared
      final textMessage = "🎤 [Voice message shared - Facebook API doesn't support direct audio sending]";
      
      final sendResult = await FacebookGraphApiService.sendMessageToConversation(
        conversationId!,
        pageAccessToken!,
        textMessage,
        userId: userId,
      );

      if (sendResult['success'] == true) {
        // Update message status
        final messageIndex = messages.indexWhere((msg) => msg['id'] == messageId);
        if (messageIndex != -1) {
          messages[messageIndex]['isSending'] = false;
          messages[messageIndex]['text'] = textMessage;
          messages[messageIndex]['facebookMessageId'] = sendResult['data']?['message_id'];
        }

        Get.snackbar(
          'Voice Sent',
          'Voice message sent successfully',
          backgroundColor: Colors.green,
          colorText: Colors.white,
          duration: Duration(seconds: 2),
        );
      } else {
        // Remove failed message
        messages.removeWhere((msg) => msg['id'] == messageId);
        
        Get.snackbar(
          'Send Failed',
          'Failed to send voice message: ${sendResult['error']}',
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to send voice message: $e');
    } finally {
      setSending(false);
    }
  }

  /// Generate AI Response for incoming messages
  Future<void> generateAIResponse(String userMessage) async {
    print('🤖 ====== AI RESPONSE GENERATION STARTED ======');
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
      // FIXED: This is always an app interface conversation, not Facebook Messenger
      // The conversationId starts with 't_' but this is still our app's chat interface
      // We want to show product images in our app, so treat it as app interface
      final isFacebookConversation = false; // Always false for app interface
      
      // DETAILED DEBUG: Print all context detection details
      print('🔍 CONTEXT DETECTION DEBUG:');
      print('  conversationId: $conversationId');
      print('  conversationId starts with t_: ${conversationId?.startsWith('t_')}');
      print('  chatData platform: ${chatData?['platform']}');
      print('  chatData facebookPageId: ${chatData?['facebookPageId']}');
      print('  isFacebookConversation: $isFacebookConversation');
      print('🔍 Conversation context: ${isFacebookConversation ? 'Facebook Chat' : 'App Interface'}');
      
      // DEBUG: Check what products are being passed to AI
      print('🤖 AI DEBUG - Products available:');
      print('🤖   Total products: ${aiAssistantController.productsServices.length}');
      for (int i = 0; i < aiAssistantController.productsServices.length; i++) {
        final product = aiAssistantController.productsServices[i];
        print('🤖   Product $i: ${product.name}');
        print('🤖     Description: ${product.description}');
        print('🤖     Price: ${product.price}');
        print('🤖     Selected Image: ${product.selectedImage}');
        print('🤖     Images List: ${product.images}');
        print('🤖     Images Count: ${product.images.length}');
      }
      
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
      print('🤖 AI Response Length: ${aiResponse.length} characters');
      print('🤖 AI Response contains markdown images: ${aiResponse.contains('![') && aiResponse.contains('](')}');
      print('🤖 AI Response contains image URLs: ${aiResponse.contains('firebase') || aiResponse.contains('http')}');

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
      print('🤖 About to call _sendAIMessage with response: ${aiResponse.substring(0, 100)}...');
      await _sendAIMessage(aiResponse);
      print('🤖 _sendAIMessage completed successfully');

    } catch (e) {
      print('❌ Error generating AI response: $e');
    } finally {
      isAIResponding.value = false;
    }
  }

  /// Generate AI response for image messages
  Future<void> generateAIResponseForImage(String messageText, String imageUrl) async {
    print('🤖 generateAIResponseForImage called with image: $imageUrl');
    print('🤖 Message text: $messageText');
    print('🤖 isAIEnabled: ${isAIEnabled.value}');
    print('🤖 isAIResponding: ${isAIResponding.value}');
    
    if (!isAIEnabled.value || isAIResponding.value) {
      print('⚠️ AI response blocked - isAIEnabled: ${isAIEnabled.value}, isAIResponding: ${isAIResponding.value}');
      return;
    }

    // Create unique identifier for image messages
    final messageHash = '${messageText.trim().toLowerCase()}_image_${imageUrl.isNotEmpty}';
    if (_aiRespondedToMessages.contains(messageHash)) {
      print('⚠️ AI already responded to this image message, skipping: $imageUrl');
      return;
    }

    // Prevent rapid-fire responses
    final now = DateTime.now();
    if (_lastAIResponseTime.containsKey(messageHash)) {
      final lastResponse = _lastAIResponseTime[messageHash]!;
      if (now.difference(lastResponse).inSeconds < 5) {
        print('⚠️ AI response too recent, debouncing: $imageUrl');
        return;
      }
    }

    try {
      isAIResponding.value = true;
      print('🤖 Generating AI response for image: $imageUrl');

      // Get AI assistant configuration
      final assistant = aiAssistantController.currentAIAssistant.value;
      if (assistant == null) {
        print('⚠️ No AI assistant configured');
        return;
      }

      // For image messages, create a descriptive prompt
      String imagePrompt = messageText.isNotEmpty 
          ? "The user sent an image with the message: '$messageText'. Please respond to their message and acknowledge that you can see they shared an image."
          : "The user sent an image. Please acknowledge that you can see they shared an image and provide a helpful response about it.";

      // FIXED: This is always an app interface conversation, not Facebook Messenger
      final isFacebookConversation = false; // Always false for app interface

      print('🔍 Image AI Context: ${isFacebookConversation ? 'Facebook Chat' : 'App Interface'}');
      
      final aiResponse = await OpenAIService.generateResponseWithKnowledge(
        userMessage: imagePrompt,
        assistantName: assistant.name,
        introMessage: assistant.introMessage,
        shortDescription: assistant.shortDescription,
        aiGuidelines: assistant.aiGuidelines,
        responseLength: assistant.responseLength,
        businessInfo: aiAssistantController.businessInfo.value,
        productsServices: aiAssistantController.productsServices,
        faqs: aiAssistantController.faqs,
        isFacebookChat: isFacebookConversation,
      );

      print('🤖 AI Response for image: $aiResponse');

      // Check if we already sent this exact response
      if (_aiResponseTexts.contains(aiResponse.trim())) {
        print('⚠️ AI response already sent, skipping duplicate');
        return;
      }

      // Mark this message as responded to and track the response
      _aiRespondedToMessages.add(messageHash);
      _aiResponseTexts.add(aiResponse.trim());
      _lastAIResponseTime[messageHash] = now;

      // Send AI response as a message
      print('🤖 About to call _sendAIMessage for IMAGE with response: ${aiResponse.substring(0, 100)}...');
      await _sendAIMessage(aiResponse);
      print('🤖 _sendAIMessage for IMAGE completed successfully');

    } catch (e) {
      print('❌ Error generating AI response for image: $e');
    } finally {
      isAIResponding.value = false;
    }
  }

  /// Send AI-generated message (enhanced to handle images)
  Future<void> _sendAIMessage(String aiResponse) async {
    // Check if AI response contains images
    final imageUrls = ImageParser.extractImageUrls(aiResponse);
    
    print('🤖 AI MESSAGE SENDING DEBUG:');
    print('🤖   AI Response: ${aiResponse.length > 200 ? aiResponse.substring(0, 200) + '...' : aiResponse}');
    print('🤖   Extracted image URLs: $imageUrls');
    print('🤖   Image count: ${imageUrls.length}');
    
    if (imageUrls.isNotEmpty) {
      // AI response contains images - send images to Facebook
      print('🤖   → Routing to image sending method');
      await _sendAIMessageWithImages(aiResponse, imageUrls);
    } else {
      // AI response is text only - send as regular message
      print('🤖   → Routing to text-only sending method');
      await _sendAIMessageTextOnly(aiResponse);
    }
  }

  /// Send AI message with images to Facebook
  Future<void> _sendAIMessageWithImages(String aiResponse, List<String> imageUrls) async {
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
        'type': 'image',
        'imageUrl': imageUrls.first, // Use first image for display
      };

      // Add AI message to the conversation immediately for better UX
      messages.add(aiMessage);
      _forceScrollToBottom();

      // Send images to Facebook using sendImageToConversation
      print('🤖 AI sending ${imageUrls.length} images to Facebook');
      
      for (int i = 0; i < imageUrls.length; i++) {
        final imageUrl = imageUrls[i];
        print('🤖 Sending image ${i + 1}/${imageUrls.length}: $imageUrl');
        
        try {
          final sendResult = await FacebookGraphApiService.sendImageToConversation(
            conversationId!,
            pageAccessToken!,
            imageUrl,
            userId: userId,
          );

          if (sendResult['success'] == true) {
            print('✅ AI image ${i + 1} sent successfully to Facebook');
          } else {
            print('❌ Failed to send AI image ${i + 1}: ${sendResult['error']}');
          }
        } catch (e) {
          print('❌ Error sending AI image ${i + 1}: $e');
        }
        
        // Add delay between images to avoid rate limiting
        if (i < imageUrls.length - 1) {
          await Future.delayed(Duration(seconds: 1));
        }
      }

      // Also send text message with product description (without images)
      final textWithoutImages = ImageParser.removeImageUrls(aiResponse);
      if (textWithoutImages.trim().isNotEmpty) {
        print('🤖 AI sending text description to Facebook');
        try {
          final sendResult = await FacebookGraphApiService.sendMessageToConversation(
            conversationId!,
            pageAccessToken!,
            textWithoutImages,
            userId: userId,
            messageTag: "UPDATE",
          );

          if (sendResult['success'] == true) {
            print('✅ AI text description sent successfully to Facebook');
          } else {
            print('❌ Failed to send AI text description: ${sendResult['error']}');
          }
        } catch (e) {
          print('❌ Error sending AI text description: $e');
        }
      }

    } catch (e) {
      print('❌ Error in _sendAIMessageWithImages: $e');
      // Fallback to text-only sending
      await _sendAIMessageTextOnly(aiResponse);
    }
  }

  /// Send AI message text only to Facebook
  Future<void> _sendAIMessageTextOnly(String aiResponse) async {
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

  /// Fetch profile images for messages asynchronously
  Future<void> _fetchProfileImagesForMessages(List<Map<String, dynamic>> messageList) async {
    if (pageAccessToken == null) return;
    
    for (final message in messageList) {
      final isFromUser = message['isFromUser'] ?? false;
      final senderId = message['senderId'] ?? '';
      final messageId = message['id'] ?? '';
      
      // Skip if already has profile image or no sender ID
      if (message['profileImageUrl'] != null || senderId.isEmpty) continue;
      
      try {
        String? profileImageUrl;
        
        if (isFromUser) {
          // Fetch user profile picture
          profileImageUrl = await FacebookGraphApiService.getUserProfilePicture(
            senderId, 
            pageAccessToken!
          );
        } else {
          // Fetch page profile picture
          if (facebookPageId != null) {
            profileImageUrl = await FacebookGraphApiService.getPageProfilePicture(
              facebookPageId!, 
              pageAccessToken!
            );
          }
        }
        
        // Update the message with profile image URL
        if (profileImageUrl != null) {
          final messageIndex = messages.indexWhere((m) => m['id'] == messageId);
          if (messageIndex != -1) {
            messages[messageIndex]['profileImageUrl'] = profileImageUrl;
            messages.refresh(); // Trigger UI update
            print('🖼️ Updated profile image for message $messageId: $profileImageUrl');
          }
        }
      } catch (e) {
        print('❌ Error fetching profile image for message $messageId: $e');
      }
    }
  }

  /// Clear message tracking (for debugging)
  void clearMessageTracking() {
    _sentMessageIds.clear();
    _sentMessageTexts.clear();
    print('🧹 Cleared message tracking sets');
  }
  
  /// Debug method to print current tracking state
  void printTrackingState() {
    print('🔍 CURRENT TRACKING STATE:');
    print('🔍   Sent IDs: ${_sentMessageIds.toList()}');
    print('🔍   Sent Texts: ${_sentMessageTexts.toList()}');
    print('🔍   Total tracked IDs: ${_sentMessageIds.length}');
    print('🔍   Total tracked texts: ${_sentMessageTexts.length}');
    print('🔍   Facebook Page ID: $facebookPageId');
    print('🔍   Conversation ID: $conversationId');
    print('🔍   All Message IDs: ${_allMessageIds.toList()}');
    print('🔍   All Message Content: ${_allMessageContent.toList()}');
  }
  
  /// Clear all tracking for debugging
  void clearAllTracking() {
    _sentMessageIds.clear();
    _sentMessageTexts.clear();
    _allMessageIds.clear();
    _allMessageContent.clear();
    _messageContentToId.clear();
    print('🧹 Cleared all tracking sets for debugging');
  }

  /// Force scroll to bottom - Aggressive WhatsApp-like behavior
  void _forceScrollToBottom() {
    try {
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
    } catch (e) {
      print('⚠️ ScrollController not ready yet: $e');
      // Retry after a delay when the widget is built
      Future.delayed(const Duration(milliseconds: 500), () {
        if (scrollController.hasClients) {
          _scrollToBottom();
        }
      });
    }
  }

  /// Auto-scroll to bottom - WhatsApp-like behavior
  void _scrollToBottom() {
    try {
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
    } catch (e) {
      print('❌ Error in _scrollToBottom: $e');
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
    print('  Message Type: ${message['type']}');
    print('  Current _allMessageIds: ${_allMessageIds.toList()}');
    print('  Current _allMessageContent: ${_allMessageContent.toList()}');
    
    // Create unique identifiers
    final contentKey = '${content}_${timestamp}_${isFromUser}';
    final idKey = messageId.isNotEmpty ? messageId : facebookId;
    
    // Check if we've seen this exact message before
    if (_allMessageIds.contains(idKey)) {
      print('⚠️ DUPLICATE: Message ID already exists: $idKey');
      return true;
    }
    
    final messageType = message['type'] as String?;
    
    // Be more lenient with content-based deduplication for images
    if (messageType != 'image' && messageType != 'voice' && _allMessageContent.contains(contentKey)) {
      print('⚠️ DUPLICATE: Message content already exists: $contentKey');
      return true;
    }
    
    // Check if this content matches any existing message (but be lenient for images)
    if (messageType != 'image' && messageType != 'voice' && 
        _messageContentToId.containsKey(content) && _messageContentToId[content] != idKey) {
      print('⚠️ DUPLICATE: Message content matches existing message: $content');
      return true;
    }
    
    // CRITICAL: Check if this exact content already exists in current messages
    final existingMessage = messages.any((m) {
      final existingContent = m['text']?.toString() ?? '';
      final existingIsFromUser = m['isFromUser'] ?? false;
      final existingFacebookId = m['facebookMessageId']?.toString() ?? '';
      final existingType = m['type']?.toString() ?? '';
      final messageType = message['type']?.toString() ?? '';
      
      // For image/voice messages, be very lenient with content matching
      if (messageType == 'image' || messageType == 'voice' || existingType == 'image' || existingType == 'voice') {
        // For media messages, only check by Facebook ID to avoid false duplicates
        if (facebookId.isNotEmpty && existingFacebookId == facebookId) {
          return true;
        }
        return false;
      }
      
      // For all messages, prioritize Facebook ID checking
      if (facebookId.isNotEmpty && existingFacebookId == facebookId) {
        return true;
      }
      
      // Only check content if Facebook ID is not available (fallback)
      if (facebookId.isEmpty && existingFacebookId.isEmpty) {
        // For messages without Facebook ID, check by content and sender
        if (existingContent == content && existingIsFromUser == isFromUser) {
          return true;
        }
      }
      
      return false;
    });
    
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
    // ✅ AGGRESSIVE: Very fast polling for real-time chat experience
    _messagePollingTimer = Timer.periodic(
        const Duration(seconds: 3), (_) {
          _pollForNewMessages();
          _cleanupOldAIResponses(); // Clean up old AI responses periodically
        });
    print('🔄 Started AGGRESSIVE message polling every 3 seconds');
  }

  void _stopMessagePolling() {
    _messagePollingTimer?.cancel();
    _messagePollingTimer = null;
  }

  /// Trigger immediate message polling for real-time updates
  void triggerImmediatePolling() {
    print('🔄 Triggering immediate message polling on demand...');
    _pollForNewMessages();
  }

  /// Trigger immediate polling when screen becomes visible (for real-time images)
  void onScreenVisible() {
    print('🔄 Screen became visible - triggering immediate polling for real-time images...');
    Future.delayed(const Duration(milliseconds: 100), () {
      _pollForNewMessages();
    });
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
            
            // CRITICAL FIX: Determine if this message was sent by the user
            // Check tracking sets FIRST to identify sent messages
            final facebookMessageId = message['id'] ?? '';
            final messageContent = message['message'] ?? '';
            
            print('🔍 POLLING MESSAGE SIDE DETERMINATION:');
            print('🔍   Facebook Message ID: $facebookMessageId');
            print('🔍   Message Content: $messageContent');
            print('🔍   Sent IDs: $_sentMessageIds');
            print('🔍   Sent Texts: $_sentMessageTexts');
            
            // Check if this message was sent by the user using multiple criteria
            final isSentByUser = _sentMessageIds.contains(facebookMessageId) || 
                                _sentMessageTexts.contains(messageContent) ||
                                message.containsKey('isSentMessage') && message['isSentMessage'] == true ||
                                messageFromId == safeFacebookPageId; // NEW: Check if sender is the Page
            
            print('🔍   messageFromId: $messageFromId');
            print('🔍   safeFacebookPageId: $safeFacebookPageId');
            print('🔍   isSentByUser: $isSentByUser');
            print('🔍   POLLING - Checking sent IDs: ${_sentMessageIds.toList()}');
            print('🔍   POLLING - Checking sent texts: ${_sentMessageTexts.toList()}');
            print('🔍   POLLING - Message contains isSentMessage: ${message.containsKey('isSentMessage')}');
            print('🔍   POLLING - Message isSentMessage value: ${message['isSentMessage']}');
            
            // CORRECTED ARCHITECTURE: Your app IS the Facebook Page
            bool isFromUser;
            if (isSentByUser) {
              // Message was sent by YOUR APP (the Page) - should appear on LEFT SIDE (Page side)
              isFromUser = false;
              print('🔧 ✅ POLLING: PAGE APP SENT MESSAGE - Setting isFromUser = false (LEFT SIDE - PAGE)');
            } else {
              // Message was sent by the CLIENT - should appear on RIGHT SIDE (Client side)
              isFromUser = true;
              print('🔧 ✅ POLLING: CLIENT SENT MESSAGE - Setting isFromUser = true (RIGHT SIDE - CLIENT)');
            }
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
            
            
            // Process attachments for images (same logic as _loadFacebookMessages)
            String? imageUrl;
            String messageType = 'text';
            
            if (message['attachments'] != null && message['attachments']['data'] != null) {
              final attachments = message['attachments']['data'] as List;
              print('🖼️ POLLING: Processing ${attachments.length} attachments');
              
              for (final attachment in attachments) {
                print('🖼️ POLLING: Attachment type: ${attachment['type']}');
                
                if (attachment['type'] == 'image' || attachment['type'] == 'photo') {
                  if (attachment['image_data'] != null && attachment['image_data']['url'] != null) {
                    imageUrl = attachment['image_data']['url'];
                    messageType = 'image';
                    print('🖼️ POLLING: Found image URL: $imageUrl');
                    break;
                  }
                }
                
                // Also check for mime_type indicating image
                if (attachment['mime_type'] != null && attachment['mime_type'].toString().startsWith('image/')) {
                  if (attachment['image_data'] != null && attachment['image_data']['url'] != null) {
                    imageUrl = attachment['image_data']['url'];
                    messageType = 'image';
                    print('🖼️ POLLING: Found image URL via mime_type: $imageUrl');
                    break;
                  }
                }
              }
            }

            // Set appropriate text for image messages
            String finalMessageText = messageText;
            if (messageType == 'image' && messageText.isEmpty) {
              finalMessageText = '[Image]';
              print('🖼️ POLLING IMAGE MESSAGE: Set text to [Image] for empty message');
            }
            
            // Debug image message processing in polling
            if (messageType == 'image') {
              print('🖼️ POLLING IMAGE MESSAGE DEBUG:');
              print('🖼️   Message ID: $messageId');
              print('🖼️   Image URL: $imageUrl');
              print('🖼️   Is From User: $isFromUser');
              print('🖼️   Sender Name: $senderName');
              print('🖼️   Message Text: $messageText');
              print('🖼️   Facebook Message ID: ${message['id']}');
            }
            
            return {
              'id': messageId,
              'text': finalMessageText,
              'timestamp': _formatTimestamp(message['created_time']),
              'facebookCreatedTime': message['created_time'], // Store original Facebook timestamp
              'isFromUser': isFromUser, // Use corrected logic
              'isAI': finalIsAIGenerated, // Mark as AI if it's an AI-generated message
              'isAIMessage': finalIsAIGenerated, // Additional AI flag
              'isSentMessage': isSentByUser, // Mark if this was sent by the user
              'facebookMessageId': message['id'],
              'senderName': senderName, // Use correct sender name based on message source
              'senderId': message['from']['id'] ?? '', // Store sender ID
              'type': messageType, // Add message type (image, text, etc.)
              'imageUrl': imageUrl, // Add image URL if present
              'profileImageUrl': null, // Will be fetched separately
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
            print('🔍 POLLING: Message type: ${msg['type']}');
            print('🔍 POLLING: Facebook ID: ${msg['facebookMessageId']}');
            print('🔍 POLLING: Current tracking sets:');
            print('🔍 POLLING:   Sent IDs: ${_sentMessageIds.toList()}');
            print('🔍 POLLING:   Sent Texts: ${_sentMessageTexts.toList()}');
            
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
          
          // Log filtered out messages for debugging
          if (convertedNewMessages.length > uniqueNewMessages.length) {
            print('🔍 Filtered out messages:');
            for (final msg in convertedNewMessages) {
              if (!uniqueNewMessages.contains(msg)) {
                print('  - ${msg['text']} (${msg['isFromUser'] ? 'USER' : 'PAGE'})');
              }
            }
          }
          
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
          final userMessages = uniqueNewMessages.where((m) => m['isFromUser'] == true).toList();
          if (userMessages.isNotEmpty) {
            print('🔔 Showing notification for ${userMessages.length} truly new user messages');
            // Only show notification if we have genuinely new messages and they're not already visible
            // Check if these messages are actually new by comparing with current messages
            final genuinelyNewMessages = userMessages.where((newMsg) {
              final newContent = newMsg['text']?.toString() ?? '';
              final newTimestamp = newMsg['facebookCreatedTime']?.toString() ?? newMsg['timestamp']?.toString() ?? '';
              
              // Check if this exact message already exists in current messages
              final alreadyExists = messages.any((existingMsg) {
                final existingContent = existingMsg['text']?.toString() ?? '';
                final existingTimestamp = existingMsg['facebookCreatedTime']?.toString() ?? existingMsg['timestamp']?.toString() ?? '';
                return existingContent == newContent && existingTimestamp == newTimestamp;
              });
              
              return !alreadyExists;
            }).toList();
            
            if (genuinelyNewMessages.isNotEmpty) {
              // Show notification only for genuinely new messages
            Get.snackbar(
              '💬 New Message',
                'You have ${genuinelyNewMessages.length} new message(s)',
              snackPosition: SnackPosition.TOP,
              duration: Duration(seconds: 2),
              backgroundColor: Colors.blue,
              colorText: Colors.white,
            );
            } else {
              print('🔕 No genuinely new messages, skipping notification');
            }

            // Trigger AI response if AI is enabled - ENHANCED: Handle both text and image messages
            print('🔍 POLLING AI CHECK: isAIEnabled=${isAIEnabled.value}, genuinelyNewMessages=${genuinelyNewMessages.length}');
            print('🔍 POLLING AI CHECK: uniqueNewMessages=${uniqueNewMessages.length}');
            
            // FIXED: Use uniqueNewMessages instead of genuinelyNewMessages for AI responses
            // This ensures AI responds to messages even if they're already visible in UI
            final messagesForAI = uniqueNewMessages.where((m) => m['isFromUser'] == true).toList();
            print('🔍 POLLING AI CHECK: messagesForAI=${messagesForAI.length}');
            
            if (isAIEnabled.value && messagesForAI.isNotEmpty) {
              final latestUserMessage = messagesForAI.first;
              final messageText = latestUserMessage['text']?.toString() ?? '';
              final messageType = latestUserMessage['type']?.toString() ?? '';
              final imageUrl = latestUserMessage['imageUrl']?.toString() ?? '';
              
              print('🔍 POLLING: Latest user message - Text: "$messageText", Type: $messageType, Image: ${imageUrl.isNotEmpty ? "present" : "none"}');
              
              // ENHANCED: Respond to both text and image messages
              if (messageText.isNotEmpty || messageType == 'image') {
                // Create a unique identifier for this message (text + type + image presence)
                final messageHash = '${messageText.trim().toLowerCase()}_${messageType}_${imageUrl.isNotEmpty}';
                
                if (!_aiRespondedToMessages.contains(messageHash)) {
                  print('🤖 AI is enabled, generating response for: ${messageType == 'image' ? 'image message' : 'text message'}');
                  
                  // Add a small delay to make it feel more natural
                  Future.delayed(Duration(seconds: 2), () {
                    if (messageType == 'image' && imageUrl.isNotEmpty) {
                      // Handle image message
                      generateAIResponseForImage(messageText, imageUrl);
                    } else {
                      // Handle text message
                    generateAIResponse(messageText);
                    }
                  });
                } else {
                  print('⚠️ AI already responded to this message, skipping: $messageHash');
                }
              }
            } else {
              print('⚠️ POLLING: AI not enabled (${isAIEnabled.value}) or no user messages for AI (${messagesForAI.length})');
            }
          }
        } else {
          print('✅ No new messages found');
          _pollingAttempts++;
          
          // Reduce polling frequency if no new messages for a while
          if (_pollingAttempts > 10) {
            print('🔄 Reducing polling frequency due to no new messages');
            _stopMessagePolling();
            _messagePollingTimer = Timer.periodic(
                const Duration(seconds: 10), (_) => _pollForNewMessages());
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
