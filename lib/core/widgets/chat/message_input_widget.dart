import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:minechat/controller/theme_controller/theme_controller.dart';
import 'package:minechat/core/utils/extensions/app_gradient/app_gradient_extension.dart';
import 'package:minechat/core/services/media_service.dart';

/// Reusable message input widget for chat conversations
class MessageInputWidget extends StatefulWidget {
  final TextEditingController messageController;
  final RxBool isSending;
  final VoidCallback? onSendMessage;
  final Function(String)? onImageSelected;
  final Function(String)? onVoiceSelected;
  final VoidCallback? onEmojiTap;
  final VoidCallback? onGifTap;
  final VoidCallback? onImageTap;
  final VoidCallback? onVoiceTap;

  const MessageInputWidget({
    Key? key,
    required this.messageController,
    required this.isSending,
    this.onSendMessage,
    this.onImageSelected,
    this.onVoiceSelected,
    this.onEmojiTap,
    this.onGifTap,
    this.onImageTap,
    this.onVoiceTap,
  }) : super(key: key);

  @override
  State<MessageInputWidget> createState() => _MessageInputWidgetState();
}

class _MessageInputWidgetState extends State<MessageInputWidget> {
  late final MediaService _mediaService;

  @override
  void initState() {
    super.initState();
    // Use Get.find to get the existing instance instead of creating new one
    try {
      _mediaService = Get.find<MediaService>();
    } catch (e) {
      // If not found, put it once
      _mediaService = Get.put(MediaService(), permanent: true);
    }
  }

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

    return Obx(() {
      // Show voice recording UI when recording
      if (_mediaService.isRecording.value) {
        return _buildVoiceRecordingUI(context, isDark);
      }

      // Show normal input UI
      return _buildNormalInputUI(context, isDark, pillBg, pillBorder, iconColor, hintColor);
    });
  }

  Widget _buildVoiceRecordingUI(BuildContext context, bool isDark) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
      decoration: BoxDecoration(
        color: isDark ? const Color(0XFF0A0A0A) : Colors.white,
      ),
      child: Row(
        children: [
          // Recording indicator
          Container(
            width: 12,
            height: 12,
            decoration: const BoxDecoration(
              color: Colors.red,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 12),
          
          // Recording duration
          Obx(() => Text(
            _mediaService.getFormattedDuration(),
            style: TextStyle(
              color: isDark ? Colors.white : Colors.black,
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          )),
          
          const Spacer(),
          
          // Cancel button
          IconButton(
            onPressed: () => _mediaService.cancelRecording(),
            icon: Icon(Icons.close, color: Colors.red),
          ),
          
          // Stop and send button
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: Colors.red,
              shape: BoxShape.circle,
            ),
            child: IconButton(
              onPressed: () async {
                final audioPath = await _mediaService.stopRecording();
                if (audioPath != null && widget.onVoiceSelected != null) {
                  widget.onVoiceSelected!(audioPath);
                }
              },
              icon: const Icon(Icons.send, color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNormalInputUI(BuildContext context, bool isDark, Color pillBg, Color pillBorder, Color iconColor, Color hintColor) {

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
                    onTap: widget.onEmojiTap ?? () => _showEmojiPicker(context),
                  ),
                  const SizedBox(width: 8),

                  // TextField
                  Expanded(
                    child: TextField(
                      controller: widget.messageController,
                      maxLines: 1,
                      textInputAction: TextInputAction.send,
                      onSubmitted: (_) => widget.onSendMessage?.call(),
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


                  // Image add
                  _IconBtn(
                    icon: Icons.add_photo_alternate_outlined,
                    color: iconColor,
                    onTap: widget.onImageTap ?? () => _pickImage(context),
                  ),
                  const SizedBox(width: 10),

                  // Mic
                  // _IconBtn(
                  //   icon: Icons.mic_none_rounded,
                  //   color: iconColor,
                  //   onTap: widget.onVoiceTap ?? () => _startVoiceRecording(),
                  // ),
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
                  onPressed: widget.isSending.value ? null : widget.onSendMessage,
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
                      child: widget.isSending.value
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

  /// Pick image from camera or gallery
  Future<void> _pickImage(BuildContext context) async {
    final imagePath = await _mediaService.pickImage(context);
    if (imagePath != null && widget.onImageSelected != null) {
      widget.onImageSelected!(imagePath);
    }
  }

  /// Start voice recording
  Future<void> _startVoiceRecording() async {
    final success = await _mediaService.startRecording();
    if (!success) {
      Get.snackbar(
        'Error',
        'Failed to start voice recording. Please check permissions.',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  /// Show emoji picker
  void _showEmojiPicker(BuildContext context) {
    _mediaService.showEmojiPicker(context, (emoji) {
      // Insert emoji at cursor position
      final text = widget.messageController.text;
      final cursorPosition = widget.messageController.selection.baseOffset;
      
      // Validate cursor position to prevent RangeError
      final validCursorPosition = cursorPosition >= 0 && cursorPosition <= text.length 
          ? cursorPosition 
          : text.length;
      
      final newText = text.substring(0, validCursorPosition) + 
                     emoji.emoji + 
                     text.substring(validCursorPosition);
      widget.messageController.text = newText;
      widget.messageController.selection = TextSelection.fromPosition(
        TextPosition(offset: validCursorPosition + emoji.emoji.length),
      );
    });
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
