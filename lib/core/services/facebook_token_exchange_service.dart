// import 'dart:convert';
// import 'package:http/http.dart' as http;
// import 'package:minechat/core/config/app_config.dart';
//
// class FacebookTokenExchangeService {
//   static const String _baseUrl = 'https://graph.facebook.com/v23.0';
//
//   /// Exchange short-lived token for long-lived token (60 days)
//   static Future<Map<String, dynamic>> exchangeForLongLivedToken({
//     required String shortLivedToken,
//   }) async {
//     try {
//       print('🔄 Exchanging short-lived token for long-lived token...');
//
//       final url = Uri.parse('$_baseUrl/oauth/access_token');
//       final response = await http.get(
//         url.replace(
//           queryParameters: {
//             'grant_type': 'fb_exchange_token',
//             'client_id': AppConfig.facebookAppId,
//             'client_secret': AppConfig.facebookAppSecret,
//             'fb_exchange_token': shortLivedToken,
//           },
//         ),
//       );
//
//       if (response.statusCode == 200) {
//         final data = json.decode(response.body);
//         print('✅ Long-lived token exchange successful');
//         return {
//           'success': true,
//           'access_token': data['access_token'],
//           'expires_in': data['expires_in'],
//           'token_type': data['token_type'],
//         };
//       } else {
//         print('❌ Token exchange failed: ${response.statusCode} - ${response.body}');
//         return {
//           'success': false,
//           'error': 'Token exchange failed: ${response.statusCode}',
//           'details': response.body,
//         };
//       }
//     } catch (e) {
//       print('❌ Error exchanging token: $e');
//       return {
//         'success': false,
//         'error': 'Network error: $e',
//       };
//     }
//   }
//
//   /// Get page access tokens (never-expiring)
//   static Future<Map<String, dynamic>> getPageAccessTokens({
//     required String longLivedUserToken,
//   }) async {
//     try {
//       print('🔄 Getting page access tokens...');
//
//       final url = Uri.parse('$_baseUrl/me/accounts');
//       final response = await http.get(
//         url.replace(
//           queryParameters: {
//             'access_token': longLivedUserToken,
//             'fields': 'id,name,access_token',
//           },
//         ),
//       );
//
//       if (response.statusCode == 200) {
//         final data = json.decode(response.body);
//         print('✅ Page tokens retrieved successfully');
//
//         // Extract page tokens
//         final pages = <Map<String, dynamic>>[];
//         if (data['data'] != null) {
//           for (var page in data['data']) {
//             pages.add({
//               'id': page['id'],
//               'name': page['name'],
//               'access_token': page['access_token'],
//             });
//           }
//         }
//
//         return {
//           'success': true,
//           'pages': pages,
//         };
//       } else {
//         print('❌ Failed to get page tokens: ${response.statusCode} - ${response.body}');
//         return {
//           'success': false,
//           'error': 'Failed to get page tokens: ${response.statusCode}',
//           'details': response.body,
//         };
//       }
//     } catch (e) {
//       print('❌ Error getting page tokens: $e');
//       return {
//         'success': false,
//         'error': 'Network error: $e',
//       };
//     }
//   }
//
//   /// Complete token exchange process: short-lived -> long-lived -> page tokens
//   static Future<Map<String, dynamic>> completeTokenExchange({
//     required String shortLivedToken,
//   }) async {
//     try {
//       print('🚀 Starting complete token exchange process...');
//
//       // Step 1: Exchange for long-lived token
//       final longLivedResult = await exchangeForLongLivedToken(
//         shortLivedToken: shortLivedToken,
//       );
//
//       if (!longLivedResult['success']) {
//         return longLivedResult;
//       }
//
//       final longLivedToken = longLivedResult['access_token'];
//       print('✅ Step 1 complete: Long-lived token obtained');
//
//       // Step 2: Get page access tokens
//       final pageTokensResult = await getPageAccessTokens(
//         longLivedUserToken: longLivedToken,
//       );
//
//       if (!pageTokensResult['success']) {
//         return pageTokensResult;
//       }
//
//       print('✅ Step 2 complete: Page tokens obtained');
//
//       return {
//         'success': true,
//         'long_lived_token': longLivedToken,
//         'expires_in': longLivedResult['expires_in'],
//         'pages': pageTokensResult['pages'],
//         'message': 'Token exchange completed successfully! Page tokens never expire.',
//       };
//     } catch (e) {
//       print('❌ Error in complete token exchange: $e');
//       return {
//         'success': false,
//         'error': 'Complete exchange failed: $e',
//       };
//     }
//   }
//
//   /// Verify if a token is valid
//   static Future<Map<String, dynamic>> verifyToken({
//     required String token,
//   }) async {
//     try {
//       print('🔍 Verifying token validity...');
//
//       final url = Uri.parse('$_baseUrl/me');
//       final response = await http.get(
//         url.replace(
//           queryParameters: {
//             'access_token': token,
//             'fields': 'id,name',
//           },
//         ),
//       );
//
//       if (response.statusCode == 200) {
//         final data = json.decode(response.body);
//         print('✅ Token is valid');
//         return {
//           'success': true,
//           'valid': true,
//           'data': data,
//         };
//       } else {
//         print('❌ Token is invalid: ${response.statusCode}');
//         return {
//           'success': true,
//           'valid': false,
//           'error': 'Token invalid: ${response.statusCode}',
//         };
//       }
//     } catch (e) {
//       print('❌ Error verifying token: $e');
//       return {
//         'success': false,
//         'error': 'Verification failed: $e',
//       };
//     }
//   }
//
//   /// Get token expiration info
//   static Future<Map<String, dynamic>> getTokenInfo({
//     required String token,
//   }) async {
//     try {
//       print('🔍 Getting token information...');
//
//       final url = Uri.parse('$_baseUrl/debug_token');
//       final response = await http.get(
//         url.replace(
//           queryParameters: {
//             'input_token': token,
//             'access_token': '${AppConfig.facebookAppId}|${AppConfig.facebookAppSecret}',
//           },
//         ),
//       );
//
//       if (response.statusCode == 200) {
//         final data = json.decode(response.body);
//         print('✅ Token info retrieved');
//         return {
//           'success': true,
//           'data': data['data'],
//         };
//       } else {
//         print('❌ Failed to get token info: ${response.statusCode}');
//         return {
//           'success': false,
//           'error': 'Failed to get token info: ${response.statusCode}',
//         };
//       }
//     } catch (e) {
//       print('❌ Error getting token info: $e');
//       return {
//         'success': false,
//         'error': 'Info retrieval failed: $e',
//       };
//     }
//   }
// }
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/app_config.dart';

