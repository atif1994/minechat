import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:cloud_firestore/cloud_firestore.dart';

class FacebookMessengerService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  
  // Facebook Graph API base URL
  static const String _graphApiBase = 'https://graph.facebook.com/v18.0';
  
  /// Get Facebook page conversations
  Future<List<Map<String, dynamic>>> getPageConversations({
    required String pageId,
    required String accessToken,
  }) async {
    try {
      final url = '$_graphApiBase/$pageId/conversations?access_token=$accessToken';
      final response = await http.get(Uri.parse(url));
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final conversations = data['data'] as List;
        
        return conversations.map((conv) {
          return {
            'id': conv['id'],
            'updated_time': conv['updated_time'],
            'message_count': conv['message_count'],
            'unread_count': conv['unread_count'] ?? 0,
            'participants': conv['participants'] ?? [],
          };
        }).toList();
      } else {
        throw Exception('Failed to fetch conversations: ${response.statusCode}');
      }
    } catch (e) {
      print('❌ Error fetching Facebook conversations: $e');
      rethrow;
    }
  }
  
  /// Get messages from a conversation
  Future<List<Map<String, dynamic>>> getConversationMessages({
    required String conversationId,
    required String accessToken,
  }) async {
    try {
      final url = '$_graphApiBase/$conversationId/messages?access_token=$accessToken';
      final response = await http.get(Uri.parse(url));
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final messages = data['data'] as List;
        
        return messages.map((msg) {
          return {
            'id': msg['id'],
            'message': msg['message'] ?? '',
            'from': msg['from'],
            'to': msg['to'],
            'created_time': msg['created_time'],
            'attachments': msg['attachments'] ?? [],
          };
        }).toList();
      } else {
        throw Exception('Failed to fetch messages: ${response.statusCode}');
      }
    } catch (e) {
      print('❌ Error fetching Facebook messages: $e');
      rethrow;
    }
  }
  
  /// Send message to Facebook conversation
  Future<bool> sendMessage({
    required String conversationId,
    required String message,
    required String accessToken,
  }) async {
    try {
      final url = '$_graphApiBase/$conversationId/messages';
      final body = {
        'message': message,
        'access_token': accessToken,
      };
      
      final response = await http.post(
        Uri.parse(url),
        body: body,
      );
      
      if (response.statusCode == 200) {
        return true;
      } else {
        print('❌ Failed to send message: ${response.statusCode} - ${response.body}');
        return false;
      }
    } catch (e) {
      print('❌ Error sending Facebook message: $e');
      return false;
    }
  }
  
  /// Verify Facebook access token
  Future<bool> verifyAccessToken({
    required String accessToken,
    required String pageId,
  }) async {
    try {
      final url = '$_graphApiBase/$pageId?fields=id,name,access_token&access_token=$accessToken';
      final response = await http.get(Uri.parse(url));
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['id'] == pageId;
      } else {
        return false;
      }
    } catch (e) {
      print('❌ Error verifying Facebook access token: $e');
      return false;
    }
  }
  
  /// Store Facebook webhook data
  Future<void> storeWebhookData({
    required String userId,
    required Map<String, dynamic> webhookData,
  }) async {
    try {
      await _firestore
          .collection('facebook_webhooks')
          .doc(userId)
          .collection('messages')
          .add({
        'data': webhookData,
        'timestamp': FieldValue.serverTimestamp(),
        'processed': false,
      });
    } catch (e) {
      print('❌ Error storing webhook data: $e');
      rethrow;
    }
  }
  
  /// Get unprocessed webhook messages
  Future<List<Map<String, dynamic>>> getUnprocessedWebhooks({
    required String userId,
  }) async {
    try {
      final snapshot = await _firestore
          .collection('facebook_webhooks')
          .doc(userId)
          .collection('messages')
          .where('processed', isEqualTo: false)
          .orderBy('timestamp', descending: true)
          .get();
      
      return snapshot.docs.map((doc) {
        final data = doc.data();
        return {
          'id': doc.id,
          'data': data['data'],
          'timestamp': data['timestamp'],
        };
      }).toList();
    } catch (e) {
      print('❌ Error getting unprocessed webhooks: $e');
      return [];
    }
  }
  
  /// Mark webhook as processed
  Future<void> markWebhookProcessed({
    required String userId,
    required String webhookId,
  }) async {
    try {
      await _firestore
          .collection('facebook_webhooks')
          .doc(userId)
          .collection('messages')
          .doc(webhookId)
          .update({'processed': true});
    } catch (e) {
      print('❌ Error marking webhook as processed: $e');
    }
  }
  
  /// Get page info
  Future<Map<String, dynamic>?> getPageInfo({
    required String pageId,
    required String accessToken,
  }) async {
    try {
      final url = '$_graphApiBase/$pageId?fields=id,name,picture,fan_count&access_token=$accessToken';
      final response = await http.get(Uri.parse(url));
      
      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        return null;
      }
    } catch (e) {
      print('❌ Error getting page info: $e');
      return null;
    }
  }
}
