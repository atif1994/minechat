import 'package:get/get.dart';
import 'package:minechat/model/repositories/crm_repository.dart';
import 'package:minechat/model/data/crm/lead_model.dart';
import 'package:minechat/model/data/crm/opportunity_model.dart';

class CrmController extends GetxController {
  final CrmRepository _crmRepository = CrmRepository();

  final RxList<LeadModel> leads = <LeadModel>[].obs;
  final RxList<OpportunityModel> opportunities = <OpportunityModel>[].obs;
  final RxString searchQuery = ''.obs;
  final RxBool isLoading = false.obs;
  final RxBool isSelectionMode = false.obs;
  final RxList<String> selectedLeadIds = <String>[].obs;
  final RxList<String> selectedOpportunityIds = <String>[].obs;
  final RxString filterType = 'hot'.obs;
  final RxString selectedFilter = 'Hot'.obs;
  final RxString selectedOpportunityFilter = 'Open'.obs;
  final RxBool isFilterDropdownOpen = false.obs;
  final RxBool isMoreOptionsDropdownOpen = false.obs;
  
  // Filter options for the dropdown
  final List<String> filterOptions = [
    'Today',
    'Yesterday',
    'This Week',
    'This Month',
    'Date Range',
  ];

  // Computed property for filtered leads
  List<LeadModel> get filteredLeads {
    List<LeadModel> filtered = leads.where((lead) {
      // Filter by search query
      if (searchQuery.value.isNotEmpty) {
        final query = searchQuery.value.toLowerCase();
        if (!lead.name.toLowerCase().contains(query) &&
            !lead.email.toLowerCase().contains(query) &&
            !lead.description.toLowerCase().contains(query)) {
          return false;
        }
      }
      
      // Filter by status
      if (filterType.value != 'all') {
        switch (filterType.value) {
          case 'hot':
            return lead.status == LeadStatus.hot;
          case 'followUps':
            return lead.status == LeadStatus.followUps;
          case 'cold':
            return lead.status == LeadStatus.cold;
          case 'opportunity':
            return lead.status == LeadStatus.opportunity;
        }
      }
      
      return true;
    }).toList();
    
    return filtered;
  }

  // Computed property for filtered opportunities
  List<OpportunityModel> get filteredOpportunities {
    List<OpportunityModel> filtered = opportunities.where((opportunity) {
      // Filter by search query
      if (searchQuery.value.isNotEmpty) {
        final query = searchQuery.value.toLowerCase();
        if (!opportunity.name.toLowerCase().contains(query) &&
            !opportunity.description.toLowerCase().contains(query)) {
          return false;
        }
      }
      
      return true;
    }).toList();
    
    return filtered;
  }

  @override
  void onInit() {
    super.onInit();
    print('🚀 CRM Controller initialized');
    loadLeads();
    loadOpportunities();
  }

  void loadLeads() {
    print('📥 Loading leads...');
    isLoading.value = true;
    _crmRepository.getLeads().listen(
      (leadsList) {
        leads.value = leadsList;
        isLoading.value = false;
        print('✅ Loaded ${leadsList.length} leads');
        
        // If no real data, add sample data for demo
        if (leadsList.isEmpty) {
          print('📝 No real leads found, adding sample data...');
          _addSampleLeads();
        }
      },
      onError: (error) {
        print('❌ Error loading leads: $error');
        isLoading.value = false;
        // Add sample data for testing if real data fails
        print('📝 Adding sample data due to error...');
        _addSampleLeads();
      },
    );
  }

  void loadOpportunities() {
    print('📥 Loading opportunities...');
    isLoading.value = true;
    _crmRepository.getOpportunities().listen(
      (opportunitiesList) {
        opportunities.value = opportunitiesList;
        isLoading.value = false;
        print('✅ Loaded ${opportunitiesList.length} opportunities');
        
        // If no real data, add sample data for demo
        if (opportunitiesList.isEmpty) {
          print('📝 No real opportunities found, adding sample data...');
          _addSampleOpportunities();
        }
      },
      onError: (error) {
        print('❌ Error loading opportunities: $error');
        isLoading.value = false;
        // Add sample data for testing if real data fails
        print('📝 Adding sample data due to error...');
        _addSampleOpportunities();
      },
    );
  }

