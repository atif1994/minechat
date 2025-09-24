import 'package:flutter/material.dart';
import 'package:get/get.dart';

/// Reusable message bubble widget for chat conversations
class MessageBubbleWidget extends StatelessWidget {
  final String message;
  final String timestamp;
  final bool isFromUser;
  final bool isAI;
  final Widget? avatar;

  const MessageBubbleWidget({
    Key? key,
    required this.message,
    required this.timestamp,
    required this.isFromUser,
    this.isAI = false,
    this.avatar,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisAlignment: isFromUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Avatar only for incoming messages (left side)
          if (!isFromUser) ...[
            avatar ?? _buildDefaultAvatar(),
            const SizedBox(width: 8),
          ],
          
          // Message bubble
          Flexible(
            child: Column(
              crossAxisAlignment: isFromUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
              children: [
                Container(
                  constraints: BoxConstraints(
                    maxWidth: MediaQuery.of(context).size.width * 0.7,
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
                    message,
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
                    timestamp,
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
            avatar ?? _buildDefaultAvatar(),
          ],
        ],
      ),
    );
  }

  Widget _buildDefaultAvatar() {
    return CircleAvatar(
      radius: 16,
      backgroundColor: isAI ? const Color(0xFF25D366) : const Color(0xFF25D366),
      child: Icon(
        isAI ? Icons.smart_toy : Icons.person,
        color: Colors.white,
        size: 16,
      ),
    );
  }
}
