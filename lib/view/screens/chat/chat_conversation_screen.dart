import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:minechat/core/constants/app_colors/app_colors.dart';
import 'package:minechat/core/services/facebook_graph_api_service.dart';
import 'package:minechat/controller/channel_controller/channel_controller.dart';

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
          // AI/Human Mode Status
          _buildStatusBar(),
          
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
      backgroundColor: Colors.white,
      elevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back, color: Colors.black),
        onPressed: () => Get.back(),
      ),
      title: Row(
        children: [
          CircleAvatar(
            radius: 16,
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
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  )
                : null,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  chat['contactName'],
                  style: const TextStyle(
                    color: Colors.black,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    // TODO: Navigate to profile
                    Get.snackbar('Info', 'Viewing profile...');
                  },
                  child: Text(
                    'View profile',
                    style: TextStyle(
                      color: Colors.blue[600],
                      fontSize: 12,
                      decoration: TextDecoration.underline,
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
          icon: const Icon(Icons.refresh, color: Colors.black),
          onPressed: () {
            conversationController.loadMessages();
            Get.snackbar('Info', 'Refreshing messages...');
          },
        ),
        IconButton(
          icon: Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: Colors.purple,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.person,
              color: Colors.white,
              size: 16,
            ),
          ),
          onPressed: () {
            // TODO: Show team members
            Get.snackbar('Info', 'Showing team members...');
          },
        ),
        IconButton(
          icon: const Icon(Icons.notifications_outlined, color: Colors.black),
          onPressed: () {
            // TODO: Notification settings
            Get.snackbar('Info', 'Notification settings...');
          },
        ),
        PopupMenuButton<String>(
          icon: const Icon(Icons.more_vert, color: Colors.black),
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

  Widget _buildStatusBar() {
    return Obx(() {
      final isAIMode = conversationController.isAIMode.value;
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: isAIMode ? Colors.purple : Colors.red,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                isAIMode ? Icons.smart_toy : Icons.person,
                color: Colors.white,
                size: 16,
              ),
              const SizedBox(width: 6),
              Text(
                isAIMode ? 'AI Enabled' : 'Human Mode',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      );
    });
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

      return ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: conversationController.messages.length,
        itemBuilder: (context, index) {
          final message = conversationController.messages[index];
          return _buildMessageItem(message);
        },
      );
    });
  }

  Widget _buildMessageItem(Map<String, dynamic> message) {
    final isFromUser = message['isFromUser'] ?? false;
    final isAI = message['isAI'] ?? false;
    
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: Row(
        mainAxisAlignment: isFromUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!isFromUser) ...[
            CircleAvatar(
              radius: 16,
              backgroundColor: isAI ? Colors.blue : Colors.green,
              child: Icon(
                isAI ? Icons.smart_toy : Icons.person,
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
                color: isFromUser 
                    ? Colors.blue 
                    : (isAI ? Colors.blue[50] : Colors.grey[100]),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    message['text'] ?? '',
                    style: TextStyle(
                      color: isFromUser ? Colors.white : Colors.black87,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    message['timestamp'] ?? '',
                    style: TextStyle(
                      color: isFromUser ? Colors.white70 : Colors.grey[600],
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
          ),
          
          if (isFromUser) ...[
            const SizedBox(width: 8),
            CircleAvatar(
              radius: 16,
              backgroundColor: Colors.grey[300],
              child: Icon(
                Icons.person,
                color: Colors.grey[600],
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
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 3,
            offset: const Offset(0, -1),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: conversationController.messageController,
              decoration: InputDecoration(
                hintText: 'Type a message...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(25),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: Colors.grey[100],
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 12,
                ),
              ),
              maxLines: null,
              textInputAction: TextInputAction.send,
              onSubmitted: (_) => conversationController.sendMessage(),
            ),
          ),
          const SizedBox(width: 12),
          Obx(() => IconButton(
            onPressed: conversationController.isSending.value 
                ? null 
                : conversationController.sendMessage,
            icon: conversationController.isSending.value
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
                    ),
                  )
                : const Icon(Icons.send, color: Colors.blue),
          )),
        ],
      ),
    );
  }
}

