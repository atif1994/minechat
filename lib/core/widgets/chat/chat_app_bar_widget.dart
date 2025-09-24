import 'package:flutter/material.dart';
import 'package:get/get.dart';

/// Reusable chat app bar widget
class ChatAppBarWidget extends StatelessWidget implements PreferredSizeWidget {
  final String contactName;
  final String? profileImageUrl;
  final VoidCallback? onBackPressed;
  final VoidCallback? onProfileTap;
  final VoidCallback? onAITap;
  final VoidCallback? onMoreTap;

  const ChatAppBarWidget({
    Key? key,
    required this.contactName,
    this.profileImageUrl,
    this.onBackPressed,
    this.onProfileTap,
    this.onAITap,
    this.onMoreTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: const Color(0xFF075E54), // WhatsApp green
      elevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back, color: Colors.white),
        onPressed: onBackPressed ?? () => Get.back(),
      ),
      title: Row(
        children: [
          Stack(
            children: [
              CircleAvatar(
                radius: 20,
                backgroundImage: profileImageUrl?.isNotEmpty == true
                    ? NetworkImage(profileImageUrl!)
                    : null,
                onBackgroundImageError: (exception, stackTrace) {
                  // Handle image error
                },
                child: profileImageUrl?.isEmpty != false
                    ? Text(
                        (contactName.isNotEmpty ? contactName[0] : '?').toUpperCase(),
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      )
                    : null,
              ),
              Positioned(
                bottom: 0,
                right: 0,
                child: Container(
                  width: 16,
                  height: 16,
                  decoration: BoxDecoration(
                    color: Colors.blue,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 2),
                  ),
                  child: const Icon(
                    Icons.chat,
                    color: Colors.white,
                    size: 8,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  contactName,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                GestureDetector(
                  onTap: onProfileTap ?? () {
                    Get.snackbar('Info', 'Viewing profile...');
                  },
                  child: const Text(
                    'View profile',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.smart_toy, color: Colors.white),
          onPressed: onAITap ?? () {
            Get.snackbar('Info', 'AI Assistant toggled...');
          },
        ),
        IconButton(
          icon: const Icon(Icons.person, color: Colors.white),
          onPressed: onProfileTap ?? () {
            Get.snackbar('Info', 'Viewing profile...');
          },
        ),
        PopupMenuButton<String>(
          icon: const Icon(Icons.more_vert, color: Colors.white),
          onSelected: (value) {
            switch (value) {
              case 'add_to_group':
                Get.snackbar('Info', 'Add to group...');
                break;
              case 'follow_up':
                Get.snackbar('Info', 'Follow-up later...');
                break;
              case 'block':
                Get.snackbar('Info', 'Block contact...');
                break;
              case 'delete':
                Get.snackbar('Info', 'Delete conversation...');
                break;
            }
          },
          itemBuilder: (context) => [
            const PopupMenuItem(
              value: 'add_to_group',
              child: Text('Add To Group'),
            ),
            const PopupMenuItem(
              value: 'follow_up',
              child: Text('Follow-up Later'),
            ),
            const PopupMenuItem(
              value: 'block',
              child: Text('Block Contact'),
            ),
            const PopupMenuItem(
              value: 'delete',
              child: Text('Delete Conversation'),
            ),
          ],
        ),
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
