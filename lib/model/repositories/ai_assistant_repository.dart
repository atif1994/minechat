import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:minechat/model/data/ai_assistant_model.dart';

class AIAssistantRepository {
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

  // Save AI Assistant
  Future<void> saveAIAssistant(AIAssistantModel assistant) async {
    try {
      await _firestore
          .collection('ai_assistants')
          .doc(assistant.id)
          .set(assistant.toMap());
    } catch (e) {
      throw Exception('Failed to save AI Assistant: $e');
    }
  }

  // Get current user's AI Assistant
  Future<AIAssistantModel?> getCurrentUserAIAssistant() async {
    try {
      final userId = getCurrentUserId();
      print('DEBUG REPO: Searching for user ID: $userId');
      
      final querySnapshot = await _firestore
          .collection('ai_assistants')
          .where('userId', isEqualTo: userId)
          .get();

      print('DEBUG REPO: Found ${querySnapshot.docs.length} documents');
      
      if (querySnapshot.docs.isNotEmpty) {
        // Sort manually to get the most recent
        final docs = querySnapshot.docs.toList();
        docs.sort((a, b) {
          final aTime = DateTime.parse(a.data()['updatedAt']);
          final bTime = DateTime.parse(b.data()['updatedAt']);
          return bTime.compareTo(aTime); // Descending order
        });
        
        final doc = docs.first;
        print('DEBUG REPO: Document data: ${doc.data()}');
        return AIAssistantModel.fromMap({
          'id': doc.id,
          ...doc.data(),
        });
      }
      return null;
    } catch (e) {
      print('DEBUG REPO: Error: $e');
      throw Exception('Failed to get AI Assistant: $e');
    }
  }

  // Get AI Assistant by ID
  Future<AIAssistantModel?> getAIAssistantById(String id) async {
    try {
      final doc = await _firestore.collection('ai_assistants').doc(id).get();
      if (doc.exists) {
        return AIAssistantModel.fromMap({
          'id': doc.id,
          ...doc.data()!,
        });
      }
      return null;
    } catch (e) {
      throw Exception('Failed to get AI Assistant: $e');
    }
  }

  // Get all AI Assistants for current user
  Future<List<AIAssistantModel>> getAllUserAIAssistants() async {
    try {
      final userId = getCurrentUserId();
      final querySnapshot = await _firestore
          .collection('ai_assistants')
          .where('userId', isEqualTo: userId)
          .orderBy('updatedAt', descending: true)
          .get();

      return querySnapshot.docs.map((doc) {
        return AIAssistantModel.fromMap({
          'id': doc.id,
          ...doc.data(),
        });
      }).toList();
    } catch (e) {
      throw Exception('Failed to get AI Assistants: $e');
    }
  }

  // Delete AI Assistant
  Future<void> deleteAIAssistant(String id) async {
    try {
      await _firestore.collection('ai_assistants').doc(id).delete();
    } catch (e) {
      throw Exception('Failed to delete AI Assistant: $e');
    }
  }

  // Update AI Assistant
  Future<void> updateAIAssistant(AIAssistantModel assistant) async {
    try {
      final updatedAssistant = assistant.copyWith(updatedAt: DateTime.now());
      await _firestore
          .collection('ai_assistants')
          .doc(assistant.id)
          .update(updatedAssistant.toMap());
    } catch (e) {
      throw Exception('Failed to update AI Assistant: $e');
    }
  }
}
