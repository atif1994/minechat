import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:minechat/controller/theme_controller/theme_controller.dart';
import 'package:minechat/controller/chat_controller/chat_controller.dart';
import 'package:minechat/core/constants/app_colors/app_colors.dart';
import 'package:minechat/core/router/app_routes.dart';
import 'package:minechat/core/utils/helpers/app_responsive/app_responsive.dart';
import 'package:minechat/core/utils/helpers/app_styles/app_text_styles.dart';
import 'package:minechat/core/widgets/chat/group_creation_widgets.dart';
import 'package:minechat/core/widgets/common/custom_text_field.dart';

class CreateGroupScreen extends StatefulWidget {
  const CreateGroupScreen({Key? key}) : super(key: key);

  @override
  State<CreateGroupScreen> createState() => _CreateGroupScreenState();
}

class _CreateGroupScreenState extends State<CreateGroupScreen> {
  final TextEditingController _groupNameController = TextEditingController();
  final TextEditingController _searchController = TextEditingController();
  
  late ChatController _chatController;
  late ThemeController _themeController;
  
  var selectedMembers = <Map<String, dynamic>>[].obs;
  var filteredContacts = <Map<String, dynamic>>[].obs;
  var searchQuery = ''.obs;
  
  // Real contacts loaded from chat list
  final RxList<Map<String, dynamic>> _availableContacts = <Map<String, dynamic>>[].obs;

  @override
  void initState() {
    super.initState();
    _chatController = Get.find<ChatController>();
    _themeController = Get.find<ThemeController>();
    _loadRealContacts();
    filteredContacts.value = _availableContacts;
    
    // Listen to search changes
    _searchController.addListener(() {
      searchQuery.value = _searchController.text;
      _filterContacts();
    });
  }