class ChatConversationController extends GetxController {
  final messageController = TextEditingController();
  var messages = <Map<String, dynamic>>[].obs;
  var isAIMode = true.obs;
  var isLoading = true.obs; // Add loading state
  var isSending = false.obs; // Add sending state
  
  // Facebook conversation data
  String? conversationId;
  String? pageAccessToken;
  String? facebookPageId;
  
  @override
  void onInit() {
    super.onInit();
    print('🔍 ChatConversationController initialized');
  }
  
  /// Set chat data and initialize conversation
  void setChatData(Map<String, dynamic> chat) {
    conversationId = chat['id'];
    print('🔍 Setting chat data for conversation: $conversationId');
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
      
      // Get messages from Facebook API - try conversation info first for fb_t_ IDs
      final messagesResult = conversationId!.startsWith('fb_t_') 
          ? await FacebookGraphApiService.getConversationInfoOnly(
              conversationId!,
              pageAccessToken!,
            )
          : await FacebookGraphApiService.getConversationMessagesWithToken(
              conversationId!,
              pageAccessToken!,
            );
      
      if (messagesResult['success'] && messagesResult['data'] != null) {
        final facebookData = messagesResult['data'] as List;
        final dataType = messagesResult['type'] ?? 'unknown';
        print('📊 Found ${facebookData.length} Facebook data items (type: $dataType)');
        
        if (dataType == 'conversation_info') {
          // We got conversation info, not messages
          final conversationInfo = facebookData.first;
          print('📋 Conversation Info: $conversationInfo');
          
          // Show a message indicating we can see the conversation but can't load messages
          final infoMessage = {
            'id': 'info_${DateTime.now().millisecondsSinceEpoch}',
            'text': 'Conversation loaded. Messages may require additional permissions to view.',
            'timestamp': _getCurrentTime(),
            'isFromUser': false,
            'isAI': true,
            'isInfo': true,
          };
          
          messages.value = [infoMessage];
          print('✅ Loaded conversation info (messages require additional permissions)');
        } else {
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
        }
        
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
      messageController.clear();
      
      // Send to Facebook API
      final sendResult = await FacebookGraphApiService.sendMessageToConversation(
        conversationId!,
        pageAccessToken!,
        messageText,
      );
      
      if (sendResult['success']) {
        print('✅ Message sent successfully to Facebook');
        
        // Simulate AI response if in AI mode
        if (isAIMode.value) {
          _simulateAIResponse();
        }
        
      } else {
        print('❌ Failed to send message to Facebook: ${sendResult['error']}');
        
        // Show error to user
        Get.snackbar(
          'Message Failed',
          'Could not send message. Please try again.',
          backgroundColor: Colors.red,
          colorText: Colors.white,
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
  
  /// Simulate AI response
  void _simulateAIResponse() {
    Future.delayed(const Duration(seconds: 2), () {
      final aiResponse = {
        'id': DateTime.now().millisecondsSinceEpoch.toString(),
        'text': 'Thank you for your message! I\'m processing your request and will get back to you soon.',
        'timestamp': _getCurrentTime(),
        'isFromUser': false,
        'isAI': true,
      };
      messages.add(aiResponse);
    });
  }
  
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

  void toggleMode() {
    isAIMode.value = !isAIMode.value;
    if (!isAIMode.value) {
      // Switch to human mode
      messages.add({
        'id': DateTime.now().millisecondsSinceEpoch.toString(),
        'text': 'I\'d like to speak with a human please.',
        'timestamp': _getCurrentTime(),
        'isFromUser': true,
        'isAI': false,
      });

      // Simulate human response
      Future.delayed(const Duration(seconds: 2), () {
        final humanResponse = {
          'id': DateTime.now().millisecondsSinceEpoch.toString(),
          'text': 'Hi! This is a customer service representative. How can I help you today?',
          'timestamp': _getCurrentTime(),
          'isFromUser': false,
          'isAI': false,
        };
        messages.add(humanResponse);
      });
    }
  }

  @override
  void onClose() {
    messageController.dispose();
    super.onClose();
  }
}
