import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/app_config.dart';

class FacebookService {
  static Future<Map<String, dynamic>> derivePageToken(
      {required String pageId}) async {
    final resp = await http.post(
      Uri.parse(AppConfig.fbDerivePageTokenUrl),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'pageId': pageId}),
    );
    final data = jsonDecode(resp.body);
    if (resp.statusCode == 200 && data is Map<String, dynamic>) return data;
    throw Exception(
        'fbDerivePageToken failed: ${resp.statusCode} ${resp.body}');
  }

  static Future<Map<String, dynamic>> sendMessage({
    required String pageId,
    required String recipientId,
    required String text,
  }) async {
    final resp = await http.post(
      Uri.parse(AppConfig.fbSendMessageUrl),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(
          {'pageId': pageId, 'recipientId': recipientId, 'text': text}),
    );
    final data = jsonDecode(resp.body);
    if (resp.statusCode == 200 && data is Map<String, dynamic>) return data;
    throw Exception('fbSendMessage failed: ${resp.statusCode} ${resp.body}');
  }
}
