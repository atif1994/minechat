import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:minechat/controller/ai_knowledge_controller/ai_knowledge_controller.dart';
import 'package:minechat/controller/business_info_controller/business_info_controller.dart';
import 'package:minechat/controller/products_services_controller/products_services_controller.dart';
import 'package:minechat/controller/faqs_controller/faqs_controller.dart';
import 'package:minechat/core/constants/app_colors/app_colors.dart';
import 'package:minechat/core/utils/helpers/app_responsive/app_responsive.dart';
import 'package:minechat/core/utils/helpers/app_spacing/app_spacing.dart';
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
    final businessInfoController = Get.put(BusinessInfoController());
    final productsServicesController = Get.put(ProductsServicesController());
    final faqsController = Get.put(FAQsController());
    final knowledgeController = Get.put(AIKnowledgeController());

    // Create a specific ScrollController for the horizontal tabs
    final ScrollController tabScrollController = ScrollController();

    return Scaffold(
      backgroundColor:AppColors.g1 ,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AppSpacing.vertical(context, 0.02),

          // Top Tabs
          Scrollbar(
            controller: tabScrollController, // Use specific controller
            thumbVisibility: true,
            trackVisibility: true,
            child: SingleChildScrollView(
              controller: tabScrollController, // Use specific controller
              scrollDirection: Axis.horizontal,
              child: Container(
                height: AppResponsive.screenHeight(context) * 0.04,
                width: AppResponsive.screenWidth(context),
                decoration: BoxDecoration(
                  color: AppColors.g2,
                ),
                child: Padding(
                  padding: const EdgeInsets.only(left: 16),
                  child: Row(
                    children: [
                      _buildTab('Business Information', 0, knowledgeController, context),
                      const SizedBox(width: 20),
                      _buildTab('Products & Services', 1, knowledgeController, context),
                      const SizedBox(width: 20),
                      _buildTab('FAQs', 2, knowledgeController, context),
                    ],
                  ),
                ),
              ),
            ),
          ),

          AppSpacing.vertical(context, 0.015),

          // Main Content
          Expanded(
            child: Obx(() {
              return IndexedStack(
                index: knowledgeController.selectedTabIndex.value,
                children: [
                  BusinessInformation(controller: businessInfoController),
                  ProductsServicesScreen(controller: productsServicesController),
                  FAQsScreen(controller: faqsController),
                ],
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildTab(
      String title,
      int index,
      AIKnowledgeController controller,
      context,
      ) {
    return GestureDetector(
      onTap: () => controller.selectedTabIndex.value = index,
      child: Obx(() {
        final isSelected = controller.selectedTabIndex.value == index;
        return Text(
          title,
          style: AppTextStyles.poppinsRegular(context).copyWith(
            color: isSelected ? AppColors.secondary : Colors.grey[600],
            decoration: isSelected ? TextDecoration.underline:TextDecoration.none,
            decorationColor: isSelected ? AppColors.secondary:Colors.transparent,   // underline color
            decorationThickness: 2,

          ),
        );
      }),
    );
  }

}
