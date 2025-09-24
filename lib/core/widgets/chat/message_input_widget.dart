import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:minechat/controller/theme_controller/theme_controller.dart';
import 'package:minechat/core/utils/extensions/app_gradient/app_gradient_extension.dart';

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
    final themeController = Get.find<ThemeController>();
    final isDark = themeController.isDarkMode;

    // Colors that match the screenshots
    final pillBg = isDark ? const Color(0xFF1A1C20) : const Color(0xFFFFFFFF);
    final pillBorder =
        isDark ? const Color(0xFF2B3038) : const Color(0xFFE9EDF5);
    final iconColor =
        isDark ? const Color(0xFF8B93A6) : const Color(0xFF8B93A6);
    final hintColor =
        isDark ? const Color(0xFF939AA9) : const Color(0xFF939AA9);

    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
      decoration: BoxDecoration(
        color: isDark ? const Color(0XFF0A0A0A) : Colors.white,
      ),
      child: Row(
        children: [
          // The pill input
          Expanded(
            child: Container(
              height: 48,
              padding: const EdgeInsets.symmetric(horizontal: 14),
              decoration: BoxDecoration(
                color: pillBg,
                borderRadius: BorderRadius.circular(28),
                border: Border.all(color: pillBorder),
              ),
              child: Row(
                children: [
                  // Emoji
                  _IconBtn(
                    icon: Icons.emoji_emotions_outlined,
                    color: iconColor,
                    onTap: onEmojiTap ??
                        () => Get.snackbar('Info', 'Emoji picker...'),
                  ),
                  const SizedBox(width: 8),

                  // TextField
                  Expanded(
                    child: TextField(
                      controller: messageController,
                      maxLines: 1,
                      textInputAction: TextInputAction.send,
                      onSubmitted: (_) => onSendMessage?.call(),
                      decoration: InputDecoration(
                        isCollapsed: true,
                        hintText: 'Send a message',
                        hintStyle: TextStyle(color: hintColor),
                        border: InputBorder.none,
                      ),
                      style: TextStyle(
                        color: isDark ? Colors.white : const Color(0xFF1D1D1D),
                        fontSize: 16,
                      ),
                    ),
                  ),

                  // Gif add
                  _IconBtn(
                    icon: Icons.gif_box_outlined,
                    color: iconColor,
                    onTap:
                        onGifTap ?? () => Get.snackbar('Info', 'GIF picker...'),
                  ),
                  const SizedBox(width: 10),

                  // Image add
                  _IconBtn(
                    icon: Icons.add_photo_alternate_outlined,
                    color: iconColor,
                    onTap: onImageTap ?? () => _showImagePicker(context),
                  ),
                  const SizedBox(width: 10),

                  // Mic
                  _IconBtn(
                    icon: Icons.mic_none_rounded,
                    color: iconColor,
                    onTap: onVoiceTap ??
                        () => Get.snackbar('Info', 'Voice recording...'),
                  ),
                ],
              ),
            ),
          ),

          // Gradient send button
          Obx(
            () => Padding(
              padding: const EdgeInsets.only(left: 10),
              child: SizedBox(
                width: 44,
                height: 44,
                child: ElevatedButton(
                  onPressed: isSending.value ? null : onSendMessage,
                  style: ButtonStyle(
                    padding: const WidgetStatePropertyAll(EdgeInsets.zero),
                    shape: WidgetStatePropertyAll(
                      RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(999)),
                    ),
                    elevation: const WidgetStatePropertyAll(0),
                    backgroundColor: WidgetStateProperty.resolveWith((states) {
                      // We’ll paint gradient manually in foreground below
                      return Colors.transparent;
                    }),
                    overlayColor:
                        const WidgetStatePropertyAll(Colors.transparent),
                  ),
                  child: Ink(
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                    ).withAppGradient,
                    child: Center(
                      child: isSending.value
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor:
                                    AlwaysStoppedAnimation<Color>(Colors.white),
                              ),
                            )
                          : const Icon(Icons.send_rounded,
                              color: Colors.white, size: 20),
                    ),
                  ),
                ),
              ),
            ),
          ),
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

class _IconBtn extends StatelessWidget {
  final IconData icon;
  final Color color;
  final VoidCallback? onTap;

  const _IconBtn({required this.icon, required this.color, this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Padding(
        padding: const EdgeInsets.all(6),
        child: Icon(icon, size: 26, color: color),
      ),
    );
  }
}
