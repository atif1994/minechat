import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:minechat/controller/channel_controller/channel_controller.dart';
import 'package:minechat/core/constants/app_colors/app_colors.dart';
import 'package:minechat/core/utils/helpers/app_spacing/app_spacing.dart';
import 'package:minechat/core/utils/helpers/app_styles/app_text_styles.dart';
import 'package:minechat/core/widgets/signUp/signUp_textfield.dart';

class ChannelsScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final channelController = Get.find<ChannelController>();
    
    // Safety check to ensure controller is properly initialized
    if (!Get.isRegistered<ChannelController>()) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }
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
          _buildChannelSelector(context, channelController),
          AppSpacing.vertical(context, 0.03),

          // Channel-specific content
          Obx(() => _buildChannelContent(context, channelController)),
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

  Widget _buildChannelSelector(BuildContext context, ChannelController channelController) {
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
                   _getChannelIcon(channelController.selectedChannel.value, channelController),
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

  String _getChannelIcon(String channelName, ChannelController channelController) {
    final channel = channelController.availableChannels.firstWhere(
      (c) => c['name'] == channelName,
      orElse: () => channelController.availableChannels.first,
    );
    return channel['icon'];
  }

  Widget _buildChannelContent(BuildContext context, ChannelController channelController) {
    switch (channelController.selectedChannel.value) {
      case 'Website':
        return _buildWebsiteChannel(context, channelController);
      case 'Messenger':
        return _buildMessengerChannel(context, channelController);
      case 'Instagram':
        return _buildInstagramChannel(context, channelController);
      case 'Telegram':
        return _buildTelegramChannel(context, channelController);
      case 'WhatsApp':
        return _buildWhatsAppChannel(context, channelController);
      case 'Slack':
        return _buildSlackChannel(context, channelController);
      case 'Viber':
        return _buildViberChannel(context, channelController);
      case 'Discord':
        return _buildDiscordChannel(context, channelController);
      default:
        return _buildComingSoonChannel(context, channelController);
    }
  }

  Widget _buildWebsiteChannel(BuildContext context, ChannelController channelController) {
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

  Widget _buildMessengerChannel(BuildContext context, ChannelController channelController) {
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
          'Choose your preferred connection method below. We recommend using the Quick Connect option for the fastest setup.',
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey[600],
          ),
        ),
        AppSpacing.vertical(context, 0.02),

        // Quick Connect Section (Most Prominent)
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.green[50],
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.green[200]!),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.rocket_launch, color: Colors.green[700], size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      '🚀 Quick Connect (Recommended)',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.green[700],
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                'Connect instantly using your provided Facebook credentials. Just enter your Page ID and click connect.',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.green[600],
                ),
              ),
              const SizedBox(height: 12),
              
              // Facebook Page ID input for Quick Connect
              SignupTextField(
                label: 'Facebook Page ID',
                hintText: 'Enter your Facebook Page ID (e.g., 313808701826338)',
                prefixIcon: '📄',
                controller: channelController.facebookPageIdCtrl,
              ),
              const SizedBox(height: 8),
              
              Text(
                '💡 How to find your Page ID:\n1. Go to your Facebook Page\n2. Click "About" in the left sidebar\n3. Scroll down to find "Page ID"',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.green[600],
                  fontStyle: FontStyle.italic,
                ),
              ),
              const SizedBox(height: 12),
              
              // Quick Connect Button
              SizedBox(
                width: double.infinity,
                child: Obx(() => TextButton(
                  onPressed: channelController.isConnectingFacebook.value
                      ? null
                      : () => channelController.connectWithProvidedToken(),
                  style: TextButton.styleFrom(
                    backgroundColor: Colors.green[600],
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: Text(
                    channelController.isConnectingFacebook.value
                        ? 'Connecting...'
                        : '🚀 Quick Connect Now',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                )),
              ),
            ],
          ),
        ),
        AppSpacing.vertical(context, 0.02),

        // OAuth-based connection (Alternative)
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.blue[50],
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.blue[200]!),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.link, color: Colors.blue[700], size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      '🔗 OAuth Connection (Alternative)',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.blue[700],
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                'Connect via Facebook OAuth for a more secure setup. This will open Facebook in your browser.',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.blue[600],
                ),
              ),
              const SizedBox(height: 12),
              
              SizedBox(
                width: double.infinity,
                child: Obx(() => TextButton(
                  onPressed: channelController.isConnectingFacebook.value
                      ? null
                      : () => channelController.connectFacebook(),
                  style: TextButton.styleFrom(
                    backgroundColor: Colors.blue[600],
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: Text(
                    channelController.isOAuthInProgress.value
                        ? 'Starting OAuth...'
                        : channelController.isConnectingFacebook.value
                            ? 'Connecting...'
                            : '🔗 Connect with OAuth',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                )),
              ),
            ],
          ),
        ),
        AppSpacing.vertical(context, 0.02),

        // Page Selector (shown after OAuth)
        Obx(() => channelController.showPageSelector.value
          ? Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.blue[50],
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.blue[200]!),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Select Your Facebook Page',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.blue[700],
                    ),
                  ),
                  const SizedBox(height: 12),
                  
                  // Available pages list
                  ...channelController.availablePages.map((page) {
                    final isSelected = channelController.selectedPageId.value == page['id'];
                    return GestureDetector(
                      onTap: () => channelController.selectedPageId.value = page['id'],
                      child: Container(
                        margin: const EdgeInsets.only(bottom: 8),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: isSelected ? Colors.blue[100] : Colors.white,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: isSelected ? Colors.blue[300]! : Colors.grey[300]!,
                          ),
                        ),
                        child: Row(
                          children: [
                            // Page picture
                            Container(
                              width: 40,
                              height: 40,
                              decoration: BoxDecoration(
                                color: Colors.grey[200],
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: page['picture']?['data']?['url'] != null
                                ? ClipRRect(
                                    borderRadius: BorderRadius.circular(20),
                                    child: Image.network(
                                      page['picture']['data']['url'],
                                      fit: BoxFit.cover,
                                      errorBuilder: (context, error, stackTrace) {
                                        return Icon(Icons.facebook, color: Colors.grey[600]);
                                      },
                                    ),
                                  )
                                : Icon(Icons.facebook, color: Colors.grey[600]),
                            ),
                            const SizedBox(width: 12),
                            
                            // Page info
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    page['name'] ?? 'Unknown Page',
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.grey[800],
                                    ),
                                  ),
                                  Text(
                                    'Page ID: ${page['id']}',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey[600],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            
                            // Selection indicator
                            if (isSelected)
                              Icon(Icons.check_circle, color: Colors.blue[600], size: 20),
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                  
                  const SizedBox(height: 12),
                  
                  // Connect button
                  SizedBox(
                    width: double.infinity,
                    child: Obx(() => TextButton(
                      onPressed: channelController.selectedPageId.value.isNotEmpty
                          ? () => channelController.connectSelectedPage()
                          : null,
                      style: TextButton.styleFrom(
                        backgroundColor: Colors.blue[600],
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: Text(
                        channelController.isConnectingFacebook.value
                            ? 'Connecting...'
                            : 'Connect Selected Page',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    )),
                  ),
                ],
              ),
            )
          : const SizedBox.shrink()),
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
        AppSpacing.vertical(context, 0.01),
        
        // Debug and Status buttons
        Row(
          children: [
            Expanded(
              child: TextButton(
                onPressed: () => channelController.checkFacebookStatus(),
                style: TextButton.styleFrom(
                  backgroundColor: Colors.blue[50],
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                    side: BorderSide(color: Colors.blue[200]!),
                  ),
                ),
                child: Text(
                  'Check Status',
                  style: TextStyle(
                    color: Colors.blue[700],
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: TextButton(
                onPressed: () => channelController.debugFacebookConnection(),
                style: TextButton.styleFrom(
                  backgroundColor: Colors.orange[50],
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                    side: BorderSide(color: Colors.orange[200]!),
                  ),
                ),
                child: Text(
                  '🔍 Debug',
                  style: TextStyle(
                    color: Colors.orange[700],
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildInstagramChannel(BuildContext context, ChannelController channelController) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Connect Your Instagram Business Account',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.grey[800],
          ),
        ),
        AppSpacing.vertical(context, 0.01),
        
        Text(
          'Connect your Instagram Business account to receive and respond to direct messages.',
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey[600],
          ),
        ),
        AppSpacing.vertical(context, 0.02),

        // Instagram Business ID input
        SignupTextField(
          label: 'Instagram Business ID',
          hintText: 'Enter your Instagram Business ID',
          prefixIcon: '📷',
          controller: channelController.instagramBusinessIdCtrl,
        ),
        AppSpacing.vertical(context, 0.01),
        
        Text(
          '💡 Note: Instagram uses the same Facebook Access Token as Messenger',
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
            color: channelController.isInstagramConnected.value
                ? Colors.pink[50]
                : Colors.grey[100],
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: channelController.isInstagramConnected.value
                  ? Colors.pink[300]!
                  : Colors.grey[300]!,
            ),
          ),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  channelController.isInstagramConnected.value
                      ? Icons.check_circle
                      : Icons.camera_alt,
                  color: channelController.isInstagramConnected.value
                      ? Colors.pink
                      : Colors.grey[600],
                  size: 32,
                ),
                const SizedBox(height: 8),
                Text(
                  channelController.isInstagramConnected.value
                      ? 'Instagram Connected'
                      : 'Not Connected',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: channelController.isInstagramConnected.value
                        ? Colors.pink[700]
                        : Colors.grey[600],
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
                onPressed: channelController.isConnectingInstagram.value
                    ? null
                    : () => channelController.disconnectInstagram(),
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
                onPressed: channelController.isConnectingInstagram.value
                    ? null
                    : () => channelController.connectInstagram(),
                style: TextButton.styleFrom(
                  backgroundColor: Colors.pink,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: Text(
                  channelController.isConnectingInstagram.value
                      ? 'Connecting...'
                      : 'Connect Instagram',
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
                onPressed: () => channelController.disconnectInstagram(),
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
                onPressed: () => channelController.toggleInstagramAI(),
                style: TextButton.styleFrom(
                  backgroundColor: channelController.isInstagramAIPaused.value
                      ? Colors.orange
                      : Colors.pink,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: Text(
                  channelController.isInstagramAIPaused.value
                      ? 'Resume Instagram AI'
                      : 'Pause Instagram AI',
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

  Widget _buildTelegramChannel(BuildContext context, ChannelController channelController) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Connect Your Telegram Bot',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.grey[800],
          ),
        ),
        AppSpacing.vertical(context, 0.01),
        
        Text(
          'Create a Telegram bot with @BotFather and connect it here to receive messages.',
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey[600],
          ),
        ),
        AppSpacing.vertical(context, 0.02),

        // Bot Token input
        SignupTextField(
          label: 'Bot Token',
          hintText: 'Enter your Telegram bot token',
          prefixIcon: '🔑',
          controller: channelController.telegramBotTokenCtrl,
        ),
        AppSpacing.vertical(context, 0.02),

        // Bot Username input
        SignupTextField(
          label: 'Bot Username',
          hintText: '@your_bot_username',
          prefixIcon: '👤',
          controller: channelController.telegramBotUsernameCtrl,
        ),
        AppSpacing.vertical(context, 0.01),
        
        Text(
          '💡 How to create a bot:\n1. Message @BotFather on Telegram\n2. Send /newbot command\n3. Follow the instructions\n4. Copy the bot token and username',
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
            color: channelController.isTelegramConnected.value
                ? Colors.blue[50]
                : Colors.grey[100],
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: channelController.isTelegramConnected.value
                  ? Colors.blue[300]!
                  : Colors.grey[300]!,
            ),
          ),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  channelController.isTelegramConnected.value
                      ? Icons.check_circle
                      : Icons.send,
                  color: channelController.isTelegramConnected.value
                      ? Colors.blue
                      : Colors.grey[600],
                  size: 32,
                ),
                const SizedBox(height: 8),
                Text(
                  channelController.isTelegramConnected.value
                      ? 'Telegram Connected'
                      : 'Not Connected',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: channelController.isTelegramConnected.value
                        ? Colors.blue[700]
                        : Colors.grey[600],
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
                onPressed: channelController.isConnectingTelegram.value
                    ? null
                    : () => channelController.disconnectTelegram(),
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
                onPressed: channelController.isConnectingTelegram.value
                    ? null
                    : () => channelController.connectTelegram(),
                style: TextButton.styleFrom(
                  backgroundColor: Colors.blue,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: Text(
                  channelController.isConnectingTelegram.value
                      ? 'Connecting...'
                      : 'Connect Telegram',
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
                onPressed: () => channelController.disconnectTelegram(),
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
                onPressed: () => channelController.toggleTelegramAI(),
                style: TextButton.styleFrom(
                  backgroundColor: channelController.isTelegramAIPaused.value
                      ? Colors.orange
                      : Colors.blue,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: Text(
                  channelController.isTelegramAIPaused.value
                      ? 'Resume Telegram AI'
                      : 'Pause Telegram AI',
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

  Widget _buildWhatsAppChannel(BuildContext context, ChannelController channelController) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Connect Your WhatsApp Business',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.grey[800],
          ),
        ),
        AppSpacing.vertical(context, 0.01),
        
        Text(
          'Connect your WhatsApp Business account to receive and respond to messages.',
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey[600],
          ),
        ),
        AppSpacing.vertical(context, 0.02),

        // Phone Number input
        SignupTextField(
          label: 'Phone Number',
          hintText: '+1234567890',
          prefixIcon: '📞',
          controller: channelController.whatsAppPhoneNumberCtrl,
        ),
        AppSpacing.vertical(context, 0.02),

        // Access Token input
        SignupTextField(
          label: 'Access Token',
          hintText: 'Enter your WhatsApp Business API token',
          prefixIcon: '🔑',
          controller: channelController.whatsAppAccessTokenCtrl,
        ),
        AppSpacing.vertical(context, 0.01),
        
        Text(
          '💡 You need a WhatsApp Business API account. Consider using Twilio or 360dialog for testing.',
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
            color: channelController.isWhatsAppConnected.value
                ? Colors.green[50]
                : Colors.grey[100],
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: channelController.isWhatsAppConnected.value
                  ? Colors.green[300]!
                  : Colors.grey[300]!,
            ),
          ),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  channelController.isWhatsAppConnected.value
                      ? Icons.check_circle
                      : Icons.phone,
                  color: channelController.isWhatsAppConnected.value
                      ? Colors.green
                      : Colors.grey[600],
                  size: 32,
                ),
                const SizedBox(height: 8),
                Text(
                  channelController.isWhatsAppConnected.value
                      ? 'WhatsApp Connected'
                      : 'Not Connected',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: channelController.isWhatsAppConnected.value
                        ? Colors.green[700]
                        : Colors.grey[600],
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
                onPressed: channelController.isConnectingWhatsApp.value
                    ? null
                    : () => channelController.disconnectWhatsApp(),
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
                onPressed: channelController.isConnectingWhatsApp.value
                    ? null
                    : () => channelController.connectWhatsApp(),
                style: TextButton.styleFrom(
                  backgroundColor: Colors.green,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: Text(
                  channelController.isConnectingWhatsApp.value
                      ? 'Connecting...'
                      : 'Connect WhatsApp',
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
                onPressed: () => channelController.disconnectWhatsApp(),
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
                onPressed: () => channelController.toggleWhatsAppAI(),
                style: TextButton.styleFrom(
                  backgroundColor: channelController.isWhatsAppAIPaused.value
                      ? Colors.orange
                      : Colors.green,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: Text(
                  channelController.isWhatsAppAIPaused.value
                      ? 'Resume WhatsApp AI'
                      : 'Pause WhatsApp AI',
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

  Widget _buildSlackChannel(BuildContext context, ChannelController channelController) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Connect Your Slack Workspace',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.grey[800],
          ),
        ),
        AppSpacing.vertical(context, 0.01),
        
        Text(
          'Create a Slack app and connect it to your workspace to receive messages.',
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey[600],
          ),
        ),
        AppSpacing.vertical(context, 0.02),

        // Bot Token input
        SignupTextField(
          label: 'Bot Token',
          hintText: 'xoxb-your-bot-token',
          prefixIcon: '🔑',
          controller: channelController.slackBotTokenCtrl,
        ),
        AppSpacing.vertical(context, 0.02),

        // App Token input
        SignupTextField(
          label: 'App Token',
          hintText: 'xapp-your-app-token',
          prefixIcon: '🔧',
          controller: channelController.slackAppTokenCtrl,
        ),
        AppSpacing.vertical(context, 0.01),
        
        Text(
          '💡 How to create a Slack app:\n1. Go to api.slack.com/apps\n2. Click "Create New App"\n3. Add bot token and app token scopes\n4. Install app to workspace',
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
            color: channelController.isSlackConnected.value
                ? Colors.purple[50]
                : Colors.grey[100],
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: channelController.isSlackConnected.value
                  ? Colors.purple[300]!
                  : Colors.grey[300]!,
            ),
          ),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  channelController.isSlackConnected.value
                      ? Icons.check_circle
                      : Icons.work,
                  color: channelController.isSlackConnected.value
                      ? Colors.purple
                      : Colors.grey[600],
                  size: 32,
                ),
                const SizedBox(height: 8),
                Text(
                  channelController.isSlackConnected.value
                      ? 'Slack Connected'
                      : 'Not Connected',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: channelController.isSlackConnected.value
                        ? Colors.purple[700]
                        : Colors.grey[600],
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
                onPressed: channelController.isConnectingSlack.value
                    ? null
                    : () => channelController.disconnectSlack(),
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
                onPressed: channelController.isConnectingSlack.value
                    ? null
                    : () => channelController.connectSlack(),
                style: TextButton.styleFrom(
                  backgroundColor: Colors.purple,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: Text(
                  channelController.isConnectingSlack.value
                      ? 'Connecting...'
                      : 'Connect Slack',
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
                onPressed: () => channelController.disconnectSlack(),
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
                onPressed: () => channelController.toggleSlackAI(),
                style: TextButton.styleFrom(
                  backgroundColor: channelController.isSlackAIPaused.value
                      ? Colors.orange
                      : Colors.purple,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: Text(
                  channelController.isSlackAIPaused.value
                      ? 'Resume Slack AI'
                      : 'Pause Slack AI',
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

  Widget _buildViberChannel(BuildContext context, ChannelController channelController) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Connect Your Viber Bot',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.grey[800],
          ),
        ),
        AppSpacing.vertical(context, 0.01),
        
        Text(
          'Create a Viber bot and connect it here to receive messages.',
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey[600],
          ),
        ),
        AppSpacing.vertical(context, 0.02),

        // Bot Token input
        SignupTextField(
          label: 'Bot Token',
          hintText: 'Enter your Viber bot token',
          prefixIcon: '🔑',
          controller: channelController.viberBotTokenCtrl,
        ),
        AppSpacing.vertical(context, 0.02),

        // Bot Name input
        SignupTextField(
          label: 'Bot Name',
          hintText: 'Enter your Viber bot name',
          prefixIcon: '👤',
          controller: channelController.viberBotNameCtrl,
        ),
        AppSpacing.vertical(context, 0.01),
        
        Text(
          '💡 How to create a Viber bot:\n1. Go to developers.viber.com\n2. Create a new bot\n3. Get the bot token and name\n4. Set up webhook URL',
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
            color: channelController.isViberConnected.value
                ? Colors.purple[50]
                : Colors.grey[100],
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: channelController.isViberConnected.value
                  ? Colors.purple[300]!
                  : Colors.grey[300]!,
            ),
          ),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  channelController.isViberConnected.value
                      ? Icons.check_circle
                      : Icons.chat_bubble,
                  color: channelController.isViberConnected.value
                      ? Colors.purple
                      : Colors.grey[600],
                  size: 32,
                ),
                const SizedBox(height: 8),
                Text(
                  channelController.isViberConnected.value
                      ? 'Viber Connected'
                      : 'Not Connected',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: channelController.isViberConnected.value
                        ? Colors.purple[700]
                        : Colors.grey[600],
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
                onPressed: channelController.isConnectingViber.value
                    ? null
                    : () => channelController.disconnectViber(),
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
                onPressed: channelController.isConnectingViber.value
                    ? null
                    : () => channelController.connectViber(),
                style: TextButton.styleFrom(
                  backgroundColor: Colors.purple,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: Text(
                  channelController.isConnectingViber.value
                      ? 'Connecting...'
                      : 'Connect Viber',
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
                onPressed: () => channelController.disconnectViber(),
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
                onPressed: () => channelController.toggleViberAI(),
                style: TextButton.styleFrom(
                  backgroundColor: channelController.isViberAIPaused.value
                      ? Colors.orange
                      : Colors.purple,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: Text(
                  channelController.isViberAIPaused.value
                      ? 'Resume Viber AI'
                      : 'Pause Viber AI',
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

  Widget _buildDiscordChannel(BuildContext context, ChannelController channelController) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Connect Your Discord Bot',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.grey[800],
          ),
        ),
        AppSpacing.vertical(context, 0.01),
        
        Text(
          'Create a Discord bot and add it to your server to receive messages.',
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey[600],
          ),
        ),
        AppSpacing.vertical(context, 0.02),

        // Bot Token input
        SignupTextField(
          label: 'Bot Token',
          hintText: 'Enter your Discord bot token',
          prefixIcon: '🔑',
          controller: channelController.discordBotTokenCtrl,
        ),
        AppSpacing.vertical(context, 0.02),

        // Client ID input
        SignupTextField(
          label: 'Client ID',
          hintText: 'Enter your Discord client ID',
          prefixIcon: '🆔',
          controller: channelController.discordClientIdCtrl,
        ),
        AppSpacing.vertical(context, 0.01),
        
        Text(
          '💡 How to create a Discord bot:\n1. Go to discord.com/developers/applications\n2. Create a new application\n3. Add a bot to your application\n4. Copy the bot token and client ID',
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
            color: channelController.isDiscordConnected.value
                ? Colors.indigo[50]
                : Colors.grey[100],
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: channelController.isDiscordConnected.value
                  ? Colors.indigo[300]!
                  : Colors.grey[300]!,
            ),
          ),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  channelController.isDiscordConnected.value
                      ? Icons.check_circle
                      : Icons.games,
                  color: channelController.isDiscordConnected.value
                      ? Colors.indigo
                      : Colors.grey[600],
                  size: 32,
                ),
                const SizedBox(height: 8),
                Text(
                  channelController.isDiscordConnected.value
                      ? 'Discord Connected'
                      : 'Not Connected',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: channelController.isDiscordConnected.value
                        ? Colors.indigo[700]
                        : Colors.grey[600],
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
                onPressed: channelController.isConnectingDiscord.value
                    ? null
                    : () => channelController.disconnectDiscord(),
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
                onPressed: channelController.isConnectingDiscord.value
                    ? null
                    : () => channelController.connectDiscord(),
                style: TextButton.styleFrom(
                  backgroundColor: Colors.indigo,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: Text(
                  channelController.isConnectingDiscord.value
                      ? 'Connecting...'
                      : 'Connect Discord',
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
                onPressed: () => channelController.disconnectDiscord(),
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
                onPressed: () => channelController.toggleDiscordAI(),
                style: TextButton.styleFrom(
                  backgroundColor: channelController.isDiscordAIPaused.value
                      ? Colors.orange
                      : Colors.indigo,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: Text(
                  channelController.isDiscordAIPaused.value
                      ? 'Resume Discord AI'
                      : 'Pause Discord AI',
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

  Widget _buildComingSoonChannel(BuildContext context, ChannelController channelController) {
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
