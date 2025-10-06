import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:minechat/controller/crm_controller/crm_controller.dart';
import 'package:minechat/model/data/crm/opportunity_model.dart';
import 'package:minechat/core/constants/app_colors/app_colors.dart';
import 'package:minechat/controller/theme_controller/theme_controller.dart';
import 'package:minechat/core/utils/helpers/app_responsive/app_responsive.dart';
import 'package:minechat/core/widgets/crm/crm_opportunities_more_options_dropdown.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:minechat/core/constants/app_assets/app_assets.dart';

class CrmOpportunitiesScreen extends StatelessWidget {
  CrmOpportunitiesScreen({super.key});

  final CrmController crmController = Get.find<CrmController>();
  final TextEditingController _searchController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final themeController = Get.find<ThemeController>();
    final isDark = themeController.isDarkMode;
    return Obx(() {
      return Stack(
        children: [
          Column(
            children: [
              if (crmController.isSelectionMode.value) 
                _buildSelectAllCheckbox(isDark)
              else
                _buildSearchSection(context, isDark),
              _buildFilterTabs(context),
              Expanded(
                child: _buildOpportunitiesList(isDark),
              ),
            ],
          ),
          // Filter Dropdown
          Positioned(
            top: 0,
            right: 16,
            child: Obx(() => crmController.isFilterDropdownOpen.value
                ? _buildFilterDropdown()
                : const SizedBox.shrink()),
          ),
          // More Options Dropdown
          if (crmController.isSelectionMode.value)
            CrmOpportunitiesMoreOptionsDropdown(
              crmController: crmController,
              themeController: themeController,
            ),
        ],
      );
    });
  }

  Widget _buildSelectAllCheckbox(bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1D1D1D) : Colors.white,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Obx(() => Checkbox(
            value: crmController.selectedOpportunityIds.length == crmController.filteredOpportunities.length && crmController.filteredOpportunities.isNotEmpty,
            onChanged: (value) {
              if (value == true) {
                crmController.selectAllOpportunities();
              } else {
                crmController.clearSelection();
              }
            },
            activeColor: AppColors.primary,
          )),
          const SizedBox(width: 8),
          Text(
            'Select all',
            style: TextStyle(
              fontSize: 14,
              color: isDark ? Colors.white : Colors.black87,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchSection(BuildContext context, bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 16, top: 16, bottom: 8),
          child: Text(
            'Opportunities',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: isDark ? Colors.white : Colors.black,
            ),
          ),
        ),
        _buildSearchBar(isDark),
      ],
    );
  }

  Widget _buildSearchBar(bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: isDark ? Color(0XFF1D1D1D) : Color(0XFFFFFFFF),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.search,
                    color: Colors.grey[600],
                    size: 25,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextField(
                      controller: _searchController,
                      onChanged: (value) => crmController.updateSearchQuery(value),
                      decoration: InputDecoration(
                        hintText: 'Search',
                        hintStyle: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 14,
                        ),
                        border: InputBorder.none,
                        isDense: true,
                        contentPadding: EdgeInsets.zero,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: isDark ? Color(0XFF1D1D1D) : Color(0XFFFFFFFF),
              borderRadius: BorderRadius.circular(8),
            ),
            child: SvgPicture.asset(AppAssets.socialMessengerLight)),
        ],
      ),
    );
  }

  Widget _buildFilterTabs(BuildContext context) {
    final themeController = Get.find<ThemeController>();
    final isDark = themeController.isDarkMode;
    return Container(
      margin: const EdgeInsets.only(top: 8),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: isDark ? Color(0XFF1D1D1D) : Color(0XFFFFFFFF)
      ),
      child: Row(
        children: [
          _buildFilterTab('Open', context),
          const SizedBox(width: 16),
          _buildFilterTab('Proposal', context),
          const SizedBox(width: 16),
          _buildFilterTab('Closed', context),
          const SizedBox(width: 16),
          _buildFilterTab('Filter', context),
        ],
      ),
    );
  }

  Widget _buildFilterTab(String title, BuildContext context) {
    final themeController = Get.find<ThemeController>();
    final isDark = themeController.isDarkMode;
    return Obx(() {
      final isSelected = crmController.selectedOpportunityFilter.value == title;
      return GestureDetector(
        onTap: () {
          if (title == 'Filter') {
            crmController.toggleFilterDropdown();
          } else {
            crmController.selectOpportunityFilter(title);
          }
        },
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: isSelected
                ? isDark
                    ? Color(0XFF0A0A0A)
                    : Color(0XFFF4F6FC)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(AppResponsive.radius(context)),
          ),
          child: Text(
            title,
            style: TextStyle(
              fontSize: 14,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
            ),
          ),
        ),
      );
    });
  }

  Widget _buildOpportunitiesList(bool isDark) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? Color(0XFF1D1D1D) : Color(0XFFFFFFFF)
      ),
      child: Obx(() {
        if (crmController.isLoading.value) {
          return const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircularProgressIndicator(
                  color: AppColors.primary,
                ),
                SizedBox(height: 16),
                Text('Loading opportunities...'),
              ],
            ),
          );
        }

        final filteredOpportunities = crmController.filteredOpportunities;
        
        if (filteredOpportunities.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.trending_up_outlined, size: 64, color: Colors.grey[400]),
                SizedBox(height: 16),
                Text(
                  crmController.opportunities.isEmpty ? 'No opportunities found' : 'No opportunities match your search',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey[600],
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  crmController.opportunities.isEmpty 
                    ? 'Pull down to refresh or convert a lead to opportunity'
                    : 'Try adjusting your search or filter',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[500],
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: () async {
            crmController.refreshData();
          },
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: filteredOpportunities.length,
            itemBuilder: (context, index) {
              final opportunity = filteredOpportunities[index];
              return _buildOpportunityCard(opportunity);
            },
          ),
        );
      }),
    );
  }

  Widget _buildOpportunityCard(OpportunityModel opportunity) {
    final themeController = Get.find<ThemeController>();
    return GestureDetector(
      onTap: () {
        if (crmController.isSelectionMode.value) {
          crmController.toggleOpportunitySelection(opportunity.id);
        }
      },
      onLongPress: () {
        if (!crmController.isSelectionMode.value) {
          crmController.enterSelectionMode();
          crmController.toggleOpportunitySelection(opportunity.id);
        }
      },
      child: Obx(
        () {
          final isSelected = crmController.isSelectionMode.value && 
                            crmController.isOpportunitySelected(opportunity.id);
          final isDark = themeController.isDarkMode;
          
          return Container(
            margin: const EdgeInsets.only(bottom: 8, top: 8),
            decoration: BoxDecoration(
              color: isSelected
                  ? (isDark
                      ? const Color(0xFF0A0A0A)
                      : const Color(0xFFF4F6FC))
                  : (isDark
                      ? const Color(0xFF1D1D1D)
                      : Colors.white),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    // Selection Checkbox or Profile Avatar
                    if (crmController.isSelectionMode.value)
                      Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: isSelected
                              ? (isDark
                                  ? const Color(0xFF3D3D3D)
                                  : Colors.white)
                              : (isDark
                                  ? const Color(0xFF2A2A2A)
                                  : const Color(0xFFF0F0F0)),
                        ),
                        child: isSelected
                            ? Icon(
                                Icons.check,
                                size: 24,
                                color: isDark ? Colors.white : Colors.black87,
                              )
                            : Center(
                                child: Text(
                                  opportunity.name.isNotEmpty ? opportunity.name[0].toUpperCase() : '?',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                      )
                    else
                      CircleAvatar(
                        radius: 24,
                        backgroundColor: AppColors.primary,
                        child: Text(
                          opportunity.name.isNotEmpty ? opportunity.name[0].toUpperCase() : '?',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Expanded(
                            child: Text(
                              opportunity.name,
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w400,
                                color: isDark ? Colors.white : Colors.black,
                              ),
                            ),
                          ),
                          Text(
                            opportunity.timeAgo,
                            style: TextStyle(
                              fontSize: 14,
                              color: Color(0XFFA8AEBF),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
              ),
              Padding(
                padding: const EdgeInsets.only(left: 56),
                child: Text(
                  '"${opportunity.description}"',
                  style: TextStyle(
                    fontSize: 14,
                    color: Color(0XFF767C8C),
                  ),
                ),
              ),
            ],
          ));
        },
      ),
    );
  }

  Widget _buildFilterDropdown() {
    final themeController = Get.find<ThemeController>();
    final isDark = themeController.isDarkMode;
    return Container(
      margin: const EdgeInsets.only(top: 8),
      decoration: BoxDecoration(
        color: isDark ? Color(0XFF0A0A0A) : Color(0XFFF4F6FC),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Active Section Header
          Container(
            width: 200,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Text(
              'Active',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Text(
            'Open opportunities',
            style: TextStyle(
              fontSize: 10,
            ),
          ).paddingOnly(left: 16, bottom: 4),
          _buildDropdownItem('📅 This Week'),
          _buildDropdownItem('📅 This Month'),
          
          // Divider
          Divider(height: 1, color: Colors.grey[300]),
          
          // Closed Section Header
          Container(
            width: 200,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Text(
              'Closed',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Text(
            'Won and Lost deals',
            style: TextStyle(
              fontSize: 10,
            ),
          ).paddingOnly(left: 16, bottom: 4),
          _buildDropdownItem('📅 Last Month'),
          _buildDropdownItem('📅 Date Range'),
        ],
      ),
    );
  }

  Widget _buildDropdownItem(String option) {
    return GestureDetector(
      onTap: () => crmController.applyDateFilter(option),
      child: Container(
        width: 200,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Text(
          option,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }

}
