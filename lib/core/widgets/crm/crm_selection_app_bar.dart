import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:minechat/controller/crm_controller/crm_controller.dart';
import 'package:minechat/controller/theme_controller/theme_controller.dart';
import 'package:minechat/core/utils/helpers/app_responsive/app_responsive.dart';
import 'package:minechat/core/utils/helpers/app_styles/app_text_styles.dart';
import 'package:minechat/core/widgets/crm/delete_leads_alert_dialog.dart';

class CrmSelectionAppBar extends StatelessWidget implements PreferredSizeWidget {
  final CrmController crmController;
  final ThemeController themeController;

  const CrmSelectionAppBar({
    super.key,
    required this.crmController,
    required this.themeController,
  });

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final isDark = themeController.isDarkMode;
      final selectedCount = crmController.selectedLeadIds.length + 
                           crmController.selectedOpportunityIds.length;
      
      return AppBar(
        backgroundColor: isDark ? const Color(0xFF1D1D1D) : Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
            color: isDark ? Colors.white : Colors.black,
          ),
          onPressed: () => crmController.exitSelectionMode(),
        ),
        title: Text(
          '$selectedCount Selected',
          style: AppTextStyles.bodyText(context).copyWith(
            fontSize: AppResponsive.scaleSize(context, 18),
            fontWeight: FontWeight.w600,
            color: isDark ? Colors.white : Colors.black,
          ),
        ),
        actions: [
          // Delete button
          IconButton(
            icon: Icon(
              Icons.delete_outline,
              color: isDark ? Colors.white : Colors.black,
            ),
            onPressed: selectedCount > 0 
                ? () => _showDeleteConfirmation(context, crmController)
                : null,
          ),
          // More options button
          IconButton(
            icon: Icon(
              Icons.more_vert,
              color: isDark ? Colors.white : Colors.black,
            ),
            onPressed: () => crmController.toggleMoreOptionsDropdown(),
          ),
          const SizedBox(width: 8),
        ],
      );
    });
  }

  void _showDeleteConfirmation(BuildContext context, CrmController controller) {
    final isLeads = controller.selectedLeadIds.isNotEmpty;
    final count = isLeads 
        ? controller.selectedLeadIds.length 
        : controller.selectedOpportunityIds.length;
    final type = isLeads ? 'lead(s)' : 'opportunit${count > 1 ? 'ies' : 'y'}';
    
    DeleteLeadsAlertDialog.show(
      onConfirm: () {
        if (isLeads) {
          controller.deleteSelectedLeads();
        } else {
          controller.deleteSelectedOpportunities();
        }
      },
      title: isLeads ? 'Delete Leads' : 'Delete Opportunities',
      message: 'Are you sure you want to delete $count $type? This action cannot be undone.',
      confirmLabel: 'Delete',
      cancelLabel: 'Cancel',
      barrier: Colors.black.withOpacity(0.55),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}

