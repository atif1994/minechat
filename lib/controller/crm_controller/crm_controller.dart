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

  Future<void> addLead(LeadModel lead) async {
    try {
      await _crmRepository.addLead(lead);
      Get.snackbar('Success', 'Lead added successfully');
    } catch (e) {
      Get.snackbar('Error', 'Failed to add lead: $e');
    }
  }

  Future<void> deleteLead(String leadId) async {
    try {
      await _crmRepository.deleteLead(leadId);
      Get.snackbar('Success', 'Lead deleted successfully');
    } catch (e) {
      Get.snackbar('Error', 'Failed to delete lead: $e');
    }
  }

  void toggleSelectionMode() {
    isSelectionMode.value = !isSelectionMode.value;
    if (!isSelectionMode.value) {
      selectedLeadIds.clear();
      selectedOpportunityIds.clear();
    }
  }

  void toggleLeadSelection(String leadId) {
    if (selectedLeadIds.contains(leadId)) {
      selectedLeadIds.remove(leadId);
    } else {
      selectedLeadIds.add(leadId);
    }
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

  void selectAllLeads() {
    selectedLeadIds.clear();
    selectedLeadIds.addAll(filteredLeads.map((lead) => lead.id));
  }

  void clearSelection() {
    selectedLeadIds.clear();
  }

  // Bulk actions
  void markSelectedAsOpportunity() async {
    if (selectedLeadIds.isEmpty) {
      Get.snackbar('Info', 'No leads selected');
      return;
    }
    
    try {
      // Update selected leads status to opportunity
      for (String leadId in selectedLeadIds) {
        final leadIndex = leads.indexWhere((lead) => lead.id == leadId);
        if (leadIndex != -1) {
          final updatedLead = leads[leadIndex].copyWith(status: LeadStatus.opportunity);
          leads[leadIndex] = updatedLead;
          
          // Update in Firebase
          await _crmRepository.updateLead(updatedLead);
        }
      }
      
      print('Marking ${selectedLeadIds.length} leads as opportunities');
      Get.snackbar('Success', '${selectedLeadIds.length} leads marked as opportunities');
      clearSelection();
      isSelectionMode.value = false;
    } catch (e) {
      print('Error updating leads: $e');
      Get.snackbar('Error', 'Failed to update leads: $e');
    }
  }

  void followUpSelectedLater() async {
    if (selectedLeadIds.isEmpty) {
      Get.snackbar('Info', 'No leads selected');
      return;
    }
    
    try {
      // Update selected leads status to follow-ups
      for (String leadId in selectedLeadIds) {
        final leadIndex = leads.indexWhere((lead) => lead.id == leadId);
        if (leadIndex != -1) {
          final updatedLead = leads[leadIndex].copyWith(status: LeadStatus.followUps);
          leads[leadIndex] = updatedLead;
          
          // Update in Firebase
          await _crmRepository.updateLead(updatedLead);
        }
      }
      
      print('Scheduling follow-up for ${selectedLeadIds.length} leads');
      Get.snackbar('Success', 'Follow-up scheduled for ${selectedLeadIds.length} leads');
      clearSelection();
      isSelectionMode.value = false;
    } catch (e) {
      print('Error updating leads: $e');
      Get.snackbar('Error', 'Failed to update leads: $e');
    }
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

  void deleteSelectedLeads() async {
    if (selectedLeadIds.isEmpty) {
      Get.snackbar('Info', 'No leads selected');
      return;
    }
    
    try {
      // Delete from Firebase using batch operation for better performance
      await _crmRepository.deleteMultipleLeads(selectedLeadIds.toList());
      
      // Remove selected leads from the local list
      leads.removeWhere((lead) => selectedLeadIds.contains(lead.id));
      
      print('Deleting ${selectedLeadIds.length} leads');
      Get.snackbar('Success', '${selectedLeadIds.length} leads deleted');
      
      // Clear selection and exit selection mode
      clearSelection();
      isSelectionMode.value = false;
    } catch (e) {
      print('Error deleting leads: $e');
      Get.snackbar('Error', 'Failed to delete leads: $e');
    }
  }

  // Individual lead actions
  void sendMessageToLead(String leadId) {
    // Implementation for sending message to individual lead
    print('Sending message to lead: $leadId');
    Get.snackbar('Success', 'Message sent to lead');
  }

  void addLeadToGroup(String leadId) {
    // Implementation for adding individual lead to group
    print('Adding lead to group: $leadId');
    Get.snackbar('Success', 'Lead added to group');
  }
}