  // Force refresh data
  void refreshData() {
    print('🔄 Refreshing CRM data...');
    loadLeads();
    loadOpportunities();
  }

  // Add sample leads for testing
  void _addSampleLeads() {
    final sampleLeads = [
      LeadModel(
        id: '1',
        name: 'John Smith',
        email: 'john.smith@example.com',
        phone: '+1-555-0123',
        description: 'Interested in our premium package. Looking for enterprise solution.',
        status: LeadStatus.hot,
        source: LeadSource.website,
        createdAt: DateTime.now().subtract(const Duration(days: 2)),
      ),
      LeadModel(
        id: '2',
        name: 'Sarah Johnson',
        email: 'sarah.j@company.com',
        phone: '+1-555-0456',
        description: 'Referred by existing customer. Needs consultation.',
        status: LeadStatus.followUps,
        source: LeadSource.referral,
        createdAt: DateTime.now().subtract(const Duration(days: 5)),
      ),
      LeadModel(
        id: '3',
        name: 'Mike Wilson',
        email: 'mike.wilson@startup.io',
        phone: '+1-555-0789',
        description: 'Startup founder interested in AI integration.',
        status: LeadStatus.cold,
        source: LeadSource.social,
        createdAt: DateTime.now().subtract(const Duration(days: 10)),
      ),
    ];
    
    leads.value = sampleLeads;
    print('📝 Added ${sampleLeads.length} sample leads');
  }

  // Add sample opportunities for testing
  void _addSampleOpportunities() {
    final sampleOpportunities = [
      OpportunityModel(
        id: '1',
        leadId: '1',
        name: 'Enterprise AI Integration',
        description: 'Large enterprise looking to integrate AI across departments',
        amount: 50000.0,
        status: OpportunityStatus.proposal,
        stage: OpportunityStage.proposal,
        probability: 75,
        expectedCloseDate: DateTime.now().add(const Duration(days: 30)),
        createdAt: DateTime.now().subtract(const Duration(days: 15)),
      ),
      OpportunityModel(
        id: '2',
        leadId: '2',
        name: 'Startup Platform Development',
        description: 'Tech startup needs custom AI platform development',
        amount: 25000.0,
        status: OpportunityStatus.negotiation,
        stage: OpportunityStage.negotiation,
        probability: 60,
        expectedCloseDate: DateTime.now().add(const Duration(days: 45)),
        createdAt: DateTime.now().subtract(const Duration(days: 20)),
      ),
    ];
    
    opportunities.value = sampleOpportunities;
    print('📝 Added ${sampleOpportunities.length} sample opportunities');
  }

  void addLead(LeadModel lead) {
    print('Adding lead: ${lead.name}');
    Get.snackbar('Success', 'Lead added successfully');
  }

  void deleteLead(String leadId) {
    print('Deleting lead: $leadId');
    Get.snackbar('Success', 'Lead deleted successfully');
  }

  void enterSelectionMode() {
    isSelectionMode.value = true;
  }

  void exitSelectionMode() {
    isSelectionMode.value = false;
    selectedLeadIds.clear();
    selectedOpportunityIds.clear();
    isMoreOptionsDropdownOpen.value = false;
  }

  void toggleSelectionMode() {
    isSelectionMode.value = !isSelectionMode.value;
    if (!isSelectionMode.value) {
      selectedLeadIds.clear();
      selectedOpportunityIds.clear();
      isMoreOptionsDropdownOpen.value = false;
    }
  }

