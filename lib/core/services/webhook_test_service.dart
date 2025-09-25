import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

/// Test service to simulate webhook messages for testing
class WebhookTestService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  
  String getCurrentUserId() {
    return FirebaseAuth.instance.currentUser?.uid ?? '';
  }

  /// Simulate a webhook message for testing
  Future<void> simulateWebhookMessage({
    required String conversationId,
    required String messageText,
    required String senderName,
  }) async {
    try {
      final userId = getCurrentUserId();
      if (userId.isEmpty) {
        print('❌ No user ID found for testing');
        return;
      }

      final messageData = {
        'conversationId': conversationId,
        'text': messageText,
        'isFromUser': true,
        'senderId': 'test_user_123',
        'senderName': senderName,
        'timestamp': DateTime.now().toIso8601String(),
        'source': 'webhook_test',
        'createdAt': FieldValue.serverTimestamp(),
      };

      await _firestore
          .collection('webhook_messages')
          .doc(userId)
          .collection('messages')
          .add(messageData);

      print('✅ Test webhook message sent: $messageText');
    } catch (e) {
      print('❌ Error sending test webhook message: $e');
    }
  }

  /// Test webhook connection
  Future<void> testWebhookConnection() async {
    try {
      print('🧪 Testing webhook connection...');
      
      // Simulate a test message
      await simulateWebhookMessage(
        conversationId: 'test_conversation_123',
        messageText: 'Test message from webhook simulation',
        senderName: 'Test User',
      );
      
      print('✅ Webhook test completed');
    } catch (e) {
      print('❌ Webhook test failed: $e');
    }
  }
}
