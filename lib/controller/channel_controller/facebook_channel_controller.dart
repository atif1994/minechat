import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:minechat/core/services/facebook_graph_api_service.dart';
import 'package:minechat/core/services/facebook_token_exchange_service.dart';
import 'base_channel_controller.dart';

/// Facebook-specific channel controller
class FacebookChannelController extends BaseChannelController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  
  // Facebook-specific fields
  final facebookPageIdCtrl = TextEditingController();
  final facebookAccessTokenCtrl = TextEditingController();
  
  // Facebook connection state
  var facebookPageName = ''.obs;
  var facebookPagePicture = ''.obs;
  
  @override
  void onInit() {
    super.onInit();
    loadFacebookConnection();
  }
  
  @override
  void onClose() {
    facebookPageIdCtrl.dispose();
    facebookAccessTokenCtrl.dispose();
    super.onClose();
  }
  
  /// Load existing Facebook connection
  Future<void> loadFacebookConnection() async {
    try {
      final data = await loadConnectionStatus('facebook');
      if (data != null) {
        facebookPageIdCtrl.text = data['pageId'] ?? '';
        facebookAccessTokenCtrl.text = data['accessToken'] ?? '';
        isConnected.value = data['isConnected'] ?? false;
        facebookPageName.value = data['pageName'] ?? '';
        facebookPagePicture.value = data['pagePicture'] ?? '';
        
        if (isConnected.value) {
          connectionStatus.value = 'Connected';
        }
      }
    } catch (e) {
      print('❌ Error loading Facebook connection: $e');
    }
  }
  
  /// Connect to Facebook
  @override
  Future<void> performConnection() async {
    final pageId = facebookPageIdCtrl.text.trim();
    final accessToken = facebookAccessTokenCtrl.text.trim();
    
    if (!validateRequiredFields({
      'Page ID': pageId,
      'Access Token': accessToken,
    })) return;
    
    // Test the connection
    final isValid = await _validateFacebookToken(pageId, accessToken);
    if (!isValid) {
      throw Exception('Invalid Facebook credentials');
    }
    
    // Get page information
    final pageInfo = await _getPageInfo(pageId, accessToken);
    if (pageInfo == null) {
      throw Exception('Failed to get page information');
    }
    
    // Save connection data
    await saveConnectionStatus('facebook', {
      'pageId': pageId,
      'accessToken': accessToken,
      'isConnected': true,
      'pageName': pageInfo['name'],
      'pagePicture': pageInfo['picture']?['data']?['url'],
      'connectedAt': FieldValue.serverTimestamp(),
    });
    
    facebookPageName.value = pageInfo['name'] ?? '';
    facebookPagePicture.value = pageInfo['picture']?['data']?['url'] ?? '';
  }
  
  /// Disconnect from Facebook
  @override
  Future<void> performDisconnection() async {
    await saveConnectionStatus('facebook', {
      'isConnected': false,
      'disconnectedAt': FieldValue.serverTimestamp(),
    });
    
    facebookPageIdCtrl.clear();
    facebookAccessTokenCtrl.clear();
    facebookPageName.value = '';
    facebookPagePicture.value = '';
  }
  
  /// Test Facebook connection
  @override
  Future<bool> testConnection() async {
    final pageId = facebookPageIdCtrl.text.trim();
    final accessToken = facebookAccessTokenCtrl.text.trim();
    
    if (pageId.isEmpty || accessToken.isEmpty) return false;
    
    return await _validateFacebookToken(pageId, accessToken);
  }
  
  /// Validate Facebook token
  Future<bool> _validateFacebookToken(String pageId, String accessToken) async {
    try {
      final result = await FacebookGraphApiService.getPageInfo(pageId, accessToken);
      return result['success'] == true;
    } catch (e) {
      print('❌ Facebook token validation failed: $e');
      return false;
    }
  }
  
  /// Get page information
  Future<Map<String, dynamic>?> _getPageInfo(String pageId, String accessToken) async {
    try {
      final result = await FacebookGraphApiService.getPageInfo(pageId, accessToken);
      if (result['success'] == true) {
        return result['data'];
      }
      return null;
    } catch (e) {
      print('❌ Error getting page info: $e');
      return null;
    }
  }
  
  /// Get stored page access token
  Future<String?> getPageAccessToken(String pageId) async {
    try {
      final userId = getCurrentUserId();
      if (userId.isEmpty) {
        print('❌ No user ID found');
        return null;
      }

      print('🔍 Looking for access token for page: $pageId, user: $userId');

      // Check Firebase Functions collection first (where tokens are actually stored)
      print('🔍 Checking Firebase Functions collection...');
      final functionsDoc = await _firestore
          .collection('integrations')
          .doc('facebook')
          .collection('pages')
          .doc(pageId)
          .get();

      if (functionsDoc.exists) {
        final data = functionsDoc.data()!;
        final token = data['pageAccessToken'] as String?;
        
        if (token != null && token.isNotEmpty) {
          print('✅ Found access token in Firebase Functions collection');
          print('🔑 Token preview: ${token.substring(0, 10)}...');
          return token;
        } else {
          print('❌ No access token in Firebase Functions collection');
        }
      } else {
        print('⚠️ No document found in Firebase Functions collection');
      }

      // Fallback to secure_tokens collection (Flutter app storage)
      print('🔍 Checking secure_tokens collection...');
      final secureDoc = await _firestore
          .collection('secure_tokens')
          .doc(userId)
          .get();

      if (secureDoc.exists) {
        final data = secureDoc.data()!;
        final pageTokens = data['facebookPageTokens'] as Map<String, dynamic>?;
        final token = pageTokens?[pageId] as String?;

        if (token != null && token.isNotEmpty) {
          print('✅ Found access token in secure_tokens collection');
          print('🔑 Token preview: ${token.substring(0, 10)}...');
          return token;
        } else {
          print('❌ No access token found for page: $pageId');
          print('📋 Available page tokens: ${pageTokens?.keys.toList()}');
        }
      } else {
        print('⚠️ No secure_tokens document found for user: $userId');
        print('💡 This means Facebook page was not properly connected');
        print('💡 User needs to reconnect Facebook page with access token');
      }

      print('❌ No access token found in any collection');
      return null;
    } catch (e) {
      print('❌ Error getting page access token: $e');
      return null;
    }
  }
  
  /// Handle OAuth callback
  void handleOAuthCallback(String code, String state) {
    print('🔗 Handling OAuth callback - code: $code, state: $state');
    // Implement OAuth callback handling
  }
}
