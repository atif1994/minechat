import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:minechat/core/utils/helpers/app_spacing/app_spacing.dart';
import 'package:minechat/core/utils/helpers/app_styles/app_text_styles.dart';
import 'package:minechat/core/constants/app_colors/app_colors.dart';
import 'package:minechat/controller/channel_controller/channel_controller.dart';

class WebsiteChannelWidget extends StatelessWidget {
  final ChannelController controller;

  const WebsiteChannelWidget({
    super.key,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
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
            'Website Channel Setup',
            style: AppTextStyles.bodyText(context).copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          AppSpacing.vertical(context, 0.02),
          
          // Website Input
          TextField(
            controller: controller.websiteUrlCtrl,
            decoration: InputDecoration(
              labelText: 'Website',
              hintText: 'https://www.yourwebsite.com',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
          AppSpacing.vertical(context, 0.02),
          
          // AI Chat Widget Color
          Text(
            'AI Chat Widget Color',
            style: AppTextStyles.bodyText(context).copyWith(
              fontWeight: FontWeight.w500,
            ),
          ),
          AppSpacing.vertical(context, 0.01),
          _buildColorPicker(context),
          AppSpacing.vertical(context, 0.02),
          
          // Website Code Generator
          _buildCodeGeneratorSection(context),
          AppSpacing.vertical(context, 0.02),
          
          // Action Buttons
          _buildActionButtons(context),
        ],
      ),
    );
  }

  Widget _buildColorPicker(BuildContext context) {
    final colors = [
      Colors.red,
      Colors.orange,
      Colors.red[800]!,
      Colors.blue,
      Colors.green,
      Colors.purple,
      Colors.lightBlue,
      Colors.blue[600]!,
    ];
    
    return Wrap(
      spacing: 8,
      children: colors.map((color) {
        return GestureDetector(
          onTap: () {
            Get.snackbar('Info', 'Color selection will be implemented');
          },
          child: Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: Colors.grey[400]!,
                width: 2,
              ),
            ),
            child: Icon(
              Icons.check,
              color: Colors.white,
              size: 20,
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildCodeGeneratorSection(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Get your website to chat assistant widget',
            style: AppTextStyles.bodyText(context).copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          AppSpacing.vertical(context, 0.01),
          Text(
            'Tap Generate, copy the code, and send to your web master or developer.',
            style: TextStyle(color: Colors.grey[600]),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton(
            onPressed: () {
              Get.snackbar('Info', 'Copy functionality will be implemented');
            },
            child: Text('Copy'),
          ),
        ),
        SizedBox(width: 12),
        Expanded(
          child: ElevatedButton(
            onPressed: () {
              Get.snackbar('Info', 'Generate functionality will be implemented');
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
            ),
            child: Text('Generate'),
          ),
        ),
      ],
    );
  }
}
