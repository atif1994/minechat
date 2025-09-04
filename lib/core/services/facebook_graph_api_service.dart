import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';

class FacebookGraphApiService {
  // Backend URL where you handle OAuth code exchange and other server-side logic
  static const String _backendUrl =
      "https://449a5e08-99f4-4100-9571-62eeba47fe54-00-3gozoz68wjgp4.spock.replit.dev/api/facebook";

  // Your Facebook App ID
  static const String _appId = "1465171591136323";

  // The redirect URI registered with your Facebook app for OAuth callbacks
  static const String _redirectUri = "minechat://facebook-oauth-callback";

  // Required Facebook permissions for your app
  static const List<String> _permissions = [
    "pages_show_list",
    "pages_messaging",
    "pages_manage_metadata",
    "pages_read_engagement",
  ];

  /// Launch Facebook OAuth URL in browser/webview to start OAuth flow.
  /// Tries multiple launch modes until success.
  static Future<Map<String, dynamic>> startOAuthFlow() async {
    final state = DateTime.now().millisecondsSinceEpoch.toString();

    final authUrl = Uri.https(
      "www.facebook.com",
      "/v23.0/dialog/oauth",
      {
        "client_id": _appId,
        "redirect_uri": _redirectUri,
        "scope": _permissions.join(","),
        "state": state,
        "response_type": "code",
      },
    );

    try {
      print('🔗 Attempting to launch Facebook OAuth URL: $authUrl');

      final List<LaunchMode> modes = [
        LaunchMode.externalApplication,
        LaunchMode.inAppWebView,
        LaunchMode.platformDefault,
      ];

      for (final mode in modes) {
        try {
          final launched = await launchUrl(authUrl, mode: mode);
          if (launched) {
            print('✅ OAuth URL launched successfully with mode: $mode');
            return {
              "success": true,
              "url": authUrl.toString(),
              "launchMode": mode.toString(),
            };
          } else {
            print('⚠️ Failed to launch with mode: $mode');
          }
        } catch (e) {
          print('⚠️ Exception during launch with $mode: $e');
        }
      }

      print('❌ All launch methods failed');
      return {
        "success": false,
        "error": "Could not launch Facebook OAuth URL with any method",
      };
    } catch (e) {
      print('❌ Error launching OAuth URL: $e');
      return {
        "success": false,
        "error": "Error launching Facebook OAuth URL: $e",
      };
    }
  }

