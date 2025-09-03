import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:minechat/core/services/facebook_graph_api_service.dart';
import 'package:minechat/controller/channel_controller/channel_controller.dart';

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

  @override
  void onInit() {
    super.onInit();
    print('🔍 ChatController initialized');
    loadChats();
  }

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
        print('⚠️ No page access token found - cannot load real Facebook chats');
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

      print('🔍 Fetching real Facebook conversations for page: $facebookPageId');

      // Get conversations from Facebook Graph API (backend approach)
      final conversationsResult = await FacebookGraphApiService.getPageConversations(
        facebookPageId,
      );

      if (!conversationsResult['success']) {
        throw Exception('Failed to load conversations: ${conversationsResult['error']}');
      }

      final conversations = conversationsResult['data'] as List;
      print('✅ Loaded ${conversations.length} Facebook conversations');

      if (conversations.isEmpty) {
        print('ℹ️ No conversations found on this Facebook page');
        Get.snackbar(
          'Info',
          'No conversations found on your Facebook page. Try sending a test message to your page first.',
          backgroundColor: Colors.blue,
          colorText: Colors.white,
          duration: Duration(seconds: 4),
        );
        return;
      }

      // Convert Facebook conversations to app format
      final facebookChats = <Map<String, dynamic>>[];
      
      for (final conversation in conversations) {
        try {
          // Convert Facebook conversation to app format
          final appChat = {
            'id': 'fb_${conversation['id']}',
            'contactName': conversation['participants']?[0]?['name'] ?? 'Unknown User',
            'lastMessage': conversation['last_message']?['message'] ?? 'No messages yet',
            'timestamp': _parseTimestamp(conversation['updated_time']),
            'unreadCount': conversation['unread_count'] ?? 0,
            'profileImageUrl': 'https://ui-avatars.com/api/?name=${conversation['participants']?[0]?['name'] ?? 'User'}&background=random',
            'platform': 'Facebook',
            'conversationId': conversation['id'],
            'pageId': facebookPageId,
          };
          facebookChats.add(appChat);
        } catch (e) {
          print('❌ Error processing conversation ${conversation['id']}: $e');
        }
      }

      // Update chat list - remove any existing Facebook chats first
      final existingChats = chatList.where((chat) => !chat['id'].toString().startsWith('fb_')).toList();
      chatList.value = [...existingChats, ...facebookChats];
      
      print('✅ Added ${facebookChats.length} real Facebook chats to chat list');
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

  /// Load mock Facebook chats as fallback
  void _loadMockFacebookChats() {
    try {
        final mockFacebookChats = [
          {
          'id': 'fb_mock_1',
            'contactName': 'Grace Spencer',
          'contactId': 'fb_user_1',
            'lastMessage': 'Hi, there welcome to our store!',
          'lastMessageTime': DateTime.now().subtract(Duration(hours: 2)).toIso8601String(),
          'messageCount': 5,
          'unreadCount': 0,
          'platform': 'Messenger',
          'platformIcon': '💬',
          'platformColor': '#0084FF',
          'profileImageUrl': 'https://ui-avatars.com/api/?name=GS&size=50&background=0084FF&color=fff',
          'conversationId': 'mock_conv_1',
          'isActive': true,
            'timestamp': DateTime.now().subtract(Duration(hours: 2)),
          },
          {
          'id': 'fb_mock_2',
            'contactName': 'Lucas James',
          'contactId': 'fb_user_2',
          'lastMessage': 'Can you tell me more about your services?',
          'lastMessageTime': DateTime.now().subtract(Duration(hours: 1)).toIso8601String(),
          'messageCount': 12,
          'unreadCount': 2,
          'platform': 'Messenger',
          'platformIcon': '💬',
          'platformColor': '#0084FF',
          'profileImageUrl': 'https://ui-avatars.com/api/?name=LJ&size=50&background=0084FF&color=fff',
          'conversationId': 'mock_conv_2',
          'isActive': true,
            'timestamp': DateTime.now().subtract(Duration(hours: 1)),
          },
          {
          'id': 'fb_mock_3',
            'contactName': 'Sarah Wilson',
          'contactId': 'fb_user_3',
            'lastMessage': 'Do you have any discounts available?',
          'lastMessageTime': DateTime.now().subtract(Duration(minutes: 30)).toIso8601String(),
          'messageCount': 3,
          'unreadCount': 1,
          'platform': 'Messenger',
          'platformIcon': '💬',
          'platformColor': '#0084FF',
          'profileImageUrl': 'https://ui-avatars.com/api/?name=SW&size=50&background=0084FF&color=fff',
          'conversationId': 'mock_conv_3',
          'isActive': true,
            'timestamp': DateTime.now().subtract(Duration(minutes: 30)),
        },
      ];

      // Remove existing mock Facebook chats
      final existingChats = chatList.where((chat) => !chat['id'].toString().startsWith('fb_mock')).toList();
      chatList.value = [...existingChats, ...mockFacebookChats];
      
      print('📝 Added ${mockFacebookChats.length} mock Facebook chats');
    } catch (e) {
      print('❌ Error loading mock Facebook chats: $e');
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

  /// Refresh chats
  Future<void> refreshChats() async {
    chatList.clear();
    await loadChats();
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
}
