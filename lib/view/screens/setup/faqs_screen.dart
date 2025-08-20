import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:minechat/controller/faqs_controller/faqs_controller.dart';
import 'package:minechat/core/constants/app_colors/app_colors.dart';
import 'package:minechat/core/utils/helpers/app_spacing/app_spacing.dart';
import 'package:minechat/core/widgets/signUp/signUp_textfield.dart';
import 'package:minechat/view/screens/setup/ai_testing_screen.dart';

import '../../../core/constants/app_assets/app_assets.dart';
import '../../../model/data/faq_model.dart';

class FAQsScreen extends StatelessWidget {
  final FAQsController controller;
  
  const FAQsScreen({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        padding: AppSpacing.all(context, factor: 2),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 40),

            // Header
            Text(
              'Frequently Asked Questions',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.grey[800],
              ),
            ),
            AppSpacing.vertical(context, 0.02),

            // Action Buttons Row
            Row(
              children: [
                // Add More Button
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.red[400]!),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: TextButton.icon(
                      onPressed: () => controller.addFAQ(),
                      icon: Icon(Icons.add, color: Colors.red[400], size: 20),
                      label: Text(
                        'Add More',
                        style: TextStyle(
                          color: Colors.red[400],
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                
                // Save Button
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.purple[400]!),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: TextButton(
                      onPressed: () => controller.saveAllFAQs(),
                      child: Text(
                        'Save',
                        style: TextStyle(
                          color: Colors.purple[400],
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                
                // Test AI Button
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.purple[400],
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: TextButton.icon(
                      onPressed: () => Get.to(() => const AITestingScreen()),
                      icon: Icon(Icons.smart_toy, color: Colors.white, size: 20),
                      label: Text(
                        'Test AI',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            AppSpacing.vertical(context, 0.02),

            // FAQs List
            Obx(() => Column(
              children: controller.faqs.map((faq) => _buildFAQCard(faq, controller, context)).toList(),
            )),
          ],
        ),
      ),
    );
  }

  Widget _buildFAQCard(FAQModel faq, FAQsController controller, BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey[300]!),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          // Question Field
          SignupTextField(
            label: 'Question',
            hintText: 'Enter your question',
            prefixIcon: AppAssets.signupIconEmail,
            controller: controller.questionCtrl,
            errorText: controller.questionError,
            onChanged: (val) => controller.validateQuestion(val),
          ),
          AppSpacing.vertical(context, 0.01),
          
          // Answer Field
          SignupTextField(
            label: 'Answer',
            hintText: 'Enter your answer',
            prefixIcon: AppAssets.signupIconEmail,
            controller: controller.answerCtrl,
            errorText: controller.answerError,
            onChanged: (val) => controller.validateAnswer(val),
          ),
          AppSpacing.vertical(context, 0.01),
          
          // Category Field
          SignupTextField(
            label: 'Category',
            hintText: 'Enter category',
            prefixIcon: AppAssets.signupIconEmail,
            controller: controller.categoryCtrl,
            errorText: controller.categoryError,
            onChanged: (val) => controller.validateCategory(val),
          ),
          AppSpacing.vertical(context, 0.01),

          // Action Buttons
          Row(
            children: [
              Expanded(
                child: TextButton.icon(
                  onPressed: () => controller.loadForEdit(faq),
                  icon: Icon(Icons.edit, color: Colors.blue),
                  label: Text('Edit', style: TextStyle(color: Colors.blue)),
                ),
              ),
              Expanded(
                child: TextButton.icon(
                  onPressed: () => controller.deleteFAQ(faq.id),
                  icon: Icon(Icons.delete, color: Colors.red),
                  label: Text('Remove', style: TextStyle(color: Colors.red)),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
