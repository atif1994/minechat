import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:minechat/model/data/ai_knowledge_model.dart';

class AIKnowledgeRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Get current user ID
  String getCurrentUserId() {
    final user = _auth.currentUser;
    if (user == null) {
      throw Exception('User not authenticated');
    }
    return user.uid;
  }

  // Save AI Knowledge
  Future<void> saveAIKnowledge(AIKnowledgeModel aiKnowledge) async {
    try {
      print('Repository: Starting saveAIKnowledge');
      print('Repository: Document ID: ${aiKnowledge.id}');
      print('Repository: Data to save: ${aiKnowledge.toMap()}');
      
      await _firestore
          .collection('ai_knowledge')
          .doc(aiKnowledge.id)
          .set(aiKnowledge.toMap());
      
      print('Repository: Data saved successfully to Firestore');
    } catch (e) {
      print('Repository: Error saving to Firestore: $e');
      throw Exception('Failed to save AI Knowledge: $e');
    }
  }

  // Get current user's AI Knowledge
  Future<AIKnowledgeModel?> getCurrentUserAIKnowledge() async {
    try {
      final userId = getCurrentUserId();
      final querySnapshot = await _firestore
          .collection('ai_knowledge')
          .where('userId', isEqualTo: userId)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        // Sort manually to get the most recent
        final docs = querySnapshot.docs.toList();
        docs.sort((a, b) {
          final aTime = DateTime.parse(a.data()['updatedAt']);
          final bTime = DateTime.parse(b.data()['updatedAt']);
          return bTime.compareTo(aTime); // Descending order
        });
        
        final doc = docs.first;
        return AIKnowledgeModel.fromMap({
          'id': doc.id,
          ...doc.data(),
        });
      }
      return null;
    } catch (e) {
      throw Exception('Failed to get AI Knowledge: $e');
    }
  }

  // Get AI Knowledge by ID
  Future<AIKnowledgeModel?> getAIKnowledgeById(String id) async {
    try {
      final doc = await _firestore.collection('ai_knowledge').doc(id).get();
      if (doc.exists) {
        return AIKnowledgeModel.fromMap({
          'id': doc.id,
          ...doc.data()!,
        });
      }
      return null;
    } catch (e) {
      throw Exception('Failed to get AI Knowledge: $e');
    }
  }

  // Get all AI Knowledge for current user
  Future<List<AIKnowledgeModel>> getAllUserAIKnowledge() async {
    try {
      final userId = getCurrentUserId();
      final querySnapshot = await _firestore
          .collection('ai_knowledge')
          .where('userId', isEqualTo: userId)
          .get();

      return querySnapshot.docs.map((doc) {
        return AIKnowledgeModel.fromMap({
          'id': doc.id,
          ...doc.data(),
        });
      }).toList();
    } catch (e) {
      throw Exception('Failed to get AI Knowledge: $e');
    }
  }

  // Delete AI Knowledge
  Future<void> deleteAIKnowledge(String id) async {
    try {
      await _firestore.collection('ai_knowledge').doc(id).delete();
    } catch (e) {
      throw Exception('Failed to delete AI Knowledge: $e');
    }
  }

  // Update AI Knowledge
  Future<void> updateAIKnowledge(AIKnowledgeModel aiKnowledge) async {
    try {
      final updatedAIKnowledge = aiKnowledge.copyWith(updatedAt: DateTime.now());
      await _firestore
          .collection('ai_knowledge')
          .doc(aiKnowledge.id)
          .update(updatedAIKnowledge.toMap());
    } catch (e) {
      throw Exception('Failed to update AI Knowledge: $e');
    }
  }
}