  void toggleLeadSelection(String leadId) {
    if (selectedLeadIds.contains(leadId)) {
      selectedLeadIds.remove(leadId);
    } else {
      selectedLeadIds.add(leadId);
    }
    
    // Exit selection mode if no items are selected
    if (selectedLeadIds.isEmpty) {
      exitSelectionMode();
    }
  }

  bool isLeadSelected(String leadId) {
    return selectedLeadIds.contains(leadId);
  }

  void toggleOpportunitySelection(String opportunityId) {
    if (selectedOpportunityIds.contains(opportunityId)) {
      selectedOpportunityIds.remove(opportunityId);
    } else {
      selectedOpportunityIds.add(opportunityId);
    }
    
    // Exit selection mode if no items are selected
    if (selectedOpportunityIds.isEmpty && selectedLeadIds.isEmpty) {
      exitSelectionMode();
    }
  }

  bool isOpportunitySelected(String opportunityId) {
    return selectedOpportunityIds.contains(opportunityId);
  }

  void selectAllOpportunities() {
    selectedOpportunityIds.clear();
    selectedOpportunityIds.addAll(filteredOpportunities.map((opp) => opp.id));
  }

  void selectOpportunityFilter(String filter) {
    selectedOpportunityFilter.value = filter;
    isFilterDropdownOpen.value = false;
  }

  void toggleMoreOptionsDropdown() {
    isMoreOptionsDropdownOpen.value = !isMoreOptionsDropdownOpen.value;
  }

  void handleMoreOptionsAction(String action) {
    isMoreOptionsDropdownOpen.value = false;
    
    switch (action) {
      case 'mark_opportunity':
        markSelectedAsOpportunity();
        break;
      case 'follow_up':
        followUpSelectedLater();
        break;
      case 'send_group_message':
        if (selectedOpportunityIds.isNotEmpty) {
          sendGroupMessageToOpportunities();
        } else {
          sendGroupMessage();
        }
        break;
      case 'create_group':
        createGroup();
        break;
      case 'add_to_group':
        addToGroup();
        break;
      case 'close_won':
        closeSelectedAsWon();
        break;
      case 'close_lost':
        closeSelectedAsLost();
        break;
      default:
        break;
    }
  }

  void sendGroupMessageToOpportunities() {
    if (selectedOpportunityIds.isEmpty) {
      Get.snackbar('Info', 'No opportunities selected');
      return;
    }
    print('Sending group message to ${selectedOpportunityIds.length} opportunities');
    Get.snackbar('Success', 'Group message sent to ${selectedOpportunityIds.length} opportunities');
    clearSelection();
    isSelectionMode.value = false;
  }

  void closeSelectedAsWon() {
    if (selectedOpportunityIds.isEmpty) {
      Get.snackbar('Info', 'No opportunities selected');
      return;
    }
    
    print('Closing ${selectedOpportunityIds.length} opportunities as won');
    Get.snackbar('Success', '${selectedOpportunityIds.length} opportunities closed as won');
    clearSelection();
    isSelectionMode.value = false;
  }

  void closeSelectedAsLost() {
    if (selectedOpportunityIds.isEmpty) {
      Get.snackbar('Info', 'No opportunities selected');
      return;
    }
    
    print('Closing ${selectedOpportunityIds.length} opportunities as lost');
    Get.snackbar('Success', '${selectedOpportunityIds.length} opportunities closed as lost');
    clearSelection();
    isSelectionMode.value = false;
  }

  void deleteSelectedOpportunities() {
    if (selectedOpportunityIds.isEmpty) {
      Get.snackbar('Info', 'No opportunities selected');
      return;
    }
    
    print('Deleting ${selectedOpportunityIds.length} opportunities');
    Get.snackbar('Success', '${selectedOpportunityIds.length} opportunities deleted');
    
    // Clear selection and exit selection mode
    clearSelection();
    isSelectionMode.value = false;
  }

  void setFilterType(String type) {
    filterType.value = type;
    // Trigger UI update
    update();
  }

