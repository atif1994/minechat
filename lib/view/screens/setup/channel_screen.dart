

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

  final channelController = Get.put(ChannelController());

  @override
  Widget build(BuildContext context) {
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
          _buildChannelSelector(context),
          AppSpacing.vertical(context, 0.03),

          // Channel-specific conten
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

          Obx(() => _buildChannelContent(context)),
          AppSpacing.vertical(context, 0.04),

          // Action Buttons
          Row(
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
                  ).withAppGradient,
                  child: Obx(() => TextButton(
                    onPressed: channelController.isLoading.value
                        ? null
                        : () => channelController.saveChannelSettings(),
                    style: TextButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: Text(
                      channelController.isLoading.value
                          ? 'Saving...'
                          : 'Save Changes',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  )),
                ),
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
                    style: AppTextStyles.bodyText(context).copyWith(
                        fontSize: AppResponsive.scaleSize(context, 16),
                        fontWeight: FontWeight.w600),
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
                onTap: () =>
                    channelController.selectChannel(channel['name']),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: channelController.selectedChannel.value ==
                        channel['name']
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
                          color:
                          channelController.selectedChannel.value ==
                              channel['name']
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
      case 'Instagram':
        return _buildInstagramChannel(context);
      case 'Telegram':
        return _buildTelegramChannel(context);
      case 'WhatsApp':
        return _buildWhatsAppChannel(context);
      case 'Slack':
        return _buildSlackChannel(context);
      case 'Viber':
        return _buildViberChannel(context);
      case 'Discord':
        return _buildDiscordChannel(context);
      default:
        return _buildComingSoonChannel(context);
    }
  }

  Widget _buildWebsiteChannel(BuildContext context) {
    final themeController = Get.find<ThemeController>();
    final isDark = themeController.isDarkMode;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,

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

}
