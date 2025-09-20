import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:minechat/core/services/facebook_graph_api_service.dart';
import 'package:minechat/controller/channel_controller/channel_controller.dart';
import 'dart:async'; // Added for Timer

class ChatController extends GetxController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Chat list state
  var chatList = <Map<String, dynamic>>[].obs;
  var filteredChatList = <Map<String, dynamic>>[].obs;
  var isLoading = false.obs;
  var selectedFilter = 'Inbox'.obs;
  var searchQuery = ''.obs;

  // Create new dropdown
  var isCreateNewDropdownOpen = false.obs;
  var isFilterDropdownOpen = false.obs;

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

  // Filter options
  final List<String> filterOptions = [
    'Today',
    'Yesterday',
    'This Week',
    'This Month',
    'Date Range'
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

    // Load initial chats
    loadFacebookChats();

    // Start real-time updates
    _startRealTimeUpdates();

    // Start time update timer
    _startTimeUpdateTimer();
  }

  @override
  void onClose() {
    // Clean up timers
    _refreshTimer?.cancel();
    _timeUpdateTimer?.cancel();
    super.onClose();
  }

  /// Start real-time chat updates (disabled auto-refresh)
  void _startRealTimeUpdates() {
    print('🔄 Real-time updates disabled - no auto-refresh');
    // Auto-refresh removed for better performance
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

  /// Load all chats from different channels
  Future<void> loadChats() async {
    try {
      isLoading.value = true;
      final userId = getCurrentUserId();
      if (userId.isEmpty) return;

      // Clear existing chats first
      chatList.clear();

      // Load Facebook Messenger chats (REAL DATA ONLY)
      await loadFacebookChats();

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
      final userId = getCurrentUserId();

      // Get user's Facebook page settings
      final userDoc = await _firestore
          .collection('channel_settings')
          .doc(userId)
          .get();

      if (!userDoc.exists || userDoc.data()!['isFacebookConnected'] != true) {
        print('⚠️ Facebook not connected, skipping Facebook chat load');
        return;
      }

      final facebookPageId = userDoc.data()!['facebookPageId'] as String?;
      if (facebookPageId == null || facebookPageId.isEmpty) {
        print('⚠️ No Facebook Page ID found');
        return;
      }

      // Get the channel controller to access page access token
      final channelController = Get.find<ChannelController>();
      final pageAccessToken = await channelController.getPageAccessToken(facebookPageId);

      if (pageAccessToken == null) {
        print('⚠️ No page access token found - trying to load from stored data');
        
        // Try to load Facebook chats from stored data (Firebase Functions)
        try {
          final userChatsDoc = await _firestore
              .collection('user_chats')
              .doc(userId)
              .get();

          if (userChatsDoc.exists) {
            final chatData = userChatsDoc.data();
            final facebookChatsData = chatData?['facebookChats'] as List<dynamic>?;

            if (facebookChatsData != null && facebookChatsData.isNotEmpty) {
              print('✅ Found ${facebookChatsData.length} stored Facebook chats');
              
              // Convert stored Facebook chats to app format
              final facebookChats = <Map<String, dynamic>>[];
              
              for (final chatData in facebookChatsData) {
                final chat = chatData as Map<String, dynamic>;
                
                // Use real user data if available
                final userName = chat['userName'] ?? 'Facebook User ${chat['conversationId'] ?? 'Unknown'}';
                final userProfilePicture = chat['userProfilePicture'] ?? 'https://dummyimage.com/100x100/cccccc/666666&text=FB';
                final lastMessage = chat['lastMessage'] ?? 'No messages yet';
                final lastMessageTime = chat['lastMessageTime'] ?? chat['lastUpdate'];
                
                // Check if we have real data vs fallback data
                final hasRealName = userName.startsWith('Facebook User') == false;
                final hasRealProfilePicture = userProfilePicture.startsWith('https://dummyimage.com') == false;
                final hasRealMessage = lastMessage != 'No messages yet';
                
                print('📊 Chat data quality: $userName - Real name: $hasRealName, Real picture: $hasRealProfilePicture, Real message: $hasRealMessage');
                
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
                
                print('✅ Loaded real Facebook chat: $userName - "$lastMessage"');
              }

              // Update chat list - remove any existing Facebook chats first
              final existingChats = chatList.where((chat) => !chat['id'].toString().startsWith('fb_')).toList();
              chatList.value = [...existingChats, ...facebookChats];

              print('✅ Added ${facebookChats.length} Facebook chats from stored data');
              
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
        
        print('⚠️ No stored Facebook chats found - cannot load real Facebook chats');
        print('💡 To get real Facebook chats, you need to:');
        print('   1. Go to https://developers.facebook.com/');
        print('   2. Create/select your app');
        print('   3. Go to Tools > Graph API Explorer');
        print('   4. Generate Access Token with permissions: pages_show_list, pages_messaging');
        print('   5. Reconnect your Facebook page with the access token');

        Get.snackbar(
          'Facebook Connected (Basic Mode)',
          'To see real chats, reconnect with Facebook Access Token.\nTap for instructions.',
          backgroundColor: Colors.orange,
          colorText: Colors.white,
          duration: Duration(seconds: 6),
          onTap: (_) {
            Get.dialog(
              AlertDialog(
                title: Text('How to Get Real Facebook Chats'),
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('1. Go to Facebook Developers Console'),
                    Text('2. Create/select your app'),
                    Text('3. Go to Tools > Graph API Explorer'),
                    Text('4. Generate Access Token'),
                    Text('5. Add permissions: pages_show_list, pages_messaging'),
                    Text('6. Reconnect your page with the token'),
                  ],
                ),
                actions: [
                  TextButton(
                    onPressed: () => Get.back(),
                    child: Text('Got it'),
                  ),
                ],
              ),
            );
          },
        );
        return; // Don't load mock data if no access token
      }

      // Skip permissions check for now - focus on loading conversations
      print('🔍 Skipping permissions check to focus on conversations...');

      // Test what we can access
      print('🧪 Testing basic page access...');
      try {
        final testResult = await FacebookGraphApiService.verifyPageAccess(facebookPageId, pageAccessToken);
        print('🧪 Page access test result: $testResult');
      } catch (e) {
        print('⚠️ Page access test failed: $e');
      }

      // Test if we can access user profiles
      print('🧪 Testing user profile access...');
      try {
        // Try to get a test user profile (this will fail if we don't have permissions)
        final testUserResult = await FacebookGraphApiService.getUserProfile('123456789', pageAccessToken);
        print('🧪 User profile test result: $testUserResult');
      } catch (e) {
        print('⚠️ User profile test failed: $e');
      }

      print('🔍 Fetching real Facebook conversations for page: $facebookPageId');

      // Get conversations from Facebook Graph API using the page access token
      final conversationsResult = await FacebookGraphApiService.getPageConversationsWithToken(
        facebookPageId,
        pageAccessToken,
      );

      print('📋 Conversations result: $conversationsResult');
      print('📋 Success: ${conversationsResult['success']}');
      print('📋 Data type: ${conversationsResult['data']?.runtimeType}');
      print('📋 Data value: ${conversationsResult['data']}');
      print('📋 Raw response: ${conversationsResult}');

      if (!conversationsResult['success']) {
        throw Exception('Failed to load conversations: ${conversationsResult['error']}');
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
        print('🔍 Keys in first conversation: ${(conversations.first as Map<String, dynamic>).keys.toList()}');
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

      print('🔍 Processing ${conversations.length} conversations...');
      print('📋 First conversation structure: ${conversations.isNotEmpty ? conversations.first : 'No conversations'}');

      for (final conversation in conversations) {
        try {
          print('🔍 Processing conversation: ${conversation['id']}');
          print('📋 Conversation data: $conversation');
          print('🔗 Link: ${conversation['link']}');
          print('🕒 Updated time: ${conversation['updated_time']}');

          // Debug: Check if link exists and its structure
          if (conversation['link'] != null) {
            final link = conversation['link'].toString();
            print('🔗 Raw link: $link');
            print('🔗 Link type: ${link.runtimeType}');
            print('🔗 Link contains /inbox/: ${link.contains('/inbox/')}');
            print('🔗 Link contains /: ${link.contains('/')}');
          } else {
            print('⚠️ No link found in conversation');
          }

          // Extract user ID from the participants array (Facebook API returns participants instead of link)
          String userId = 'unknown';
          String contactName = 'Unknown User'; // Initialize contact name

          // NEW: Try to get real participant information from the conversation
          try {
            print('🔍 Getting real participant information for conversation: ${conversation['id']}');
            print('🔑 Using page access token: ${pageAccessToken.substring(0, 10)}...');

            final participantsResult = await FacebookGraphApiService.getConversationParticipants(
              conversation['id'],
              pageAccessToken,
            );

            print('📋 Participants API result: $participantsResult');
            print('📋 Participants success: ${participantsResult['success']}');
            print('📋 Participants data: ${participantsResult['data']}');

            if (participantsResult['success'] && participantsResult['data'] != null) {
              final convData = participantsResult['data'];
              print('📋 Conversation data from participants API: $convData');
              print('📋 Available keys: ${convData.keys.toList()}');

              // Check if we have participants
              if (convData['participants'] != null && convData['participants'] is Map<String, dynamic>) {
                final participants = convData['participants'];
                print('👥 Real participants from API: $participants');

                if (participants['data'] != null && participants['data'] is List) {
                  final participantsList = participants['data'] as List;
                  print('👥 Participants list: $participantsList');
                  print('👥 Participants length: ${participantsList.length}');

                  if (participantsList.length >= 2) {
                    // First participant is the user, second is the page
                    final userParticipant = participantsList[0];
                    print('👤 User participant: $userParticipant');

                    if (userParticipant is Map<String, dynamic>) {
                      final userParticipantId = userParticipant['id'];
                      final userParticipantName = userParticipant['name'];

                      print('👤 Real user participant ID: $userParticipantId, Name: $userParticipantName');
                      print('👤 ID type: ${userParticipantId.runtimeType}');
                      print('👤 Name type: ${userParticipantName.runtimeType}');

                      // Check if this is a valid user ID (numeric and not the page ID)
                      if (userParticipantId != null &&
                          userParticipantId.toString() != facebookPageId &&
                          RegExp(r'^\d+$').hasMatch(userParticipantId.toString())) {
                        userId = userParticipantId.toString();
                        contactName = userParticipantName ?? 'Unknown User';
                        print('✅ Extracted real user ID: $userId, Name: $contactName');
                      } else if (userParticipantName != null && userParticipantName != 'User inbox') {
                        // If we have a real name but no valid ID, use the name
                        print('📝 Using real participant name: $userParticipantName');
                        contactName = userParticipantName;
                      } else {
                        print('⚠️ Invalid real user participant: ID=$userParticipantId, Name=$userParticipantName');
                      }
                    }
                  } else {
                    print('⚠️ Not enough participants: ${participantsList.length}');
                  }
                } else {
                  print('⚠️ No participants data field or not a list: ${participants['data']}');
                }
              } else {
                print('⚠️ No participants field or not a map: ${convData['participants']}');
              }

              // If still no user ID, try to extract from link
              if (userId == 'unknown' && convData['link'] != null) {
                final link = convData['link'].toString();
                print('🔗 Trying to extract user ID from real link: $link');

                // Facebook link format: /{pageId}/inbox/{userId}/?section=messages
                final linkParts = link.split('/');
                print('🔗 Link parts: $linkParts');

                if (linkParts.length >= 4 && linkParts[2] == 'inbox') {
                  final potentialUserId = linkParts[3];
                  print('🔗 Potential user ID from link: $potentialUserId');

                  if (RegExp(r'^\d+$').hasMatch(potentialUserId) && potentialUserId != facebookPageId) {
                    userId = potentialUserId;
                    print('✅ Extracted user ID from real link: $userId');
                  }
                }
              }
            } else {
              print('❌ Participants API failed: ${participantsResult['error']}');
            }
          } catch (e) {
            print('⚠️ Error getting real participants: $e');
            print('⚠️ Error stack trace: ${StackTrace.current}');
          }

          // Fallback: If participants didn't give us a valid user ID, try to get it from messages
          if (userId == 'unknown') {
            print('🔍 Real participants didn\'t give valid user ID, trying messages...');
            final userInfo = await _getUserInfoFromMessages(conversation['id'], pageAccessToken);
            if (userInfo != null) {
              userId = userInfo['id'];
              contactName = userInfo['name'];
              print('✅ Got user info from messages: $contactName (ID: $userId)');
            }
          }

          print('🔍 Final extracted user ID: $userId');

          // Use the real participant name we already have - don't try to fetch profiles
          String profileImageUrl = '';

          if (contactName != 'Unknown User') {
            print('✅ Using real participant name: $contactName');
            // Generate a nice avatar based on the real name
            profileImageUrl = 'https://dummyimage.com/100x100/0084FF/ffffff&text=${contactName.split(' ').take(2).map((n) => n[0]).join('').toUpperCase()}';
          } else {
            print('⚠️ No real name available, using fallback');
            profileImageUrl = 'https://dummyimage.com/100x100/cccccc/666666&text=UnknownUser';
          }

          // Convert Facebook conversation to app format
          final appChat = {
            'id': 'fb_${conversation['id']}',
            'contactName': contactName,
            'lastMessage': 'Conversation started', // Will be updated with real message if available
            'timestamp': _parseTimestamp(conversation['updated_time']),
            'unreadCount': conversation['unread_count'] ?? 0,
            'profileImageUrl': profileImageUrl.isNotEmpty ? profileImageUrl : 'https://dummyimage.com/100x100/cccccc/666666&text=${contactName.replaceAll(' ', '')}',
            'platform': 'Facebook',
            'platformIcon': '💬',
            'conversationId': conversation['id'],
            'pageId': facebookPageId,
            'messageCount': conversation['message_count'] ?? 0,
            'needsLastMessage': true, // Flag to indicate we need to fetch the last message
          };
          facebookChats.add(appChat);

          print('✅ Processed conversation: $contactName (${conversation['id']})');
        } catch (e) {
          print('❌ Error processing conversation ${conversation['id']}: $e');
        }
      }

      // Update chat list - remove any existing Facebook chats first
      final existingChats = chatList.where((chat) => !chat['id'].toString().startsWith('fb_')).toList();
      chatList.value = [...existingChats, ...facebookChats];

      print('✅ Added ${facebookChats.length} real Facebook chats to chat list');

      // Update last messages for conversations that need them (limit to first 10 to avoid too many API calls)
      if (facebookChats.isNotEmpty) {
        await _updateLastMessages(facebookChats.take(10).toList(), pageAccessToken);
      }

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
  }

  /// Update last messages for Facebook conversations
  Future<void> _updateLastMessages(List<Map<String, dynamic>> conversations, String pageAccessToken) async {
    try {
      print('🔄 Updating last messages for ${conversations.length} conversations...');

      for (final conversation in conversations) {
        if (conversation['needsLastMessage'] == true) {
          try {
            final conversationId = conversation['conversationId'];
            final result = await FacebookGraphApiService.getConversationMessagesWithToken(
              conversationId,
              pageAccessToken,
            );

            if (result['success'] && result['data'] != null) {
              final messages = result['data'] as List;
              if (messages.isNotEmpty) {
                final message = messages.first; // Get the first (most recent) message
                final messageText = message['message'] ?? 'No message content';

                // Update the conversation in the chat list
                final chatIndex = chatList.indexWhere((chat) => chat['id'] == conversation['id']);
                if (chatIndex != -1) {
                  chatList[chatIndex]['lastMessage'] = messageText.length > 50
                      ? '${messageText.substring(0, 50)}...'
                      : messageText;
                  chatList[chatIndex]['needsLastMessage'] = false;

                  print('✅ Updated last message for ${conversation['contactName']}: ${messageText.substring(0, messageText.length > 30 ? 30 : messageText.length)}...');
                }
              }
            }

            // Small delay to avoid hitting rate limits
            await Future.delayed(Duration(milliseconds: 100));

          } catch (e) {
            print('⚠️ Failed to update last message for conversation ${conversation['conversationId']}: $e');
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
    print('ℹ️ Other channel integrations not yet implemented - only Facebook data will be shown');

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
        'lastMessageTime': DateTime.now().subtract(Duration(hours: 3)).toIso8601String(),
        'messageCount': 8,
        'unreadCount': 0,
        'platform': 'Website',
        'platformIcon': '🌐',
        'platformColor': '#2196F3',
        'profileImageUrl': 'https://ui-avatars.com/api/?name=WV&size=50&background=2196F3&color=fff',
        'conversationId': 'web_conv_1',
        'isActive': true,
        'timestamp': DateTime.now().subtract(Duration(hours: 3)),
      },
      {
        'id': 'ig_1',
        'contactName': 'Instagram User',
        'contactId': 'ig_user_1',
        'lastMessage': 'Love your products!',
        'lastMessageTime': DateTime.now().subtract(Duration(hours: 4)).toIso8601String(),
        'messageCount': 4,
        'unreadCount': 0,
        'platform': 'Instagram',
        'platformIcon': '📷',
        'platformColor': '#E1306C',
        'profileImageUrl': 'https://ui-avatars.com/api/?name=IU&size=50&background=E1306C&color=fff',
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
        return chat['contactName'].toString().toLowerCase()
            .contains(searchQuery.value.toLowerCase()) ||
            chat['lastMessage'].toString().toLowerCase()
                .contains(searchQuery.value.toLowerCase()) ||
            chat['platform'].toString().toLowerCase()
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
    return chatList.fold(0, (sum, chat) => sum + ((chat['unreadCount'] ?? 0) as int));
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

  /// Get user information from conversation messages
  Future<Map<String, dynamic>?> _getUserInfoFromMessages(String conversationId, String pageAccessToken) async {
    try {
      print('🔍 Getting user info from messages for conversation: $conversationId');

      final messagesResult = await FacebookGraphApiService.getConversationMessagesWithToken(
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
              if (fromId != '313808701826338' && RegExp(r'^\d+$').hasMatch(fromId)) {
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
}