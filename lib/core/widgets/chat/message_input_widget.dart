import 'package:flutter/material.dart';
import 'package:get/get.dart';

/// Reusable message input widget for chat conversations
class MessageInputWidget extends StatelessWidget {
  final TextEditingController messageController;
  final RxBool isSending;
  final VoidCallback? onSendMessage;
  final VoidCallback? onEmojiTap;
  final VoidCallback? onGifTap;
  final VoidCallback? onImageTap;
  final VoidCallback? onVoiceTap;

  const MessageInputWidget({
    Key? key,
    required this.messageController,
    required this.isSending,
    this.onSendMessage,
    this.onEmojiTap,
    this.onGifTap,
    this.onImageTap,
    this.onVoiceTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
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
            onPressed: onEmojiTap ?? () {
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
                controller: messageController,
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
                onSubmitted: (_) => onSendMessage?.call(),
                style: const TextStyle(fontSize: 16),
              ),
            ),
          ),
          
          // Attachment buttons
          IconButton(
            onPressed: onGifTap ?? () {
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
            onPressed: onImageTap ?? () {
              _showImagePicker(context);
            },
            icon: const Icon(Icons.add_photo_alternate, color: Colors.grey),
          ),
          
          IconButton(
            onPressed: onVoiceTap ?? () {
              Get.snackbar('Info', 'Voice recording...');
            },
            icon: const Icon(Icons.mic, color: Colors.grey),
          ),
          
          // Send button
          Obx(() => Container(
            margin: const EdgeInsets.only(left: 8),
            child: IconButton(
              onPressed: isSending.value ? null : onSendMessage,
              icon: isSending.value
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

  void _showImagePicker(BuildContext context) {
    showModalBottomSheet(
      context: context,
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