  @override
  void dispose() {
    _groupNameController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  /// Load real contacts from the chat list
  void _loadRealContacts() {
    try {
      // Extract unique contacts from the chat list
      final Set<String> uniqueContactIds = {};
      final List<Map<String, dynamic>> contacts = [];

      for (final chat in _chatController.chatList) {
        // Skip group chats - we only want individual contacts
        if (chat['type'] == 'group') continue;

        // Use contactId or conversationId as unique identifier
        final contactId = chat['contactId'] ?? chat['conversationId'] ?? chat['id'];
        
        // Skip if we've already added this contact
        if (uniqueContactIds.contains(contactId)) continue;
        
        // Add to unique set
        uniqueContactIds.add(contactId);

        // Create contact entry
        contacts.add({
          'id': contactId,
          'name': chat['contactName'] ?? 'Unknown Contact',
          'profileImageUrl': chat['profileImageUrl'],
          'platform': chat['platform'] ?? 'Unknown',
        });
      }

      // Sort contacts alphabetically by name
      contacts.sort((a, b) => (a['name'] as String).compareTo(b['name'] as String));

      _availableContacts.assignAll(contacts);
      filteredContacts.value = contacts;
      
      print('✅ Loaded ${contacts.length} real contacts from chat list');
      
      if (contacts.isEmpty) {
        Get.snackbar(
          'No Contacts',
          'You don\'t have any chat contacts yet. Start a conversation first!',
          backgroundColor: Colors.orange,
          colorText: Colors.white,
          duration: const Duration(seconds: 3),
        );
      }
    } catch (e) {
      print('❌ Error loading contacts: $e');
      Get.snackbar(
        'Error',
        'Failed to load contacts. Please try again.',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  void _filterContacts() {
    if (searchQuery.value.isEmpty) {
      filteredContacts.value = _availableContacts;
    } else {
      filteredContacts.value = _availableContacts.where((contact) {
        return contact['name'].toString().toLowerCase()
            .contains(searchQuery.value.toLowerCase());
      }).toList();
    }
  }

  void _toggleMemberSelection(Map<String, dynamic> contact) {
    if (selectedMembers.any((member) => member['id'] == contact['id'])) {
      selectedMembers.removeWhere((member) => member['id'] == contact['id']);
    } else {
      selectedMembers.add(contact);
    }
  }

  bool _isMemberSelected(String contactId) {
    return selectedMembers.any((member) => member['id'] == contactId);
  }

  void _removeSelectedMember(Map<String, dynamic> contact) {
    selectedMembers.removeWhere((member) => member['id'] == contact['id']);
  }

  Future<void> _createGroup() async {
    if (selectedMembers.isEmpty) {
      Get.snackbar(
        'Error',
        'Please select at least one member',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }

    try {
      // Show loading
      Get.dialog(
        const Center(
          child: CircularProgressIndicator(color: AppColors.primary),
        ),
        barrierDismissible: false,
      );

      // Create group data
      final groupId = 'group_${DateTime.now().millisecondsSinceEpoch}';
      final groupName = _groupNameController.text.trim().isEmpty 
          ? selectedMembers.map((m) => m['name']).join(', ')
          : _groupNameController.text.trim();

      final groupData = {
        'id': groupId,
        'contactName': groupName,
        'members': selectedMembers.toList(),
        'createdAt': DateTime.now().toIso8601String(),
        'type': 'group',
        'lastMessage': 'Group created',
        'lastMessageTime': DateTime.now().toIso8601String(),
        'messageCount': 0,
        'unreadCount': 0,
        'platform': 'Group',
        'profileImageUrl': null,
        'conversationId': groupId,
        'isActive': true,
        'timestamp': DateTime.now(),
      };

      // Add to chat list and save to Firestore
      await _chatController.addGroupToChatList(groupData);

      // Close loading dialog
      Get.back();

      // Navigate to group chat
      Get.back(); // Go back to chat list
      Get.toNamed(AppRoutes.groupChat, arguments: groupData);

      Get.snackbar(
        'Success',
        'Group created successfully',
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
    } catch (e) {
      Get.back(); // Close loading dialog
      Get.snackbar(
        'Error',
        'Failed to create group: $e',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = _themeController.isDarkMode;
    
    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0A0A0A) : const Color(0xFFF4F6FC),
      appBar: AppBar(
        backgroundColor: isDark ? const Color(0xFF1D1D1D) : Colors.white,
        elevation: 0,
        leading: TextButton(
          onPressed: () => Get.back(),
          child: Text(
            'Cancel',
            style: AppTextStyles.bodyText(context).copyWith(
              color: AppColors.primary,
            ),
          ),
        ),
        title: Text(
          'New group',
          style: AppTextStyles.bodyText(context).copyWith(
            fontSize: AppResponsive.scaleSize(context, 18),
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
        actions: [
          Obx(() => TextButton(
            onPressed: selectedMembers.isNotEmpty ? _createGroup : null,
            child: Text(
              'Create',
              style: AppTextStyles.bodyText(context).copyWith(
                color: selectedMembers.isNotEmpty 
                    ? AppColors.primary 
                    : Colors.grey,
                fontWeight: FontWeight.w600,
              ),
            ),
          )),
        ],
      ),
      body: Column(
        children: [
          // Group Name Input
          Container(
            padding: const EdgeInsets.all(16),
            color: isDark ? const Color(0xFF1D1D1D) : Colors.white,
            child: CustomTextField(
              controller: _groupNameController,
              hintText: 'Group name (optional)',
            ),
          ),
          
          // Selected Members Display
          Obx(() {
            if (selectedMembers.isEmpty) {
              return const SizedBox.shrink();
            }
            
            return Container(
              padding: const EdgeInsets.all(16),
              color: isDark ? const Color(0xFF1D1D1D) : Colors.white,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Selected Members',
                    style: AppTextStyles.bodyText(context).copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    height: 80,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: selectedMembers.length,
                      itemBuilder: (context, index) {
                        final member = selectedMembers[index];
                        return SelectedMemberChip(
                          contactId: member['id'],
                          name: member['name'],
                          profileImageUrl: member['profileImageUrl'],
                          onRemove: () => _removeSelectedMember(member),
                        );
                      },
                    ),
                  ),
                ],
              ),
            );
          }),
          
          // Search Bar
          Container(
            padding: const EdgeInsets.all(16),
            color: isDark ? const Color(0xFF1D1D1D) : Colors.white,
            child: CustomTextField(
              controller: _searchController,
              hintText: 'Search',
            ),
          ),
          
          // Suggested Section
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            color: isDark ? const Color(0xFF1D1D1D) : Colors.white,
            child: Row(
              children: [
                Text(
                  'Suggested',
                  style: AppTextStyles.bodyText(context).copyWith(
                    fontWeight: FontWeight.w600,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
          
          // Contacts List
          Expanded(
            child: Container(
              color: isDark ? const Color(0xFF0A0A0A) : const Color(0xFFF4F6FC),
              child: Obx(() => ListView.builder(
                padding: const EdgeInsets.only(bottom: 16),
                itemCount: filteredContacts.length,
                itemBuilder: (context, index) {
                  final contact = filteredContacts[index];
                  final isSelected = _isMemberSelected(contact['id']);
                  
                  return ContactSelectionItem(
                    contactId: contact['id'],
                    name: contact['name'],
                    profileImageUrl: contact['profileImageUrl'],
                    isSelected: isSelected,
                    onTap: () => _toggleMemberSelection(contact),
                  );
                },
              )),
            ),
          ),
        ],
      ),
    );
  }
}

