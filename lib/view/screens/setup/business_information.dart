import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';

import '../../../controller/ai_knowledge_controller/ai_knowledge_controller.dart';
import '../../../core/utils/helpers/app_spacing/app_spacing.dart';
import '../../../core/widgets/signUp/signUp_textfield.dart';

class BusinessInformation extends StatelessWidget {
  const BusinessInformation({super.key});

  @override
  Widget build(BuildContext context) {
    final knowledgeController = Get.put(AIKnowledgeController());
    return Scaffold(
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.only(left: 16,right: 16),
          child: Column(
            children: [
              _buildBusinessInformationTab(knowledgeController, context)
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBusinessInformationTab(AIKnowledgeController controller,
      BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Business Information',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: Colors.grey[800],
          ),
        ),
        AppSpacing.vertical(context, 0.02),

        // File Upload Section
        _buildFileUploadSection(controller, context),
        AppSpacing.vertical(context, 0.02),

        // Business Name
        SignupTextField(
          labelText: 'Company Name',
          hintText: 'Enter Company Name',
          controller: controller.businessNameCtrl,
          errorText: controller.businessNameError,
        ),
        AppSpacing.vertical(context, 0.015),

        // Phone Number
        SignupTextField(
          labelText: 'Phone Number',
          hintText: 'Enter phone number',
          prefixIcon: 'assets/icons/phone.png',
          // optional
          controller: controller.phoneCtrl,
          errorText: controller.phoneError,
          keyboardType: TextInputType.phone,
        ),
        AppSpacing.vertical(context, 0.015),

        // Address
        SignupTextField(
          labelText: 'Address',
          hintText: 'Enter address',
          controller: controller.addressCtrl,
          errorText: controller.addressError,
        ),
        AppSpacing.vertical(context, 0.015),

        // Email
        SignupTextField(
          labelText: 'Email',
          hintText: 'Enter email',
          controller: controller.emailCtrl,
          errorText: controller.emailError,
          keyboardType: TextInputType.emailAddress,
        ),
        AppSpacing.vertical(context, 0.015),

        // Company Story
        SignupTextField(
          labelText: 'Company Story or Other information',
          hintText: 'Enter Company Story or Other information',
          controller: controller.companyStoryCtrl,
          errorText: controller.companyStoryError,
        ),
        AppSpacing.vertical(context, 0.015),

        // Payment Details
        SignupTextField(
          labelText: 'Payment Details',
          hintText: 'Enter Payment Details',
          controller: controller.paymentDetailsCtrl,
          errorText: controller.paymentDetailsError,
        ),
        AppSpacing.vertical(context, 0.015),

        // Discounts
        SignupTextField(
          labelText: 'Discounts',
          hintText: 'Enter Discounts',
          controller: controller.discountsCtrl,
          errorText: controller.discountsError,
        ),
        AppSpacing.vertical(context, 0.015),

        // Policy
        SignupTextField(
          labelText: 'Policy',
          hintText: 'Enter Policy',
          controller: controller.policyCtrl,
          errorText: controller.policyError,
        ),
        AppSpacing.vertical(context, 0.015),

        // Additional Notes
        SignupTextField(
          labelText: 'Additional Notes',
          hintText: 'Enter Additional Notes',
          controller: controller.additionalNotesCtrl,
          errorText: controller.additionalNotesError,
        ),
        AppSpacing.vertical(context, 0.015),

        // Thank you message
        SignupTextField(
          labelText: 'Thank You Message',
          hintText: 'Enter Thank You Message',
          controller: controller.thankYouMessageCtrl,
          errorText: controller.thankYouMessageError,
        ),
        AppSpacing.vertical(context, 0.02),

        // Action Buttons
        _buildActionButtons(controller, context),
      ],
    );
  }

  Widget _buildFileUploadSection(dynamic controller, BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Upload file you want to import (see sample document)',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Colors.grey[700],
            ),
          ),
          AppSpacing.vertical(context, 0.01),
          GestureDetector(
            // onTap: () => _showFileUploadOptions(context, controller),
            child: Container(
              width: double.infinity,
              height: 120,
              decoration: BoxDecoration(
                border: Border.all(
                    color: Colors.grey[300]!, style: BorderStyle.solid),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.upload_file, color: Colors.grey[400], size: 40),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.red[400],
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Text(
                      'Upload file',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          AppSpacing.vertical(context, 0.01),

          // Upload Progress (example)
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Dashboard prototype FINAL.fig',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      Text(
                        '4.2 MB',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
                      ),
                      const SizedBox(height: 4),
                      LinearProgressIndicator(
                        value: 0.8,
                        backgroundColor: Colors.grey[300],
                        valueColor: AlwaysStoppedAnimation<Color>(
                            Colors.red[400]!),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: () {},
                  icon: Icon(Icons.close, color: Colors.grey[600]),
                ),
              ],
            ),
          ),
          AppSpacing.vertical(context, 0.01),

          // Upload Failed Message
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.red[50],
              border: Border.all(color: Colors.red[200]!),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Icon(Icons.error_outline, color: Colors.red[400], size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Upload failed, please try again',
                    style: TextStyle(
                      color: Colors.red[400],
                      fontSize: 14,
                    ),
                  ),
                ),
                TextButton.icon(
                  onPressed: () {},
                  icon: Icon(Icons.refresh, color: Colors.red[400], size: 16),
                  label: Text(
                    'Upload again',
                    style: TextStyle(
                      color: Colors.red[400],
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
          ),
          AppSpacing.vertical(context, 0.01),

          // Previously Uploaded File
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Dashboard prototype FINAL.fig',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      Text(
                        '4.2 MB',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: () {},
                  icon: Icon(Icons.delete, color: Colors.grey[600]),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
  Widget _buildActionButtons(dynamic controller, BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: Container(
                height: 48,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.red[400]!),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: TextButton(
                  onPressed: () => Get.back(),
                  child: Text(
                    'Save',
                    style: TextStyle(
                      color: Colors.red[400],
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Container(
                height: 48,
                decoration: BoxDecoration(
                  color: Colors.red[400],
                  borderRadius: BorderRadius.circular(12),
                ),
                child: TextButton.icon(
                  onPressed: () {
                    // TODO: Implement Test AI functionality
                    Get.snackbar('Info', 'Test AI functionality coming soon!');
                  },
                  icon: Icon(
                    Icons.smart_toy,
                    color: Colors.white,
                    size: 20,
                  ),
                  label: Text(
                    'Test AI',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
