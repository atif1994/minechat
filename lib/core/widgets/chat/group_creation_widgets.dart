import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:minechat/core/constants/app_colors/app_colors.dart';
import 'package:minechat/core/utils/helpers/app_styles/app_text_styles.dart';

/// Reusable widget for contact selection in group creation
class ContactSelectionItem extends StatelessWidget {
  final String contactId;
  final String name;
  final String? profileImageUrl;
  final bool isSelected;
  final VoidCallback onTap;

  const ContactSelectionItem({
    Key? key,
    required this.contactId,
    required this.name,
    this.profileImageUrl,
    required this.isSelected,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            // Profile Avatar
            _buildProfileAvatar(),
            const SizedBox(width: 12),
            
            // Contact Name
            Expanded(
              child: Text(
                name,
                style: AppTextStyles.bodyText(context),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            
            // Selection Indicator
            Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSelected ? AppColors.primary : Colors.grey[300]!,
                  width: 2,
                ),
                color: isSelected ? AppColors.primary : Colors.transparent,
              ),
              child: isSelected
                  ? const Icon(
                      Icons.check,
                      size: 16,
                      color: Colors.white,
                    )
                  : null,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileAvatar() {
    if (profileImageUrl != null && profileImageUrl!.isNotEmpty) {
      return CachedNetworkImage(
        imageUrl: profileImageUrl!,
        imageBuilder: (context, imageProvider) => Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            image: DecorationImage(
              image: imageProvider,
              fit: BoxFit.cover,
            ),
          ),
        ),
        placeholder: (context, url) => _buildInitialsAvatar(),
        errorWidget: (context, url, error) => _buildInitialsAvatar(),
      );
    }
    
    return _buildInitialsAvatar();
  }

