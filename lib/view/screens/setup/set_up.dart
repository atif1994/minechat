import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:minechat/controller/ai_assistant_controller/ai_assistant_controller.dart';
import 'package:minechat/core/constants/app_colors/app_colors.dart';
import 'package:minechat/core/utils/helpers/app_spacing/app_spacing.dart';
import 'package:minechat/core/widgets/signUp/signUp_textfield.dart';

import '../../../core/constants/app_assets/app_assets.dart';
import 'ai_testing_screen.dart';

class AIAssistantSetupScreen extends StatelessWidget {
  const AIAssistantSetupScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(AIAssistantController());

    return Scaffold(
      // appBar: AppBar(
      //   title: const Text('AI Assistant'),
      //   backgroundColor: Colors.transparent,
      //   elevation: 0,
      //   leading: IconButton(
      //     icon: const Icon(Icons.arrow_back),
      //     onPressed: () => Get.back(),
      //   ),
      // ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        return SingleChildScrollView(
          padding: AppSpacing.all(context, factor: 2),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 40,),
              // Breadcrumbs
              _buildBreadcrumbs(context),
              AppSpacing.vertical(context, 0.02),

              // AI Assistant Name
              SignupTextField(
                label: 'Name',
                hintText: 'Enter AI assistant name',
                prefixIcon: AppAssets.signupIconEmail,
                controller: controller.nameCtrl,
                errorText: controller.nameError,
                onChanged: (val) => controller.validateName(val),
              ),
              AppSpacing.vertical(context, 0.01),

              // Intro Message
              SignupTextField(
                label: 'Intro Message',
                hintText: 'Enter Intro Message',
                prefixIcon: AppAssets.signupIconEmail,
                controller: controller.introMessageCtrl,
                errorText: controller.introMessageError,
                onChanged: (val) => controller.validateIntroMessage(val),
              ),
              AppSpacing.vertical(context, 0.01),

              // Short Description
              SignupTextField(
                label: 'Short Description',
                hintText: 'Enter Description',
                prefixIcon: AppAssets.signupIconEmail,
                controller: controller.shortDescriptionCtrl,
                errorText: controller.shortDescriptionError,
                onChanged: (val) => controller.validateShortDescription(val),
              ),
              AppSpacing.vertical(context, 0.01),

              // AI Guidelines
              _buildAIGuidelinesField(controller),
              AppSpacing.vertical(context, 0.01),

              // Response Length
              _buildResponseLengthSelector(controller),
              AppSpacing.vertical(context, 0.02),

              // Action Buttons
              _buildActionButtons(controller,context),
            ],
          ),
        );
      }),
    );
  }
  Widget _buildBreadcrumbs(BuildContext context) {
    TextStyle linkStyle = TextStyle(fontSize: 12, color: Colors.blue);
    TextStyle separatorStyle = TextStyle(fontSize: 12, color: Colors.grey[600]);

    return Wrap(
      children: [
        GestureDetector(
          onTap: () {

          },
          child: Text('Setup', style: linkStyle),
        ),

        Text(' > ', style: separatorStyle),
        GestureDetector(
          onTap: (){  Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => AITestingScreen()),
          );},
          child: Text('AI Assistant', style: linkStyle),
        ),
        Text(' > ', style: separatorStyle),
        GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => AITestingScreen()),
            );
          },
          child: Text('AI Knowledge', style: linkStyle),
        ),
        Text(' > ', style: separatorStyle),
        GestureDetector(
          onTap: () => Navigator.pushNamed(context, '/business-info'),
          child: Text('Channels', style: linkStyle),
        ),
      ],
    );
  }

  Widget _buildAIGuidelinesField(AIAssistantController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'AI Guidelines',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Colors.grey[800],
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            border: Border.all(
              color: controller.aiGuidelinesError.value.isNotEmpty
                  ? Colors.red
                  : Colors.grey[300]!,
            ),
            borderRadius: BorderRadius.circular(12),
          ),
          child: TextField(
            controller: controller.aiGuidelinesCtrl,
            onChanged: (val) => controller.validateAIGuidelines(val),
            maxLines: 4,
            decoration: InputDecoration(
              hintText: 'Enter AI guidelines and behavior instructions...',
              hintStyle: TextStyle(color: Colors.grey[500]),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.all(16),
            ),
          ),
        ),
        if (controller.aiGuidelinesError.value.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 8, left: 16),
            child: Text(
              controller.aiGuidelinesError.value,
              style: const TextStyle(
                color: Colors.red,
                fontSize: 12,
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildResponseLengthSelector(AIAssistantController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Response Length',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Colors.grey[800],
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey[300]!),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: controller.responseLengthOptions.map((option) {
              final isSelected = controller.selectedResponseLength.value == option;
              return Expanded(
                child: GestureDetector(
                  onTap: () => controller.selectedResponseLength.value = option,
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    decoration: BoxDecoration(
                      color: isSelected ? AppColors.primary : Colors.transparent,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      option,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: isSelected ? Colors.white : Colors.grey[700],
                        fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildActionButtons(AIAssistantController controller,context) {
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
              onPressed: controller.isSaving.value ? null : controller.saveAIAssistant,
              child: controller.isSaving.value
                  ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
                  : const Text(
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
              onPressed:  () {
                // Navigate to AITestingScreen
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => AITestingScreen()),
                );
              },
              icon:
                   const Icon(
                Icons.smart_toy,
                color: Colors.white,
                size: 20,
              ),
              label: Text(
                'Test AI',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
            )
            ,
          ),
        ),
      ],
    );
  }
}