  /// Send OAuth code to backend server for token exchange.
  static Future<Map<String, dynamic>> handleOAuthCallback(String code) async {
    try {
      final response = await http.post(
        Uri.parse("$_backendUrl/oauth/callback"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"code": code, "redirectUri": _redirectUri}),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        return {
          "success": false,
          "error": "Backend responded with status ${response.statusCode}",
          "body": response.body,
        };
      }
    } catch (e) {
      return {"success": false, "error": e.toString()};
    }
  }

  /// Get user pages from backend
  static Future<Map<String, dynamic>> getUserPages() async {
    try {
      final response = await http.get(Uri.parse("$_backendUrl/pages"));

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        return {
          "success": false,
          "error": "Backend responded with status ${response.statusCode}",
          "body": response.body,
        };
      }
    } catch (e) {
      return {"success": false, "error": e.toString()};
    }
  }

  /// Get user pages directly using Facebook API and access token
  static Future<Map<String, dynamic>> getUserPagesWithToken(
      String accessToken) async {
    try {
      final response = await http.get(
        Uri.https("graph.facebook.com", "/v23.0/me/accounts", {
          "access_token": accessToken,
          "fields": "id,name,access_token,category",
        }),
      );

      if (response.statusCode == 200) {
        final decodedData = jsonDecode(response.body);

        if (decodedData is Map<String, dynamic>) {
          return {"success": true, "data": decodedData};
        } else {
          return {
            "success": false,
            "error":
            "Facebook API returned unexpected data type: ${decodedData.runtimeType}",
          };
        }
      } else {
        final error = jsonDecode(response.body);
        return {
          "success": false,
          "error": error['error']?['message'] ?? "Failed to fetch pages",
          "code": response.statusCode,
        };
      }
    } catch (e) {
      return {"success": false, "error": e.toString()};
    }
  }

  /// Verify if an access token is valid by querying the user's info.
  static Future<Map<String, dynamic>> verifyAccessToken(
      String accessToken) async {
    try {
      final response = await http.get(
        Uri.https("graph.facebook.com", "/v23.0/me", {
          "access_token": accessToken,
          "fields": "id,name,email",
        }),
      );

      if (response.statusCode == 200) {
        final decodedData = jsonDecode(response.body);

        if (decodedData is Map<String, dynamic>) {
          return {"success": true, "data": decodedData};
        } else {
          return {
            "success": false,
            "error":
            "Facebook API returned unexpected data type: ${decodedData.runtimeType}",
          };
        }
      } else {
        final error = jsonDecode(response.body);
        return {
          "success": false,
          "error": error['error']?['message'] ?? "Invalid access token",
          "errorType": error['error']?['type'] ?? "unknown",
          "code": response.statusCode,
        };
      }
    } catch (e) {
      return {"success": false, "error": e.toString()};
    }
  }

  /// Verify page access with page ID and access token
  static Future<Map<String, dynamic>> verifyPageAccess(
      String pageId, String pageAccessToken) async {
    try {
      final response = await http.get(
        Uri.https("graph.facebook.com", "/v23.0/$pageId", {
          "access_token": pageAccessToken,
          "fields": "id,name,category",
        }),
      );

      if (response.statusCode == 200) {
        final decodedData = jsonDecode(response.body);

        if (decodedData is Map<String, dynamic>) {
          return {"success": true, "data": decodedData};
        } else {
          return {
            "success": false,
            "error":
            "Facebook API returned unexpected data type: ${decodedData.runtimeType}",
          };
        }
      } else {
        final error = jsonDecode(response.body);
        return {
          "success": false,
          "error": error['error']?['message'] ?? "Cannot access page",
          "code": response.statusCode,
        };
      }
    } catch (e) {
      return {"success": false, "error": e.toString()};
    }
  }

  /// Get page conversations using page access token
  static Future<Map<String, dynamic>> getPageConversationsWithToken(
      String pageId, String pageAccessToken) async {
    try {
      final url = Uri.https(
        "graph.facebook.com",
        "/v23.0/$pageId/conversations",
        {
          "access_token": pageAccessToken,
          "limit": "50",
          "fields": "id,link,updated_time,unread_count,message_count,participants",
        },
      );

      print('🔗 Calling Facebook API: ${url.toString().replaceAll(pageAccessToken, '***TOKEN***')}');
      print('🔑 Token length: ${pageAccessToken.length}');

      final response = await http.get(url);
      
      print('📊 Conversations API response status: ${response.statusCode}');
      print('📊 Response body length: ${response.body.length}');
      print('📊 Response body preview: ${response.body.substring(0, response.body.length > 200 ? 200 : response.body.length)}');

      if (response.statusCode == 200) {
        try {
          final decodedData = jsonDecode(response.body);
          print('📋 Decoded conversations data: $decodedData');
          print('📋 Data type: ${decodedData.runtimeType}');
          print('📋 Available keys: ${decodedData is Map ? decodedData.keys.toList() : 'Not a map'}');

          if (decodedData is Map<String, dynamic> && decodedData.containsKey('data')) {
            final conversationsData = decodedData['data'];
            print('📋 Conversations data field: $conversationsData');
            print('📋 Conversations data type: ${conversationsData.runtimeType}');

            if (conversationsData is List) {
              final enhancedConversations = <Map<String, dynamic>>[];

              for (final conv in conversationsData) {
                print('📋 Processing conversation: $conv');
                // Keep the original data structure from Facebook
                enhancedConversations.add({
                  'id': conv['id'],
                  'link': conv['link'],
                  'updated_time': conv['updated_time'],
                  'unread_count': conv['unread_count'] ?? 0,
                  'message_count': conv['message_count'] ?? 1,
                  // Don't artificially create participants - let the chat controller handle this
                });
              }

              print('✅ Enhanced ${enhancedConversations.length} conversations');
              return {"success": true, "data": enhancedConversations};
            } else {
              print('⚠️ Conversations data is not a list: ${conversationsData.runtimeType}');
              return {
                "success": false,
                "error":
                "Facebook API returned unexpected data type: ${conversationsData.runtimeType}",
              };
            }
          } else {
            print('⚠️ Missing data field in response');
            return {
              "success": false,
              "error": "Facebook API response missing 'data' field",
            };
          }
        } catch (jsonError) {
          print('❌ JSON parsing failed for conversations: $jsonError');
          print('❌ Raw response body: ${response.body}');
          return {
            "success": false,
            "error": "JSON parsing failed: $jsonError"
          };
        }
      } else {
        try {
          final error = jsonDecode(response.body);
          print('❌ Facebook API error for conversations: ${response.statusCode} - ${error['error']?['message']}');
          return {
            "success": false,
            "error": error['error']?['message'] ?? "Facebook API error",
            "code": response.statusCode,
          };
        } catch (e) {
          print('❌ Error parsing error response: $e');
          print('❌ Raw error response: ${response.body}');
          return {
            "success": false,
            "error": "HTTP ${response.statusCode}: ${response.body}",
            "code": response.statusCode,
          };
        }
      }
    } catch (e) {
      print('❌ Exception in getPageConversationsWithToken: $e');
      print('❌ Stack trace: ${StackTrace.current}');
      return {"success": false, "error": e.toString()};
    }
  }

  /// Get messages in a conversation using Facebook Graph API
  static Future<Map<String, dynamic>> getConversationMessagesWithToken(
      String conversationId, String pageAccessToken) async {
    try {
      final response = await http.get(
        Uri.https(
          "graph.facebook.com",
          "/v23.0/$conversationId/messages",
          {
            "access_token": pageAccessToken,
            "fields": "id,message,created_time,from",
            "limit": "1", // Last message
          },
        ),
      );

      if (response.statusCode == 200) {
        final decodedData = jsonDecode(response.body);

        if (decodedData is Map<String, dynamic>) {
          final messages = decodedData['data'] as List? ?? [];

          if (messages.isNotEmpty) {
            return {"success": true, "data": messages.first};
          } else {
            return {"success": true, "data": null};
          }
        } else {
          return {
            "success": false,
            "error":
            "Facebook API returned unexpected data type: ${decodedData.runtimeType}",
          };
        }
      } else {
        final error = jsonDecode(response.body);
        return {
          "success": false,
          "error": error['error']?['message'] ?? "Facebook API error",
          "code": response.statusCode,
        };
      }
    } catch (e) {
      return {"success": false, "error": e.toString()};
    }
  }

  /// Send a message (via backend)
  static Future<Map<String, dynamic>> sendMessage(
      String conversationId, String message) async {
    try {
      final response = await http.post(
        Uri.parse("$_backendUrl/conversations/$conversationId/messages"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"message": message}),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        return {
          "success": false,
          "error": "Backend responded with status ${response.statusCode}",
          "body": response.body,
        };
      }
    } catch (e) {
      return {"success": false, "error": e.toString()};
    }
  }

  /// Send message to a Facebook conversation
  static Future<Map<String, dynamic>> sendMessageToConversation(
      String conversationId, String pageAccessToken, String message) async {
    try {
      print('📤 Sending message to conversation: $conversationId');
      print('📝 Message: $message');
      print('🔑 Token length: ${pageAccessToken.length}');
      
      // Facebook requires the conversation ID to be in a specific format
      // For thread conversations, we need to use the thread_id
      final url = Uri.https(
        "graph.facebook.com",
        "/v23.0/me/messages",
        {
          "access_token": pageAccessToken,
        },
      );

      final requestBody = {
        "recipient": {"thread_id": conversationId},
        "message": {"text": message},
      };

      print('🔗 API URL: ${url.toString().replaceAll(pageAccessToken, '***TOKEN***')}');
      print('📤 Request body: $requestBody');

      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode(requestBody),
      );

      print('📊 Send message response status: ${response.statusCode}');
      print('📊 Response body: ${response.body}');

      if (response.statusCode == 200) {
        try {
          final decodedData = jsonDecode(response.body);
          print('✅ Message sent successfully: $decodedData');
          return {"success": true, "data": decodedData};
        } catch (jsonError) {
          print('⚠️ JSON parsing failed for send response: $jsonError');
          return {
            "success": false,
            "error": "JSON parsing failed: $jsonError"
          };
        }
      } else {
        try {
          final error = jsonDecode(response.body);
          print('❌ Facebook API error sending message: ${response.statusCode} - ${error['error']?['message']}');
          return {
            "success": false,
            "error": error['error']?['message'] ?? "Facebook API error",
            "code": response.statusCode,
          };
        } catch (e) {
          print('❌ Error parsing error response: $e');
          print('❌ Raw error response: ${response.body}');
          return {
            "success": false,
            "error": "HTTP ${response.statusCode}: ${response.body}",
            "code": response.statusCode,
          };
        }
      }
    } catch (e) {
      print('❌ Exception in sendMessageToConversation: $e');
      print('❌ Stack trace: ${StackTrace.current}');
      return {"success": false, "error": e.toString()};
    }
  }

  /// Check what page endpoints you have access to with the given token.
  static Future<Map<String, dynamic>> checkPagePermissions(
      String pageId, String pageAccessToken) async {
    final endpoints = [
      '/conversations',
      '/messages',
      '/posts',
      '/comments',
      '/insights'
    ];

    final results = <String, dynamic>{};

    for (final endpoint in endpoints) {
      try {
        final response = await http.get(
          Uri.https(
            "graph.facebook.com",
            "/v23.0/$pageId$endpoint",
            {
              "access_token": pageAccessToken,
              "limit": "1",
            },
          ),
        );

        if (response.statusCode == 200) {
          final decodedData = jsonDecode(response.body);

          if (decodedData is Map<String, dynamic>) {
            final dataField = decodedData['data'];
            bool hasData = false;
            String dataType = 'unknown';

            if (dataField != null) {
              dataType = dataField.runtimeType.toString();
              hasData = dataField is List && dataField.isNotEmpty;
            }

            results[endpoint] = {
              'accessible': true,
              'data_type': dataType,
              'has_data': hasData,
            };
          } else if (decodedData is int) {
            results[endpoint] = {
              'accessible': true,
              'data_type': 'int',
              'has_data': false,
            };
          } else {
            results[endpoint] = {
              'accessible': false,
              'data_type': decodedData.runtimeType.toString(),
              'has_data': false,
            };
          }
        } else {
          results[endpoint] = {
            'accessible': false,
            'error': 'HTTP status ${response.statusCode}',
          };
        }
      } catch (e) {
        results[endpoint] = {'accessible': false, 'error': e.toString()};
      }
    }

    return {"success": true, "results": results};
  }

  /// Get user profile information including name and profile picture
  static Future<Map<String, dynamic>> getUserProfile(String userId, String pageAccessToken) async {
    try {
      print('🔍 Fetching user profile for: $userId');
      
      final url = Uri.https("graph.facebook.com", "/v23.0/$userId", {
        "access_token": pageAccessToken,
        "fields": "id,name,picture"
      });
      
      final response = await http.get(url);
      print('📊 User profile response status: ${response.statusCode}');
      
      if (response.statusCode == 200) {
        try {
          final dynamic decodedData = jsonDecode(response.body);
          print('📋 User profile data: $decodedData');
          
          if (decodedData is Map<String, dynamic>) {
            final data = decodedData as Map<String, dynamic>;
            
            // Extract user information
            final userName = data['name'] ?? 'Unknown User';
            String profileImageUrl = '';
            
            // Extract profile picture URL
            if (data['picture'] != null && data['picture'] is Map<String, dynamic>) {
              final picture = data['picture'] as Map<String, dynamic>;
              if (picture['data'] != null && picture['data'] is Map<String, dynamic>) {
                final pictureData = picture['data'] as Map<String, dynamic>;
                profileImageUrl = pictureData['url'] ?? '';
              }
            }
            
            return {
              "success": true,
              "data": {
                "id": userId,
                "name": userName,
                "profileImageUrl": profileImageUrl,
              }
            };
          } else {
            print('⚠️ Facebook API returned unexpected data type for user profile: ${decodedData.runtimeType}');
            return {
              "success": false,
              "error": "Facebook API returned unexpected data type: ${decodedData.runtimeType}"
            };
          }
        } catch (jsonError) {
          print('⚠️ JSON parsing failed for user profile: $jsonError');
          return {
            "success": false,
            "error": "JSON parsing failed: $jsonError"
          };
        }
      } else {
        try {
          final error = jsonDecode(response.body);
          print('❌ Facebook API error for user profile: ${response.statusCode} - ${error['error']?['message']}');
          return {
            "success": false,
            "error": "Facebook API error: ${error['error']?['message'] ?? 'Unknown error'}"
          };
        } catch (jsonError) {
          print('⚠️ Failed to parse error response for user profile: $jsonError');
          return {
            "success": false,
            "error": "Failed to parse error response: $jsonError"
          };
        }
      }
    } catch (e) {
      print('❌ Error fetching user profile: $e');
      return {"success": false, "error": e.toString()};
    }
  }

  /// Get multiple user profiles in batch (more efficient than individual calls)
  static Future<Map<String, dynamic>> getBatchUserProfiles(List<String> userIds, String pageAccessToken) async {
    try {
      print('🔍 Fetching batch profiles for ${userIds.length} users');
      
      if (userIds.isEmpty) {
        return {"success": true, "data": {}};
      }
      
      // Create batch request
      final batchRequests = <String>[];
      for (final userId in userIds) {
        batchRequests.add('{"method":"GET","relative_url":"$userId?fields=id,name,picture"}');
      }
      
      final url = Uri.https("graph.facebook.com", "/v23.0/", {
        "access_token": pageAccessToken,
        "batch": "[${batchRequests.join(',')}]"
      });
      
      final response = await http.post(url);
      print('📊 Batch profiles response status: ${response.statusCode}');
      
      if (response.statusCode == 200) {
        try {
          final List<dynamic> batchResults = jsonDecode(response.body);
          final Map<String, dynamic> userProfiles = {};
          
          for (int i = 0; i < batchResults.length && i < userIds.length; i++) {
            final result = batchResults[i];
            final userId = userIds[i];
            
            if (result['code'] == 200) {
              try {
                final userData = jsonDecode(result['body']);
                if (userData is Map<String, dynamic>) {
                  final userName = userData['name'] ?? 'Unknown User';
                  String profileImageUrl = '';
                  
                  // Extract profile picture URL
                  if (userData['picture'] != null && userData['picture'] is Map<String, dynamic>) {
                    final picture = userData['picture'] as Map<String, dynamic>;
                    if (picture['data'] != null && picture['data'] is Map<String, dynamic>) {
                      final pictureData = picture['data'] as Map<String, dynamic>;
                      profileImageUrl = pictureData['url'] ?? '';
                    }
                  }
                  
                  userProfiles[userId] = {
                    "id": userId,
                    "name": userName,
                    "profileImageUrl": profileImageUrl,
                  };
                }
              } catch (e) {
                print('⚠️ Failed to parse user data for $userId: $e');
                userProfiles[userId] = {
                  "id": userId,
                  "name": "User $userId",
                  "profileImageUrl": "",
                };
              }
            } else {
              print('⚠️ Failed to fetch profile for $userId: ${result['body']}');
              userProfiles[userId] = {
                "id": userId,
                "name": "User $userId",
                "profileImageUrl": "",
              };
            }
          }
          
          print('✅ Successfully fetched ${userProfiles.length} user profiles');
          return {"success": true, "data": userProfiles};
          
        } catch (jsonError) {
          print('⚠️ JSON parsing failed for batch profiles: $jsonError');
          return {
            "success": false,
            "error": "JSON parsing failed: $jsonError"
          };
        }
      } else {
        print('❌ Batch profiles request failed: ${response.statusCode}');
        return {
          "success": false,
          "error": "Batch request failed: ${response.statusCode}"
        };
      }
    } catch (e) {
      print('❌ Error fetching batch user profiles: $e');
      return {"success": false, "error": e.toString()};
    }
  }

  /// Get conversation participants
  static Future<Map<String, dynamic>> getConversationParticipants(
      String conversationId, String pageAccessToken) async {
    try {
      final url = Uri.https(
        "graph.facebook.com",
        "/v23.0/$conversationId",
        {
          "access_token": pageAccessToken,
          "fields": "participants,link",
        },
      );

      print('🔗 Getting participants for conversation: $conversationId');
      print('🔗 API URL: ${url.toString().replaceAll(pageAccessToken, '***TOKEN***')}');
      print('🔑 Token length: ${pageAccessToken.length}');

      final response = await http.get(url);
      
      print('📊 Participants API response status: ${response.statusCode}');
      print('📊 Response body length: ${response.body.length}');
      print('📊 Response body preview: ${response.body.substring(0, response.body.length > 200 ? 200 : response.body.length)}');

      if (response.statusCode == 200) {
        try {
          final decodedData = jsonDecode(response.body);
          print('📋 Decoded participants data: $decodedData');
          print('📋 Data type: ${decodedData.runtimeType}');
          print('📋 Available keys: ${decodedData is Map ? decodedData.keys.toList() : 'Not a map'}');

          if (decodedData is Map<String, dynamic>) {
            return {"success": true, "data": decodedData};
          } else {
            return {
              "success": false,
              "error":
              "Facebook API returned unexpected data type: ${decodedData.runtimeType}",
            };
          }
        } catch (jsonError) {
          print('❌ JSON parsing failed for participants: $jsonError');
          print('❌ Raw response body: ${response.body}');
          return {
            "success": false,
            "error": "JSON parsing failed: $jsonError"
          };
        }
      } else {
        try {
          final error = jsonDecode(response.body);
          print('❌ Facebook API error for participants: ${response.statusCode} - ${error['error']?['message']}');
          return {
            "success": false,
            "error": error['error']?['message'] ?? "Facebook API error",
            "code": response.statusCode,
          };
        } catch (e) {
          print('❌ Error parsing error response: $e');
          print('❌ Raw error response: ${response.body}');
          return {
            "success": false,
            "error": "HTTP ${response.statusCode}: ${response.body}",
            "code": response.statusCode,
          };
        }
      }
    } catch (e) {
      print('❌ Exception in getConversationParticipants: $e');
      print('❌ Stack trace: ${StackTrace.current}');
      return {"success": false, "error": e.toString()};
    }
  }
}
