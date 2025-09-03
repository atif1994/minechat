import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:minechat/controller/ai_assistant_controller/ai_assistant_controller.dart';
import 'package:minechat/controller/channel_controller/channel_controller.dart';
import 'package:minechat/controller/theme_controller/theme_controller.dart';
import 'package:minechat/core/constants/app_colors/app_colors.dart';
import 'package:minechat/core/utils/helpers/app_spacing/app_spacing.dart';
import 'package:minechat/core/utils/helpers/app_styles/app_text_styles.dart';
import 'package:minechat/core/widgets/signUp/signUp_textfield.dart';
import '../../../core/utils/helpers/app_responsive/app_responsive.dart';
import '../../../core/widgets/app_button/app_save_ai_button.dart';
import 'ai_testing_screen.dart';
import 'ai_knowledge_screen.dart';
import 'channel_screen.dart';

class AIAssistantSetupScreen extends StatelessWidget {
  const AIAssistantSetupScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final themeController = Get.find<ThemeController>();
    final isDark = themeController.isDarkMode;
    final controller = Get.put(AIAssistantController());
    final channelController = Get.find<ChannelController>();
    
    // Safety check to ensure controllers are properly initialized
    if (!Get.isRegistered<ChannelController>() || !Get.isRegistered<ThemeController>()) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    final indexMap = {
      "AI Assistant": 0,
      "AI Knowledge": 1,
      "Channels": 2, // ✅ Fixed name to match breadcrumb
    };

    return Scaffold(
      backgroundColor: isDark ? Color(0XFF0A0A0A) : Color(0XFFF4F6FC),
      body: SafeArea(
        child: Padding(
          padding: AppSpacing.all(context, factor: 2),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Breadcrumb Navigation
              _buildBreadcrumbs(context, controller),

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
        ),
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
          Text(
            "Ai Persona",
            style: AppTextStyles.bodyText(context).copyWith(
                fontSize: AppResponsive.scaleSize(context, 16),
                fontWeight: FontWeight.w600),
          ),
          AppSpacing.vertical(context, 0.01),
          SignupTextField(
            label: 'Name',
            hintText: 'Enter AI assistant name',
            controller: controller.nameCtrl,
            errorText: controller.nameError,
            onChanged: controller.validateName,
          ),
          AppSpacing.vertical(context, 0.01),
          SignupTextField(
            label: 'Intro Message',
            hintText: 'Enter Intro Message',
            controller: controller.introMessageCtrl,
            errorText: controller.introMessageError,
            onChanged: controller.validateIntroMessage,
          ),
          AppSpacing.vertical(context, 0.01),
          SignupTextField(
            label: 'Short Description',
            hintText: 'Enter Description',
            controller: controller.shortDescriptionCtrl,
            errorText: controller.shortDescriptionError,
            onChanged: controller.validateShortDescription,
          ),
          AppSpacing.vertical(context, 0.01),
          _buildAIGuidelinesField(context, controller),
          AppSpacing.vertical(context, 0.01),
          _buildResponseLengthSelector(context, controller),
          AppSpacing.vertical(context, 0.02),
          // Example usage inside your widget
          TwoButtonsRow(
            isSaving: controller.isSaving,
            // your RxBool
            onSave: controller.saveAIAssistant,
            // your save function
            secondLabel: "Test AI",
            // text for second button
            secondIcon: "assets/images/icons/icon_setup_test_ai_button.svg",
            // icon for second button
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
    final themeController = Get.find<ThemeController>();
    final isDark = themeController.isDarkMode;
    TextStyle activeStyle = AppTextStyles.bodyText(context).copyWith(
      fontSize: 13,
      fontWeight: FontWeight.w600,
      color: isDark ? AppColors.white : AppColors.secondary,
    );
    TextStyle linkStyle = AppTextStyles.bodyText(context).copyWith(
      fontSize: 13,
      fontWeight: FontWeight.w400,
      color: Color(0XFF767C8C),
    );
    TextStyle inactiveStyle = AppTextStyles.bodyText(context).copyWith(
      fontSize: 13,
      fontWeight: FontWeight.w400,
      color: Color(0XFF767C8C),
    );
    TextStyle separatorStyle = AppTextStyles.bodyText(context).copyWith(
      fontSize: 13,
      color: Color(0XFFA8AEBF),
    );

    return Obx(() {
      final themeController = Get.find<ThemeController>();
      final isDark = themeController.isDarkMode;
      return Wrap(
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          Text('Setup',
              style: AppTextStyles.bodyText(context).copyWith(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: isDark ? Color(0XFFFFFFFF) : Color(0XFF222222),
              ) // Always active style since it's the main title
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
  Widget _buildAIGuidelinesField(
      BuildContext context, AIAssistantController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'AI Guidelines',
          style: AppTextStyles.bodyText(context)
              .copyWith(fontSize: 14, fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            border: Border.all(
              color: controller.aiGuidelinesError.value.isNotEmpty
                  ? AppColors.error
                  : Color(0XFFEBEDF0),
            ),
            borderRadius: BorderRadius.circular(12),
          ),
          child: TextField(
            controller: controller.aiGuidelinesCtrl,
            onChanged: controller.validateAIGuidelines,
            maxLines: 4,
            decoration: InputDecoration(
              hintText: 'Enter Guidelines',
              hintStyle: AppTextStyles.hintText(context),
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
  Widget _buildResponseLengthSelector(
      BuildContext context, AIAssistantController controller) {
    final themeController = Get.find<ThemeController>();
    final isDark = themeController.isDarkMode;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Response Length',
          style: AppTextStyles.bodyText(context)
              .copyWith(fontSize: 15, fontWeight: FontWeight.w500),
        ),
        AppSpacing.vertical(context, 0.01),
        Container(
          height: AppResponsive.screenHeight(context) * 0.065,
          width: AppResponsive.screenWidth(context) * 0.75,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: controller.responseLengthOptions.map((option) {
              final isSelected =
                  controller.selectedResponseLength.value == option;
              return Expanded(
                child: GestureDetector(
                  onTap: () => controller.selectedResponseLength.value = option,
                  child: Padding(
                    padding: AppSpacing.symmetric(context, h: 0.02, v: 0)
                        .copyWith(left: 0),
                    child: Container(
                      padding: AppSpacing.all(context, factor: 1.8),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                            color: isSelected
                                ? AppColors.primary
                                : isDark
                                    ? Color(0XFFFFFFFF).withValues(alpha: .12)
                                    : Color(0XFFEBEDF0),
                            width: 2),
                      ),
                      child: Text(
                        option,
                        textAlign: TextAlign.center,
                        style: AppTextStyles.bodyText(context).copyWith(
                            color: isSelected
                                ? AppColors.primary
                                : isDark
                                    ? Color(0XFFFFFFFF)
                                    : Color(0XFF222222),
                            fontWeight: FontWeight.w500,
                            fontSize: AppResponsive.scaleSize(context, 14)),
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
