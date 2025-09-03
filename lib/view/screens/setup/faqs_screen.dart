import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:file_picker/file_picker.dart';
import 'package:minechat/controller/faqs_controller/faqs_controller.dart';
import 'package:minechat/controller/theme_controller/theme_controller.dart';
import 'package:minechat/core/utils/extensions/app_gradient/app_gradient_extension.dart';
import 'package:minechat/core/utils/helpers/app_responsive/app_responsive.dart';
import 'package:minechat/core/utils/helpers/app_spacing/app_spacing.dart';
import 'package:minechat/core/utils/helpers/app_styles/app_text_styles.dart';
import 'package:minechat/core/widgets/signUp/signUp_textfield.dart';
import 'package:minechat/view/screens/setup/faqs_ai_testing_screen.dart';

import '../../../core/constants/app_assets/app_assets.dart';
import '../../../core/constants/app_colors/app_colors.dart';
import '../../../model/data/faq_model.dart';

class FAQsScreen extends StatelessWidget {
  final FAQsController controller;

  const FAQsScreen({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    final themeController = Get.find<ThemeController>();
    final isDark = themeController.isDarkMode;
    return Scaffold(
      backgroundColor: isDark ? Color(0XFF0A0A0A) : Color(0XFFF4F6FC),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // File Upload Section
            _buildFileUploadSection(context),
            AppSpacing.vertical(context, 0.04),

            // Individual FAQ Entries Section
            _buildIndividualFAQSection(context),
            AppSpacing.vertical(context, 0.02),
            // Always-show "+ Add More" button (outlined, red)
            OutlinedButton.icon(
              onPressed: () => _showQuickAddFAQDialog(context),
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: AppColors.primary, width: 1.4),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              ),
              icon: const Icon(Icons.add, color: AppColors.primary),
              label: Text(
                'Add More',
                style: AppTextStyles.bodyText(context).copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            AppSpacing.vertical(context, 0.02),

            // Action Buttons Row
            Row(
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
                      onPressed: () => controller.saveAllFAQs(),
                      child: Text(
                        'Save',
                        style: TextStyle(
                          color: isDark ? AppColors.white : AppColors.primary,
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
                      borderRadius: BorderRadius.circular(12),
                    ).withAppGradient,
                    child: TextButton.icon(
                      onPressed: () => Get.to(() =>
                          FAQsAITestingScreen(faqsController: controller)),
                      icon: SvgPicture.asset(
                        "assets/images/icons/icon_setup_test_ai_button.svg",width: 20,
                        height: 20,
                        colorFilter: const ColorFilter.mode(
                            Colors.white, BlendMode.srcIn),
                      ),
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
    final themeController = Get.find<ThemeController>();
    final isDark = themeController.isDarkMode;
    final linkStyle = AppTextStyles.bodyText(context).copyWith(
      fontSize: 10,
      color: Color(0xFF1677FF),
      decoration: TextDecoration.underline,
      decorationColor: Color(0xFF1677FF),
      fontWeight: FontWeight.w500,
    );

    final subStyle = AppTextStyles.bodyText(context).copyWith(
      fontSize: 10,
      fontWeight: FontWeight.w400,
    );
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header
        Text(
          'Frequently Asked Questions',
          style: AppTextStyles.bodyText(context).copyWith(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        AppSpacing.vertical(context, 0.01),

        // Instruction
        RichText(
          text: TextSpan(
            children: [
              TextSpan(
                text: 'Upload file you want to import ',
                style: subStyle,
              ),
              TextSpan(
                text: '(see sample document)',
                style: linkStyle,
              ),
            ],
          ),
        ),
        AppSpacing.vertical(context, 0.01),

        // File Upload Area
        GestureDetector(
          onTap: () => _pickFile(context),
          child: DottedBorder(
            color: isDark
                ? Color(0XFFFFFFFF).withValues(alpha: .12)
                : Color(0XFFEBEDF0),
            strokeWidth: 1.6,
            dashPattern: const [6, 6],
            borderType: BorderType.RRect,
            radius: const Radius.circular(12),
            child: Obx(() {
              final name = controller.lastPickedFileName.value;

              return Container(
                width: double.infinity,
                height: 150,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: name.isEmpty
                    ? Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            width: 42,
                            height: 42,
                            decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: isDark
                                    ? Color(0XFFF0F1F5).withValues(alpha: .12)
                                    : Color(0XFFF0F1F5)),
                            child: Center(
                              child: SvgPicture.asset(
                                "assets/images/icons/icon_setup_file_upload.svg",
                                color: isDark
                                    ? Color(0XFFFFFFFF)
                                    : Color(0XFF15181F),
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 32,
                              vertical: 10,
                            ),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(24),
                            ).withAppGradient,
                            child: const Text(
                              'Upload file',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                                fontSize: 14,
                              ),
                            ),
                          ),
                        ],
                      )
                    : Stack(
                        children: [
                          // File name centered
                          Center(
                            child: Text(
                              name,
                              style: TextStyle(
                                color: Colors.green[800],
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                              ),
                              overflow: TextOverflow.ellipsis,
                              textAlign: TextAlign.center,
                            ),
                          ),

                          // Close button at top-right
                          Positioned(
                            top: 8,
                            right: 8,
                            child: GestureDetector(
                              onTap: () => controller.clearFileSelection(),
                              child: Container(
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: AppColors.primary,
                                  border: Border.all(
                                    color: Colors.red[300]!,
                                    width: 1.2,
                                  ),
                                  boxShadow: const [
                                    BoxShadow(
                                      color: Colors.black26,
                                      blurRadius: 3,
                                      offset: Offset(1, 1),
                                    )
                                  ],
                                ),
                                padding: const EdgeInsets.all(4),
                                child: Icon(
                                  Icons.close,
                                  size: 16,
                                  color: AppColors.white,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
              );
            }),
          ),
        ),
      ],
    );
  }

  Widget _buildIndividualFAQSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header
        Text('Individual FAQ Entries',
            style: AppTextStyles.bodyText(context).copyWith(
                fontSize: AppResponsive.scaleSize(context, 14),
                fontWeight: FontWeight.w500)),
        AppSpacing.vertical(context, 0.02),

        // Existing FAQs List
        Obx(() => Column(
              children: controller.faqs
                  .map((faq) => _buildFAQCard(faq, context))
                  .toList(),
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
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Color(0XFFFFFFFF).withOpacity(0.12)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Question Field
          SignupTextField(
            label: 'Question',
            hintText: 'Enter your question',
            controller: controller.questionCtrl,
            errorText: controller.questionError,
            onChanged: (val) => controller.validateQuestion(val),
          ),
          AppSpacing.vertical(context, 0.01),

          // Answer Field
          SignupTextField(
            label: 'Answer',
            hintText: 'Enter your answer',
            controller: controller.answerCtrl,
            errorText: controller.answerError,
            onChanged: (val) => controller.validateAnswer(val),
          ),
          AppSpacing.vertical(context, 0.02),

          // Add FAQ Button
          Container(
            width: double.infinity,
            decoration: BoxDecoration(
              border: Border.all(color: AppColors.primary),
              borderRadius: BorderRadius.circular(12),
            ),
            child: TextButton.icon(
              onPressed: () => controller.addIndividualFAQ(),
              icon: Icon(Icons.add, color: AppColors.primary, size: 20),
              label: Text(
                'Add FAQ',
                style: TextStyle(
                  color: AppColors.primary,
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
        color: AppColors.g1,
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
                  label: Text('Edit',
                      style: TextStyle(color: Colors.blue, fontSize: 12)),
                ),
              ),
              Expanded(
                child: TextButton.icon(
                  onPressed: () => controller.deleteFAQ(faq.id),
                  icon: Icon(Icons.delete, color: Colors.red, size: 16),
                  label: Text('Remove',
                      style: TextStyle(color: Colors.red, fontSize: 12)),
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
      print(
          '🔍 Result: ${result != null ? 'File selected' : 'No file selected'}');

      if (result != null && result.files.isNotEmpty) {
        PlatformFile file = result.files.first;
        print('🔍 Selected file: ${file.name}');
        print('🔍 File path: ${file.path}');
        print('🔍 File size: ${file.size}');
        print('🔍 File extension: ${file.extension}');

        if (file.path != null && file.path!.isNotEmpty) {
          controller.selectedFile.value = file.path!;
          controller.lastPickedFileName.value = file.name;
          print(
              '🔍 File path set to controller: ${controller.selectedFile.value}');
          print(
              '🔍 File name set to controller: ${controller.lastPickedFileName.value}');

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

  void _showQuickAddFAQDialog(BuildContext context) {
    final qCtrl = TextEditingController();
    final aCtrl = TextEditingController();
    String qErr = '';
    String aErr = '';

    showDialog(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setState) {
            return AlertDialog(
              title: const Text('Add FAQ'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Reuse your app textfield style
                    SignupTextField(
                      label: 'Question',
                      hintText: 'Enter your question',
                      controller: qCtrl,
                    ),
                    if (qErr.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(top: 6),
                        child: Text(qErr,
                            style: const TextStyle(color: Colors.red)),
                      ),
                    const SizedBox(height: 12),
                    SignupTextField(
                      label: 'Answer',
                      hintText: 'Enter your answer',
                      controller: aCtrl,
                    ),
                    if (aErr.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(top: 6),
                        child: Text(aErr,
                            style: const TextStyle(color: Colors.red)),
                      ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(ctx).pop(),
                  child: const Text('Cancel'),
                ),
                TextButton(
                  onPressed: () async {
                    setState(() {
                      qErr = qCtrl.text.trim().isEmpty
                          ? 'Question is required'
                          : '';
                      aErr =
                          aCtrl.text.trim().isEmpty ? 'Answer is required' : '';
                    });
                    if (qErr.isEmpty && aErr.isEmpty) {
                      await controller.addFAQDirect(
                        question: qCtrl.text,
                        answer: aCtrl.text,
                      );
                      if (ctx.mounted) Navigator.of(ctx).pop();
                    }
                  },
                  child: const Text('Save'),
                ),
              ],
            );
          },
        );
      },
    );
  }
}
