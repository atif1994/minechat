import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:minechat/controller/faq_controller/faq_controller.dart';
import 'package:minechat/core/constants/app_colors/app_colors.dart';
import 'package:minechat/core/utils/helpers/app_spacing/app_spacing.dart';
import 'package:minechat/core/widgets/signUp/signUp_textfield.dart';
import 'package:minechat/view/screens/setup/ai_testing_screen.dart';

import '../../../core/constants/app_assets/app_assets.dart';
import '../../../model/data/faq_model.dart';

class FAQsScreen extends StatelessWidget {
  const FAQsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(FAQController());

    return Scaffold(
      body: SingleChildScrollView(
        padding: AppSpacing.all(context, factor: 2),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 40),

            // Header
            Row(
              children: [
                Text(
                  'Frequently Asked Questions',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey[800],
                  ),
                ),
                const SizedBox(width: 8),
                GestureDetector(
                  onTap: () {
                    // Show sample document
                  },
                  child: Text(
                    '(see sample document)',
                    style: TextStyle(
                      color: Colors.blue[600],
                      fontSize: 12,
                      decoration: TextDecoration.underline,
                    ),
                  ),
                ),
              ],
            ),
            AppSpacing.vertical(context, 0.02),

            // File Upload Section
            _buildFileUploadSection(controller, context),
            AppSpacing.vertical(context, 0.02),

            Text(
              'Individual FAQ Entries',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.grey[800],
              ),
            ),
            AppSpacing.vertical(context, 0.01),

            // FAQs List
            Obx(() => Column(
              children: controller.faqs.map((faq) => _buildFAQCard(faq, controller, context)).toList(),
            )),

            // Add More Button
            Container(
              width: double.infinity,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.red[400]!),
                borderRadius: BorderRadius.circular(12),
              ),
              child: TextButton.icon(
                onPressed: () => controller.addNewFAQ(),
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
            AppSpacing.vertical(context, 0.02),

            // Action Buttons
            _buildActionButtons(controller, context),
          ],
        ),
      ),
    );
  }

  Widget _buildFileUploadSection(FAQController controller, BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Upload file you want to import',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Colors.grey[700],
          ),
        ),
        AppSpacing.vertical(context, 0.01),
        GestureDetector(
          onTap: () {
            _showFileUploadOptions(context);
          },
          child: Container(
            width: double.infinity,
            height: 120,
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey[300]!, style: BorderStyle.solid),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.upload_file,
                  size: 40,
                  color: Colors.grey[400],
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.red[400],
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    'Upload file',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  void _showFileUploadOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Choose File Source',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey[800],
                ),
              ),
              const SizedBox(height: 20),
              ListTile(
                leading: Icon(Icons.photo_library, color: Colors.blue),
                title: Text('Gallery'),
                onTap: () {
                  Navigator.pop(context);
                  _selectFromGallery();
                },
              ),
              ListTile(
                leading: Icon(Icons.camera_alt, color: Colors.green),
                title: Text('Camera'),
                onTap: () {
                  Navigator.pop(context);
                  _captureFromCamera();
                },
              ),
              ListTile(
                leading: Icon(Icons.folder, color: Colors.orange),
                title: Text('Documents'),
                onTap: () {
                  Navigator.pop(context);
                  _selectDocument();
                },
              ),
              const SizedBox(height: 10),
            ],
          ),
        );
      },
    );
  }

  void _selectFromGallery() async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );

      if (image != null) {
        Get.snackbar(
          'Success',
          'Image selected from gallery',
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to select image: $e',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  void _captureFromCamera() async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(
        source: ImageSource.camera,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );

      if (image != null) {
        Get.snackbar(
          'Success',
          'Image captured from camera',
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to capture image: $e',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  void _selectDocument() async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? document = await picker.pickMedia(
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );

      if (document != null) {
        Get.snackbar(
          'Success',
          'Document selected',
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to select document: $e',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  Widget _buildFAQCard(FAQModel faq, FAQController controller, BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey[300]!),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          SignupTextField(
            label: 'Question',
            hintText: 'Enter your question',
            prefixIcon: AppAssets.signupIconEmail,
            controller: faq.questionCtrl,
            errorText: faq.questionError,
            // onChanged: (val) => controller.validateFAQQuestion(faq, val),
          ),
          AppSpacing.vertical(context, 0.01),
          SignupTextField(
            label: 'Answer',
            hintText: 'Enter your answer',
            prefixIcon: AppAssets.signupIconEmail,
            controller: faq.answerCtrl,
            errorText: faq.answerError,
            // onChanged: (val) => controller.validateFAQAnswer(faq, val),
          ),
          AppSpacing.vertical(context, 0.01),
          Row(
            children: [
              Expanded(
                child: TextButton.icon(
                  onPressed: () => controller.removeFAQ(faq),
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

  Widget _buildActionButtons(FAQController controller, BuildContext context) {
    return Row(
      children: [
        // Save Button
        Expanded(
          child: Container(
            height: 48,
            decoration: BoxDecoration(
              border: Border.all(color: AppColors.primary),
              borderRadius: BorderRadius.circular(12),
            ),
            child: TextButton(
              onPressed: () {
                if (controller.validateAllFAQs()) {
                  Get.snackbar(
                    'Success',
                    'FAQs saved successfully!',
                    backgroundColor: Colors.green,
                    colorText: Colors.white,
                  );
                } else {
                  Get.snackbar(
                    'Validation Error',
                    'Please fill all required fields',
                    backgroundColor: Colors.red,
                    colorText: Colors.white,
                  );
                }
              },
              child: const Text(
                'Save',
                style: TextStyle(
                  color: AppColors.primary,
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
            height: 48,
            decoration: BoxDecoration(
              color: AppColors.primary,
              borderRadius: BorderRadius.circular(12),
            ),
            child: TextButton.icon(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const AITestingScreen()),
                );
              },
              icon: const Icon(
                Icons.smart_toy,
                color: Colors.white,
                size: 20,
              ),
              label: const Text(
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
    );
  }
}
