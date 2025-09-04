import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:minechat/core/utils/helpers/app_spacing/app_spacing.dart';
import 'package:minechat/core/utils/helpers/app_styles/app_text_styles.dart';
import 'package:minechat/core/constants/app_colors/app_colors.dart';

class InstagramChannelWidget extends StatelessWidget {
  const InstagramChannelWidget({super.key});

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
            'Instagram Channel Setup',
            style: AppTextStyles.bodyText(context).copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          AppSpacing.vertical(context, 0.02),
          
          Text(
            'Connect Your Instagram Business Chat',
            style: TextStyle(
              fontWeight: FontWeight.w600,
              color: Colors.orange[800],
            ),
          ),
          AppSpacing.vertical(context, 0.01),
          
          Text(
            'Please make sure you are logged in on the Instagram page you want to connect with.',
            style: TextStyle(color: Colors.grey[600]),
          ),
          AppSpacing.vertical(context, 0.02),
          
          // Action Buttons
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: null,
                  child: Text('Disconnect'),
                ),
              ),
              SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    Get.snackbar('Info', 'Instagram connection will be implemented');
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                  ),
                  child: Text('Connect Instagram'),
                ),
              ),
            ],
          ),
          AppSpacing.vertical(context, 0.02),
          
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: null,
                  child: Text('Disconnect'),
                ),
              ),
              SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  onPressed: null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange,
                    foregroundColor: Colors.white,
                  ),
                  child: Text('Pause Instagram AI'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
