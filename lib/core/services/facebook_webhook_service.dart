import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'package:minechat/core/config/webhook_config.dart';

/// Facebook Webhook Service for Real-Time Messaging
class FacebookWebhookService {
  static const String _webhookUrl = WebhookConfig.webhookUrl;
  static const String _secretToken = WebhookConfig.secretToken;
  
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  StreamSubscription? _webhookSubscription;
  Timer? _heartbeatTimer;
  
  String getCurrentUserId() {
    return FirebaseAuth.instance.currentUser?.uid ?? '';
  }

  /// Start listening for webhook messages
  void startWebhookListening() {
    final userId = getCurrentUserId();
    if (userId.isEmpty) {
      print('⚠️ No user ID found, skipping webhook listening');
      return;
    }

    // Check if we're already listening
    if (_webhookSubscription != null) {
      print('⚠️ Webhook already listening, skipping');
      return;
    }

    print('🔄 Starting Facebook webhook listening for user: $userId');
    
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
          print('📨 Webhook update: ${snapshot.docs.length} messages');
          
          // Process new webhook messages
          for (final doc in snapshot.docChanges) {
            if (doc.type == DocumentChangeType.added) {
              final messageData = doc.doc.data() as Map<String, dynamic>;
              _handleWebhookMessage(messageData);
            }
          }
        },
        onError: (error) {
          print('❌ Error listening for webhook messages: $error');
        },
      );

      // Start heartbeat to keep webhook active
      _startHeartbeat();
      
      print('✅ Webhook listening started successfully');
    } catch (e) {
      print('❌ Error starting webhook listening: $e');
    }
  }

  /// Handle incoming webhook message
  void _handleWebhookMessage(Map<String, dynamic> messageData) {
    try {
      print('📨 Webhook message received: ${messageData['text']}');
      
      // Extract message details
      final conversationId = messageData['conversationId'];
      final messageText = messageData['text'];
      final isFromUser = messageData['isFromUser'] ?? true; // Webhook messages are usually from users
      final senderId = messageData['senderId'];
      final senderName = messageData['senderName'] ?? 'Facebook User';
      final timestamp = messageData['timestamp'];
      
      // Notify chat controllers about new message
      _notifyChatControllers(
        conversationId: conversationId,
        messageText: messageText,
        isFromUser: isFromUser,
        senderId: senderId,
        senderName: senderName,
        timestamp: timestamp,
      );
      
      print('✅ Webhook message processed successfully');
    } catch (e) {
      print('❌ Error handling webhook message: $e');
    }
  }

  /// Notify chat controllers about new message
  void _notifyChatControllers({
    required String conversationId,
    required String messageText,
    required bool isFromUser,
    required String senderId,
    required String senderName,
    required String timestamp,
  }) {
    try {
      // Store message data for controllers to pick up
      final messageData = {
        'conversationId': conversationId,
        'text': messageText,
        'isFromUser': isFromUser,
        'senderId': senderId,
        'senderName': senderName,
        'timestamp': timestamp,
        'source': 'webhook',
        'createdAt': DateTime.now().toIso8601String(),
      };

      // Store in Firebase for controllers to listen to
      storeWebhookMessage(
        conversationId: conversationId,
        messageText: messageText,
        isFromUser: isFromUser,
        senderId: senderId,
        senderName: senderName,
        timestamp: timestamp,
      );

      print('✅ Webhook message stored for controller pickup');
    } catch (e) {
      print('❌ Error notifying controllers: $e');
    }
  }

  /// Start heartbeat to keep webhook connection active
  void _startHeartbeat() {
    _heartbeatTimer = Timer.periodic(Duration(minutes: 5), (timer) {
      _sendHeartbeat();
    });
    print('💓 Started webhook heartbeat');
  }

  /// Send heartbeat to webhook
  Future<void> _sendHeartbeat() async {
    try {
      final response = await http.post(
        Uri.parse('$_webhookUrl/heartbeat'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $_secretToken',
        },
        body: jsonEncode({
          'userId': getCurrentUserId(),
          'timestamp': DateTime.now().toIso8601String(),
        }),
      );

      if (response.statusCode == 200) {
        print('💓 Webhook heartbeat successful');
      } else {
        print('⚠️ Webhook heartbeat failed: ${response.statusCode}');
      }
    } catch (e) {
      print('❌ Webhook heartbeat error: $e');
    }
  }

  /// Store webhook message in Firebase
  Future<void> storeWebhookMessage({
    required String conversationId,
    required String messageText,
    required bool isFromUser,
    required String senderId,
    required String senderName,
    required String timestamp,
  }) async {
    try {
      final userId = getCurrentUserId();
      if (userId.isEmpty) return;

      final messageData = {
        'conversationId': conversationId,
        'text': messageText,
        'isFromUser': isFromUser,
        'senderId': senderId,
        'senderName': senderName,
        'timestamp': timestamp,
        'source': 'webhook',
        'createdAt': FieldValue.serverTimestamp(),
      };

      await _firestore
          .collection('webhook_messages')
          .doc(userId)
          .collection('messages')
          .add(messageData);

      print('✅ Webhook message stored in Firebase');
    } catch (e) {
      print('❌ Error storing webhook message: $e');
    }
  }

  /// Verify webhook connection
  Future<bool> verifyWebhookConnection() async {
    try {
      final response = await http.get(
        Uri.parse('$_webhookUrl/status'),
        headers: {
          'Authorization': 'Bearer $_secretToken',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        print('✅ Webhook connection verified: ${data['status']}');
        return true;
      } else {
        print('❌ Webhook verification failed: ${response.statusCode}');
        return false;
      }
    } catch (e) {
      print('❌ Webhook verification error: $e');
      return false;
    }
  }

  /// Stop webhook listening
  void stopWebhookListening() {
    _webhookSubscription?.cancel();
    _heartbeatTimer?.cancel();
    _webhookSubscription = null;
    _heartbeatTimer = null;
    print('🛑 Stopped webhook listening');
  }

  /// Clean up old webhook messages
  Future<void> cleanupOldWebhookMessages() async {
    try {
      final userId = getCurrentUserId();
      if (userId.isEmpty) return;

      // Delete messages older than 7 days
      final cutoffDate = DateTime.now().subtract(Duration(days: 7));
      
      final oldMessages = await _firestore
          .collection('webhook_messages')
          .doc(userId)
          .collection('messages')
          .where('createdAt', isLessThan: cutoffDate)
          .get();

      for (final message in oldMessages.docs) {
        await message.reference.delete();
      }

      print('🧹 Cleaned up ${oldMessages.docs.length} old webhook messages');
    } catch (e) {
      print('❌ Error cleaning up webhook messages: $e');
    }
  }
}

// Note: Controllers will be imported via Get.find() at runtime
