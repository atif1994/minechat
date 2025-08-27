import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:minechat/controller/ai_assistant_controller/ai_assistant_controller.dart';
import 'package:minechat/controller/theme_controller/theme_controller.dart';
import 'package:minechat/core/constants/app_colors/app_colors.dart';
import 'package:minechat/core/utils/extensions/app_gradient/app_gradient_extension.dart';
import 'package:minechat/core/utils/helpers/app_spacing/app_spacing.dart';
import 'package:minechat/core/utils/helpers/app_styles/app_text_styles.dart';

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
    final themeController = Get.find<ThemeController>();
    final isDark = themeController.isDarkMode;
    final controller = Get.find<AIAssistantController>();

    return Scaffold(
      backgroundColor: isDark ? Color(0XFF0A0A0A) : Color(0XFFF4F6FC),
      appBar: AppBar(
        title: Text('AI Testing'),
        elevation: 0,
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

          // Loading Indicator
          Obx(() {
            if (controller.isLoading.value) {
              return Container(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    const SizedBox(width: 8),
                    const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      'AI is thinking...',
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              );
            }
            return const SizedBox.shrink();
          }),

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
        mainAxisAlignment:
            isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
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
                  bottomLeft: isUser
                      ? const Radius.circular(18)
                      : const Radius.circular(4),
                  bottomRight: isUser
                      ? const Radius.circular(4)
                      : const Radius.circular(18),
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
    final themeController = Get.find<ThemeController>();
    final isDark = themeController.isDarkMode;
    final textController =
        TextEditingController(); // consider hoisting to State

    final fieldBg = isDark ? const Color(0xFF1D1D1D) : const Color(0xFFFFFFFF);
    final iconColor =
        isDark ? const Color(0xFFBDBDBD) : const Color(0xFF616161);

    return Container(
      padding: AppSpacing.all(Get.context!, factor: 2),
      child: Row(
        children: [
          // TextField with inline SVGs
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: fieldBg,
                borderRadius: BorderRadius.circular(24),
              ),
              child: TextField(
                controller: textController,
                maxLines: null,
                textInputAction: TextInputAction.send,
                onSubmitted: (message) {
                  final m = message.trim();
                  if (m.isNotEmpty) {
                    controller.sendMessage(m);
                    textController.clear();
                  }
                },
                decoration: InputDecoration(
                  hintText: 'Send a message',
                  hintStyle: AppTextStyles.hintText(Get.context!),
                  border: InputBorder.none,
                  isDense: true,
                  // Left icon (smiley)
                  prefixIcon: _SvgIconButton(
                    asset: 'assets/images/icons/icon_setup_message_emjoi.svg',
                    onTap: () {
                      // open emoji picker
                    },
                    padding: const EdgeInsets.only(left: 12, right: 4),
                  ),
                  // Right side icons (GIF, image, mic)
                  suffixIconConstraints: const BoxConstraints(
                    // Allow the row to size itself instead of forcing 48px width
                    minWidth: 0,
                    minHeight: 0,
                  ),
                  suffixIcon: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _SvgIconButton(
                        asset: 'assets/images/icons/icon_setup_message_gif.svg',
                        onTap: () {
                          // open GIF picker
                        },
                      ),
                      _SvgIconButton(
                        asset:
                            'assets/images/icons/icon_setup_message_attach_image.svg',
                        onTap: () {
                          // open image/file picker
                        },
                      ),
                      _SvgIconButton(
                        asset:
                            'assets/images/icons/icon_setup_message_voice.svg',
                        onTap: () {
                          // start/stop voice input
                        },
                        padding: const EdgeInsets.only(left: 6, right: 12),
                      ),
                    ],
                  ),
                  // Space for text
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 0, vertical: 12),
                ),
              ),
            ),
          ),
          const SizedBox(width: 10),
          // Send button (outside the field)
          Obx(
            () => Container(
              decoration: BoxDecoration(
                color: controller.isLoading.value
                    ? Colors.grey
                    : AppColors.primary,
                shape: BoxShape.circle,
              ).withAppGradient,
              child: SizedBox(
                width: 36,
                height: 36,
                child: Padding(
                  padding: const EdgeInsets.all(5.0),
                  child: InkWell(
                    onTap: controller.isLoading.value
                        ? null
                        : () {
                            final message = textController.text.trim();
                            if (message.isNotEmpty) {
                              controller.sendMessage(message);
                              textController.clear();
                            }
                          },
                    child: SvgPicture.asset(
                      'assets/images/icons/icon_setup_message_send.svg',
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

class _SvgIconButton extends StatelessWidget {
  const _SvgIconButton({
    required this.asset,
    required this.onTap,
    this.size = 20,
    this.padding = const EdgeInsets.symmetric(horizontal: 6),
  });

  final String asset;
  final VoidCallback onTap;
  final double size;
  final EdgeInsets padding;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Padding(
        padding: padding,
        child: SvgPicture.asset(
          asset,
          width: size,
          height: size,
          colorFilter: ColorFilter.mode(Color(0XFFA8AEBF), BlendMode.srcIn),
        ),
      ),
    );
  }
}
