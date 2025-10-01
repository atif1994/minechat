import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:minechat/controller/crm_controller/crm_controller.dart';
import 'package:minechat/model/data/crm/opportunity_model.dart';
import 'package:minechat/core/constants/app_colors/app_colors.dart';

class CrmOpportunitiesScreen extends StatelessWidget {
  CrmOpportunitiesScreen({super.key});

  final CrmController crmController = Get.put(CrmController());
  final TextEditingController _searchController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.gray,
      appBar: AppBar(
        title: const Text('Opportunities'),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: Column(
        children: [
          _buildSearchBar(),
          Expanded(
            child: _buildOpportunitiesList(),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      padding: const EdgeInsets.all(16),
      color: Colors.white,
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
    );
  }

  Widget _buildOpportunitiesList() {
    return Obx(() {
      if (crmController.isLoading.value) {
        return const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(),
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
              Icon(Icons.trending_up_outlined, size: 64, color: Colors.grey),
              SizedBox(height: 16),
              Text(
                crmController.opportunities.isEmpty ? 'No opportunities found' : 'No opportunities match your search',
                style: TextStyle(fontSize: 18, color: Colors.grey),
              ),
              SizedBox(height: 8),
              Text(
                crmController.opportunities.isEmpty 
                  ? 'Pull down to refresh or convert a lead to opportunity'
                  : 'Try adjusting your search',
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
        itemCount: filteredOpportunities.length,
        itemBuilder: (context, index) {
          final opportunity = filteredOpportunities[index];
          return _buildOpportunityCard(opportunity);
        },
        ),
      );
    });
  }

  Widget _buildOpportunityCard(OpportunityModel opportunity) {
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
              CircleAvatar(
                radius: 20,
                child: Text(
                  opportunity.name.isNotEmpty ? opportunity.name[0].toUpperCase() : '?',
                  style: const TextStyle(color: Colors.white),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      opportunity.name,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      opportunity.timeAgo,
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
          Text(
            opportunity.description,
            style: const TextStyle(fontSize: 14),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: _getStatusColor(opportunity.status).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  opportunity.statusDisplayName,
                  style: TextStyle(
                    fontSize: 12,
                    color: _getStatusColor(opportunity.status),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              const Spacer(),
              Text(
                opportunity.formattedAmount,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(OpportunityStatus status) {
    switch (status) {
      case OpportunityStatus.open:
        return Colors.orange;
      case OpportunityStatus.qualified:
        return Colors.blue;
      case OpportunityStatus.proposal:
        return Colors.purple;
      case OpportunityStatus.negotiation:
        return Colors.indigo;
      case OpportunityStatus.closedWon:
        return Colors.green;
      case OpportunityStatus.closedLost:
        return Colors.red;
    }
  }
}
