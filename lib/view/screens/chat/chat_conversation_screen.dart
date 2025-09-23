import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:minechat/core/constants/app_colors/app_colors.dart';
import 'package:minechat/core/services/facebook_graph_api_service.dart';
import 'package:minechat/controller/channel_controller/channel_controller.dart';
import 'package:minechat/controller/chat_controller/chat_controller.dart';
import 'package:minechat/core/widgets/chat/enhanced_message_bubble.dart';
import 'package:minechat/core/services/realtime_message_service.dart';
// AI imports removed

class ChatConversationScreen extends StatelessWidget {
  final Map<String, dynamic> chat;
  final conversationController = Get.put(ChatConversationController());

  ChatConversationScreen({required this.chat});

  @override
  Widget build(BuildContext context) {
    // Pass chat data to controller
    conversationController.setChatData(chat);
    
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: _buildAppBar(context),
      body: Column(
        children: [
          // AI Enabled indicator
          _buildAIEnabledIndicator(),
          
          // Messages
          Expanded(
            child: _buildMessagesList(),
          ),
          
          // Message Input
          _buildMessageInput(),
        ],
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: const Color(0xFF075E54), // WhatsApp green
      elevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back, color: Colors.white),
        onPressed: () => Get.back(),
      ),
      title: Row(
        children: [
          Stack(
            children: [
              CircleAvatar(
                radius: 20,
                backgroundImage: chat['profileImageUrl']?.isNotEmpty == true
                    ? NetworkImage(chat['profileImageUrl'])
                    : null,
                onBackgroundImageError: (exception, stackTrace) {
                  // Handle image error
                },
                child: chat['profileImageUrl']?.isEmpty != false
                    ? Text(
                        (chat['contactName']?[0] ?? '?').toUpperCase(),
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      )
                    : null,
              ),
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
                  child: const Icon(
                    Icons.chat,
                    color: Colors.white,
                    size: 8,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                  Text(
                    chat['contactName'] ?? 'Unknown',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      // TODO: Navigate to profile
                      Get.snackbar('Info', 'Viewing profile...');
                    },
                    child: const Text(
                      'View profile',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 12,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
        actions: [
          IconButton(
            icon: const Icon(Icons.smart_toy, color: Colors.white),
            onPressed: () {
              // AI assistant toggle
              Get.snackbar('Info', 'AI Assistant toggled...');
            },
          ),
          IconButton(
            icon: const Icon(Icons.person, color: Colors.white),
            onPressed: () {
              // View profile
              Get.snackbar('Info', 'Viewing profile...');
            },
          ),
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert, color: Colors.white),
          onSelected: (value) {
            switch (value) {
              case 'add_to_group':
                Get.snackbar('Info', 'Add to group...');
                break;
              case 'follow_up':
                Get.snackbar('Info', 'Follow-up later...');
                break;
              case 'block':
                Get.snackbar('Info', 'Block contact...');
                break;
              case 'delete':
                Get.snackbar('Info', 'Delete conversation...');
                break;
            }
          },
          itemBuilder: (context) => [
            const PopupMenuItem(
              value: 'add_to_group',
              child: Text('Add To Group'),
            ),
            const PopupMenuItem(
              value: 'follow_up',
              child: Text('Follow-up Later'),
            ),
            const PopupMenuItem(
              value: 'block',
              child: Text('Block Contact'),
            ),
            const PopupMenuItem(
              value: 'delete',
              child: Text('Delete Conversation'),
            ),
          ],
        ),
      ],
    );
  }

  // AI Enabled indicator
  Widget _buildAIEnabledIndicator() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Center(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
          decoration: BoxDecoration(
            color: const Color(0xFFFFEBEE), // Light red background
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: const Color(0xFFFFCDD2), width: 1),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.smart_toy,
                color: Color(0xFFD32F2F), // Dark red
                size: 16,
              ),
              const SizedBox(width: 8),
              const Text(
                'AI Enabled',
                style: TextStyle(
                  color: Color(0xFFD32F2F), // Dark red
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMessagesList() {
    return Obx(() {
      // Show loading indicator while messages are being loaded
      if (conversationController.isLoading.value) {
        return const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Colors.purple),
              ),
              SizedBox(height: 16),
              Text(
                'Loading messages...',
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
            ],
          ),
        );
      }
      
      // Show no messages message only after loading is complete
      if (conversationController.messages.isEmpty) {
        return const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.chat_bubble_outline, size: 48, color: Colors.grey),
              SizedBox(height: 12),
              Text(
                'No messages yet',
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
            ],
          ),
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
            return _buildMessageItem(message);
          },
        ),
      );
    });
  }

  Widget _buildMessageItem(Map<String, dynamic> message) {
    final isFromUser = message['isFromUser'] ?? false;
    final isAI = message['isAI'] ?? false;
    
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisAlignment: isFromUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Avatar only for incoming messages (left side)
          if (!isFromUser) ...[
            CircleAvatar(
              radius: 16,
              backgroundColor: isAI ? const Color(0xFF25D366) : const Color(0xFF25D366),
              child: Icon(
                isAI ? Icons.smart_toy : Icons.person,
                color: Colors.white,
                size: 16,
              ),
            ),
            const SizedBox(width: 8),
          ],
          
          // Message bubble
          Flexible(
            child: Column(
              crossAxisAlignment: isFromUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
              children: [
                Container(
                  constraints: BoxConstraints(
                    maxWidth: MediaQuery.of(Get.context!).size.width * 0.7,
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: isFromUser ? const Color(0xFFDCF8C6) : Colors.white,
                    borderRadius: BorderRadius.only(
                      topLeft: const Radius.circular(18),
                      topRight: const Radius.circular(18),
                      bottomLeft: Radius.circular(isFromUser ? 18 : 4),
                      bottomRight: Radius.circular(isFromUser ? 4 : 18),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 1,
                        offset: const Offset(0, 1),
                      ),
                    ],
                  ),
                  child: Text(
                    message['text'] ?? '',
                    style: TextStyle(
                      color: Colors.black87,
                      fontSize: 16,
                      height: 1.3,
                    ),
                  ),
                ),
                const SizedBox(height: 2),
                Padding(
                  padding: EdgeInsets.only(
                    right: isFromUser ? 8 : 0,
                    left: isFromUser ? 0 : 8,
                  ),
                  child: Text(
                    message['timestamp'] ?? '',
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 11,
                    ),
                  ),
                ),
              ],
            ),
          ),
          
          // Avatar only for outgoing messages (right side)
          if (isFromUser) ...[
            const SizedBox(width: 8),
            CircleAvatar(
              radius: 16,
              backgroundColor: const Color(0xFF25D366),
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

  Widget _buildMessageInput() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: const BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 4,
            offset: Offset(0, -1),
          ),
        ],
      ),
      child: Row(
        children: [
          // Emoji button
          IconButton(
            onPressed: () {
              // TODO: Show emoji picker
              Get.snackbar('Info', 'Emoji picker...');
            },
            icon: const Icon(Icons.emoji_emotions, color: Colors.grey),
          ),
          
          // Text input field
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(25),
                border: Border.all(color: Colors.grey[300]!, width: 1),
              ),
              child: TextField(
                controller: conversationController.messageController,
                decoration: const InputDecoration(
                  hintText: 'Message',
                  hintStyle: TextStyle(color: Colors.grey),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 10,
                  ),
                ),
                maxLines: null,
                textInputAction: TextInputAction.send,
                onSubmitted: (_) => conversationController.sendMessage(),
                style: const TextStyle(fontSize: 16),
              ),
            ),
          ),
          
          // Attachment buttons
          IconButton(
            onPressed: () {
              // TODO: Show GIF picker
              Get.snackbar('Info', 'GIF picker...');
            },
            icon: Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Text(
                'GIF',
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey,
                ),
              ),
            ),
          ),
          
          IconButton(
            onPressed: () {
              // TODO: Show image picker
              _showImagePicker();
            },
            icon: const Icon(Icons.add_photo_alternate, color: Colors.grey),
          ),
          
          IconButton(
            onPressed: () {
              // TODO: Start voice recording
              Get.snackbar('Info', 'Voice recording...');
            },
            icon: const Icon(Icons.mic, color: Colors.grey),
          ),
          
            // Send button
            Obx(() => Container(
              margin: const EdgeInsets.only(left: 8),
              child: IconButton(
                onPressed: conversationController.isSending.value 
                    ? null 
                    : conversationController.sendMessage,
                icon: conversationController.isSending.value
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF25D366)),
                        ),
                      )
                    : Container(
                        width: 36,
                        height: 36,
                        decoration: const BoxDecoration(
                          color: Color(0xFF25D366),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.send,
                          color: Colors.white,
                          size: 18,
                        ),
                      ),
              ),
            )),
        ],
      ),
    );
  }

  void _showImagePicker() {
    showModalBottomSheet(
      context: Get.context!,
      builder: (context) => Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text('Take Photo'),
              onTap: () {
                Get.back();
                Get.snackbar('Info', 'Camera opened...');
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('Choose from Gallery'),
              onTap: () {
                Get.back();
                Get.snackbar('Info', 'Gallery opened...');
              },
            ),
            ListTile(
              leading: const Icon(Icons.file_present),
              title: const Text('Send File'),
              onTap: () {
                Get.back();
                Get.snackbar('Info', 'File picker opened...');
              },
            ),
          ],
        ),
      ),
    );
  }
}

