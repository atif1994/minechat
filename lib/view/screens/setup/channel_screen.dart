import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:minechat/core/utils/helpers/app_spacing/app_spacing.dart';
import 'package:minechat/core/utils/helpers/app_styles/app_text_styles.dart';
import 'package:minechat/core/utils/helpers/app_responsive/app_responsive.dart';
import 'package:minechat/controller/channel_controller/channel_controller.dart';
import 'package:minechat/controller/theme_controller/theme_controller.dart';
import 'package:minechat/core/widgets/app_button/app_large_button.dart';
import 'package:minechat/core/widgets/channels/index.dart';
import 'package:minechat/core/constants/app_assets/app_assets.dart';

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

          // Debug Button (temporary)
          // _buildDebugButton(context, channelController),
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

  Widget _buildChannelSelector(
      BuildContext context, ChannelController controller) {
    return Column(
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
                contentPadding:
                    EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              ),
              items: controller.availableChannels.map((channel) {
                final isDark = Get.find<ThemeController>().isDarkMode;
                final iconPath = AppAssets.getSocialIcon(channel['icon'], isDark);
                
                return DropdownMenuItem<String>(
                  value: channel['name'],
                  child: Row(
                    children: [
                      SvgPicture.asset(
                        iconPath,
                        height: 20,
                        width: 20,
                      ),
                      SizedBox(width: 8),
                      Text(channel['name']),
                      if (channel['isConnected'] == true)
                        Container(
                          margin: EdgeInsets.only(left: 8),
                          padding:
                              EdgeInsets.symmetric(horizontal: 8, vertical: 2),
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
    );
  }

  Widget _buildChannelContent(
      BuildContext context, ChannelController controller) {
    return Obx(() {
      final selectedChannel = controller.selectedChannel.value;

      switch (selectedChannel) {
        case 'Messenger':
          return _buildMessengerSection(context, controller);
        // return MessengerChannelWidget(controller: controller);
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

  Widget _buildActionButtons(
      BuildContext context, ChannelController controller, bool isDark) {
    return Row(
      children: [
        // Cancel Button
        Expanded(
          child: AppLargeButton(
            borderColor: isDark
                ? Color(0XFFFFFFFF).withValues(alpha: 0.12)
                : Color(0XFFEBEDF0),
            useGradient: false,
            solidColor: isDark ? Color(0XFF1D1D1D) : Color(0XFFFFFFFF),
            textColor: isDark ? Color(0XFFFFFFFF) : Color(0XFF1D1D1D),
            label: 'Cancel',
            onTap: () {
              controller.loadChannelSettings();
              Get.snackbar(
                'Cancelled',
                'Changes have been cancelled',
                backgroundColor: Colors.orange,
                colorText: Colors.white,
              );
            },
          ),
        ),
        const SizedBox(width: 12),

        // Save Changes Button
        Expanded(
          child: Obx(
            () => AppLargeButton(
              label: 'Save Changes',
              onTap: controller.isLoading.value
                  ? null
                  : controller.saveChannelSettings,
              isLoading: controller.isLoading.value,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMessengerSection(BuildContext context, ChannelController c) {
    final themeController = Get.find<ThemeController>();
    final isDark = themeController.isDarkMode;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Heading
        Text(
          'Connect Your Facebook Business Chat',
          style: AppTextStyles.bodyText(context)
              .copyWith(fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 12),

        // Info panel
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF0F1115) : const Color(0xFFF5F7FF),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
                color: isDark ? Colors.white12 : const Color(0xFFE6EBFF)),
          ),
          child: const Text(
            'Please make sure you are logged in on the Facebook page you wish to connect with.',
            style: TextStyle(fontSize: 13),
          ),
        ),
        const SizedBox(height: 16),

        // Row 1: Disconnect + Connect Facebook
        Row(
          children: [
            Expanded(
                child: AppLargeButton(
                    borderColor: isDark
                        ? Color(0XFFFFFFFF).withValues(alpha: 0.12)
                        : Color(0XFFEBEDF0),
                    useGradient: false,
                    solidColor: isDark ? Color(0XFF1D1D1D) : Color(0XFFFFFFFF),
                    textColor: isDark ? Color(0XFFFFFFFF) : Color(0XFF1D1D1D),
                    label: 'Disconnect',
                    onTap: () => c.disconnectFacebook())),
            const SizedBox(width: 12),
            Expanded(
              child: Obx(() => AppLargeButton(
                    label: c.isConnectingFacebook.value
                        ? 'Connecting...'
                        : (c.isFacebookConnected.value
                            ? 'Connected'
                            : 'Connect Facebook'),
                    onTap: (c.isConnectingFacebook.value ||
                            c.isFacebookConnected.value)
                        ? null
                        : () async {
                            await c.connectFacebook(); // backend stays the same
                          },
                  )),
            ),
          ],
        ),
        const SizedBox(height: 12),

        // Row 2: Disconnect + Pause Facebook AI
        Row(
          children: [
            Expanded(
                child: AppLargeButton(
                    borderColor: isDark
                        ? Color(0XFFFFFFFF).withValues(alpha: 0.12)
                        : Color(0XFFEBEDF0),
                    useGradient: false,
                    solidColor: isDark ? Color(0XFF1D1D1D) : Color(0XFFFFFFFF),
                    textColor: isDark ? Color(0XFFFFFFFF) : Color(0XFF1D1D1D),
                    label: 'Disconnect',
                    onTap: () => c.disconnectFacebook())),
            const SizedBox(width: 12),
            Expanded(
              child: Obx(() => AppLargeButton(
                    label: c.isFacebookAIPaused.value
                        ? 'Resume Facebook AI'
                        : 'Pause Facebook AI',
                    onTap: c.toggleFacebookAI,
                  )),
            ),
          ],
        ),
      ],
    );
  }
}
