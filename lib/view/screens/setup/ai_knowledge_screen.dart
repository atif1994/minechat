import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:minechat/controller/ai_knowledge_controller/ai_knowledge_controller.dart';
import 'package:minechat/controller/product_controller/product_controller.dart';
import 'package:minechat/controller/faq_controller/faq_controller.dart';
import 'package:minechat/core/constants/app_colors/app_colors.dart';
import 'package:minechat/core/utils/helpers/app_styles/app_text_styles.dart';

// Import your 3 separate screens
import 'business_information.dart';
import 'products_services_screen.dart';
import 'faqs_screen.dart';

import '../../../controller/ai_assistant_controller/ai_assistant_controller.dart';

class AIKnowledgeScreen extends StatelessWidget {
  final AIAssistantController controller;

  const AIKnowledgeScreen({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    // Init controllers
    final productController = Get.put(ProductController());
    final faqController = Get.put(FAQController());
    final knowledgeController = Get.put(AIKnowledgeController());

    return Scaffold(
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [


          // Top Tabs
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _buildTab('Business Information', 0, knowledgeController,context),
                const SizedBox(width: 20),
                _buildTab('Products & Services', 1, knowledgeController,context),
                const SizedBox(width: 20),
                _buildTab('FAQs', 2, knowledgeController,context),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // Main Content
          Expanded(
            child: Obx(() {
              return IndexedStack(
                index: knowledgeController.selectedTabIndex.value,
                children: const [
                  BusinessInformation(),
                  ProductsServicesScreen(),
                  FAQsScreen(),
                ],
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildTab(String title, int index, AIKnowledgeController controller,context) {
    final isSelected = controller.selectedTabIndex.value == index;
    return GestureDetector(
      onTap: () => controller.selectedTabIndex.value = index,
      child: Text(
        title,
        style: AppTextStyles.poppinsRegular(context).copyWith(color: isSelected ? AppColors.secondary : Colors.grey[600] ))



      );

  }
}
