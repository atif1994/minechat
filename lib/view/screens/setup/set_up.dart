import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:minechat/controller/ai_assistant_controller/ai_assistant_controller.dart';
import 'package:minechat/controller/channel_controller/channel_controller.dart';
import 'package:minechat/core/constants/app_colors/app_colors.dart';
import 'package:minechat/core/utils/helpers/app_spacing/app_spacing.dart';
import 'package:minechat/core/utils/helpers/app_styles/app_text_styles.dart';
import 'package:minechat/core/widgets/signUp/signUp_textfield.dart';
import '../../../core/constants/app_assets/app_assets.dart';
import '../../../core/utils/helpers/app_responsive/app_responsive.dart';
import '../../../core/widgets/app_button/app_save_ai_button.dart';
import 'ai_testing_screen.dart';
import 'ai_knowledge_screen.dart';
import 'channel_screen.dart';

class AIAssistantSetupScreen extends StatelessWidget {
  const AIAssistantSetupScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(AIAssistantController());
    final channelController = Get.put(ChannelController());

    final indexMap = {
      "AI Assistant": 0,
      "AI Knowledge": 1,
      "Channels": 2, // ✅ Fixed name to match breadcrumb
    };

    return Scaffold(
      backgroundColor:AppColors.g1 ,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: 40,),
          // Breadcrumb Navigation
          Padding(
            padding: const EdgeInsets.only(left: 16,right: 16,top: 16),
            child: _buildBreadcrumbs(context, controller),
          ),

          // Main content - keeps all pages alive
          Expanded(
            child: Obx(() => IndexedStack(
              index: indexMap[controller.currentStep.value] ?? 0,
              children: [
                _buildAIAssistantForm(controller, context),
                AIKnowledgeScreen(controller: controller),
                ChannelsScreen(),
              ],
            )),
          ),
        ],
      ),
    );
  }

  // ---------------------- AI Assistant Form ----------------------
  Widget _buildAIAssistantForm(
      AIAssistantController controller, BuildContext context) {
    return SingleChildScrollView(
      padding: AppSpacing.all(context, factor: 1),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("Ai Assistant",style: AppTextStyles.bodyText(context).copyWith(
              fontSize: AppResponsive.scaleSize(context, 14),
              fontWeight: FontWeight.w500),),
          AppSpacing.vertical(context, 0.01),
          SignupTextField(
            label: 'Name',
            hintText: 'Enter AI assistant name',
            prefixIcon: AppAssets.signupIconEmail,
            controller: controller.nameCtrl,
            errorText: controller.nameError,
            onChanged: controller.validateName,
          ),
          AppSpacing.vertical(context, 0.01),
          SignupTextField(
            label: 'Intro Message',
            hintText: 'Enter Intro Message',
            prefixIcon: AppAssets.signupIconEmail,
            controller: controller.introMessageCtrl,
            errorText: controller.introMessageError,
            onChanged: controller.validateIntroMessage,
          ),
          AppSpacing.vertical(context, 0.01),
          SignupTextField(
            label: 'Short Description',
            hintText: 'Enter Description',
            prefixIcon: AppAssets.signupIconEmail,
            controller: controller.shortDescriptionCtrl,
            errorText: controller.shortDescriptionError,
            onChanged: controller.validateShortDescription,
          ),
          AppSpacing.vertical(context, 0.01),
          _buildAIGuidelinesField(controller),
          AppSpacing.vertical(context, 0.01),
          _buildResponseLengthSelector(controller),
          AppSpacing.vertical(context, 0.02),
          // Example usage inside your widget
          TwoButtonsRow(
            isSaving: controller.isSaving,          // your RxBool
            onSave: controller.saveAIAssistant,     // your save function
            secondLabel: "Test AI",                 // text for second button
            secondIcon: Icons.smart_toy,            // icon for second button
            onSecondTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const AITestingScreen(),
                ),
              );
            },
          )

        ],
      ),
    );
  }

  // ---------------------- Breadcrumbs ----------------------
  Widget _buildBreadcrumbs(
      BuildContext context, AIAssistantController controller) {
    TextStyle activeStyle = TextStyle(
      fontSize: 14,
      fontWeight: FontWeight.w600,
      color: AppColors.secondary,
    );
    TextStyle linkStyle = TextStyle(
      fontSize: 14,
      fontWeight: FontWeight.w500,
      color: Colors.grey[800],
    );
    TextStyle inactiveStyle = TextStyle(
      fontSize: 12,
      fontWeight: FontWeight.normal,
      color: Colors.grey[500],
    );
    TextStyle separatorStyle = TextStyle(
      fontSize: 12,
      color: Colors.grey[400],
    );

    return Obx(() {
      return Wrap(
        children: [
          Text(
            'Setup',
            style:TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppColors.black,
            )  // Always active style since it's the main title
          ),
          Text(' > ', style: separatorStyle),
          GestureDetector(
            onTap: () => controller.currentStep.value = "AI Assistant",
            child: Text(
              'AI Assistant',
              style: controller.currentStep.value == "AI Assistant"
                  ? activeStyle
                  : linkStyle,
            ),
          ),
          Text(' > ', style: separatorStyle),
          GestureDetector(
            onTap: () => controller.currentStep.value = "AI Knowledge",
            child: Text(
              'AI Knowledge',
              style: controller.currentStep.value == "AI Knowledge"
                  ? activeStyle
                  : inactiveStyle,
            ),
          ),
          Text(' > ', style: separatorStyle),
          GestureDetector(
            onTap: () => controller.currentStep.value = "Channels",
            child: Text(
              'Channels',
              style: controller.currentStep.value == "Channels"
                  ? activeStyle
                  : inactiveStyle,
            ),
          ),
        ],
      );
    });
  }

  // ---------------------- AI Guidelines ----------------------
  Widget _buildAIGuidelinesField(AIAssistantController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'AI Guidelines',
          style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
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
            onChanged: controller.validateAIGuidelines,
            maxLines: 4,
            decoration: const InputDecoration(
              hintText: 'Enter AI guidelines...',
              border: InputBorder.none,
              contentPadding: EdgeInsets.all(16),
            ),
          ),
        ),
        if (controller.aiGuidelinesError.value.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 8, left: 16),
            child: Text(
              controller.aiGuidelinesError.value,
              style: const TextStyle(color: Colors.red, fontSize: 12),
            ),
          ),
      ],
    );
  }

  // ---------------------- Response Length ----------------------
  Widget _buildResponseLengthSelector(AIAssistantController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Response Length',
          style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey[300]!),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: controller.responseLengthOptions.map((option) {
              final isSelected =
                  controller.selectedResponseLength.value == option;
              return Expanded(
                child: GestureDetector(
                  onTap: () =>
                  controller.selectedResponseLength.value = option,
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? AppColors.primary
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      option,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: isSelected
                            ? Colors.white
                            : Colors.grey[700],
                        fontWeight: isSelected
                            ? FontWeight.w600
                            : FontWeight.normal,
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


}
