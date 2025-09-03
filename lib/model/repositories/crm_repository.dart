import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../data/crm/lead_model.dart';
import '../data/crm/opportunity_model.dart';

class CrmRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Get current user ID
  String get _currentUserId => _auth.currentUser?.uid ?? '';

  // Collection references
  CollectionReference get _leadsCollection => 
      _firestore.collection('users').doc(_currentUserId).collection('leads');
  
  CollectionReference get _opportunitiesCollection => 
      _firestore.collection('users').doc(_currentUserId).collection('opportunities');

  // ===== LEAD OPERATIONS =====

  // Get all leads
  Stream<List<LeadModel>> getLeads() {
    try {
      print('🔍 CRM Repository: Getting leads for user: $_currentUserId');
      if (_currentUserId.isEmpty) {
        print('⚠️ CRM Repository: No current user ID, returning empty stream');
        return Stream.value([]);
      }
      
      return _leadsCollection
          .orderBy('createdAt', descending: true)
          .snapshots()
          .map((snapshot) {
            print('📊 CRM Repository: Received ${snapshot.docs.length} leads from Firestore');
            return snapshot.docs
                .map((doc) => LeadModel.fromFirestore(doc))
                .toList();
          })
          .handleError((error) {
            print('❌ CRM Repository: Error getting leads: $error');
            throw error;
          });
    } catch (e) {
      print('❌ CRM Repository: Exception getting leads: $e');
      return Stream.error(e);
    }
  }

  // Get leads by status
  Stream<List<LeadModel>> getLeadsByStatus(LeadStatus status) {
    return _leadsCollection
        .where('status', isEqualTo: status.toString().split('.').last)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => LeadModel.fromFirestore(doc))
            .toList());
  }

  // Get leads by date range
  Stream<List<LeadModel>> getLeadsByDateRange(DateTime startDate, DateTime endDate) {
    return _leadsCollection
        .where('createdAt', isGreaterThanOrEqualTo: Timestamp.fromDate(startDate))
        .where('createdAt', isLessThanOrEqualTo: Timestamp.fromDate(endDate))
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => LeadModel.fromFirestore(doc))
            .toList());
  }

  // Search leads
  Stream<List<LeadModel>> searchLeads(String query) {
    return _leadsCollection
        .orderBy('name')
        .startAt([query])
        .endAt([query + '\uf8ff'])
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => LeadModel.fromFirestore(doc))
            .toList());
  }

  // Add new lead
  Future<String> addLead(LeadModel lead) async {
    try {
      final docRef = await _leadsCollection.add(lead.toFirestore());
      return docRef.id;
    } catch (e) {
      throw Exception('Failed to add lead: $e');
    }
  }

  // Update lead
  Future<void> updateLead(LeadModel lead) async {
    try {
      await _leadsCollection.doc(lead.id).update(lead.toFirestore());
    } catch (e) {
      throw Exception('Failed to update lead: $e');
    }
  }

  // Delete lead
  Future<void> deleteLead(String leadId) async {
    try {
      await _leadsCollection.doc(leadId).delete();
    } catch (e) {
      throw Exception('Failed to delete lead: $e');
    }
  }

  // Delete multiple leads
  Future<void> deleteMultipleLeads(List<String> leadIds) async {
    try {
      final batch = _firestore.batch();
      for (String leadId in leadIds) {
        batch.delete(_leadsCollection.doc(leadId));
      }
      await batch.commit();
    } catch (e) {
      throw Exception('Failed to delete leads: $e');
    }
  }

  // Convert lead to opportunity
  Future<String> convertLeadToOpportunity(String leadId, OpportunityModel opportunity) async {
    try {
      final batch = _firestore.batch();
      
      // Update lead status to opportunity
      batch.update(_leadsCollection.doc(leadId), {
        'status': LeadStatus.opportunity.toString().split('.').last,
        'lastModified': Timestamp.now(),
      });
      
      // Add opportunity
      final opportunityRef = _opportunitiesCollection.doc();
      batch.set(opportunityRef, opportunity.toFirestore());
      
      await batch.commit();
      return opportunityRef.id;
    } catch (e) {
      throw Exception('Failed to convert lead to opportunity: $e');
    }
  }

  // ===== OPPORTUNITY OPERATIONS =====

  // Get all opportunities
  Stream<List<OpportunityModel>> getOpportunities() {
    try {
      print('🔍 CRM Repository: Getting opportunities for user: $_currentUserId');
      if (_currentUserId.isEmpty) {
        print('⚠️ CRM Repository: No current user ID, returning empty stream');
        return Stream.value([]);
      }
      
      return _opportunitiesCollection
          .orderBy('createdAt', descending: true)
          .snapshots()
          .map((snapshot) {
            print('📊 CRM Repository: Received ${snapshot.docs.length} opportunities from Firestore');
            return snapshot.docs
                .map((doc) => OpportunityModel.fromFirestore(doc))
                .toList();
          })
          .handleError((error) {
            print('❌ CRM Repository: Error getting opportunities: $error');
            throw error;
          });
    } catch (e) {
      print('❌ CRM Repository: Exception getting opportunities: $e');
      return Stream.error(e);
    }
  }

  // Get opportunities by status
  Stream<List<OpportunityModel>> getOpportunitiesByStatus(OpportunityStatus status) {
    return _opportunitiesCollection
        .where('status', isEqualTo: status.toString().split('.').last)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => OpportunityModel.fromFirestore(doc))
            .toList());
  }

  // Get opportunities by stage
  Stream<List<OpportunityModel>> getOpportunitiesByStage(OpportunityStage stage) {
    return _opportunitiesCollection
        .where('stage', isEqualTo: stage.toString().split('.').last)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => OpportunityModel.fromFirestore(doc))
            .toList());
  }

  // Search opportunities
  Stream<List<OpportunityModel>> searchOpportunities(String query) {
    return _opportunitiesCollection
        .orderBy('name')
        .startAt([query])
        .endAt([query + '\uf8ff'])
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => OpportunityModel.fromFirestore(doc))
            .toList());
  }

  // Add new opportunity
  Future<String> addOpportunity(OpportunityModel opportunity) async {
    try {
      final docRef = await _opportunitiesCollection.add(opportunity.toFirestore());
      return docRef.id;
    } catch (e) {
      throw Exception('Failed to add opportunity: $e');
    }
  }

  // Update opportunity
  Future<void> updateOpportunity(OpportunityModel opportunity) async {
    try {
      await _opportunitiesCollection.doc(opportunity.id).update(opportunity.toFirestore());
    } catch (e) {
      throw Exception('Failed to update opportunity: $e');
    }
  }

  // Delete opportunity
  Future<void> deleteOpportunity(String opportunityId) async {
    try {
      await _opportunitiesCollection.doc(opportunityId).delete();
    } catch (e) {
      throw Exception('Failed to delete opportunity: $e');
    }
  }

  // Delete multiple opportunities
  Future<void> deleteMultipleOpportunities(List<String> opportunityIds) async {
    try {
      final batch = _firestore.batch();
      for (String opportunityId in opportunityIds) {
        batch.delete(_opportunitiesCollection.doc(opportunityId));
      }
      await batch.commit();
    } catch (e) {
      throw Exception('Failed to delete opportunities: $e');
    }
  }

  // Update opportunity status
  Future<void> updateOpportunityStatus(String opportunityId, OpportunityStatus status) async {
    try {
      await _opportunitiesCollection.doc(opportunityId).update({
        'status': status.toString().split('.').last,
        'lastModified': Timestamp.now(),
      });
    } catch (e) {
      throw Exception('Failed to update opportunity status: $e');
    }
  }

  // ===== ANALYTICS =====

  // Get lead statistics
  Future<Map<String, dynamic>> getLeadStatistics() async {
    try {
      final leadsSnapshot = await _leadsCollection.get();
      final leads = leadsSnapshot.docs.map((doc) => LeadModel.fromFirestore(doc)).toList();
      
      final totalLeads = leads.length;
      final hotLeads = leads.where((lead) => lead.status == LeadStatus.hot).length;
      final followUpLeads = leads.where((lead) => lead.status == LeadStatus.followUps).length;
      final coldLeads = leads.where((lead) => lead.status == LeadStatus.cold).length;
      final opportunityLeads = leads.where((lead) => lead.status == LeadStatus.opportunity).length;
      
      return {
        'totalLeads': totalLeads,
        'hotLeads': hotLeads,
        'followUpLeads': followUpLeads,
        'coldLeads': coldLeads,
        'opportunityLeads': opportunityLeads,
      };
    } catch (e) {
      throw Exception('Failed to get lead statistics: $e');
    }
  }

  // Get opportunity statistics
  Future<Map<String, dynamic>> getOpportunityStatistics() async {
    try {
      final opportunitiesSnapshot = await _opportunitiesCollection.get();
      final opportunities = opportunitiesSnapshot.docs
          .map((doc) => OpportunityModel.fromFirestore(doc))
          .toList();
      
      final totalOpportunities = opportunities.length;
      final openOpportunities = opportunities.where((opp) => opp.status == OpportunityStatus.open).length;
      final closedWonOpportunities = opportunities.where((opp) => opp.status == OpportunityStatus.closedWon).length;
      final closedLostOpportunities = opportunities.where((opp) => opp.status == OpportunityStatus.closedLost).length;
      
      final totalValue = opportunities
          .where((opp) => opp.status == OpportunityStatus.closedWon)
          .fold(0.0, (sum, opp) => sum + opp.amount);
      
      return {
        'totalOpportunities': totalOpportunities,
        'openOpportunities': openOpportunities,
        'closedWonOpportunities': closedWonOpportunities,
        'closedLostOpportunities': closedLostOpportunities,
        'totalValue': totalValue,
      };
    } catch (e) {
      throw Exception('Failed to get opportunity statistics: $e');
    }
  }
}
