import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:minechat/controller/crm_controller/crm_controller.dart';
import 'package:minechat/model/data/crm/lead_model.dart';
import 'package:minechat/core/constants/app_colors/app_colors.dart';

class CrmLeadsScreen extends StatelessWidget {
  CrmLeadsScreen({super.key});

  final CrmController crmController = Get.put(CrmController());
  final TextEditingController _searchController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      return Scaffold(
        backgroundColor: AppColors.gray,
        appBar: crmController.isSelectionMode.value 
          ? _buildSelectionAppBar(context)
          : _buildNormalAppBar(context),
        body: Column(
          children: [
            if (crmController.isSelectionMode.value) _buildSelectAllCheckbox(),
            _buildSearchBar(),
            _buildFilterTabs(),
            Expanded(
              child: _buildLeadsList(),
            ),
          ],
        ),
      );
    });
  }

  PreferredSizeWidget _buildNormalAppBar(BuildContext context) {
    return AppBar(
      title: const Text('Leads'),
      backgroundColor: Colors.white,
      elevation: 0,
      actions: [
        IconButton(
          onPressed: () {
            crmController.toggleSelectionMode();
          },
          icon: const Icon(Icons.checklist, color: AppColors.primary),
        ),
      ],
    );
  }

  PreferredSizeWidget _buildSelectionAppBar(BuildContext context) {
    return AppBar(
      leading: IconButton(
        icon: const Icon(Icons.arrow_back),
        onPressed: () {
          crmController.toggleSelectionMode();
        },
      ),
      title: Text('${crmController.selectedLeadIds.length} Selected'),
      backgroundColor: Colors.white,
      elevation: 0,
      actions: [
        IconButton(
          onPressed: () {
            crmController.deleteSelectedLeads();
          },
          icon: const Icon(Icons.delete, color: Colors.red),
        ),
        PopupMenuButton<String>(
          onSelected: (value) {
            switch (value) {
              case 'mark_opportunity':
                crmController.markSelectedAsOpportunity();
                break;
              case 'follow_up':
                crmController.followUpSelectedLater();
                break;
              case 'group_message':
                crmController.sendGroupMessage();
                break;
              case 'create_group':
                crmController.createGroup();
                break;
              case 'add_to_group':
                crmController.addToGroup();
                break;
            }
          },
          itemBuilder: (context) => [
            const PopupMenuItem(
              value: 'mark_opportunity',
              child: Text('Mark as opportunity'),
            ),
            const PopupMenuItem(
              value: 'follow_up',
              child: Text('Follow-up later'),
            ),
            const PopupMenuItem(
              value: 'group_message',
              child: Text('Send a group message'),
            ),
            const PopupMenuItem(
              value: 'create_group',
              child: Text('Create a group'),
            ),
            const PopupMenuItem(
              value: 'add_to_group',
              child: Text('Add to a group'),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSelectAllCheckbox() {
    return Container(
      padding: const EdgeInsets.all(16),
      color: Colors.white,
      child: Row(
        children: [
          Checkbox(
            value: crmController.selectedLeadIds.length == crmController.filteredLeads.length && crmController.filteredLeads.isNotEmpty,
            onChanged: (value) {
              if (value == true) {
                crmController.selectAllLeads();
              } else {
                crmController.clearSelection();
              }
            },
          ),
          const Text('Select all'),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      padding: const EdgeInsets.all(16),
      color: Colors.white,
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _searchController,
              decoration: const InputDecoration(
                hintText: 'Search',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
              ),
              onChanged: (value) {
                crmController.updateSearchQuery(value);
              },
            ),
          ),
          const SizedBox(width: 12),
          Container(
            width: 40,
            height: 40,
            decoration: const BoxDecoration(
              color: Color(0xFF8B5CF6), // Purple color like Facebook Messenger
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.chat,
              color: Colors.white,
              size: 20,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterTabs() {
    return Container(
      padding: const EdgeInsets.all(16),
      color: Colors.white,
      child: Row(
        children: [
          _buildFilterTab('Hot', 'hot'),
          const SizedBox(width: 8),
          _buildFilterTab('Follow-ups', 'followUps'),
          const SizedBox(width: 8),
          _buildFilterTab('Cold', 'cold'),
          const SizedBox(width: 8),
          _buildFilterTab('Filter', 'filter'),
        ],
      ),
    );
  }

  Widget _buildFilterTab(String label, String value) {
    return Obx(() => GestureDetector(
          onTap: () => crmController.setFilterType(value),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: crmController.filterType.value == value
                  ? AppColors.primary
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.grey[300]!),
            ),
            child: Text(
              label,
              style: TextStyle(
                color: crmController.filterType.value == value
                    ? Colors.white
                    : Colors.black,
              ),
            ),
          ),
        ));
  }

  Widget _buildLeadsList() {
    return Obx(() {
      if (crmController.isLoading.value) {
        return const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 16),
              Text('Loading leads...'),
            ],
          ),
        );
      }

      final filteredLeads = crmController.filteredLeads;
      
      if (filteredLeads.isEmpty) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.people_outline, size: 64, color: Colors.grey),
              SizedBox(height: 16),
              Text(
                crmController.leads.isEmpty ? 'No leads found' : 'No leads match your search',
                style: TextStyle(fontSize: 18, color: Colors.grey),
              ),
              SizedBox(height: 8),
              Text(
                crmController.leads.isEmpty 
                  ? 'Pull down to refresh or add a new lead'
                  : 'Try adjusting your search or filter',
                style: TextStyle(fontSize: 14, color: Colors.grey),
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
          padding: const EdgeInsets.all(16),
          itemCount: filteredLeads.length,
          itemBuilder: (context, index) {
            final lead = filteredLeads[index];
            return _buildLeadCard(lead);
          },
        ),
      );
    });
  }

  Widget _buildLeadCard(LeadModel lead) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              // Checkbox for selection mode
              if (crmController.isSelectionMode.value) ...[
                Checkbox(
                  value: crmController.selectedLeadIds.contains(lead.id),
                  onChanged: (value) {
                    crmController.toggleLeadSelection(lead.id);
                  },
                ),
                const SizedBox(width: 8),
              ],
              CircleAvatar(
                radius: 20,
                child: Text(
                  lead.name.isNotEmpty ? lead.name[0].toUpperCase() : '?',
                  style: const TextStyle(color: Colors.white),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      lead.name,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      lead.timeAgo,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(lead.description),
          const SizedBox(height: 12),
          // Different actions based on selection mode
          if (crmController.isSelectionMode.value) ...[
            // No individual actions in selection mode
          ] else ...[
            Row(
              children: [
                _buildActionButton(
                  'Send a message', 
                  Colors.blue,
                  Icons.message,
                  () => crmController.sendMessageToLead(lead.id),
                ),
                const SizedBox(width: 12),
                _buildActionButton(
                  'Add to a group', 
                  Colors.green,
                  Icons.group_add,
                  () => crmController.addLeadToGroup(lead.id),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildActionButton(String label, Color color, IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 16, color: color),
            const SizedBox(width: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: color,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
