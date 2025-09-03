import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';

class FacebookGraphApiService {
  static const String _backendUrl = "https://449a5e08-99f4-4100-9571-62eeba47fe54-00-3gozoz68wjgp4.spock.replit.dev/api/facebook";
  static const String _appId = "1465171591136323";
  static const String _redirectUri = "minechat://facebook-oauth-callback";
  static const List<String> _permissions = [
    "pages_show_list",
    "pages_messaging",
    "pages_manage_metadata",
    "pages_read_engagement",
  ];

  /// Start Facebook OAuth (just open URL)
  static Future<Map<String, dynamic>> startOAuthFlow() async {
    final state = DateTime.now().millisecondsSinceEpoch.toString();
    final authUrl = Uri.https("www.facebook.com", "/v18.0/dialog/oauth", {
      "client_id": _appId,
      "redirect_uri": _redirectUri,
      "scope": _permissions.join(","),
      "state": state,
      "response_type": "code",
    });

    if (await canLaunchUrl(authUrl)) {
      await launchUrl(authUrl, mode: LaunchMode.externalApplication);
      return {"success": true, "authUrl": authUrl.toString(), "state": state};
    } else {
      return {"success": false, "error": "Could not launch Facebook OAuth URL"};
    }
  }

  /// Send OAuth code to backend
  static Future<Map<String, dynamic>> handleOAuthCallback(String code) async {
    try {
      final response = await http.post(
        Uri.parse("$_backendUrl/oauth/callback"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"code": code, "redirectUri": _redirectUri}),
      );
      return jsonDecode(response.body);
    } catch (e) {
      return {"success": false, "error": e.toString()};
    }
  }

  /// Get user pages (backend approach)
  static Future<Map<String, dynamic>> getUserPages() async {
    try {
      final response = await http.get(Uri.parse("$_backendUrl/pages"));
      return jsonDecode(response.body);
    } catch (e) {
      return {"success": false, "error": e.toString()};
    }
  }

  /// Get user pages with access token (direct API approach)
  static Future<Map<String, dynamic>> getUserPagesWithToken(String accessToken) async {
    try {
      final response = await http.get(
        Uri.https("graph.facebook.com", "/v18.0/me/accounts", {
          "access_token": accessToken,
          "fields": "id,name,access_token,category"
        }),
      );
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return {"success": true, "data": data};
      } else {
        return {"success": false, "error": "Failed to fetch pages: ${response.statusCode}"};
      }
    } catch (e) {
      return {"success": false, "error": e.toString()};
    }
  }

  /// Verify access token
  static Future<Map<String, dynamic>> verifyAccessToken(String accessToken) async {
    try {
      final response = await http.get(
        Uri.https("graph.facebook.com", "/v18.0/me", {
          "access_token": accessToken,
          "fields": "id,name,email"
        }),
      );
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return {"success": true, "data": data};
      } else {
        final error = jsonDecode(response.body);
        return {
          "success": false, 
          "error": error['error']?['message'] ?? "Invalid access token",
          "errorType": error['error']?['type'] ?? "unknown"
        };
      }
    } catch (e) {
      return {"success": false, "error": e.toString()};
    }
  }

  /// Verify page access
  static Future<Map<String, dynamic>> verifyPageAccess(String pageId, String pageAccessToken) async {
    try {
      final response = await http.get(
        Uri.https("graph.facebook.com", "/v18.0/$pageId", {
          "access_token": pageAccessToken,
          "fields": "id,name,category"
        }),
      );
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return {"success": true, "data": data};
      } else {
        final error = jsonDecode(response.body);
        return {
          "success": false, 
          "error": error['error']?['message'] ?? "Cannot access page"
        };
      }
    } catch (e) {
      return {"success": false, "error": e.toString()};
    }
  }

  /// Get conversations for a page
  static Future<Map<String, dynamic>> getPageConversations(String pageId) async {
    try {
      final response = await http.get(Uri.parse("$_backendUrl/$pageId/conversations"));
      return jsonDecode(response.body);
    } catch (e) {
      return {"success": false, "error": e.toString()};
    }
  }

  /// Get messages in a conversation
  static Future<Map<String, dynamic>> getConversationMessages(String conversationId) async {
    try {
      final response = await http.get(Uri.parse("$_backendUrl/conversations/$conversationId/messages"));
      return jsonDecode(response.body);
    } catch (e) {
      return {"success": false, "error": e.toString()};
    }
  }

  /// Send message
  static Future<Map<String, dynamic>> sendMessage(String conversationId, String message) async {
    try {
      final response = await http.post(
        Uri.parse("$_backendUrl/conversations/$conversationId/messages"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"message": message}),
      );
      return jsonDecode(response.body);
    } catch (e) {
      return {"success": false, "error": e.toString()};
    }
  }
}
