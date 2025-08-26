import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:minechat/controller/channel_controller/channel_controller.dart';
import 'package:minechat/core/constants/app_colors/app_colors.dart';
import 'package:minechat/core/utils/helpers/app_spacing/app_spacing.dart';
import 'package:minechat/core/utils/helpers/app_styles/app_text_styles.dart';
import 'package:minechat/core/widgets/signUp/signUp_textfield.dart';

class ChannelsScreen extends StatelessWidget {
  final channelController = Get.put(ChannelController());

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: AppSpacing.all(context, factor: 2),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Text(
            'Channels',
            style: AppTextStyles.heading(context),
          ),
          const SizedBox(height: 4),
          GestureDetector(
            onTap: () {
              // TODO: Open tutorial video
              Get.snackbar('Info', 'Tutorial video will open here');
            },
            child: Text(
              '(watch tutorial video)',
              style: TextStyle(
                color: Colors.blue[600],
                fontSize: 14,
                decoration: TextDecoration.underline,
              ),
            ),
          ),
          AppSpacing.vertical(context, 0.03),

          // Channel Selector
          _buildChannelSelector(context),
          AppSpacing.vertical(context, 0.03),

          // Channel-specific content
          Obx(() => _buildChannelContent(context)),
          AppSpacing.vertical(context, 0.04),

          // Action Buttons
          Row(
            children: [
              // Cancel Button
              Expanded(
                child: TextButton(
                  onPressed: () {
                    // Reset to original settings
                    channelController.loadChannelSettings();
                    Get.snackbar(
                      'Cancelled',
                      'Changes have been cancelled',
                      backgroundColor: Colors.orange,
                      colorText: Colors.white,
                    );
                  },
                  style: TextButton.styleFrom(
                    backgroundColor: Colors.grey[300],
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: Text(
                    'Cancel',
                    style: TextStyle(
                      color: Colors.grey[700],
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              
              // Save Changes Button
              Expanded(
                child: Obx(() => TextButton(
                  onPressed: channelController.isLoading.value
                      ? null
                      : () => channelController.saveChannelSettings(),
                  style: TextButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: Text(
                    channelController.isLoading.value
                        ? 'Saving...'
                        : 'Save Changes',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                )),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildChannelSelector(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Select Channel',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.grey[800],
          ),
        ),
        AppSpacing.vertical(context, 0.01),
        
        // Channel dropdown
        GestureDetector(
          onTap: () => channelController.toggleChannelDropdown(),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey[300]!),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                // Channel icon
                Obx(() => Text(
                  _getChannelIcon(channelController.selectedChannel.value),
                  style: TextStyle(fontSize: 20),
                )),
                const SizedBox(width: 12),
                
                // Channel name
                Expanded(
                  child: Obx(() => Text(
                    channelController.selectedChannel.value,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  )),
                ),
                
                // Dropdown arrow
                Obx(() => Icon(
                  channelController.isChannelDropdownOpen.value
                      ? Icons.keyboard_arrow_up
                      : Icons.keyboard_arrow_down,
                  color: Colors.grey[600],
                )),
              ],
            ),
          ),
        ),

        // Channel dropdown list
        Obx(() => channelController.isChannelDropdownOpen.value
          ? Container(
              margin: const EdgeInsets.only(top: 4),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey[300]!),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                children: channelController.availableChannels.map((channel) {
                  return GestureDetector(
                    onTap: () => channelController.selectChannel(channel['name']),
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      decoration: BoxDecoration(
                        color: channelController.selectedChannel.value == channel['name']
                            ? Colors.blue[50]
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          Text(
                            channel['icon'],
                            style: TextStyle(fontSize: 18),
                          ),
                          const SizedBox(width: 12),
                          Text(
                            channel['name'],
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: channelController.selectedChannel.value == channel['name']
                                  ? Colors.blue[700]
                                  : Colors.grey[800],
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ),
            )
          : const SizedBox.shrink()),
      ],
    );
  }

  String _getChannelIcon(String channelName) {
    final channel = channelController.availableChannels.firstWhere(
      (c) => c['name'] == channelName,
      orElse: () => channelController.availableChannels.first,
    );
    return channel['icon'];
  }

  Widget _buildChannelContent(BuildContext context) {
    switch (channelController.selectedChannel.value) {
      case 'Website':
        return _buildWebsiteChannel(context);
      case 'Messenger':
        return _buildMessengerChannel(context);
      default:
        return _buildComingSoonChannel(context);
    }
  }

  Widget _buildWebsiteChannel(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Website URL input
        SignupTextField(
          label: 'Website',
          hintText: 'https://www.yourwebsite.com',
          prefixIcon: '🌐',
          controller: channelController.websiteUrlCtrl,
        ),
        AppSpacing.vertical(context, 0.02),

        // Widget color selection
        Text(
          'AI Chat Widget Color',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.grey[800],
          ),
        ),
        AppSpacing.vertical(context, 0.01),
        
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: channelController.widgetColors.map((colorData) {
            return Obx(() {
              final isSelected = channelController.selectedWidgetColor.value == colorData['name'];
              return GestureDetector(
                onTap: () => channelController.selectWidgetColor(colorData['name']),
                child: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: colorData['color'],
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: isSelected ? Colors.blue : Colors.transparent,
                      width: 2,
                    ),
                  ),
                  child: isSelected
                      ? Icon(Icons.check, color: Colors.white, size: 20)
                      : null,
                ),
              );
            });
          }).toList(),
        ),
        AppSpacing.vertical(context, 0.02),

