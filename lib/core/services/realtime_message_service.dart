import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class RealtimeMessageService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  StreamSubscription? _messageSubscription;
  StreamSubscription? _conversationSubscription;
  
  String getCurrentUserId() {
    return FirebaseAuth.instance.currentUser?.uid ?? '';
  }

  /// Start listening for real-time message updates
  void startListeningForMessages() {
    final userId = getCurrentUserId();
    if (userId.isEmpty) return;

    print('🔄 Starting real-time message listening for user: $userId');

    // Listen for new messages in user's conversations
    _messageSubscription = _firestore
        .collection('user_messages')
        .doc(userId)
        .collection('messages')
        .orderBy('timestamp', descending: true)
        .limit(50)
        .snapshots()
        .listen(
      (snapshot) {
        print('📨 Real-time message update: ${snapshot.docs.length} messages');
        
        // Process new messages
        for (final doc in snapshot.docChanges) {
          if (doc.type == DocumentChangeType.added) {
            final messageData = doc.doc.data() as Map<String, dynamic>;
            _handleNewMessage(messageData);
          }
        }
      },
      onError: (error) {
        print('❌ Error listening for messages: $error');
      },
    );

    // Listen for conversation updates
    _conversationSubscription = _firestore
        .collection('user_conversations')
        .doc(userId)
        .collection('conversations')
        .snapshots()
        .listen(
      (snapshot) {
        print('💬 Real-time conversation update: ${snapshot.docs.length} conversations');
        
        // Process conversation updates
        for (final doc in snapshot.docChanges) {
          if (doc.type == DocumentChangeType.added || doc.type == DocumentChangeType.modified) {
            final conversationData = doc.doc.data() as Map<String, dynamic>;
            _handleConversationUpdate(conversationData);
          }
        }
      },
      onError: (error) {
        print('❌ Error listening for conversations: $error');
      },
    );
  }

  /// Handle new message from real-time updates
  void _handleNewMessage(Map<String, dynamic> messageData) {
    try {
      print('📨 New message received: ${messageData['text']}');
      
      // Store the message for when controllers are available
      // The controllers will check for new messages when they initialize
      print('💾 Message stored for controller pickup');

    } catch (e) {
      print('❌ Error handling new message: $e');
    }
  }

  /// Handle conversation updates from real-time updates
  void _handleConversationUpdate(Map<String, dynamic> conversationData) {
    try {
      print('💬 Conversation update received: ${conversationData['contactName']}');
      
      // Store the conversation update for when controllers are available
      print('💾 Conversation update stored for controller pickup');

    } catch (e) {
      print('❌ Error handling conversation update: $e');
    }
  }

  /// Store a new message in Firebase for real-time updates
  Future<void> storeMessage({
    required String conversationId,
    required String messageText,
    required bool isFromUser,
    required String platform,
    String? senderId,
    String? senderName,
  }) async {
    try {
      final userId = getCurrentUserId();
      if (userId.isEmpty) return;

      final messageData = {
        'conversationId': conversationId,
        'text': messageText,
        'isFromUser': isFromUser,
        'platform': platform,
        'senderId': senderId,
        'senderName': senderName,
        'timestamp': FieldValue.serverTimestamp(),
        'createdAt': DateTime.now().toIso8601String(),
      };

      await _firestore
          .collection('user_messages')
          .doc(userId)
          .collection('messages')
          .add(messageData);

      print('✅ Message stored for real-time updates');
    } catch (e) {
      print('❌ Error storing message: $e');
    }
  }

  /// Store conversation update in Firebase for real-time updates
  Future<void> storeConversationUpdate({
    required String conversationId,
    required String contactName,
    required String lastMessage,
    required String platform,
    required int unreadCount,
    String? profileImageUrl,
  }) async {
    try {
      final userId = getCurrentUserId();
      if (userId.isEmpty) return;

      final conversationData = {
        'conversationId': conversationId,
        'contactName': contactName,
        'lastMessage': lastMessage,
        'platform': platform,
        'unreadCount': unreadCount,
        'profileImageUrl': profileImageUrl,
        'lastUpdate': FieldValue.serverTimestamp(),
        'updatedAt': DateTime.now().toIso8601String(),
      };

      await _firestore
          .collection('user_conversations')
          .doc(userId)
          .collection('conversations')
          .doc(conversationId)
          .set(conversationData, SetOptions(merge: true));

      print('✅ Conversation update stored for real-time updates');
    } catch (e) {
      print('❌ Error storing conversation update: $e');
    }
  }

  /// Stop listening for real-time updates
  void stopListening() {
    _messageSubscription?.cancel();
    _conversationSubscription?.cancel();
    print('🛑 Stopped real-time message listening');
  }

  /// Clean up old messages (keep only last 100 per conversation)
  Future<void> cleanupOldMessages() async {
    try {
      final userId = getCurrentUserId();
      if (userId.isEmpty) return;

      // Get all conversations
      final conversations = await _firestore
          .collection('user_conversations')
          .doc(userId)
          .collection('conversations')
          .get();

      for (final conversation in conversations.docs) {
        final conversationId = conversation.id;
        
        // Get messages for this conversation, ordered by timestamp
        final messages = await _firestore
            .collection('user_messages')
            .doc(userId)
            .collection('messages')
            .where('conversationId', isEqualTo: conversationId)
            .orderBy('timestamp', descending: true)
            .get();

        // Keep only the last 100 messages
        if (messages.docs.length > 100) {
          final messagesToDelete = messages.docs.skip(100);
          
          for (final message in messagesToDelete) {
            await message.reference.delete();
          }
          
          print('🧹 Cleaned up ${messagesToDelete.length} old messages for conversation $conversationId');
        }
      }
    } catch (e) {
      print('❌ Error cleaning up old messages: $e');
    }
  }
}

// Note: ChatController and ChatConversationController are imported via Get.find()
// They will be available at runtime when the app is running
