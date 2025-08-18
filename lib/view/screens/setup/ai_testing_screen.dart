import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:minechat/controller/ai_assistant_controller/ai_assistant_controller.dart';

import '../../../model/data/chat_mesage_model.dart';


class AITestingScreen extends StatefulWidget {
  const AITestingScreen({super.key});

  @override
  State<AITestingScreen> createState() => _AITestingScreenState();
}

class _AITestingScreenState extends State<AITestingScreen> {
  final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<AIAssistantController>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('AI Testing'),
        backgroundColor: Colors.red,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Get.back(),
        ),

      ),
      body: Column(
        children: [
          // Chat Messages Area
          Expanded(
            child: Obx(() {
              if (controller.chatMessages.isEmpty) {
                return _buildEmptyChatState(controller);
              }
              return _buildChatMessages(controller);
            }),
          ),

          // Message Input Area
          _buildMessageInput(controller),
        ],
      ),
    );
  }

  Widget _buildEmptyChatState(AIAssistantController controller) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [

          if (controller.currentAIAssistant.value != null)
            Container(
              padding: const EdgeInsets.all(16),
              margin: const EdgeInsets.symmetric(horizontal: 32),
              decoration: BoxDecoration(
                color: Colors.blue[50],
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.blue[200]!),
              ),
              child: Column(
                children: [
                  Text(
                    'AI Assistant: ${controller.currentAIAssistant.value!.name}',
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      color: Colors.blue,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    controller.currentAIAssistant.value!.introMessage,
                    style: TextStyle(
                      color: Colors.blue[700],
                      fontSize: 14,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildChatMessages(AIAssistantController controller) {
    // Auto-scroll to bottom when new messages are added
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollToBottom();
    });

    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.all(16),
      itemCount: controller.chatMessages.length,
      itemBuilder: (context, index) {
        final message = controller.chatMessages[index];
        return _buildMessageBubble(message, index);
      },
    );
  }

  Widget _buildMessageBubble(ChatMessageModel message, int index) {
    final isUser = message.type == MessageType.user;

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        mainAxisAlignment: isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!isUser) ...[
            CircleAvatar(
              radius: 16,
              backgroundColor: Colors.blue[100],
              child: Icon(
                Icons.smart_toy,
                size: 16,
                color: Colors.blue[700],
              ),
            ),
            const SizedBox(width: 8),
          ],
          Flexible(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: isUser ? Colors.blue[600] : Colors.grey[100],
                borderRadius: BorderRadius.circular(18).copyWith(
                  bottomLeft: isUser ? const Radius.circular(18) : const Radius.circular(4),
                  bottomRight: isUser ? const Radius.circular(4) : const Radius.circular(18),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    message.message,
                    style: TextStyle(
                      color: isUser ? Colors.white : Colors.black87,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _formatTime(message.timestamp),
                    style: TextStyle(
                      color: isUser ? Colors.white70 : Colors.grey[600],
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (isUser) ...[
            const SizedBox(width: 8),
            CircleAvatar(
              radius: 16,
              backgroundColor: Colors.grey[300],
              child: Icon(
                Icons.person,
                size: 16,
                color: Colors.grey[700],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildMessageInput(AIAssistantController controller) {
    final textController = TextEditingController();

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
          // Emoji Button
          // IconButton(
          //   icon: const Icon(Icons.emoji_emotions_outlined),
          //   onPressed: () {
          //     // TODO: Implement emoji picker
          //   },
          //   color: Colors.grey[600],
          // ),

          // Message Input Field
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(24),
              ),
              child: TextField(
                controller: textController,
                decoration: const InputDecoration(
                  hintText: 'Send a message',
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                ),
                maxLines: null,
                textInputAction: TextInputAction.send,
                onSubmitted: (message) {
                  if (message.trim().isNotEmpty) {
                    controller.sendMessage(message);
                    textController.clear();
                  }
                },
              ),
            ),
          ),

          // const SizedBox(width: 8),
          //
          // // Attachment Button
          // IconButton(
          //   icon: const Icon(Icons.attach_file),
          //   onPressed: () {
          //     // TODO: Implement file attachment
          //   },
          //   color: Colors.grey[600],
          // ),
          //
          // // Image Button
          // IconButton(
          //   icon: const Icon(Icons.image),
          //   onPressed: () {
          //     // TODO: Implement image picker
          //   },
          //   color: Colors.grey[600],
          // ),
          //
          // // Voice Button
          // IconButton(
          //   icon: const Icon(Icons.mic),
          //   onPressed: () {
          //     // TODO: Implement voice recording
          //   },
          //   color: Colors.grey[600],
          // ),

          // Send Button
          Container(
            decoration: const BoxDecoration(
              color: Colors.blue,
              shape: BoxShape.circle,
            ),
            child: IconButton(
              icon: const Icon(Icons.send, color: Colors.white),
              onPressed: () {
                final message = textController.text.trim();
                if (message.isNotEmpty) {
                  controller.sendMessage(message);
                  textController.clear();
                }
              },
            ),
          ),
        ],
      ),
    );
  }

  String _formatTime(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inMinutes < 1) {
      return 'Just now';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    } else {
      return '${timestamp.day}/${timestamp.month}/${timestamp.year}';
    }
  }
}