        // Code generation section
        Container(
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
                'Get your website AI chat assistant widget. Tap Generate, copy the code, and send to your web master or developer.',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[700],
                ),
              ),
              AppSpacing.vertical(context, 0.02),
              
              // Generated code display
              Obx(() => channelController.generatedCode.value.isNotEmpty
                ? Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      channelController.generatedCode.value,
                      style: TextStyle(
                        fontSize: 12,
                        fontFamily: 'monospace',
                        color: Colors.grey[800],
                      ),
                    ),
                  )
                : const SizedBox.shrink()),
              AppSpacing.vertical(context, 0.02),
              
              // Action buttons
              Row(
                children: [
                  Expanded(
                    child: Obx(() => TextButton(
                      onPressed: channelController.generatedCode.value.isNotEmpty
                          ? () => channelController.copyGeneratedCode()
                          : null,
                      style: TextButton.styleFrom(
                        backgroundColor: Colors.grey[300],
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: Text(
                        'Copy',
                        style: TextStyle(
                          color: Colors.grey[700],
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    )),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Obx(() => TextButton(
                      onPressed: channelController.isGeneratingCode.value
                          ? null
                          : () => channelController.generateWebsiteCode(),
                      style: TextButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: Text(
                        channelController.isGeneratingCode.value
                            ? 'Generating...'
                            : 'Generate',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    )),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildMessengerChannel(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Connect Your Facebook Business Chat',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.grey[800],
          ),
        ),
        AppSpacing.vertical(context, 0.01),
        
        Text(
          'Please make sure you are logged in on the Facebook page you wish to connect with.',
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey[600],
          ),
        ),
        AppSpacing.vertical(context, 0.02),

        // Facebook Page ID input
        SignupTextField(
          label: 'Facebook Page ID',
          hintText: 'Enter your Facebook Page ID (e.g., 123456789)',
          prefixIcon: '📄',
          controller: channelController.facebookPageIdCtrl,
        ),
        AppSpacing.vertical(context, 0.01),
        
        Text(
          '💡 How to find your Page ID:\n1. Go to your Facebook Page\n2. Click "About" in the left sidebar\n3. Scroll down to find "Page ID"',
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
            fontStyle: FontStyle.italic,
          ),
        ),
        AppSpacing.vertical(context, 0.02),

        // Connection status area
        Obx(() => Container(
          width: double.infinity,
          height: 120,
          decoration: BoxDecoration(
            color: channelController.isFacebookConnected.value
                ? Colors.green[50]
                : Colors.grey[100],
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: channelController.isFacebookConnected.value
                  ? Colors.green[300]!
                  : Colors.grey[300]!,
            ),
          ),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  channelController.isFacebookConnected.value
                      ? Icons.check_circle
                      : Icons.facebook,
                  color: channelController.isFacebookConnected.value
                      ? Colors.green
                      : Colors.grey[600],
                  size: 32,
                ),
                const SizedBox(height: 8),
                Text(
                  channelController.isFacebookConnected.value
                      ? 'Facebook Connected'
                      : 'Not Connected',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: channelController.isFacebookConnected.value
                        ? Colors.green[700]
                        : Colors.grey[600],
                  ),
                ),
                if (channelController.isFacebookConnected.value)
                  Text(
                    'Page ID: ${channelController.facebookPageIdCtrl.text}',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.green[600],
                    ),
                  ),
              ],
            ),
          ),
        )),
        AppSpacing.vertical(context, 0.02),

        // Action buttons
        Row(
          children: [
            Expanded(
              child: Obx(() => TextButton(
                onPressed: channelController.isConnectingFacebook.value
                    ? null
                    : () => channelController.disconnectFacebook(),
                style: TextButton.styleFrom(
                  backgroundColor: Colors.grey[300],
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: Text(
                  'Disconnect',
                  style: TextStyle(
                    color: Colors.grey[700],
                    fontWeight: FontWeight.w600,
                  ),
                ),
              )),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Obx(() => TextButton(
                onPressed: channelController.isConnectingFacebook.value
                    ? null
                    : () => channelController.connectFacebook(),
                style: TextButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: Text(
                  channelController.isConnectingFacebook.value
                      ? 'Connecting...'
                      : 'Connect Facebook',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              )),
            ),
          ],
        ),
        AppSpacing.vertical(context, 0.02),

        // AI control buttons
        Row(
          children: [
            Expanded(
              child: TextButton(
                onPressed: () => channelController.disconnectFacebook(),
                style: TextButton.styleFrom(
                  backgroundColor: Colors.grey[300],
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: Text(
                  'Disconnect',
                  style: TextStyle(
                    color: Colors.grey[700],
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Obx(() => TextButton(
                onPressed: () => channelController.toggleFacebookAI(),
                style: TextButton.styleFrom(
                  backgroundColor: channelController.isFacebookAIPaused.value
                      ? Colors.orange
                      : AppColors.primary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: Text(
                  channelController.isFacebookAIPaused.value
                      ? 'Resume Facebook AI'
                      : 'Pause Facebook AI',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              )),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildComingSoonChannel(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 200,
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.construction,
              size: 48,
              color: Colors.grey[600],
            ),
            const SizedBox(height: 16),
            Text(
              'Coming Soon',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.grey[800],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '${channelController.selectedChannel.value} integration\nwill be available soon!',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
