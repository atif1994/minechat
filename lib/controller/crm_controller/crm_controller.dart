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
      },
      onError: (error) {
        print('❌ Error loading leads: $error');
        isLoading.value = false;
        // Add sample data for testing if no data exists
        if (leads.isEmpty) {
          print('📝 No leads found, adding sample data...');
          _addSampleLeads();
        }
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
      },
      onError: (error) {
        print('❌ Error loading opportunities: $error');
        isLoading.value = false;
        // Add sample data for testing if no data exists
        if (opportunities.isEmpty) {
          print('📝 No opportunities found, adding sample data...');
          _addSampleOpportunities();
        }
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
  }
}
