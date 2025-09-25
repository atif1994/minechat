import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

/// Simple Webhook Service - No controller dependencies
class SimpleWebhookService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  StreamSubscription? _webhookSubscription;
  
  String getCurrentUserId() {
    return FirebaseAuth.instance.currentUser?.uid ?? '';
  }

  /// Start simple webhook listening
  void startSimpleWebhookListening() {
    final userId = getCurrentUserId();
    if (userId.isEmpty) {
      print('⚠️ No user ID found, skipping simple webhook listening');
      return;
    }

    print('🔄 Starting simple webhook listening for user: $userId');
    
    try {
      // Listen for webhook messages in Firebase
      _webhookSubscription = _firestore
          .collection('webhook_messages')
          .doc(userId)
          .collection('messages')
          .orderBy('timestamp', descending: true)
          .snapshots()
          .listen(
        (snapshot) {
          print('📨 Simple webhook update: ${snapshot.docs.length} messages');
          
          // Just log the messages for now
          for (final doc in snapshot.docChanges) {
            if (doc.type == DocumentChangeType.added) {
              final messageData = doc.doc.data() as Map<String, dynamic>;
              print('📨 New webhook message: ${messageData['text']}');
            }
          }
        },
        onError: (error) {
          print('❌ Error in simple webhook listening: $error');
        },
      );
      
      print('✅ Simple webhook listening started successfully');
    } catch (e) {
      print('❌ Error starting simple webhook listening: $e');
    }
  }

  /// Stop simple webhook listening
  void stopSimpleWebhookListening() {
    _webhookSubscription?.cancel();
    _webhookSubscription = null;
    print('🛑 Stopped simple webhook listening');
  }
}
