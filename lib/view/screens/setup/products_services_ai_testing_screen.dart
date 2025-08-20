import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:minechat/controller/ai_assistant_controller/ai_assistant_controller.dart';
import 'package:minechat/controller/products_services_controller/products_services_controller.dart';
import 'package:minechat/core/constants/app_colors/app_colors.dart';
import 'package:minechat/core/utils/helpers/app_spacing/app_spacing.dart';
import 'package:minechat/core/widgets/signUp/signUp_textfield.dart';
import 'package:minechat/model/data/chat_mesage_model.dart';

class ProductsServicesAITestingScreen extends StatelessWidget {
  final ProductsServicesController productsController;
  
  const ProductsServicesAITestingScreen({
    super.key, 
    required this.productsController,
  });

  @override
  Widget build(BuildContext context) {
    final aiController = Get.find<AIAssistantController>();
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('AI Testing - Products & Services'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
        actions: [
          // Refresh knowledge data button
          IconButton(
            icon: const Icon(Icons.sync),
            onPressed: () async {
              await aiController.refreshKnowledgeData();
              Get.snackbar('Success', 'Knowledge data refreshed!');
            },
            tooltip: 'Refresh Knowledge Data',
          ),
          // Test button for quick testing
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () async {
              await aiController.refreshKnowledgeData();
              aiController.sendMessage("Tell me about your products and services");
            },
            tooltip: 'Test Products & Services',
          ),
          // Test knowledge integration
          IconButton(
            icon: const Icon(Icons.lightbulb_outline),
            onPressed: () async {
              await aiController.refreshKnowledgeData();
              aiController.sendMessage("What products and services do you offer? Can you provide details about pricing and features?");
            },
            tooltip: 'Test Knowledge Integration',
          ),
        ],
      ),
      body: Column(
        children: [
          // Chat Messages
          Expanded(
            child: Container(
              padding: AppSpacing.all(context, factor: 2),
              child: Obx(() => ListView.builder(
                reverse: true,
                itemCount: aiController.chatMessages.length,
                itemBuilder: (context, index) {
                  final ChatMessageModel message = aiController.chatMessages[aiController.chatMessages.length - 1 - index];
                  final bool isUser = message.type == MessageType.user;
                  
                  return Container(
                    margin: const EdgeInsets.only(bottom: 16),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
                      children: [
                        if (!isUser) ...[
                          CircleAvatar(
                            backgroundColor: Colors.purple[100],
                            child: Icon(
                              Icons.smart_toy,
                              color: Colors.purple[600],
                              size: 20,
                            ),
                          ),
                          const SizedBox(width: 8),
                        ],
                        Flexible(
                          child: Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: isUser ? Colors.purple[600] : Colors.grey[100],
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              message.message,
                              style: TextStyle(
                                color: isUser ? Colors.white : Colors.black87,
                                fontSize: 14,
                              ),
                            ),
                          ),
                        ),
                        if (isUser) ...[
                          const SizedBox(width: 8),
                          CircleAvatar(
                            backgroundColor: Colors.grey[300],
                            child: Icon(
                              Icons.person,
                              color: Colors.grey[600],
                              size: 20,
                            ),
                          ),
                        ],
                      ],
                    ),
                  );
                },
              )),
            ),
          ),
          
          // Loading indicator
          Obx(() => aiController.isLoading.value
            ? Container(
                padding: const EdgeInsets.all(16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
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
              )
            : const SizedBox.shrink(),
          ),
          
          // Input Section
          Container(
            padding: AppSpacing.all(context, factor: 2),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.1),
                  spreadRadius: 1,
                  blurRadius: 5,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey[300]!),
                      borderRadius: BorderRadius.circular(25),
                    ),
                    child: TextField(
                      controller: aiController.messageController,
                      decoration: const InputDecoration(
                        hintText: 'Ask about products and services...',
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      ),
                      maxLines: null,
                      textInputAction: TextInputAction.send,
                      onSubmitted: (value) {
                        if (value.trim().isNotEmpty) {
                          aiController.sendMessage(value.trim());
                        }
                      },
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Obx(() => Container(
                  decoration: BoxDecoration(
                    color: aiController.isLoading.value ? Colors.grey : Colors.purple[600],
                    borderRadius: BorderRadius.circular(25),
                  ),
                  child: IconButton(
                    onPressed: aiController.isLoading.value
                        ? null
                        : () {
                            if (aiController.messageController.text.trim().isNotEmpty) {
                              aiController.sendMessage(aiController.messageController.text.trim());
                            }
                          },
                    icon: Icon(
                      Icons.send,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                )),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