  Widget _buildInitialsAvatar() {
    final initials = _getInitials(name);
    final avatarColor = _getAvatarColor(name);
    
    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        color: avatarColor,
        shape: BoxShape.circle,
      ),
      child: Center(
        child: Text(
          initials,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  String _getInitials(String name) {
    if (name.isEmpty) return '?';
    
    final words = name.trim().split(' ');
    if (words.length == 1) {
      return words[0].substring(0, 1).toUpperCase();
    } else {
      final firstLetter = words[0].substring(0, 1).toUpperCase();
      final secondLetter = words[1].substring(0, 1).toUpperCase();
      return firstLetter + secondLetter;
    }
  }

  Color _getAvatarColor(String name) {
    final colors = [
      Colors.blue,
      Colors.green,
      Colors.orange,
      Colors.purple,
      Colors.teal,
      Colors.indigo,
      Colors.pink,
      Colors.cyan,
      Colors.red,
      Colors.amber,
      Colors.deepPurple,
      Colors.lightBlue,
    ];
    
    final hash = name.hashCode;
    return colors[hash.abs() % colors.length];
  }
}

/// Widget for displaying selected members with remove option
class SelectedMemberChip extends StatelessWidget {
  final String contactId;
  final String name;
  final String? profileImageUrl;
  final VoidCallback onRemove;

  const SelectedMemberChip({
    Key? key,
    required this.contactId,
    required this.name,
    this.profileImageUrl,
    required this.onRemove,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(right: 8),
      child: Column(
        children: [
          // Profile Picture with Remove Button
          Stack(
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.grey[300]!, width: 2),
                ),
                child: ClipOval(
                  child: profileImageUrl != null && profileImageUrl!.isNotEmpty
                      ? CachedNetworkImage(
                          imageUrl: profileImageUrl!,
                          fit: BoxFit.cover,
                          placeholder: (context, url) => _buildInitialsAvatar(),
                          errorWidget: (context, url, error) => _buildInitialsAvatar(),
                        )
                      : _buildInitialsAvatar(),
                ),
              ),
              // Remove Button
              Positioned(
                top: 0,
                right: 0,
                child: GestureDetector(
                  onTap: onRemove,
                  child: Container(
                    width: 20,
                    height: 20,
                    decoration: const BoxDecoration(
                      color: Colors.red,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.close,
                      size: 12,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          
          // Name
          Container(
            width: 60,
            child: Text(
              name,
              style: AppTextStyles.hintText(context).copyWith(fontSize: 10),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInitialsAvatar() {
    final initials = _getInitials(name);
    final avatarColor = _getAvatarColor(name);
    
    return Container(
      color: avatarColor,
      child: Center(
        child: Text(
          initials,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  String _getInitials(String name) {
    if (name.isEmpty) return '?';
    
    final words = name.trim().split(' ');
    if (words.length == 1) {
      return words[0].substring(0, 1).toUpperCase();
    } else {
      final firstLetter = words[0].substring(0, 1).toUpperCase();
      final secondLetter = words[1].substring(0, 1).toUpperCase();
      return firstLetter + secondLetter;
    }
  }

  Color _getAvatarColor(String name) {
    final colors = [
      Colors.blue,
      Colors.green,
      Colors.orange,
      Colors.purple,
      Colors.teal,
      Colors.indigo,
      Colors.pink,
      Colors.cyan,
      Colors.red,
      Colors.amber,
      Colors.deepPurple,
      Colors.lightBlue,
    ];
    
    final hash = name.hashCode;
    return colors[hash.abs() % colors.length];
  }
}

/// Group profile avatar widget for showing multiple members
class GroupProfileAvatar extends StatelessWidget {
  final List<Map<String, dynamic>> members;
  final double size;

  const GroupProfileAvatar({
    Key? key,
    required this.members,
    this.size = 120,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (members.isEmpty) {
      return _buildEmptyAvatar();
    }

    if (members.length == 1) {
      return _buildSingleAvatar(members.first);
    }

    if (members.length == 2) {
      return _buildTwoAvatars(members);
    }

    return _buildMultipleAvatars(members);
  }

  Widget _buildEmptyAvatar() {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: Colors.grey[300],
        shape: BoxShape.circle,
      ),
      child: Icon(
        Icons.group,
        size: size * 0.5,
        color: Colors.grey[600],
      ),
    );
  }

  Widget _buildSingleAvatar(Map<String, dynamic> member) {
    final name = member['name'] ?? '';
    final profileImageUrl = member['profileImageUrl'] as String?;
    
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: Colors.grey[300]!, width: 2),
      ),
      child: ClipOval(
        child: profileImageUrl != null && profileImageUrl.isNotEmpty
            ? CachedNetworkImage(
                imageUrl: profileImageUrl,
                fit: BoxFit.cover,
                placeholder: (context, url) => _buildInitialsAvatar(name),
                errorWidget: (context, url, error) => _buildInitialsAvatar(name),
              )
            : _buildInitialsAvatar(name),
      ),
    );
  }

  Widget _buildTwoAvatars(List<Map<String, dynamic>> members) {
    return Container(
      width: size,
      height: size,
      child: Stack(
        children: [
          // First avatar (left)
          Positioned(
            left: 0,
            top: 0,
            child: Container(
              width: size * 0.7,
              height: size * 0.7,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: Colors.grey[300]!, width: 2),
              ),
              child: ClipOval(
                child: _buildMemberAvatar(members[0]),
              ),
            ),
          ),
          // Second avatar (right, overlapping)
          Positioned(
            right: 0,
            bottom: 0,
            child: Container(
              width: size * 0.7,
              height: size * 0.7,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: Colors.grey[300]!, width: 2),
              ),
              child: ClipOval(
                child: _buildMemberAvatar(members[1]),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMultipleAvatars(List<Map<String, dynamic>> members) {
    return Container(
      width: size,
      height: size,
      child: Stack(
        children: [
          // Top row
          Positioned(
            left: size * 0.1,
            top: 0,
            child: Container(
              width: size * 0.35,
              height: size * 0.35,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: Colors.grey[300]!, width: 2),
              ),
              child: ClipOval(
                child: _buildMemberAvatar(members[0]),
              ),
            ),
          ),
          Positioned(
            right: size * 0.1,
            top: 0,
            child: Container(
              width: size * 0.35,
              height: size * 0.35,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: Colors.grey[300]!, width: 2),
              ),
              child: ClipOval(
                child: _buildMemberAvatar(members[1]),
              ),
            ),
          ),
          // Bottom row
          Positioned(
            left: 0,
            bottom: 0,
            child: Container(
              width: size * 0.35,
              height: size * 0.35,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: Colors.grey[300]!, width: 2),
              ),
              child: ClipOval(
                child: _buildMemberAvatar(members[2]),
              ),
            ),
          ),
          Positioned(
            right: 0,
            bottom: 0,
            child: Container(
              width: size * 0.35,
              height: size * 0.35,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: Colors.grey[300]!, width: 2),
              ),
              child: ClipOval(
                child: _buildMemberAvatar(members[3]),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMemberAvatar(Map<String, dynamic> member) {
    final name = member['name'] ?? '';
    final profileImageUrl = member['profileImageUrl'] as String?;
    
    if (profileImageUrl != null && profileImageUrl.isNotEmpty) {
      return CachedNetworkImage(
        imageUrl: profileImageUrl,
        fit: BoxFit.cover,
        placeholder: (context, url) => _buildInitialsAvatar(name),
        errorWidget: (context, url, error) => _buildInitialsAvatar(name),
      );
    }
    
    return _buildInitialsAvatar(name);
  }

  Widget _buildInitialsAvatar(String name) {
    final initials = _getInitials(name);
    final avatarColor = _getAvatarColor(name);
    
    return Container(
      color: avatarColor,
      child: Center(
        child: Text(
          initials,
          style: TextStyle(
            color: Colors.white,
            fontSize: size * 0.15,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  String _getInitials(String name) {
    if (name.isEmpty) return '?';
    
    final words = name.trim().split(' ');
    if (words.length == 1) {
      return words[0].substring(0, 1).toUpperCase();
    } else {
      final firstLetter = words[0].substring(0, 1).toUpperCase();
      final secondLetter = words[1].substring(0, 1).toUpperCase();
      return firstLetter + secondLetter;
    }
  }

  Color _getAvatarColor(String name) {
    final colors = [
      Colors.blue,
      Colors.green,
      Colors.orange,
      Colors.purple,
      Colors.teal,
      Colors.indigo,
      Colors.pink,
      Colors.cyan,
      Colors.red,
      Colors.amber,
      Colors.deepPurple,
      Colors.lightBlue,
    ];
    
    final hash = name.hashCode;
    return colors[hash.abs() % colors.length];
  }
}
