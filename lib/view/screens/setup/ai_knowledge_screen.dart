import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:minechat/controller/ai_knowledge_controller/ai_knowledge_controller.dart';
import 'package:minechat/controller/business_info_controller/business_info_controller.dart';
import 'package:minechat/controller/products_services_controller/products_services_controller.dart';
import 'package:minechat/controller/faqs_controller/faqs_controller.dart';
import 'package:minechat/controller/theme_controller/theme_controller.dart';
import 'package:minechat/core/constants/app_colors/app_colors.dart';
import 'package:minechat/core/utils/helpers/app_responsive/app_responsive.dart';
import 'package:minechat/core/utils/helpers/app_spacing/app_spacing.dart';
import 'package:minechat/core/utils/helpers/app_styles/app_text_styles.dart';

// Import your 3 separate screens
import 'business_information.dart';
import 'products_services_screen.dart';
import 'faqs_screen.dart';

import '../../../controller/ai_assistant_controller/ai_assistant_controller.dart';

class AIKnowledgeScreen extends StatefulWidget {
  final AIAssistantController controller;

  const AIKnowledgeScreen({super.key, required this.controller});

  @override
  State<AIKnowledgeScreen> createState() => _AIKnowledgeScreenState();
}

class _AIKnowledgeScreenState extends State<AIKnowledgeScreen> {
  late BusinessInfoController businessInfoController;
  late ProductsServicesController productsServicesController;
  late FAQsController faqsController;
  late AIKnowledgeController knowledgeController;

  @override
  void initState() {
    super.initState();
    _initializeControllers();
  }

  void _initializeControllers() {
    businessInfoController =
        Get.put(BusinessInfoController(), permanent: true);
    productsServicesController =
        Get.put(ProductsServicesController(), permanent: true);
    faqsController = Get.put(FAQsController(), permanent: true);
    knowledgeController = Get.put(AIKnowledgeController(), permanent: true);
  }

  @override
  Widget build(BuildContext context) {
    final themeController = Get.find<ThemeController>();
    final isDark = themeController.isDarkMode;

    return Scaffold(
      backgroundColor: isDark ? const Color(0XFF0A0A0A) : const Color(0XFFF4F6FC),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AppSpacing.vertical(context, 0.02),

          // Top Tabs
          Row(
            children: [
              _buildTab('Business Information', 0, knowledgeController, context),
              AppSpacing.horizontal(context, 0.03),
              _buildTab('Products & Services', 1, knowledgeController, context),
              AppSpacing.horizontal(context, 0.03),
              _buildTab('FAQs', 2, knowledgeController, context),
            ],
          ),

          AppSpacing.vertical(context, 0.015),

          // Main Content
          Expanded(
            child: Obx(() {
              return IndexedStack(
                key: const ValueKey('ai_knowledge_indexed_stack'),
                index: knowledgeController.selectedTabIndex.value,
                children: [
                  BusinessInformation(
                    key: const ValueKey('business_information'),
                    controller: businessInfoController,
                  ),
                  ProductsServicesScreen(
                    key: const ValueKey('products_services'),
                    controller: productsServicesController,
                  ),
                  FAQsScreen(
                    key: const ValueKey('faqs'),
                    controller: faqsController,
                  ),
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
      BuildContext context,
      ) {
    final themeController = Get.find<ThemeController>();
    final isDark = themeController.isDarkMode;

    return GestureDetector(
      onTap: () => controller.selectedTabIndex.value = index,
      child: Obx(() {
        final isSelected = controller.selectedTabIndex.value == index;
        return Text(
          title,
          style: AppTextStyles.bodyText(context).copyWith(
            color: isSelected
                ? (isDark ? AppColors.white : AppColors.secondary)
                : Colors.grey[600],
            decoration:
            isSelected ? TextDecoration.underline : TextDecoration.none,
            decorationColor: isSelected
                ? (isDark ? AppColors.white : AppColors.secondary)
                : Colors.transparent,
            fontSize: AppResponsive.scaleSize(context, 13),
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
          ),
        );
      }),
    );
  }
}
