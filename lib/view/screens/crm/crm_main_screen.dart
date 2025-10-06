import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:minechat/controller/crm_controller/crm_controller.dart';
import 'package:minechat/controller/auth_controller/auth_controller.dart';
import 'package:minechat/core/constants/app_colors/app_colors.dart';
import 'crm_leads_screen.dart';
import 'package:minechat/controller/theme_controller/theme_controller.dart';
import 'crm_opportunities_screen.dart';
import 'package:minechat/core/utils/helpers/app_styles/app_text_styles.dart';
import 'package:minechat/core/widgets/crm/crm_selection_app_bar.dart';

class CrmMainScreen extends StatefulWidget {
  const CrmMainScreen({super.key});

  @override
  State<CrmMainScreen> createState() => _CrmMainScreenState();
}

class _CrmMainScreenState extends State<CrmMainScreen> {
  final CrmController crmController = Get.find<CrmController>();
  final RxString currentSection = "Leads".obs;

  final Map<String, int> indexMap = {
    "Leads": 0,
    "Opportunities": 1,
  };

  @override
  Widget build(BuildContext context) {
    final themeController = Get.find<ThemeController>();
    final isDark = themeController.isDarkMode;
    return Obx(() {
      return Scaffold(
        backgroundColor: isDark ? Color(0XFF0A0A0A) : Color(0XFFF4F6FC),
        appBar: crmController.isSelectionMode.value
            ? CrmSelectionAppBar(
                crmController: crmController,
                themeController: themeController,
              )
            : _buildBreadcrumbsAppBar(context, isDark),
        body: Obx(() => IndexedStack(
          index: indexMap[currentSection.value] ?? 0,
          children: [
            CrmLeadsScreen(),
            CrmOpportunitiesScreen(),
          ],
        )),
      );
    });
  }

  PreferredSizeWidget _buildBreadcrumbsAppBar(BuildContext context, bool isDark) {
    return AppBar(
      backgroundColor: isDark ? Color(0XFF1D1D1D) : Color(0XFFFFFFFF),
      elevation: 0,
      title: _buildBreadcrumbs(context),
    );
  }

  // ---------------------- Breadcrumbs ----------------------
  Widget _buildBreadcrumbs(BuildContext context) {
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
          Text('CRM',
              style: AppTextStyles.bodyText(context).copyWith(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: isDark ? Color(0XFFFFFFFF) : Color(0XFF222222),
              ) // Always active style since it's the main title
          ),
          Text(' > ', style: separatorStyle),
          GestureDetector(
            onTap: () => currentSection.value = "Leads",
            child: Text(
              'Leads',
              style: currentSection.value == "Leads"
                  ? activeStyle
                  : linkStyle,
            ),
          ),
          Text(' > ', style: separatorStyle),
          GestureDetector(
            onTap: () => currentSection.value = "Opportunities",
            child: Text(
              'Opportunities',
              style: currentSection.value == "Opportunities"
                  ? activeStyle
                  : inactiveStyle,
            ),
          ),
        ],
      );
    });
  }
}
