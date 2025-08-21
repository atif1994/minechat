import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:file_picker/file_picker.dart';
import 'package:minechat/controller/faqs_controller/faqs_controller.dart';
import 'package:minechat/core/utils/helpers/app_spacing/app_spacing.dart';
import 'package:minechat/core/widgets/signUp/signUp_textfield.dart';
import 'package:minechat/view/screens/setup/faqs_ai_testing_screen.dart';

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


            // File Upload Section
            _buildFileUploadSection(context),
            AppSpacing.vertical(context, 0.04),

            // Individual FAQ Entries Section
            _buildIndividualFAQSection(context),
            AppSpacing.vertical(context, 0.04),

            // Action Buttons Row
            Row(
              children: [
                // Save Button
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.red[400]!),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: TextButton(
                      onPressed: () => controller.saveAllFAQs(),
                      child: Text(
                        'Save',
                        style: TextStyle(
                          color: Colors.red[400],
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
                      gradient: LinearGradient(
                        colors: [Colors.pink[400]!, Colors.red[400]!],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: TextButton.icon(
                      onPressed: () => Get.to(() => FAQsAITestingScreen(faqsController: controller)),
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
          ],
        ),
      ),
    );
  }

  Widget _buildFileUploadSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header
        Text(
          'Frequently Asked Questions',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Colors.grey[800],
          ),
        ),
        AppSpacing.vertical(context, 0.01),
        
        // Instruction text
        RichText(
          text: TextSpan(
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
            ),
            children: [
              TextSpan(text: 'Upload any file to save in Firebase. '),
              TextSpan(
                text: 'Text files (.txt, .csv) will be processed for FAQs.',
                style: TextStyle(
                  color: Colors.blue[600],
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
        AppSpacing.vertical(context, 0.02),

        // File Upload Area
        GestureDetector(
          onTap: () => _pickFile(context),
          child: Container(
            width: double.infinity,
            height: 120,
            decoration: BoxDecoration(
              border: Border.all(
                color: Colors.grey[400]!,
                style: BorderStyle.solid,
                width: 2,
              ),
              borderRadius: BorderRadius.circular(12),
              color: Colors.grey[50],
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.upload_file,
                  color: Colors.grey[400],
                  size: 40,
                ),
                const SizedBox(height: 8),
                Text(
                  'Drag and drop any file here or click to browse',
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        ),
        AppSpacing.vertical(context, 0.02),

        // Upload File Button
        Obx(() => Container(
          width: double.infinity,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.pink[400]!, Colors.red[400]!],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(12),
          ),
          child: TextButton(
            onPressed: controller.isUploading.value ? null : () => _pickFile(context),
            child: Text(
              controller.isUploading.value ? 'Uploading...' : 'Upload file',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        )),

        // Last picked file name
        Obx(() {
          final name = controller.lastPickedFileName.value;
          if (name.isEmpty) return const SizedBox.shrink();
          return Container(
            margin: const EdgeInsets.only(top: 8.0),
            padding: const EdgeInsets.all(8.0),
            decoration: BoxDecoration(
              color: Colors.green[50],
              border: Border.all(color: Colors.green[200]!),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Icon(Icons.check_circle, color: Colors.green, size: 16),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Selected: $name',
                    style: TextStyle(
                      color: Colors.green[700], 
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: () => controller.clearFileSelection(),
                  child: Icon(Icons.close, color: Colors.green[600], size: 16),
                ),
              ],
            ),
          );
        }),
      ],
    );
  }

  Widget _buildIndividualFAQSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header
        Text(
          'Individual FAQ Entries',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Colors.grey[800],
          ),
        ),
        AppSpacing.vertical(context, 0.02),

        // Existing FAQs List
        Obx(() => Column(
          children: controller.faqs.map((faq) => _buildFAQCard(faq, context)).toList(),
        )),

        // Individual FAQ Form
        _buildIndividualFAQForm(context),
      ],
    );
  }

  Widget _buildIndividualFAQForm(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
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
          AppSpacing.vertical(context, 0.02),

          // Add FAQ Button
          Container(
            width: double.infinity,
            decoration: BoxDecoration(
              border: Border.all(color: Colors.red[400]!),
              borderRadius: BorderRadius.circular(12),
            ),
            child: TextButton.icon(
              onPressed: () => controller.addIndividualFAQ(),
              icon: Icon(Icons.add, color: Colors.red[400], size: 20),
              label: Text(
                'Add FAQ',
                style: TextStyle(
                  color: Colors.red[400],
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFAQCard(FAQModel faq, BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Q: ${faq.question}',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Colors.grey[800],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'A: ${faq.answer}',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 12),
          
          // Action Buttons
          Row(
            children: [
              Expanded(
                child: TextButton.icon(
                  onPressed: () => _showEditFAQDialog(context, faq),
                  icon: Icon(Icons.edit, color: Colors.blue, size: 16),
                  label: Text('Edit', style: TextStyle(color: Colors.blue, fontSize: 12)),
                ),
              ),
              Expanded(
                child: TextButton.icon(
                  onPressed: () => controller.deleteFAQ(faq.id),
                  icon: Icon(Icons.delete, color: Colors.red, size: 16),
                  label: Text('Remove', style: TextStyle(color: Colors.red, fontSize: 12)),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _pickFile(BuildContext context) async {
    try {
      print('🔍 Starting file picker...');
      
      // Try with any file type first to see if file picker works at all
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.any,
        allowMultiple: false,
      );

      print('🔍 File picker completed');
      print('🔍 Result: ${result != null ? 'File selected' : 'No file selected'}');
      
      if (result != null && result.files.isNotEmpty) {
        PlatformFile file = result.files.first;
        print('🔍 Selected file: ${file.name}');
        print('🔍 File path: ${file.path}');
        print('🔍 File size: ${file.size}');
        print('🔍 File extension: ${file.extension}');
        
        if (file.path != null && file.path!.isNotEmpty) {
          controller.selectedFile.value = file.path!;
          controller.lastPickedFileName.value = file.name;
          print('🔍 File path set to controller: ${controller.selectedFile.value}');
          print('🔍 File name set to controller: ${controller.lastPickedFileName.value}');
          
          print('🔍 Calling uploadFAQFile...');
          await controller.uploadFAQFile();
        } else {
          print('❌ File path is null or empty');
          Get.snackbar(
            'Error',
            'Could not access file path. Please try again.',
            backgroundColor: Colors.red,
            colorText: Colors.white,
          );
        }
      } else {
        print('🔍 No file selected by user');
        Get.snackbar(
          'Info',
          'No file selected. Please try again.',
          backgroundColor: Colors.blue,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      print('❌ File picker error: $e');
      print('❌ Error type: ${e.runtimeType}');
      
      Get.snackbar(
        'Error',
        'Failed to pick file: $e',
        backgroundColor: Colors.red,
        colorText: Colors.white,
        duration: Duration(seconds: 5),
      );
    }
  }

  void _showEditFAQDialog(BuildContext context, FAQModel faq) {
    controller.loadForEdit(faq);
    _showFAQDialog(context, 'Edit FAQ', () {
      // TODO: Implement edit functionality
      Get.snackbar('Info', 'Edit functionality will be implemented');
    });
  }

  void _showFAQDialog(BuildContext context, String title, VoidCallback onSave) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: Column(
            mainAxisSize: MainAxisSize.min,
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
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                onSave();
                Navigator.of(context).pop();
              },
              child: Text('Save'),
            ),
          ],
        );
      },
    );
  }
}