class ChatConversationController extends GetxController {
  final messageController = TextEditingController();
  var messages = <Map<String, dynamic>>[].obs;
  // AI mode removed
  var isLoading = true.obs; // Add loading state
  var isSending = false.obs; // Add sending state
  
  // Facebook conversation data
  String? conversationId;
  String? userId; // Store the user ID for sending messages
  String? pageAccessToken;
  String? facebookPageId;
  
  // Real-time service
  final RealtimeMessageService _realtimeService = RealtimeMessageService();
  
  // Message polling timer
  Timer? _messagePollingTimer;
  
  // Scroll controller for auto-scrolling to bottom
  final ScrollController _scrollController = ScrollController();
  
  // AI Assistant controller removed
  
  @override
  void onInit() {
    super.onInit();
    print('🔍 ChatConversationController initialized');
  }
  
  /// Set chat data and initialize conversation
  void setChatData(Map<String, dynamic> chat) {
    conversationId = chat['conversationId'] ?? chat['id'];
    userId = chat['userId']; // Store the user ID for sending messages
    print('🔍 Setting chat data for conversation: $conversationId');
    print('🔍 User ID: $userId');
    print('📋 Chat data: $chat');
    
    // Load real messages
    loadMessages();
  }

  /// Load real messages from Facebook Messenger
  Future<void> loadMessages() async {
    try {
      isLoading.value = true; // Start loading
      print('📥 Loading messages for conversation: $conversationId');
      
      // Get Facebook credentials
      await _getFacebookCredentials();
      
      if (pageAccessToken == null || facebookPageId == null) {
        print('⚠️ No Facebook credentials available, trying to get them...');
        // Don't load mock messages, try to get real credentials
        isLoading.value = false; // Stop loading
        return;
      }
      
      // Load real messages from Facebook API
      await _loadFacebookMessages();
      
      // Start polling for new messages in this conversation
      _startMessagePolling();
      
    } catch (e) {
      print('❌ Error loading messages: $e');
      // Don't load mock messages, show error instead
      Get.snackbar(
        'Error',
        'Failed to load messages: $e',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false; // Always stop loading
    }
  }
  
  /// Get Facebook credentials from ChannelController
  Future<void> _getFacebookCredentials() async {
    try {
      final channelController = Get.find<ChannelController>();
      facebookPageId = channelController.facebookPageIdCtrl.text.trim();
      
      if (facebookPageId!.isNotEmpty) {
        pageAccessToken = await channelController.getPageAccessToken(facebookPageId!);
        print('✅ Got Facebook credentials - Page: $facebookPageId, Token: ${pageAccessToken?.substring(0, 10)}...');
      } else {
        // Use the updated token from config if no page ID is set
        print('⚠️ No page ID found, using config token');
        pageAccessToken = 'EAAU0kNg5hEMBPYZA62EkNSGUM0V3syrYypZCBzxj9gyCGwozFsIk7dGfNZCCKopy97elvldckz9uwDWHiiohawQ9nVsYVTRXbMeIm0BY1ZBgX9LfWEa3F3EcyjeXtfbgusQR7PbtuZCzIAzkfg64Iqswu07l0YxWqQLTZBxAYx6wDvMDFBNvpzDbIJ4bYOfWcZCqJ4PStlXzw0xveZCKtO49CGMaiaJo9H10EvLAq6Mjy9sybUmm';
        facebookPageId = '313808701826338'; // Use the page ID from your token
        print('✅ Using config token for page: $facebookPageId');
      }
      
      // Get valid token with automatic refresh if needed
      final validToken = await FacebookGraphApiService.getValidToken();
      if (validToken != null) {
        pageAccessToken = validToken;
        print('🔄 Using automatically refreshed token: ${validToken.substring(0, 10)}...');
      }
    } catch (e) {
      print('❌ Error getting Facebook credentials: $e');
      // Fallback to config token
      pageAccessToken = 'EAAU0kNg5hEMBPYZA62EkNSGUM0V3syrYypZCBzxj9gyCGwozFsIk7dGfNZCCKopy97elvldckz9uwDWHiiohawQ9nVsYVTRXbMeIm0BY1ZBgX9LfWEa3F3EcyjeXtfbgusQR7PbtuZCzIAzkfg64Iqswu07l0YxWqQLTZBxAYx6wDvMDFBNvpzDbIJ4bYOfWcZCqJ4PStlXzw0xveZCKtO49CGMaiaJo9H10EvLAq6Mjy9sybUmm';
      facebookPageId = '313808701826338';
    }
  }
  
  /// Load real messages from Facebook Graph API
  Future<void> _loadFacebookMessages() async {
    try {
      print('🔍 Loading Facebook messages for conversation: $conversationId');
      
      // First check token permissions
      final permissionsResult = await FacebookGraphApiService.checkTokenPermissions(pageAccessToken!);
      if (permissionsResult['success']) {
        print('✅ Token permissions: ${permissionsResult['data']}');
      } else {
        print('⚠️ Could not check permissions: ${permissionsResult['error']}');
      }
      
      // Get messages from Facebook API
      final messagesResult = await FacebookGraphApiService.getConversationMessagesWithToken(
        conversationId!,
        pageAccessToken!,
      );
      
      if (messagesResult['success'] && messagesResult['data'] != null) {
        final facebookData = messagesResult['data'] as List;
        final dataType = messagesResult['type'] ?? 'unknown';
        print('📊 Found ${facebookData.length} Facebook data items (type: $dataType)');
        
        // Convert Facebook messages to our format
        final convertedMessages = <Map<String, dynamic>>[];
        
        for (final message in facebookData) {
          final isFromUser = message['from']?['id'] != facebookPageId;
          final messageText = message['message'] ?? '';
          final timestamp = message['created_time'] ?? DateTime.now().toIso8601String();
          
          if (messageText.isNotEmpty) {
            convertedMessages.add({
              'id': message['id'] ?? DateTime.now().millisecondsSinceEpoch.toString(),
              'text': messageText,
              'timestamp': _formatTimestamp(timestamp),
              'isFromUser': isFromUser,
              'isAI': false, // Facebook messages are from real users
              'facebookMessageId': message['id'],
            });
          }
        }
        
        // Sort messages by timestamp (oldest first)
        convertedMessages.sort((a, b) => a['timestamp'].compareTo(b['timestamp']));
        
        messages.value = convertedMessages;
        print('✅ Loaded ${convertedMessages.length} real Facebook messages');
        
        // Auto-scroll to bottom after loading messages
        _scrollToBottom();
        
      } else {
        print('⚠️ Failed to load Facebook messages: ${messagesResult['error']}');
        Get.snackbar(
          'Error',
          'Failed to load Facebook messages: ${messagesResult['error']}',
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      }
      
    } catch (e) {
      print('❌ Error loading Facebook messages: $e');
      Get.snackbar(
        'Error',
        'Error loading Facebook messages: $e',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }
  
  /// Load mock messages as fallback
  void _loadMockMessages() {
    print('📝 Loading mock messages as fallback');
    messages.value = [
      {
        'id': '1',
        'text': 'Hi there! How can I help you today?',
        'timestamp': '12:31 PM',
        'isFromUser': false,
        'isAI': true,
      },
      {
        'id': '2',
        'text': 'I have a question about your services',
        'timestamp': '12:32 PM',
        'isFromUser': true,
        'isAI': false,
      },
    ];
  }

  /// Send message to Facebook Messenger
  Future<void> sendMessage() async {
    if (messageController.text.trim().isEmpty || isSending.value) return;
    
    try {
      isSending.value = true; // Start sending
      
      // Ensure we have credentials
      if (pageAccessToken == null || conversationId == null) {
        print('⚠️ No credentials, getting them...');
        await _getFacebookCredentials();
      }
      
      if (pageAccessToken == null || conversationId == null) {
        print('❌ Cannot send message - no Facebook credentials available');
        Get.snackbar(
          'Error',
          'Cannot send message - Facebook not connected',
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
        return;
      }

      final messageText = messageController.text.trim();
      
      print('📤 Sending message to Facebook: $messageText');
      print('📤 Using token: ${pageAccessToken!.substring(0, 20)}...');
      print('📤 To conversation: $conversationId');
      
      // Add message to local list immediately
      final newMessage = {
        'id': DateTime.now().millisecondsSinceEpoch.toString(),
        'text': messageText,
        'timestamp': _getCurrentTime(),
        'isFromUser': true,
        'isAI': false,
      };
      
      messages.add(newMessage);
      print('📝 Added message to local list: $newMessage');
      print('📝 Total messages now: ${messages.length}');
      messageController.clear();
      
      // Auto-scroll to bottom after adding new message
      _scrollToBottom();
      
      // Store message in Firebase for real-time updates (non-blocking)
      _realtimeService.storeMessage(
        conversationId: conversationId!,
        messageText: messageText,
        isFromUser: true,
        platform: 'Facebook',
        senderId: 'current_user',
        senderName: 'You',
      ).catchError((e) {
        print('⚠️ Could not store message in Firebase: $e');
      });
      
      // Send to Facebook API
      final sendResult = await FacebookGraphApiService.sendMessageToConversation(
        conversationId!,
        pageAccessToken!,
        messageText,
        userId: userId, // Pass the user ID for proper messaging
      );
      
      if (sendResult['success']) {
        print('✅ Message sent successfully to Facebook');
        
        // Chat list update disabled to prevent alert dialogs
        // _updateChatListInBackground();
        
        // AI response removed - no automatic AI responses
        
      } else {
        print('❌ Failed to send message to Facebook: ${sendResult['error']}');
        
        // Remove the message from local list since it failed
        messages.removeLast();
        messageController.text = messageText; // Restore the message text
        
        // Show detailed error to user
        final errorMessage = sendResult['error']?.toString() ?? 'Unknown error';
        Get.snackbar(
          'Message Failed',
          'Could not send message: $errorMessage\n\nPlease check your Facebook connection and try again.',
          backgroundColor: Colors.red,
          colorText: Colors.white,
          duration: Duration(seconds: 5),
        );
      }
      
    } catch (e) {
      print('❌ Error sending message: $e');
      Get.snackbar(
        'Error',
        'Failed to send message: $e',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isSending.value = false; // Always stop sending
    }
  }
  
  // AI response methods removed
  
  /// Format timestamp from Facebook API
  String _formatTimestamp(String timestamp) {
    try {
      final dateTime = DateTime.parse(timestamp);
      return '${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
    } catch (e) {
      return _getCurrentTime();
    }
  }

  String _getCurrentTime() {
    final now = DateTime.now();
    return '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}';
  }

  // AI toggle mode removed

  /// Handle real-time message updates
  void handleRealtimeMessage(Map<String, dynamic> messageData) {
    try {
      print('📨 Conversation received real-time message: ${messageData['text']}');
      
      final messageConversationId = messageData['conversationId'];
      
      // Only handle messages for this conversation
      if (messageConversationId == conversationId) {
        final messageText = messageData['text'];
        final isFromUser = messageData['isFromUser'] ?? false;
        final timestamp = messageData['timestamp'] ?? _getCurrentTime();
        
        // Add the message to the conversation
        final newMessage = {
          'id': messageData['id'] ?? DateTime.now().millisecondsSinceEpoch.toString(),
          'text': messageText,
          'timestamp': timestamp,
          'isFromUser': isFromUser,
          'isAI': false, // Real messages are not AI
          'facebookMessageId': messageData['facebookMessageId'],
        };
        
        messages.add(newMessage);
        
        // Store the message in Firebase for real-time updates
        _realtimeService.storeMessage(
          conversationId: conversationId!,
          messageText: messageText,
          isFromUser: isFromUser,
          platform: 'Facebook',
          senderId: messageData['senderId'],
          senderName: messageData['senderName'],
        );
        
        print('✅ Added real-time message to conversation');
      }
      
    } catch (e) {
      print('❌ Error handling real-time message in conversation: $e');
    }
  }

  /// Start polling for new messages in this conversation
  void _startMessagePolling() {
    print('🔄 Message polling disabled to prevent excessive API calls');
    // Polling disabled to prevent excessive API calls
    // _messagePollingTimer = Timer.periodic(Duration(seconds: 10), (timer) {
    //   _pollForNewMessages();
    // });
  }

  /// Stop message polling
  void _stopMessagePolling() {
    _messagePollingTimer?.cancel();
    _messagePollingTimer = null;
  }

  /// Update chat list in background without blocking UI
  void _updateChatListInBackground() {
    // Run in background to avoid blocking the UI
    Future.microtask(() async {
      try {
        final chatController = Get.find<ChatController>();
        await chatController.loadChats(); // Refresh the chat list
        print('✅ Chat list refreshed in background');
      } catch (e) {
        print('⚠️ Could not refresh chat list in background: $e');
      }
    });
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

  /// Poll for new messages in this conversation
  Future<void> _pollForNewMessages() async {
    try {
      if (pageAccessToken == null || conversationId == null) return;
      
      print('🔍 Polling for new messages in conversation: $conversationId');
      
      // Get latest messages from Facebook API
      final messagesResult = await FacebookGraphApiService.getConversationMessagesWithToken(
        conversationId!,
        pageAccessToken!,
      );
      
      if (messagesResult['success'] && messagesResult['data'] != null) {
        final newMessages = messagesResult['data'] as List;
        print('📊 Polling found ${newMessages.length} messages');
        
        // Check if we have new messages
        if (newMessages.isNotEmpty) {
          final latestMessage = newMessages.first;
          final latestMessageId = latestMessage['id'] as String?;
          
          // Check if this is a new message we haven't seen
          final existingMessageIds = messages.value.map((msg) => msg['id']).toList();
          if (latestMessageId != null && !existingMessageIds.contains(latestMessageId)) {
            print('🆕 New message detected, refreshing conversation...');
            await loadMessages(); // Reload all messages
          }
        }
      }
      
    } catch (e) {
      print('❌ Error polling for new messages: $e');
    }
  }

  @override
  void onClose() {
    _stopMessagePolling();
    messageController.dispose();
    super.onClose();
  }
}