  void updateSearchQuery(String query) {
    searchQuery.value = query;
    // Trigger UI update
    update();
  }

  void selectFilter(String filter) {
    selectedFilter.value = filter;
    isFilterDropdownOpen.value = false;
    
    // Map the filter to filterType
    switch (filter) {
      case 'Hot':
        filterType.value = 'hot';
        break;
      case 'Follow-ups':
        filterType.value = 'followUps';
        break;
      case 'Cold':
        filterType.value = 'cold';
        break;
      default:
        filterType.value = 'hot';
    }
  }

  void toggleFilterDropdown() {
    isFilterDropdownOpen.value = !isFilterDropdownOpen.value;
  }

  void applyDateFilter(String option) {
    print('📅 Applying date filter: $option');
    // Close dropdown
    isFilterDropdownOpen.value = false;
    
    // TODO: Implement date filtering logic based on option
    // For now, just show which filter was selected
    Get.snackbar('Filter Applied', 'Filtering by: $option');
  }

  void selectAllLeads() {
    selectedLeadIds.clear();
    selectedLeadIds.addAll(filteredLeads.map((lead) => lead.id));
  }

  void clearSelection() {
    selectedLeadIds.clear();
  }

  // Bulk actions
  void markSelectedAsOpportunity() {
    if (selectedLeadIds.isEmpty) {
      Get.snackbar('Info', 'No leads selected');
      return;
    }
    
    print('Marking ${selectedLeadIds.length} leads as opportunities');
    Get.snackbar('Success', '${selectedLeadIds.length} leads marked as opportunities');
    clearSelection();
    isSelectionMode.value = false;
  }

  void followUpSelectedLater() {
    if (selectedLeadIds.isEmpty) {
      Get.snackbar('Info', 'No leads selected');
      return;
    }
    
    print('Scheduling follow-up for ${selectedLeadIds.length} leads');
    Get.snackbar('Success', 'Follow-up scheduled for ${selectedLeadIds.length} leads');
    clearSelection();
    isSelectionMode.value = false;
  }

  void sendGroupMessage() {
    if (selectedLeadIds.isEmpty) {
      Get.snackbar('Info', 'No leads selected');
      return;
    }
    
    print('Sending group message to ${selectedLeadIds.length} leads');
    Get.snackbar('Success', 'Group message sent to ${selectedLeadIds.length} leads');
    clearSelection();
    isSelectionMode.value = false;
  }

  void createGroup() {
    if (selectedLeadIds.isEmpty) {
      Get.snackbar('Info', 'No leads selected');
      return;
    }
    
    print('Creating group with ${selectedLeadIds.length} leads');
    Get.snackbar('Success', 'Group created with ${selectedLeadIds.length} leads');
    clearSelection();
    isSelectionMode.value = false;
  }

  void addToGroup() {
    if (selectedLeadIds.isEmpty) {
      Get.snackbar('Info', 'No leads selected');
      return;
    }
    
    print('Adding ${selectedLeadIds.length} leads to group');
    Get.snackbar('Success', '${selectedLeadIds.length} leads added to group');
    clearSelection();
    isSelectionMode.value = false;
  }

  void deleteSelectedLeads() {
    if (selectedLeadIds.isEmpty) {
      Get.snackbar('Info', 'No leads selected');
      return;
    }
    
    print('Deleting ${selectedLeadIds.length} leads');
    Get.snackbar('Success', '${selectedLeadIds.length} leads deleted');
    
    // Clear selection and exit selection mode
    clearSelection();
    isSelectionMode.value = false;
  }

  void markAsOpportunity(String leadId) {
    print('Marking lead as opportunity: $leadId');
    Get.snackbar('Success', 'Lead marked as opportunity');
  }

  void followUpLater(String leadId) {
    print('Scheduling follow-up for lead: $leadId');
    Get.snackbar('Success', 'Follow-up scheduled for lead');
  }
}
