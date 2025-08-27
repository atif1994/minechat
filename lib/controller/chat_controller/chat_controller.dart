import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

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

      // Load Facebook Messenger chats
      await loadFacebookChats();
      
      // Load other channel chats (placeholder for now)
      await loadOtherChannelChats();

      // Apply current filter
      applyFilter();
      
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

  /// Load Facebook Messenger chats
  Future<void> loadFacebookChats() async {
    try {
      final userId = getCurrentUserId();
      
      // Get user's Facebook page settings
      final userDoc = await _firestore
          .collection('channel_settings')
          .doc(userId)
          .get();

      if (userDoc.exists && userDoc.data()!['isFacebookConnected'] == true) {
        final facebookPageId = userDoc.data()!['facebookPageId'];
        
        // TODO: Replace with actual Facebook Graph API call
        // For now, using mock data
        final mockFacebookChats = [
          {
            'id': 'fb_1',
            'contactName': 'Grace Spencer',
            'contactImage': 'https://via.placeholder.com/50',
            'lastMessage': 'Hi, there welcome to our store!',
            'timestamp': DateTime.now().subtract(Duration(hours: 2)),
            'unreadCount': 0,
            'channel': 'Messenger',
            'channelIcon': '💬',
            'isOnline': true,
            'aiEnabled': true,
          },
          {
            'id': 'fb_2',
            'contactName': 'Lucas James',
            'contactImage': 'https://via.placeholder.com/50',
            'lastMessage': 'Hi, there welcome to our store!',
            'timestamp': DateTime.now().subtract(Duration(hours: 1)),
            'unreadCount': 2,
            'channel': 'Messenger',
            'channelIcon': '💬',
            'isOnline': false,
            'aiEnabled': false,
          },
          {
            'id': 'fb_3',
            'contactName': 'Sarah Wilson',
            'contactImage': 'https://via.placeholder.com/50',
            'lastMessage': 'Do you have any discounts available?',
            'timestamp': DateTime.now().subtract(Duration(minutes: 30)),
            'unreadCount': 1,
            'channel': 'Messenger',
            'channelIcon': '💬',
            'isOnline': true,
            'aiEnabled': true,
          },
        ];

        // Add to chat list
        chatList.addAll(mockFacebookChats);
      }
    } catch (e) {
      print('❌ Error loading Facebook chats: $e');
    }
  }

  /// Load other channel chats (placeholder)
  Future<void> loadOtherChannelChats() async {
    // TODO: Implement other channel integrations
    // For now, adding some mock data for other channels
    final mockOtherChats = [
      {
        'id': 'web_1',
        'contactName': 'Website Visitor',
        'contactImage': 'https://via.placeholder.com/50',
        'lastMessage': 'I need help with my order',
        'timestamp': DateTime.now().subtract(Duration(hours: 3)),
        'unreadCount': 0,
        'channel': 'Website',
        'channelIcon': '🌐',
        'isOnline': false,
        'aiEnabled': true,
      },
      {
        'id': 'ig_1',
        'contactName': 'Instagram User',
        'contactImage': 'https://via.placeholder.com/50',
        'lastMessage': 'Love your products!',
        'timestamp': DateTime.now().subtract(Duration(hours: 4)),
        'unreadCount': 0,
        'channel': 'Instagram',
        'channelIcon': '📷',
        'isOnline': true,
        'aiEnabled': false,
      },
    ];

    chatList.addAll(mockOtherChats);
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
}