class FacebookTokenExchangeService {
  static const String _graphApiVersion = 'v21.0'; // just for logs

  /// Exchange short-lived user token for long-lived user token (server does the secret work)
  static Future<Map<String, dynamic>> exchangeShortLivedToken(
      String shortLivedToken) async {
    try {
      final resp = await http.post(
        Uri.parse(AppConfig.fbExchangeUserTokenUrl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'shortLivedToken': shortLivedToken}),
      );
      final data = jsonDecode(resp.body);
      if (resp.statusCode == 200 && data['ok'] == true) {
        return {
          'success': true,
          'access_token': data['access_token'],
          'expires_in': data['expires_in'],
        };
      }
      return {
        'success': false,
        'error': data['error']?.toString() ?? 'Exchange failed',
      };
    } catch (e) {
      return {'success': false, 'error': 'Network error: $e'};
    }
  }

  /// Debug any token (user/page) — validity, expiry, etc.
  static Future<Map<String, dynamic>> debugToken(String token) async {
    try {
      final resp = await http.post(
        Uri.parse(AppConfig.fbDebugTokenUrl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'token': token}),
      );
      final data = jsonDecode(resp.body);
      if (resp.statusCode == 200 && data['ok'] == true) {
        return {'success': true, 'data': data['data']};
      }
      return {
        'success': false,
        'error': data['error']?.toString() ?? 'Debug failed',
      };
    } catch (e) {
      return {'success': false, 'error': 'Network error: $e'};
    }
  }

  /// Get a Page Access Token using a long-lived user token
  static Future<Map<String, dynamic>> getPageAccessToken({
    required String pageId,
    required String longLivedUserToken,
  }) async {
    try {
      final resp = await http.post(
        Uri.parse(AppConfig.fbGetPageTokenFromUserUrl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'pageId': pageId,
          'longLivedUserToken': longLivedUserToken,
        }),
      );
      final data = jsonDecode(resp.body);
      if (resp.statusCode == 200 && data['ok'] == true) {
        return {'success': true, 'pageAccessToken': data['pageAccessToken']};
      }
      return {
        'success': false,
        'error': data['error']?.toString() ?? 'Get page token failed',
      };
    } catch (e) {
      return {'success': false, 'error': 'Network error: $e'};
    }
  }

  static Future<Map<String, dynamic>> getPageAccessTokens(
      {required String longLivedUserToken}) async {
    final resp = await http.post(
      Uri.parse(AppConfig.fbGetPagesWithTokensFromUserUrl),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'longLivedUserToken': longLivedUserToken}),
    );
    final data = jsonDecode(resp.body);
    if (resp.statusCode == 200 && data['ok'] == true) {
      return {'success': true, 'pages': data['pages']};
    }
    return {
      'success': false,
      'error': data['error']?.toString() ?? 'Failed to fetch pages'
    };
  }

  static Future<Map<String, dynamic>> completeTokenExchange(
      {required String shortLivedToken}) async {
    final exResp = await http.post(
      Uri.parse(AppConfig.fbExchangeUserTokenUrl),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'shortLivedToken': shortLivedToken}),
    );
    final exJson = jsonDecode(exResp.body);
    if (exResp.statusCode != 200 || exJson['ok'] != true) {
      return {
        'success': false,
        'error': exJson['error']?.toString() ?? 'Exchange failed'
      };
    }
    final longToken = exJson['access_token'] as String?;
    if (longToken == null || longToken.isEmpty) {
      return {'success': false, 'error': 'No long-lived token returned'};
    }

    final pagesResp = await getPageAccessTokens(longLivedUserToken: longToken);
    if (pagesResp['success'] == true) {
      return {
        'success': true,
        'longLivedUserToken': longToken,
        'pages': pagesResp['pages']
      };
    }
    return {
      'success': false,
      'error': pagesResp['error'] ?? 'Failed to fetch pages'
    };
  }

  static Future<Map<String, dynamic>> verifyToken(
      {required String token}) async {
    final resp = await http.post(
      Uri.parse(AppConfig.fbDebugTokenUrl),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'token': token}),
    );
    final data = jsonDecode(resp.body);
    if (resp.statusCode == 200 && data['ok'] == true) {
      final d = data['data'] ?? {};
      return {'success': true, 'valid': d['is_valid'] == true, 'data': d};
    }
    return {
      'success': false,
      'valid': false,
      'error': data['error']?.toString() ?? 'Debug failed'
    };
  }
}
