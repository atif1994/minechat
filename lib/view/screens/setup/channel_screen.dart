

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:minechat/core/utils/helpers/app_spacing/app_spacing.dart';
import 'package:minechat/core/utils/helpers/app_styles/app_text_styles.dart';
import 'package:minechat/core/utils/helpers/app_responsive/app_responsive.dart';
import 'package:minechat/core/constants/app_colors/app_colors.dart';
import 'package:minechat/controller/channel_controller/channel_controller.dart';
import 'package:minechat/controller/theme_controller/theme_controller.dart';

// Import channel widgets
import 'package:minechat/core/widgets/channels/index.dart';

class ChannelsScreen extends StatelessWidget {
  const ChannelsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final channelController = Get.find<ChannelController>();
    final themeController = Get.find<ThemeController>();
    final isDark = themeController.isDarkMode;

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AppSpacing.vertical(context, 0.01),

          // Header
          _buildHeader(context),
          AppSpacing.vertical(context, 0.01),

          // Channel Selector
          _buildChannelSelector(context, channelController),
          AppSpacing.vertical(context, 0.03),

          // Channel-specific content
          _buildChannelContent(context, channelController),
          AppSpacing.vertical(context, 0.04),

          // Action Buttons
          _buildActionButtons(context, channelController, isDark),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Row(
      children: [
        Text(
          'Channels',
          style: AppTextStyles.bodyText(context).copyWith(
              fontSize: AppResponsive.scaleSize(context, 16),
              fontWeight: FontWeight.w600),
        ),
        AppSpacing.horizontal(context, 0.01),
        GestureDetector(
          onTap: () {
            Get.snackbar('Info', 'Tutorial video will open here');
          },
          child: Text(
            '(watch tutorial video)',
            style: TextStyle(
                color: Color(0XFF1677FF),
                fontSize: 14,
                decoration: TextDecoration.underline,
                decorationColor: Color(0XFF1677FF)),
          ),
        ),
      ],
    );
  }

  Widget _buildChannelSelector(BuildContext context, ChannelController controller) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Select Channel Type',
            style: AppTextStyles.bodyText(context).copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          AppSpacing.vertical(context, 0.01),

          // Channel Dropdown
          Obx(() => DropdownButtonFormField<String>(
            value: controller.selectedChannel.value,
            decoration: InputDecoration(
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            ),
            items: controller.availableChannels.map((channel) {
              return DropdownMenuItem<String>(
                value: channel['name'],
                child: Row(
                  children: [
                    Text(channel['icon']),
                    SizedBox(width: 8),
                    Text(channel['name']),
                    if (channel['isConnected'] == true)
                      Container(
                        margin: EdgeInsets.only(left: 8),
                        padding: EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.green,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          'Connected',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                  ],
                ),
              );
            }).toList(),
            onChanged: (value) {
              if (value != null) {
                controller.selectedChannel.value = value;
              }
            },
          )),
        ],
      ),
    );
  }

  Widget _buildChannelContent(BuildContext context, ChannelController controller) {
    return Obx(() {
      final selectedChannel = controller.selectedChannel.value;

      switch (selectedChannel) {
        case 'Website':
          return WebsiteChannelWidget(controller: controller);
        case 'Messenger':
          return MessengerChannelWidget(controller: controller);
        case 'Instagram':
          return InstagramChannelWidget();
        case 'WhatsApp':
          return WhatsAppChannelWidget();
        case 'Telegram':
          return TelegramChannelWidget();
        default:
          return _buildDefaultChannel(context);
      }
    });
  }

  Widget _buildDefaultChannel(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Channel Configuration',
            style: AppTextStyles.bodyText(context).copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          AppSpacing.vertical(context, 0.01),
          Text('Please select a channel type to configure.'),
        ],
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context, ChannelController controller, bool isDark) {
    return Row(
      children: [
        // Cancel Button
        Expanded(
          child: Container(
            height: 48,
            decoration: BoxDecoration(
              border: Border.all(
                  color: isDark
                      ? Color(0XFFFFFFFF).withValues(alpha: 0.12)
                      : Color(0XFFEBEDF0)),
              borderRadius: BorderRadius.circular(12),
            ),
            child: TextButton(
              onPressed: () {
                controller.loadChannelSettings();
                Get.snackbar(
                  'Cancelled',
                  'Changes have been cancelled',
                  backgroundColor: Colors.orange,
                  colorText: Colors.white,
                );
              },
              style: TextButton.styleFrom(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Text(
                'Cancel',
                style: TextStyle(
                  color: isDark ? AppColors.white : AppColors.black,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),

        // Save Changes Button
        Expanded(
          child: Container(
            height: 48,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
            ),
            child: Obx(() => TextButton(
              onPressed: controller.isLoading.value
                  ? null
                  : controller.saveChannelSettings,
              style: TextButton.styleFrom(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: controller.isLoading.value
                  ? const CircularProgressIndicator()
                  : Text(
                'Save Changes',
                style: TextStyle(
                  color: AppColors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
            )),
          ),
        ),
      ],
    );
  }
}
