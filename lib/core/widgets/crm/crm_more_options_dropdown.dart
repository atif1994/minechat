import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:minechat/controller/crm_controller/crm_controller.dart';
import 'package:minechat/controller/theme_controller/theme_controller.dart';
import 'package:minechat/core/utils/helpers/app_responsive/app_responsive.dart';
import 'package:minechat/core/utils/helpers/app_styles/app_text_styles.dart';

class CrmMoreOptionsDropdown extends StatelessWidget {
  final CrmController crmController;
  final ThemeController themeController;

  const CrmMoreOptionsDropdown({
    super.key,
    required this.crmController,
    required this.themeController,
  });

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (!crmController.isMoreOptionsDropdownOpen.value) {
        return const SizedBox.shrink();
      }

      final isDark = themeController.isDarkMode;
      
      return Positioned(
        top: kToolbarHeight + MediaQuery.of(context).padding.top + 8,
        right: 16,
        child: Material(
          color: Colors.transparent,
          child: Container(
            width: AppResponsive.scaleSize(context, 200),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF2D2D2D) : Colors.white,
              borderRadius: BorderRadius.circular(8),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: crmController.selectedFilter.value == 'Follow-ups'
                  ? [
                      _buildOptionItem(
                        context,
                        'Send a group message',
                        () => crmController.handleMoreOptionsAction('send_group_message'),
                        isDark,
                      ),
                      _buildOptionItem(
                        context,
                        'Create a group',
                        () => crmController.handleMoreOptionsAction('create_group'),
                        isDark,
                      ),
                      _buildOptionItem(
                        context,
                        'Add to a group',
                        () => crmController.handleMoreOptionsAction('add_to_group'),
                        isDark,
                      ),
                    ]
                  : [
                      _buildOptionItem(
                        context,
                        'Mark as opportunity',
                        () => crmController.handleMoreOptionsAction('mark_opportunity'),
                        isDark,
                      ),
                      _buildOptionItem(
                        context,
                        'Follow-up later',
                        () => crmController.handleMoreOptionsAction('follow_up'),
                        isDark,
                      ),
                    ],
            ),
          ),
        ),
      );
    });
  }

  Widget _buildOptionItem(
    BuildContext context,
    String title,
    VoidCallback onTap,
    bool isDark,
  ) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.symmetric(
          horizontal: AppResponsive.scaleSize(context, 16),
          vertical: AppResponsive.scaleSize(context, 12),
        ),
        child: Text(
          title,
          style: AppTextStyles.bodyText(context).copyWith(
            fontSize: AppResponsive.scaleSize(context, 14),
            color: isDark ? Colors.white : Colors.black87,
          ),
        ),
      ),
    );
  }
}

