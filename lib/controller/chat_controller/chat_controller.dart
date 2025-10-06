import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:minechat/core/services/facebook_graph_api_service.dart';
import 'package:minechat/controller/channel_controller/channel_controller.dart';
import 'package:minechat/core/services/realtime_message_service.dart';
import 'package:minechat/core/services/facebook_webhook_service.dart';
import 'package:minechat/core/services/simple_webhook_service.dart';
import 'dart:async'; // Added for Timer
import 'dart:convert';
import 'package:http/http.dart' as http;

class ChatController extends GetxController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final RealtimeMessageService _realtimeService = RealtimeMessageService();
  final FacebookWebhookService _webhookService = FacebookWebhookService();
  final SimpleWebhookService _simpleWebhookService = SimpleWebhookService();

  // Chat list state
  var chatList = <Map<String, dynamic>>[].obs;
  var filteredChatList = <Map<String, dynamic>>[].obs;
  var isLoading = false.obs;
  var selectedFilter = 'Inbox'.obs;
  var searchQuery = ''.obs;

  // Create new dropdown
  var isCreateNewDropdownOpen = false.obs;
  var isFilterDropdownOpen = false.obs;

  // Selection mode state
  var isSelectionMode = false.obs;
  var selectedChats = <String>[].obs; // List of chat IDs that are selected
  var isMoreOptionsDropdownOpen = false.obs;

  // Chat channels
  final List<Map<String, dynamic>> availableChannels = [
    {'name': 'Website', 'icon': '🌐', 'color': Colors.blue},
    {'name': 'Messenger', 'icon': '💬', 'color': Colors.blue[600]},
    {'name': 'Instagram', 'icon': '📷', 'color': Colors.pink},
    {'name': 'Telegram', 'icon': '📱', 'color': Colors.blue[400]},
    {'name': 'WhatsApp', 'icon': '📞', 'color': Colors.green},
    {'name': 'Slack', 'icon': '💼', 'color': Colors.purple},
    {'name': 'Viber', 'icon': '💜', 'color': Colors.purple[600]},
    {'name': 'Discord', 'icon': '🎮', 'color': Colors.indigo},
  ];

  // Create New dropdown options (exact list & order from screenshot)
  final List<Map<String, dynamic>> createNewOptions = [
    {'key': 'new_group', 'label': 'New Group', 'enabled': true},
    {'key': 'new_group_message', 'label': 'New Group Message', 'enabled': true},
    {
      'key': 'follow_up_campaign',
      'label': 'Follow-up Campaign (coming soon)',
      'enabled': false
    },
  ];

  // Filter options
  final List<String> filterOptions = [
    '📅 Today',
    '📅 Yesterday',
    '📅 This Week',
    '📅 This Month',
    '📅 Date Range'
  ];

  // Add real-time update properties
  Timer? _refreshTimer;
  Timer? _timeUpdateTimer;
  var _isRefreshing = false.obs; // Make this observable
  var _lastRefreshTime = DateTime.now().obs; // Make this observable
  var _timeSinceLastRefresh = '0s ago'.obs; // Make this observable

  @override
  void onInit() {
    super.onInit();
    print('🔍 ChatController initialized');
    print('🔍 About to call loadChats...');

    // Load initial chats
    loadChats();
    print('🔍 loadChats called');

    // Don't call loadChats again - it's already called above

    // Start real-time updates
    _startRealTimeUpdates();

    // Start time update timer
    _startTimeUpdateTimer();

    // Start real-time message listening
    _realtimeService.startListeningForMessages();
    
    // Start simple webhook listening (no controller dependencies)
    Future.delayed(Duration(seconds: 2), () {
      _simpleWebhookService.startSimpleWebhookListening();
    });
  }

  @override
  void onClose() {
    // Clean up timers
    _refreshTimer?.cancel();
    _timeUpdateTimer?.cancel();

    // Stop real-time listening
    _realtimeService.stopListening();
    
    // Stop webhook listening
    _webhookService.stopWebhookListening();
    _simpleWebhookService.stopSimpleWebhookListening();

    super.onClose();
  }

  /// Start real-time chat updates with message polling
  void _startRealTimeUpdates() {
    print('🔄 Starting real-time message polling...');

    // Don't load chats here - they're already loaded in onInit

    // Polling disabled to prevent excessive API calls
    print('🔄 Main chat polling disabled to prevent excessive API calls');
    // _refreshTimer = Timer.periodic(Duration(minutes: 5), (timer) {
    //   if (isLoading.value) return; // Don't refresh if already loading
    //   print('🔄 Polling for new Facebook messages...');
    //   _pollForNewMessages();
    // });
  }

  /// Start time update timer to keep UI reactive
  void _startTimeUpdateTimer() {
    _timeUpdateTimer = Timer.periodic(Duration(seconds: 1), (timer) {
      _updateTimeSinceLastRefresh();
    });
  }

  /// Update the time since last refresh
  void _updateTimeSinceLastRefresh() {
    final difference = DateTime.now().difference(_lastRefreshTime.value);
    if (difference.inMinutes < 1) {
      _timeSinceLastRefresh.value = '${difference.inSeconds}s ago';
    } else if (difference.inHours < 1) {
      _timeSinceLastRefresh.value = '${difference.inMinutes}m ago';
    } else {
      _timeSinceLastRefresh.value = '${difference.inHours}h ago';
    }
  }

  /// Silent refresh removed for better performance

  /// Manual refresh with loading indicator
  Future<void> refreshChats() async {
    if (_isRefreshing.value) return;

    _isRefreshing.value = true;
    try {
      print('🔄 Manual refresh started...');
      await loadFacebookChats();
      _lastRefreshTime.value = DateTime.now();

      // Show success message
      Get.snackbar(
        'Chats Updated',
        'Latest conversations loaded successfully',
        snackPosition: SnackPosition.TOP,
        duration: Duration(seconds: 2),
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );

      print('✅ Manual refresh completed');
    } catch (e) {
      print('❌ Manual refresh failed: $e');

      // Show error message
      Get.snackbar(
        'Update Failed',
        'Could not refresh chats: ${e.toString()}',
        snackPosition: SnackPosition.TOP,
        duration: Duration(seconds: 3),
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      _isRefreshing.value = false;
    }
  }

  /// Check for new messages and update unread counts
  /// Auto message checking removed for better performance
  Future<void> checkForNewMessages() async {
    // Method disabled - no auto-checking
  }

  /// Get refresh status
  bool get isRefreshing => _isRefreshing.value;

  /// Get time since last refresh
  String get timeSinceLastRefresh => _timeSinceLastRefresh.value;

  /// Get time since last refresh as observable
  RxString get timeSinceLastRefreshObs => _timeSinceLastRefresh;

  String getCurrentUserId() {
    return FirebaseAuth.instance.currentUser?.uid ?? '';
  }

  /// Generate initials from a name
  String _generateInitials(String name) {
    if (name.isEmpty) return '?';
    
    final words = name.trim().split(' ').where((word) => word.isNotEmpty).toList();
    if (words.isEmpty) return '?';
    
    if (words.length == 1) {
      return words[0][0].toUpperCase();
    } else {
      return '${words[0][0]}${words[1][0]}'.toUpperCase();
    }
  }

  /// Get a consistent color scheme based on name hash
  String _getColorSchemeForName(String name) {
    if (name.isEmpty) return '6B7280'; // Gray fallback
    
    // Generate a hash from the name
    int hash = 0;
    for (int i = 0; i < name.length; i++) {
      hash = name.codeUnitAt(i) + ((hash << 5) - hash);
    }
    
    // Use absolute value and modulo to get a consistent color
    final colorIndex = hash.abs() % 8;
    
    // Professional color palette
    final colors = [
      '3B82F6', // Blue
      '10B981', // Green  
      'F59E0B', // Amber
      'EF4444', // Red
      '8B5CF6', // Purple
      '06B6D4', // Cyan
      'F97316', // Orange
      '84CC16', // Lime
    ];
    
    return colors[colorIndex];
  }

  /// Load all chats from different channels
  Future<void> loadChats() async {
    try {
      print('🔍 loadChats method called');
      print('🔍 loadChats method started');
      isLoading.value = true;
      final userId = getCurrentUserId();
      if (userId.isEmpty) return;

      // Clear existing chats first
      chatList.clear();
      print('🔍 Cleared existing chats, chatList length: ${chatList.length}');

      // Load Facebook Messenger chats (REAL DATA ONLY)
      print('🔍 About to call loadFacebookChats...');
      await loadFacebookChats();
      print(
          '🔍 loadFacebookChats completed, chatList length: ${chatList.length}');

      // Load other channel chats (REAL DATA ONLY)
      await loadOtherChannelChats();

      // Apply current filter
      applyFilter();

      print('✅ Chat loading completed - showing only real data');
    } catch (e) {
      print('❌ Error loading chats: $e');
      Get.snackbar(
        'Error',
        'Failed to load chats: $e',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }

  /// Load Facebook Messenger chats using real Graph API
  Future<void> loadFacebookChats() async {
    try {
      print('📥 Loading Facebook chats...');
      print('🔍 loadFacebookChats method called');
      print('🔍 loadFacebookChats method started');
      final userId = getCurrentUserId();

      // Get user's Facebook page settings
      final userDoc =
          await _firestore.collection('channel_settings').doc(userId).get();

      if (!userDoc.exists || userDoc.data()!['isFacebookConnected'] != true) {
        print('⚠️ Facebook not connected, skipping Facebook chat load');
        print('🔍 User doc exists: ${userDoc.exists}');
        if (userDoc.exists) {
          print(
              '🔍 Facebook connected: ${userDoc.data()!['isFacebookConnected']}');
        }
        return;
      }

      final facebookPageId = userDoc.data()!['facebookPageId'] as String?;
      if (facebookPageId == null || facebookPageId.isEmpty) {
        print('⚠️ No Facebook Page ID found');
        print('🔍 Facebook Page ID: $facebookPageId');
        return;
      }

      print('✅ Facebook is connected, Page ID: $facebookPageId');

      // Get the channel controller to access page access token
      final channelController = Get.find<ChannelController>();
      final pageAccessToken =
          await channelController.getPageAccessToken(facebookPageId);

      if (pageAccessToken == null || pageAccessToken.isEmpty) {
        print(
            '⚠️ No page access token found - trying to load from stored data');
        print(
            '💡 This means the Facebook page was not properly connected with an access token');

        // Try to load Facebook chats from stored data (Firebase Functions)
        try {
          final userChatsDoc =
              await _firestore.collection('user_chats').doc(userId).get();

          if (userChatsDoc.exists) {
            final chatData = userChatsDoc.data();
            final facebookChatsData =
                chatData?['facebookChats'] as List<dynamic>?;

            if (facebookChatsData != null && facebookChatsData.isNotEmpty) {
              print(
                  '✅ Found ${facebookChatsData.length} stored Facebook chats');

              // Convert stored Facebook chats to app format
              final facebookChats = <Map<String, dynamic>>[];

              for (final chatData in facebookChatsData) {
                final chat = chatData as Map<String, dynamic>;

                // Use real user data if available
                final userName = chat['userName'] ??
                    'Facebook User ${chat['conversationId'] ?? 'Unknown'}';
                final userProfilePicture = chat['userProfilePicture'] ??
                    'https://dummyimage.com/100x100/cccccc/666666&text=FB';
                final lastMessage = chat['lastMessage'] ?? 'No messages yet';
                final lastMessageTime =
                    chat['lastMessageTime'] ?? chat['lastUpdate'];

                // Check if we have real data vs fallback data
                final hasRealName =
                    userName.startsWith('Facebook User') == false;
                final hasRealProfilePicture =
                    userProfilePicture.startsWith('https://dummyimage.com') ==
                        false;
                final hasRealMessage = lastMessage != 'No messages yet';

                print(
                    '📊 Chat data quality: $userName - Real name: $hasRealName, Real picture: $hasRealProfilePicture, Real message: $hasRealMessage');

                final appChat = {
                  'id': chat['id'] ?? 'unknown',
                  'contactName': userName,
                  'lastMessage': lastMessage,
                  'timestamp': _parseTimestamp(lastMessageTime),
                  'unreadCount': chat['unreadCount'] ?? 0,
                  'profileImageUrl': userProfilePicture,
                  'platform': 'Facebook',
                  'platformIcon': '💬',
                  'conversationId': chat['conversationId'],
                  'pageId': chat['pageId'],
                  'messageCount': chat['messageCount'] ?? 0,
                  'needsLastMessage': false,
                  'canReply': chat['canReply'] ?? false,
                };
                facebookChats.add(appChat);

                print(
                    '✅ Loaded real Facebook chat: $userName - "$lastMessage"');
              }

              // Update chat list - remove any existing Facebook chats first
              final existingChats = chatList
                  .where((chat) => !chat['id'].toString().startsWith('fb_'))
                  .toList();
              chatList.value = [...existingChats, ...facebookChats];

              print(
                  '✅ Added ${facebookChats.length} Facebook chats from stored data');

              Get.snackbar(
                'Facebook Chats Loaded!',
                'Successfully loaded ${facebookChats.length} Facebook conversations with real user data.',
                backgroundColor: Colors.green,
                colorText: Colors.white,
                duration: Duration(seconds: 3),
              );

              return; // Success - chats loaded from stored data
            }
          }
        } catch (e) {
          print('❌ Error loading stored Facebook chats: $e');
        }

        print(
            '⚠️ No stored Facebook chats found - cannot load real Facebook chats');
        print('💡 To get real Facebook chats, you need to:');
        print('   1. Go to https://developers.facebook.com/');
        print('   2. Create/select your app');
        print('   3. Go to Tools > Graph API Explorer');
        print(
            '   4. Generate Access Token with permissions: pages_show_list, pages_messaging');
        print('   5. Reconnect your Facebook page with the access token');

        // Token is already saved in Firebase Functions

        // Token is already saved in Firebase Functions - no need for dialogs
        return; // Don't load mock data if no access token
      }

      // Skip permissions check for now - focus on loading conversations
      print('🔍 Skipping permissions check to focus on conversations...');

      // Test what we can access
      print('🧪 Testing basic page access...');
      try {
        final testResult = await FacebookGraphApiService.verifyPageAccess(
            facebookPageId, pageAccessToken);
        print('🧪 Page access test result: $testResult');
      } catch (e) {
        print('⚠️ Page access test failed: $e');
      }

      // Test if we can access user profiles
      print('🧪 Testing user profile access...');
      try {
        // Try to get a test user profile (this will fail if we don't have permissions)
        final testUserResult = await FacebookGraphApiService.getUserProfile(
            '123456789', pageAccessToken);
        print('🧪 User profile test result: $testUserResult');
      } catch (e) {
        print('⚠️ User profile test failed: $e');
      }

      print(
          '🔍 Fetching real Facebook conversations for page: $facebookPageId');

      // Token is already validated by Firebase Functions
      print('✅ Using Facebook Page Access Token from Firebase Functions');

      // Get conversations from Facebook Graph API using the page access token
      final conversationsResult =
          await FacebookGraphApiService.getPageConversationsWithToken(
        facebookPageId,
        pageAccessToken,
      );

      print('📋 Conversations result: $conversationsResult');
      print('📋 Success: ${conversationsResult['success']}');
      print('📋 Data type: ${conversationsResult['data']?.runtimeType}');
      print('📋 Data value: ${conversationsResult['data']}');
      print('📋 Raw response: ${conversationsResult}');

      if (!conversationsResult['success']) {
        throw Exception(
            'Failed to load conversations: ${conversationsResult['error']}');
      }

      // Safely handle the data field
      final data = conversationsResult['data'];
      List conversations;

      if (data is List) {
        conversations = data;
      } else if (data is int) {
        print('⚠️ Facebook API returned count instead of conversations: $data');
        conversations = []; // Empty list if no conversations
      } else {
        print('⚠️ Unexpected data type: ${data.runtimeType}');
        conversations = [];
      }
      print('✅ Loaded ${conversations.length} Facebook conversations');

      // Debug: Print the structure of the first conversation if available
      if (conversations.isNotEmpty) {
        print('📋 Sample conversation structure: ${conversations.first}');
        print(
            '🔍 Keys in first conversation: ${(conversations.first as Map<String, dynamic>).keys.toList()}');
      }

      if (conversations.isEmpty) {
        print('ℹ️ No conversations found on this Facebook page');
        Get.snackbar(
          'Info',
          'No conversations found on your Facebook page. This could mean:\n• No one has messaged your page yet\n• The page is new and has no conversations\n• Try sending a test message to your page first',
          backgroundColor: Colors.blue,
          colorText: Colors.white,
          duration: Duration(seconds: 6),
        );
        return;
      }

      // Convert Facebook conversations to app format
      final facebookChats = <Map<String, dynamic>>[];

      // Processing conversations

      for (final conversation in conversations) {
        try {
          // Process conversation (simplified)

          // Extract user ID from the participants array (Facebook API returns participants instead of link)
          String userId = 'unknown';
          String contactName = 'Unknown User'; // Initialize contact name

          // PRIORITY: Use real participant names from Facebook API
          print(
              '🔍 Checking participants for conversation: ${conversation['id']}');
          print('🔍 Participants data: ${conversation['participants']}');
          print(
              '🔍 Participants type: ${conversation['participants'].runtimeType}');

          if (conversation['participants'] != null) {
            print('🔍 Participants is not null');
            if (conversation['participants']['data'] != null) {
              print('🔍 Participants data is not null');
            } else {
              print('⚠️ Participants data is null');
            }
          } else {
            print('⚠️ Participants is null');
          }

          if (conversation['participants'] != null &&
              conversation['participants']['data'] != null) {
            final participants = conversation['participants']['data'] as List;
            print(
                '🔍 Found ${participants.length} participants in conversation');

            if (participants.length >= 2) {
              // Find the user (not the page)
              for (final participant in participants) {
                final participantId = participant['id'].toString();
                final participantName = participant['name']?.toString();

                print('🔍 Participant: $participantName (ID: $participantId)');
                print('🔍 Page ID: $facebookPageId');
                print('🔍 Is not page: ${participantId != facebookPageId}');

                if (participantId != facebookPageId &&
                    participantName != null) {
                  userId = participantId;
                  contactName = participantName;
                  print('✅ Using real participant: $contactName (ID: $userId)');
                  break;
                } else {
                  print(
                      '⚠️ Skipping participant: $participantName (ID: $participantId) - is page or no name');
                }
              }
            } else {
              print('⚠️ Not enough participants: ${participants.length}');
            }
          } else {
            print('⚠️ No participants data found');
          }

          // Fallback: extract from link if no participants
          if (userId == 'unknown' && conversation['link'] != null) {
            print('⚠️ No real participants found, using link fallback');
            final link = conversation['link'].toString();
            final linkParts = link.split('/');
            if (linkParts.length >= 4 && linkParts[2] == 'inbox') {
              final potentialUserId = linkParts[3];
              if (RegExp(r'^\d+$').hasMatch(potentialUserId) &&
                  potentialUserId != facebookPageId) {
                userId = potentialUserId;
                contactName = 'Facebook User $userId';
                print('⚠️ Using fallback name: $contactName');
              }
            }
          }

          // Fallback: If participants didn't give us a valid user ID, try to get it from messages
          if (userId == 'unknown') {
            print(
                '🔍 Real participants didn\'t give valid user ID, trying messages...');
            final userInfo = await _getUserInfoFromMessages(
                conversation['id'], pageAccessToken);
            if (userInfo != null) {
              userId = userInfo['id'];
              contactName = userInfo['name'];
              print(
                  '✅ Got user info from messages: $contactName (ID: $userId)');
            }
          }

          // User ID extracted

          // Generate profile image based on real name
          String profileImageUrl = '';
          print('🔍 PROFILE IMAGE DEBUG for $contactName (ID: $userId)');
          
          if (contactName != 'Unknown User' &&
              contactName != 'Facebook User $userId') {
            
            // APPROACH 1: Try direct Facebook profile picture URL (most reliable)
            try {
              final directProfileUrl = 'https://graph.facebook.com/$userId/picture?type=normal';
              print('🔍 Trying direct URL: $directProfileUrl');
              
              // Test if the URL is accessible with a GET request (not HEAD)
              final testResponse = await http.get(Uri.parse(directProfileUrl));
              print('🔍 Direct URL response: ${testResponse.statusCode}');
              
              if (testResponse.statusCode == 200) {
                profileImageUrl = directProfileUrl;
                print('✅ SUCCESS: Got direct Facebook profile picture for $contactName: $profileImageUrl');
              } else {
                throw Exception('Direct profile URL returned ${testResponse.statusCode}');
              }
            } catch (e) {
              print('⚠️ Direct profile URL failed for $contactName: $e');
              
              // APPROACH 2: Try Graph API call
              try {
                print('🔍 Trying Graph API for $contactName...');
                final profileResult = await FacebookGraphApiService.getUserProfile(
                    userId, pageAccessToken);
                print('🔍 Graph API result: ${profileResult['success']}');
                
                if (profileResult['success'] && profileResult['data'] != null) {
                  final profileData = profileResult['data'] as Map<String, dynamic>;
                  final realProfileUrl = profileData['profileImageUrl'] as String?;
                  print('🔍 Graph API profile URL: $realProfileUrl');
                  
                  if (realProfileUrl != null && realProfileUrl.isNotEmpty) {
                    profileImageUrl = realProfileUrl;
                    print('✅ SUCCESS: Got Facebook profile picture via API for $contactName: $profileImageUrl');
                  } else {
                    throw Exception('No profile picture available from API');
                  }
                } else {
                  throw Exception('Failed to get profile: ${profileResult['error']}');
                }
              } catch (apiError) {
                print('⚠️ Graph API profile fetch failed for $contactName: $apiError');
                
                // APPROACH 3: Try alternative Facebook profile URL formats
                try {
                  final altUrl1 = 'https://graph.facebook.com/$userId/picture?width=200&height=200';
                  final altUrl2 = 'https://graph.facebook.com/$userId/picture?type=large';
                  
                  print('🔍 Trying alternative URL 1: $altUrl1');
                  final altResponse1 = await http.get(Uri.parse(altUrl1));
                  if (altResponse1.statusCode == 200) {
                    profileImageUrl = altUrl1;
                    print('✅ SUCCESS: Got profile picture via alternative URL 1 for $contactName: $profileImageUrl');
                  } else {
                    print('🔍 Alternative URL 1 failed: ${altResponse1.statusCode}');
                    print('🔍 Trying alternative URL 2: $altUrl2');
                    final altResponse2 = await http.get(Uri.parse(altUrl2));
                    if (altResponse2.statusCode == 200) {
                      profileImageUrl = altUrl2;
                      print('✅ SUCCESS: Got profile picture via alternative URL 2 for $contactName: $profileImageUrl');
                    } else {
                      throw Exception('All alternative URLs failed');
                    }
                  }
                } catch (altError) {
                  print('⚠️ Alternative URLs failed for $contactName: $altError');
                  
                  // FINAL FALLBACK: Generated avatar with real name initials
                  final initials = _generateInitials(contactName);
                  // Use a more professional color scheme based on name hash
                  final colorScheme = _getColorSchemeForName(contactName);
                  profileImageUrl = 'https://dummyimage.com/100x100/$colorScheme/ffffff&text=$initials&font=roboto';
                  print('⚠️ FALLBACK: Generated avatar for $contactName: $profileImageUrl');
                }
              }
            }
          } else {
            // Use fallback for generic names
            final initials = _generateInitials(contactName);
            final colorScheme = _getColorSchemeForName(contactName);
            profileImageUrl = 'https://dummyimage.com/100x100/$colorScheme/ffffff&text=$initials&font=roboto';
            print('⚠️ Using fallback avatar for generic name: $contactName');
          }

          // Get the actual last message from Facebook
          String lastMessage = 'Tap to view messages';
          try {
            print('🔍 Fetching last message for conversation: ${conversation['id']}');
            final messagesResult = await FacebookGraphApiService.getConversationMessagesWithToken(
              conversation['id'],
              pageAccessToken,
            );
            
            if (messagesResult['success'] == true && messagesResult['data'] != null) {
              final messages = messagesResult['data'] as List<dynamic>;
              if (messages.isNotEmpty) {
                final lastMsg = messages.first; // Facebook returns messages in reverse chronological order
                final messageText = lastMsg['message']?.toString() ?? '';
                final messageFromId = lastMsg['from']['id']?.toString() ?? '';
                final isFromUser = messageFromId != facebookPageId;
                
                if (messageText.isNotEmpty) {
                  lastMessage = isFromUser ? messageText : 'You: $messageText';
                  print('✅ Got last message: "$lastMessage" (from ${isFromUser ? 'USER' : 'PAGE'})');
                } else {
                  print('⚠️ Last message is empty');
                }
              } else {
                print('⚠️ No messages found in conversation');
              }
            } else {
              print('⚠️ Failed to fetch messages: ${messagesResult['error']}');
            }
          } catch (e) {
            print('⚠️ Error fetching last message: $e');
          }

          // Convert Facebook conversation to app format
          final appChat = {
            'id': conversation['id'],
            // Use the actual conversation ID directly
            'contactName': contactName,
            'lastMessage': lastMessage,
            'timestamp': _parseTimestamp(conversation['updated_time']),
            'unreadCount': conversation['unread_count'] ?? 0,
            'profileImageUrl': profileImageUrl.isNotEmpty
                ? profileImageUrl
                : 'https://dummyimage.com/100x100/cccccc/666666&text=${contactName.replaceAll(' ', '')}',
            'platform': 'Facebook',
            'platformIcon': '💬',
            'conversationId': conversation['id'],
            'userId': userId,
            // Store the actual user ID for sending messages
            'pageId': facebookPageId,
            'messageCount': conversation['message_count'] ?? 0,
            'needsLastMessage': false,
            // We've already fetched the last message
          };
          facebookChats.add(appChat);

          print('✅ Added chat: $contactName with avatar: $profileImageUrl');
          print('📱 Chat details: ID=${conversation['id']}, Messages=${conversation['message_count']}, Last active=${_formatLastActive(conversation['updated_time'])}');
          print('📱 Last message: "$lastMessage"');
          print('📱 Profile image: $profileImageUrl');

          // Conversation processed
        } catch (e) {
          print('❌ Error processing conversation ${conversation['id']}: $e');
          print('❌ Stack trace: ${StackTrace.current}');
        }
      }

      // Update chat list - remove any existing Facebook chats first
      final existingChats =
          chatList.where((chat) => chat['platform'] != 'Facebook').toList();
      chatList.value = [...existingChats, ...facebookChats];

      // Facebook chats added to list

      // Skip updating last messages to avoid excessive API calls

      applyFilter();

      // Show success message
      if (facebookChats.isNotEmpty) {
        Get.snackbar(
          'Success',
          'Loaded ${facebookChats.length} real Facebook conversations!',
          backgroundColor: Colors.green,
          colorText: Colors.white,
          duration: Duration(seconds: 3),
        );
      }
    } catch (e) {
      print('❌ Error loading Facebook chats: $e');
      print('❌ Stack trace: ${StackTrace.current}');
      Get.snackbar(
        'Error',
        'Failed to load Facebook chats: $e\nPlease check your connection and try again.',
        backgroundColor: Colors.red,
        colorText: Colors.white,
        duration: Duration(seconds: 5),
      );

      // Only show mock data if explicitly requested for testing
      // _loadMockFacebookChats(); // Commented out - no more fake data!
    }

    print('🔍 loadFacebookChats method completed');
    print('🔍 loadFacebookChats method finished');
  }

  /// Update last messages for Facebook conversations
  Future<void> _updateLastMessages(
      List<Map<String, dynamic>> conversations, String pageAccessToken) async {
    try {
      print(
          '🔄 Updating last messages for ${conversations.length} conversations...');

      for (final conversation in conversations) {
        if (conversation['needsLastMessage'] == true) {
          try {
            final conversationId = conversation['conversationId'];
            final result =
                await FacebookGraphApiService.getConversationMessagesWithToken(
              conversationId,
              pageAccessToken,
            );

            if (result['success'] && result['data'] != null) {
              final messages = result['data'] as List;
              if (messages.isNotEmpty) {
                final message =
                    messages.first; // Get the first (most recent) message
                final messageText = message['message'] ?? 'No message content';

                // Update the conversation in the chat list
                final chatIndex = chatList
                    .indexWhere((chat) => chat['id'] == conversation['id']);
                if (chatIndex != -1) {
                  chatList[chatIndex]['lastMessage'] = messageText.length > 50
                      ? '${messageText.substring(0, 50)}...'
                      : messageText;
                  chatList[chatIndex]['needsLastMessage'] = false;

                  print(
                      '✅ Updated last message for ${conversation['contactName']}: ${messageText.substring(0, messageText.length > 30 ? 30 : messageText.length)}...');
                }
              }
            }

            // Small delay to avoid hitting rate limits
            await Future.delayed(Duration(milliseconds: 100));
          } catch (e) {
            print(
                '⚠️ Failed to update last message for conversation ${conversation['conversationId']}: $e');
          }
        }
      }

      print('✅ Last message update completed');
    } catch (e) {
      print('❌ Error updating last messages: $e');
    }
  }

  /// Load other channel chats (REAL DATA ONLY)
  Future<void> loadOtherChannelChats() async {
    // TODO: Implement other channel integrations
    // For now, only load real data - no mock data
    print(
        'ℹ️ Other channel integrations not yet implemented - only Facebook data will be shown');

    // You can uncomment this for testing, but it will show fake data
    // _loadMockOtherChannelChats();
  }

  /// Load mock other channel chats (FOR TESTING ONLY)
  void _loadMockOtherChannelChats() {
    final mockOtherChats = [
      {
        'id': 'web_1',
        'contactName': 'Website Visitor',
        'contactId': 'web_user_1',
        'lastMessage': 'I need help with my order',
        'lastMessageTime':
            DateTime.now().subtract(Duration(hours: 3)).toIso8601String(),
        'messageCount': 8,
        'unreadCount': 0,
        'platform': 'Website',
        'platformIcon': '🌐',
        'platformColor': '#2196F3',
        'profileImageUrl':
            'https://ui-avatars.com/api/?name=WV&size=50&background=2196F3&color=fff',
        'conversationId': 'web_conv_1',
        'isActive': true,
        'timestamp': DateTime.now().subtract(Duration(hours: 3)),
      },
      {
        'id': 'ig_1',
        'contactName': 'Instagram User',
        'contactId': 'ig_user_1',
        'lastMessage': 'Love your products!',
        'lastMessageTime':
            DateTime.now().subtract(Duration(hours: 4)).toIso8601String(),
        'messageCount': 4,
        'unreadCount': 0,
        'platform': 'Instagram',
        'platformIcon': '📷',
        'platformColor': '#E1306C',
        'profileImageUrl':
            'https://ui-avatars.com/api/?name=IU&size=50&background=E1306C&color=fff',
        'conversationId': 'ig_conv_1',
        'isActive': true,
        'timestamp': DateTime.now().subtract(Duration(hours: 4)),
      },
    ];

    chatList.addAll(mockOtherChats);
    print('⚠️ Added mock other channel chats (FOR TESTING ONLY)');
  }

  /// Apply current filter and search
  void applyFilter() {
    var filtered = List<Map<String, dynamic>>.from(chatList);

    // Apply search filter
    if (searchQuery.value.isNotEmpty) {
      filtered = filtered.where((chat) {
        return chat['contactName']
                .toString()
                .toLowerCase()
                .contains(searchQuery.value.toLowerCase()) ||
            chat['lastMessage']
                .toString()
                .toLowerCase()
                .contains(searchQuery.value.toLowerCase()) ||
            chat['platform']
                .toString()
                .toLowerCase()
                .contains(searchQuery.value.toLowerCase());
      }).toList();
    }

    // Apply category filter
    switch (selectedFilter.value) {
      case 'Unread':
        filtered = filtered.where((chat) => chat['unreadCount'] > 0).toList();
        break;
      case 'Groups':
        // TODO: Implement groups filter
        break;
      case 'Filter':
        // TODO: Implement date filter
        break;
      default: // Inbox - show all
        break;
    }

    // Sort by timestamp (newest first)
    filtered.sort((a, b) => b['timestamp'].compareTo(a['timestamp']));

    filteredChatList.value = filtered;
  }

  /// Search chats
  void searchChats(String query) {
    searchQuery.value = query;
    applyFilter();
  }

  /// Select filter
  void selectFilter(String filter) {
    selectedFilter.value = filter;
    applyFilter();
  }

  /// Toggle create new dropdown
  void toggleCreateNewDropdown() {
    isCreateNewDropdownOpen.value = !isCreateNewDropdownOpen.value;
    if (isCreateNewDropdownOpen.value) {
      isFilterDropdownOpen.value = false;
    }
  }

  void onCreateNewOptionTap(String key) {
    switch (key) {
      case 'new_group':
        Get.snackbar('New Group', 'Opening group creation...',
            backgroundColor: Colors.blue, colorText: Colors.white);
        break;
      case 'new_group_message':
        Get.snackbar('New Group Message', 'Opening group message...',
            backgroundColor: Colors.blue, colorText: Colors.white);
        break;
      case 'follow_up_campaign':
        Get.snackbar('Coming soon', 'Follow-up Campaign is coming soon',
            backgroundColor: Colors.grey, colorText: Colors.white);
        break;
    }
    isCreateNewDropdownOpen.value = false;
  }

  /// Toggle filter dropdown
  void toggleFilterDropdown() {
    isFilterDropdownOpen.value = !isFilterDropdownOpen.value;
    if (isFilterDropdownOpen.value) {
      isCreateNewDropdownOpen.value = false;
    }
  }

  /// Get formatted timestamp
  String getFormattedTimestamp(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inDays > 0) {
      return '${difference.inDays}d ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m ago';
    } else {
      return 'Just now';
    }
  }

  /// Get time for display
  String getTimeDisplay(DateTime timestamp) {
    return '${timestamp.hour.toString().padLeft(2, '0')}:${timestamp.minute.toString().padLeft(2, '0')}';
  }

  /// Create new chat/channel
  void createNewChat(String channelName) {
    // TODO: Implement new chat creation
    Get.snackbar(
      'Info',
      'Creating new $channelName chat...',
      backgroundColor: Colors.blue,
      colorText: Colors.white,
    );
    isCreateNewDropdownOpen.value = false;
  }

  /// Apply date filter
  void applyDateFilter(String filter) {
    // TODO: Implement date filtering
    Get.snackbar(
      'Info',
      'Filtering by $filter...',
      backgroundColor: Colors.blue,
      colorText: Colors.white,
    );
    isFilterDropdownOpen.value = false;
  }

  /// Refresh only Facebook chats
  Future<void> refreshFacebookChats() async {
    try {
      print('🔄 Refreshing Facebook chats...');
      await loadFacebookChats();
    } catch (e) {
      print('❌ Error refreshing Facebook chats: $e');
    }
  }

  /// Mark chat as read
  void markAsRead(String chatId) {
    final chatIndex = chatList.indexWhere((chat) => chat['id'] == chatId);
    if (chatIndex != -1) {
      chatList[chatIndex]['unreadCount'] = 0;
      applyFilter();
    }
  }

  /// Get total unread count
  int get totalUnreadCount {
    return chatList.fold(
        0, (sum, chat) => sum + ((chat['unreadCount'] ?? 0) as int));
  }

  /// Parse timestamp from various formats
  DateTime _parseTimestamp(dynamic timestamp) {
    if (timestamp == null) return DateTime.now();

    if (timestamp is String) {
      try {
        return DateTime.parse(timestamp);
      } catch (e) {
        print('❌ Error parsing timestamp: $timestamp');
        return DateTime.now();
      }
    } else if (timestamp is DateTime) {
      return timestamp;
    } else {
      return DateTime.now();
    }
  }

  /// Format last active time
  String _formatLastActive(dynamic timestamp) {
    final dateTime = _parseTimestamp(timestamp);
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inDays > 7) {
      // Show date for old messages
      return '${dateTime.day}/${dateTime.month}';
    } else if (difference.inDays > 0) {
      return '${difference.inDays}d ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m ago';
    } else {
      return 'now';
    }
  }

  /// Get meaningful last message text
  String _getLastMessageText(Map<String, dynamic> conversation) {
    final messageCount = conversation['message_count'] ?? 0;

    if (messageCount == 0) {
      return 'No messages yet';
    } else {
      // Show a simple message indicating there are messages
      return 'Tap to view messages';
    }
  }

  // Last message content fetching removed to reduce API calls

  /// Get user information from conversation messages
  Future<Map<String, dynamic>?> _getUserInfoFromMessages(
      String conversationId, String pageAccessToken) async {
    try {
      print(
          '🔍 Getting user info from messages for conversation: $conversationId');

      final messagesResult =
          await FacebookGraphApiService.getConversationMessagesWithToken(
        conversationId,
        pageAccessToken,
      );

      if (messagesResult['success'] && messagesResult['data'] != null) {
        final messages = messagesResult['data'];
        if (messages is List && messages.isNotEmpty) {
          // Look for the first message from a user (not from the page)
          for (final message in messages) {
            if (message['from'] != null &&
                message['from']['id'] != null &&
                message['from']['name'] != null) {
              final fromId = message['from']['id'].toString();
              final fromName = message['from']['name'].toString();

              // Check if this is a real user (not the page)
              if (fromId != '313808701826338' &&
                  RegExp(r'^\d+$').hasMatch(fromId)) {
                print('✅ Found user from message: $fromName (ID: $fromId)');
                return {
                  'id': fromId,
                  'name': fromName,
                };
              }
            }
          }
        }
      }

      return null;
    } catch (e) {
      print('⚠️ Error getting user info from messages: $e');
      return null;
    }
  }

  /// Test method disabled - auto-refresh removed
  Future<void> testRealTimeUpdates() async {
    print('🧪 Real-time updates disabled');
  }

  /// Show notification for new messages
  void _showNewMessageNotification(String contactName, int messageCount) {
    final messageText = messageCount == 1
        ? 'New message from $contactName'
        : '$messageCount new messages from $contactName';

    Get.snackbar(
      '💬 New Message',
      messageText,
      snackPosition: SnackPosition.TOP,
      duration: Duration(seconds: 2),
      backgroundColor: Colors.blue,
      colorText: Colors.white,
      icon: Icon(Icons.chat_bubble, color: Colors.white),
    );
  }

  /// Poll for new Facebook messages
  Future<void> _pollForNewMessages() async {
    try {
      final userId = getCurrentUserId();
      if (userId.isEmpty) return;

      // Get user's Facebook page settings
      final userDoc =
          await _firestore.collection('channel_settings').doc(userId).get();

      if (!userDoc.exists || userDoc.data()!['isFacebookConnected'] != true) {
        return; // Facebook not connected
      }

      final facebookPageId = userDoc.data()!['facebookPageId'] as String?;
      if (facebookPageId == null || facebookPageId.isEmpty) return;

      // Get page access token
      final channelController = Get.find<ChannelController>();
      final pageAccessToken =
          await channelController.getPageAccessToken(facebookPageId);

      if (pageAccessToken == null || pageAccessToken.isEmpty) {
        print('⚠️ No access token for polling');
        return;
      }

      // Get latest conversations to check for new messages
      final conversationsResult =
          await FacebookGraphApiService.getPageConversationsWithToken(
        facebookPageId,
        pageAccessToken,
      );

      if (conversationsResult['success'] &&
          conversationsResult['data'] != null) {
        final conversations = conversationsResult['data'] as List;
        print('📊 Polling found ${conversations.length} conversations');

        // Check if any conversations have new messages
        bool hasNewMessages = false;
        for (final conversation in conversations) {
          final lastUpdate = conversation['updated_time'] as String?;
          if (lastUpdate != null) {
            // Check if this conversation was updated recently
            final updateTime = DateTime.tryParse(lastUpdate);
            if (updateTime != null) {
              final timeDiff = DateTime.now().difference(updateTime);
              if (timeDiff.inMinutes < 5) {
                // Updated in last 5 minutes
                hasNewMessages = true;
                print(
                    '🆕 New messages detected in conversation: ${conversation['id']}');
                break;
              }
            }
          }
        }

        if (hasNewMessages) {
          print('🔄 New messages detected, refreshing chat list...');
          await loadFacebookChats();
        } else {
          // No new messages, just continue polling
          print('🔄 No new messages detected');
        }
      }
    } catch (e) {
      print('❌ Error polling for new messages: $e');
    }
  }

  /// Handle real-time message updates
  void handleRealtimeMessage(Map<String, dynamic> messageData) {
    try {
      print('📨 Handling real-time message: ${messageData['text']}');

      final conversationId = messageData['conversationId'];
      final messageText = messageData['text'];
      final isFromUser = messageData['isFromUser'] ?? false;
      final platform = messageData['platform'] ?? 'Unknown';

      // Find the conversation in the chat list
      final chatIndex = chatList.indexWhere((chat) =>
          chat['conversationId'] == conversationId ||
          chat['id'] == conversationId);

      if (chatIndex != -1) {
        // Update the last message and timestamp
        chatList[chatIndex]['lastMessage'] = messageText;
        chatList[chatIndex]['timestamp'] = DateTime.now();

        // Update unread count if message is from user
        if (isFromUser) {
          chatList[chatIndex]['unreadCount'] =
              (chatList[chatIndex]['unreadCount'] ?? 0) + 1;
        }

        // Move the conversation to the top
        final updatedChat = chatList[chatIndex];
        chatList.removeAt(chatIndex);
        chatList.insert(0, updatedChat);

        // Apply filter to update the filtered list
        applyFilter();

        // Show notification for new messages from users
        if (isFromUser) {
          final contactName = updatedChat['contactName'] ?? 'Unknown';
          _showNewMessageNotification(contactName, 1);
        }

        print('✅ Updated chat list with real-time message');
      } else {
        print('⚠️ Conversation not found in chat list: $conversationId');
      }
    } catch (e) {
      print('❌ Error handling real-time message: $e');
    }
  }

  /// Handle real-time conversation updates
  void handleRealtimeConversationUpdate(Map<String, dynamic> conversationData) {
    try {
      print(
          '💬 Handling real-time conversation update: ${conversationData['contactName']}');

      final conversationId = conversationData['conversationId'];
      final contactName = conversationData['contactName'];
      final lastMessage = conversationData['lastMessage'];
      final platform = conversationData['platform'] ?? 'Unknown';
      final unreadCount = conversationData['unreadCount'] ?? 0;
      final profileImageUrl = conversationData['profileImageUrl'];

      // Find the conversation in the chat list
      final chatIndex = chatList.indexWhere((chat) =>
          chat['conversationId'] == conversationId ||
          chat['id'] == conversationId);

      if (chatIndex != -1) {
        // Update existing conversation
        chatList[chatIndex]['contactName'] = contactName;
        chatList[chatIndex]['lastMessage'] = lastMessage;
        chatList[chatIndex]['unreadCount'] = unreadCount;
        chatList[chatIndex]['timestamp'] = DateTime.now();
        if (profileImageUrl != null) {
          chatList[chatIndex]['profileImageUrl'] = profileImageUrl;
        }

        // Move to top if there are unread messages
        if (unreadCount > 0) {
          final updatedChat = chatList[chatIndex];
          chatList.removeAt(chatIndex);
          chatList.insert(0, updatedChat);
        }

        print('✅ Updated existing conversation');
      } else {
        // Add new conversation
        final newChat = {
          'id': conversationId,
          'conversationId': conversationId,
          'contactName': contactName,
          'lastMessage': lastMessage,
          'timestamp': DateTime.now(),
          'unreadCount': unreadCount,
          'profileImageUrl': profileImageUrl ??
              'https://dummyimage.com/100x100/cccccc/666666&text=${contactName.replaceAll(' ', '')}',
          'platform': platform,
          'platformIcon': _getPlatformIcon(platform),
          'messageCount': 1,
          'needsLastMessage': false,
          'canReply': true,
        };

        chatList.insert(0, newChat);
        print('✅ Added new conversation from real-time update');
      }

      // Apply filter to update the filtered list
      applyFilter();
    } catch (e) {
      print('❌ Error handling real-time conversation update: $e');
    }
  }

  /// Get platform icon for a platform name
  String _getPlatformIcon(String platform) {
    switch (platform.toLowerCase()) {
      case 'facebook':
        return '💬';
      case 'instagram':
        return '📷';
      case 'telegram':
        return '📱';
      case 'whatsapp':
        return '📞';
      case 'slack':
        return '💼';
      case 'viber':
        return '💜';
      case 'discord':
        return '🎮';
      case 'website':
        return '🌐';
      default:
        return '💬';
    }
  }

  /// Handle webhook message from webhook service
  void handleWebhookMessage(Map<String, dynamic> messageData) {
    try {
      print('📨 ChatController received webhook message: ${messageData['text']}');
      
      // Update chat list with new message
      final conversationId = messageData['conversationId'];
      final messageText = messageData['text'];
      final senderName = messageData['senderName'] ?? 'Facebook User';
      final isFromUser = messageData['isFromUser'] ?? true;
      
      // Find the conversation in chat list
      final chatIndex = chatList.indexWhere((chat) => 
          chat['conversationId'] == conversationId || chat['id'] == conversationId);
      
      if (chatIndex != -1) {
        // Update existing conversation
        chatList[chatIndex]['lastMessage'] = messageText;
        chatList[chatIndex]['timestamp'] = DateTime.now();
        
        if (isFromUser) {
          chatList[chatIndex]['unreadCount'] = (chatList[chatIndex]['unreadCount'] ?? 0) + 1;
        }
        
        // Move conversation to top if it has unread messages
        if (chatList[chatIndex]['unreadCount'] > 0) {
          final updatedChat = chatList[chatIndex];
          chatList.removeAt(chatIndex);
          chatList.insert(0, updatedChat);
        }
        
        // Apply filter to update filtered list
        applyFilter();
        
        print('✅ Updated chat list with webhook message');
      } else {
        print('⚠️ Conversation not found in chat list: $conversationId');
      }
    } catch (e) {
      print('❌ Error handling webhook message in ChatController: $e');
    }
  }

  // ====== SELECTION MODE METHODS ======

  /// Enter selection mode
  void enterSelectionMode() {
    isSelectionMode.value = true;
    selectedChats.clear();
    isCreateNewDropdownOpen.value = false;
    isFilterDropdownOpen.value = false;
  }

  /// Exit selection mode
  void exitSelectionMode() {
    isSelectionMode.value = false;
    selectedChats.clear();
    isMoreOptionsDropdownOpen.value = false;
  }

  /// Toggle selection of a chat
  void toggleChatSelection(String chatId) {
    if (selectedChats.contains(chatId)) {
      selectedChats.remove(chatId);
    } else {
      selectedChats.add(chatId);
    }
    
    // Exit selection mode if no chats are selected
    if (selectedChats.isEmpty) {
      exitSelectionMode();
    }
  }

  /// Select all chats
  void selectAllChats() {
    selectedChats.clear();
    for (var chat in filteredChatList) {
      selectedChats.add(chat['id'] ?? chat['conversationId'] ?? '');
    }
  }

  /// Check if a chat is selected
  bool isChatSelected(String chatId) {
    return selectedChats.contains(chatId);
  }

  /// Get selected chats count
  int get selectedChatsCount => selectedChats.length;

  /// Delete selected chats (both from Facebook and Firestore)
  Future<void> deleteSelectedChats() async {
    if (selectedChats.isEmpty) return;

    print('🗑️ Starting deletion of ${selectedChats.length} chats');
    print('🗑️ Selected chat IDs: $selectedChats');

    try {
      isLoading.value = true;
      
      int facebookDeletedCount = 0;
      int firestoreDeletedCount = 0;
      List<String> errors = [];
      
      // Delete from Facebook and Firestore
      for (String chatId in selectedChats) {
        print('🗑️ Processing chat ID: $chatId');
        try {
          // Find the chat data to get platform info
          final chat = chatList.firstWhere(
            (chat) => (chat['id'] ?? chat['conversationId']) == chatId,
            orElse: () => {},
          );
          
          print('🗑️ Found chat data: $chat');
          final platform = chat['platform'] as String?;
          final conversationId = chat['conversationId'] as String?;
          print('🗑️ Platform: $platform, Conversation ID: $conversationId');
          print('🗑️ Platform check: ${platform?.toLowerCase() == 'facebook'}');
          print('🗑️ Platform type: ${platform.runtimeType}');
          
          // Attempt Facebook operations - try to mark conversation as read and hide it
          if (platform?.toLowerCase() == 'facebook') {
            final fbConversationId = conversationId ?? chatId;
            print('🗑️ Attempting Facebook conversation management for: $fbConversationId');
            try {
              // Get page access token from Firestore
              final pageTokenDoc = await _firestore
                  .collection('integrations')
                  .doc('facebook')
                  .collection('pages')
                  .limit(1)
                  .get();
              
              print('🗑️ Found ${pageTokenDoc.docs.length} Facebook page configurations');
              if (pageTokenDoc.docs.isNotEmpty) {
                final pageData = pageTokenDoc.docs.first.data();
                final pageId = pageTokenDoc.docs.first.id;
                final pageAccessToken = pageData['pageAccessToken'] as String?;
                print('🗑️ Page ID: $pageId, Has token: ${pageAccessToken != null}');
                
                if (pageAccessToken != null) {
                  // Try to mark conversation as read (this might help "hide" it)
                  print('🗑️ Attempting to mark conversation as read...');
                  final readResponse = await http.post(
                    Uri.parse('https://graph.facebook.com/v23.0/$fbConversationId'),
                    headers: {'Content-Type': 'application/json'},
                    body: jsonEncode({
                      'access_token': pageAccessToken,
                      'is_read': true,
                    }),
                  );
                  
                  print('🗑️ Facebook read status response: ${readResponse.statusCode}');
                  print('🗑️ Facebook read status body: ${readResponse.body}');
                  
                  if (readResponse.statusCode == 200) {
                    facebookDeletedCount++;
                    print('✅ Facebook conversation marked as read: $fbConversationId');
                  } else {
                    print('⚠️ Could not mark conversation as read: ${readResponse.body}');
                    errors.add('Facebook: Could not manage conversation - ${readResponse.body}');
                  }
                } else {
                  errors.add('No Facebook access token found for $fbConversationId');
                }
              } else {
                errors.add('No Facebook page configuration found for $fbConversationId');
              }
            } catch (e) {
              print('🗑️ Facebook management error: $e');
              errors.add('Facebook management error for $fbConversationId: ${e.toString()}');
            }
          } else {
            print('🗑️ Skipping Facebook deletion - Platform: $platform, Conversation ID: $conversationId');
          }
          
          // Delete from Firestore (using user_chats collection where data is actually stored)
          final userId = FirebaseAuth.instance.currentUser?.uid;
          print('🗑️ Current user ID: $userId');
          if (userId != null) {
            // Update the user_chats document to remove this chat
            final userChatsDoc = await _firestore.collection('user_chats').doc(userId).get();
            print('🗑️ User chats document exists: ${userChatsDoc.exists}');
            if (userChatsDoc.exists) {
              final chatData = userChatsDoc.data();
              final facebookChats = chatData?['facebookChats'] as List<dynamic>? ?? [];
              print('🗑️ Current Facebook chats count: ${facebookChats.length}');
              
              // Remove the chat from the list
              final originalCount = facebookChats.length;
              print('🗑️ Looking for chat with ID: $chatId');
              print('🗑️ Available chat IDs in array: ${facebookChats.map((c) => c['id'] ?? c['conversationId']).toList()}');
              
              facebookChats.removeWhere((chat) {
                final chatIdInArray = chat['id'] ?? chat['conversationId'];
                // Try both with and without fb_ prefix
                final matches = chatIdInArray == chatId || 
                               chatIdInArray == 'fb_$chatId' || 
                               chatId == chatIdInArray.replaceFirst('fb_', '') ||
                               chatIdInArray == chatId.replaceFirst('t_', 'fb_t_');
                if (matches) {
                  print('🗑️ Found matching chat to remove: $chatIdInArray');
                }
                return matches;
              });
              print('🗑️ After removal: ${facebookChats.length} (removed ${originalCount - facebookChats.length})');
              
              // Update the document
              await _firestore.collection('user_chats').doc(userId).update({
                'facebookChats': facebookChats,
                'updatedAt': FieldValue.serverTimestamp(),
              });
              print('🗑️ Updated user_chats document successfully');
            }
          }
          firestoreDeletedCount++;
          
        } catch (e) {
          errors.add('Firestore deletion error for $chatId: ${e.toString()}');
        }
      }
      
      // Remove from local lists
      print('🗑️ Removing from local lists...');
      final originalChatListCount = chatList.length;
      final originalFilteredCount = filteredChatList.length;
      
      chatList.removeWhere((chat) => selectedChats.contains(chat['id'] ?? chat['conversationId']));
      filteredChatList.removeWhere((chat) => selectedChats.contains(chat['id'] ?? chat['conversationId']));
      
      print('🗑️ Local lists updated - Chat list: $originalChatListCount -> ${chatList.length}, Filtered: $originalFilteredCount -> ${filteredChatList.length}');
      
      // Clear selection and exit selection mode
      selectedChats.clear();
      exitSelectionMode();
      
      // Show success message with details
      String message = 'Deleted $firestoreDeletedCount chat(s) from app';
      if (facebookDeletedCount > 0) {
        message += ' and managed $facebookDeletedCount on Facebook';
      }
      if (errors.isNotEmpty) {
        message += ' (${errors.length} errors occurred)';
      }
      
      Get.snackbar(
        'Success',
        message,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green,
        colorText: Colors.white,
        duration: Duration(seconds: 4),
      );
      
      // Show errors if any
      if (errors.isNotEmpty) {
        Get.snackbar(
          'Partial Success',
          'Some deletions failed. Check console for details.',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.orange,
          colorText: Colors.white,
        );
      }
      
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to delete chats: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }

  /// Toggle more options dropdown
  void toggleMoreOptionsDropdown() {
    isMoreOptionsDropdownOpen.value = !isMoreOptionsDropdownOpen.value;
  }

  /// Handle more options actions (UI only for now)
  void handleMoreOptionsAction(String action) {
    switch (action) {
      case 'create_group':
        Get.snackbar('Info', 'Create a group - Coming soon', snackPosition: SnackPosition.BOTTOM);
        break;
      case 'send_group_message':
        Get.snackbar('Info', 'Send a group message - Coming soon', snackPosition: SnackPosition.BOTTOM);
        break;
      case 'mark_as_read':
        Get.snackbar('Info', 'Mark as read - Coming soon', snackPosition: SnackPosition.BOTTOM);
        break;
      case 'move_to_another_group':
        Get.snackbar('Info', 'Move to another group - Coming soon', snackPosition: SnackPosition.BOTTOM);
        break;
    }
    isMoreOptionsDropdownOpen.value = false;
  }
}
