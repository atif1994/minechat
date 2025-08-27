import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:minechat/core/constants/app_colors/app_colors.dart';

class ChatConversationScreen extends StatelessWidget {
  final Map<String, dynamic> chat;
  final conversationController = Get.put(ChatConversationController());

  ChatConversationScreen({required this.chat});

  @override
  Widget build(BuildContext context) {
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
            backgroundImage: NetworkImage(chat['contactImage']),
            onBackgroundImageError: (exception, stackTrace) {
              // Handle image error
            },
            child: chat['contactImage'].contains('placeholder')
                ? Text(
                    chat['contactName'][0].toUpperCase(),
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
      return ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: conversationController.messages.length,
        itemBuilder: (context, index) {
          final message = conversationController.messages[index];
          return _buildMessageBubble(message);
        },
      );
    });
  }

  Widget _buildMessageBubble(Map<String, dynamic> message) {
    final isFromUser = message['isFromUser'];
    final isAI = message['isAI'] ?? false;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!isFromUser) ...[
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: isAI ? Colors.purple : Colors.grey[300],
                shape: BoxShape.circle,
              ),
              child: Icon(
                isAI ? Icons.smart_toy : Icons.person,
                color: Colors.white,
                size: 16,
              ),
            ),
            const SizedBox(width: 8),
          ],
          Expanded(
            child: Column(
              crossAxisAlignment: isFromUser 
                  ? CrossAxisAlignment.end 
                  : CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    color: isFromUser ? Colors.blue[600] : Colors.grey[200],
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Text(
                    message['text'],
                    style: TextStyle(
                      color: isFromUser ? Colors.white : Colors.black87,
                      fontSize: 14,
                    ),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  message['timestamp'],
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          if (isFromUser) ...[
            const SizedBox(width: 8),
            CircleAvatar(
              radius: 16,
              backgroundImage: NetworkImage(chat['contactImage']),
              onBackgroundImageError: (exception, stackTrace) {
                // Handle image error
              },
              child: chat['contactImage'].contains('placeholder')
                  ? Text(
                      chat['contactName'][0].toUpperCase(),
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    )
                  : null,
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
        border: Border(
          top: BorderSide(color: Colors.grey[300]!),
        ),
      ),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.emoji_emotions_outlined),
            onPressed: () {
              // TODO: Show emoji picker
            },
          ),
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(24),
              ),
              child: TextField(
                controller: conversationController.messageController,
                decoration: const InputDecoration(
                  hintText: 'Send a message',
                  border: InputBorder.none,
                  isDense: true,
                  contentPadding: EdgeInsets.zero,
                ),
                maxLines: null,
              ),
            ),
          ),
          const SizedBox(width: 8),
          IconButton(
            icon: const Icon(Icons.attach_file),
            onPressed: () {
              // TODO: Attach file
            },
          ),
          IconButton(
            icon: const Icon(Icons.image),
            onPressed: () {
              // TODO: Attach image
            },
          ),
          IconButton(
            icon: const Icon(Icons.mic),
            onPressed: () {
              // TODO: Voice message
            },
          ),
          Container(
            decoration: BoxDecoration(
              color: Colors.purple,
              shape: BoxShape.circle,
            ),
            child: IconButton(
              icon: const Icon(Icons.send, color: Colors.white),
              onPressed: () {
                conversationController.sendMessage();
              },
            ),
          ),
        ],
      ),
    );
  }
}

class ChatConversationController extends GetxController {
  final messageController = TextEditingController();
  var messages = <Map<String, dynamic>>[].obs;
  var isAIMode = true.obs;

  @override
  void onInit() {
    super.onInit();
    loadMessages();
  }

  void loadMessages() {
    // Mock messages - replace with actual data
    messages.value = [
      {
        'id': '1',
        'text': 'Hi there! I\'m Janna, an AI assistant for Beauty Hub. How can I help you today?',
        'timestamp': '12:31 PM',
        'isFromUser': false,
        'isAI': true,
      },
      {
        'id': '2',
        'text': 'What can you recommend to get rid of acne scars?',
        'timestamp': '12:32 PM',
        'isFromUser': true,
        'isAI': false,
      },
    ];
  }

  void sendMessage() {
    if (messageController.text.trim().isEmpty) return;

    final newMessage = {
      'id': DateTime.now().millisecondsSinceEpoch.toString(),
      'text': messageController.text.trim(),
      'timestamp': _getCurrentTime(),
      'isFromUser': true,
      'isAI': false,
    };

    messages.add(newMessage);
    messageController.clear();

    // Simulate AI response
    _simulateAIResponse();
  }

  void _simulateAIResponse() {
    Future.delayed(const Duration(seconds: 2), () {
      final aiResponse = {
        'id': DateTime.now().millisecondsSinceEpoch.toString(),
        'text': 'I can recommend several treatments for acne scars. Would you like me to provide more details about specific options?',
        'timestamp': _getCurrentTime(),
        'isFromUser': false,
        'isAI': true,
      };
      messages.add(aiResponse);
    });
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
          'text': 'Hi! This is Dress, Customer Relations Manager at the Beauty Hub. How can I help you today?',
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
