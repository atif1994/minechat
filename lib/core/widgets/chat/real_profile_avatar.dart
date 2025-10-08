import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';

class RealProfileAvatar extends StatelessWidget {
  final String? profileImageUrl;
  final String displayName;
  final double radius;
  final bool isFromUser;

  const RealProfileAvatar({
    Key? key,
    this.profileImageUrl,
    required this.displayName,
    this.radius = 16,
    this.isFromUser = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // If we have a real profile image URL, try to load it
    if (profileImageUrl != null && profileImageUrl!.isNotEmpty) {
      return _buildNetworkAvatar();
    }
    
    // Fallback to initials
    return _buildInitialsAvatar();
  }

  Widget _buildNetworkAvatar() {
    return CachedNetworkImage(
      imageUrl: profileImageUrl!,
      imageBuilder: (context, imageProvider) => Container(
        width: radius * 2,
        height: radius * 2,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          image: DecorationImage(
            image: imageProvider,
            fit: BoxFit.cover,
          ),
          border: Border.all(
            color: Colors.white,
            width: 2,
          ),
        ),
      ),
      placeholder: (context, url) => _buildInitialsAvatar(),
      errorWidget: (context, url, error) {
        print('❌ Failed to load profile image: $error');
        return _buildInitialsAvatar();
      },
      memCacheWidth: (radius * 2 * 2).round(), // Use fixed multiplier for caching
      memCacheHeight: (radius * 2 * 2).round(), // Use fixed multiplier for caching
    );
  }

  Widget _buildInitialsAvatar() {
    final initials = _getInitials(displayName);
    final avatarColor = _getAvatarColor(displayName);
    
    return Container(
      width: radius * 2,
      height: radius * 2,
      decoration: BoxDecoration(
        color: avatarColor,
        shape: BoxShape.circle,
        border: Border.all(
          color: Colors.white,
          width: 2,
        ),
      ),
      child: Center(
        child: Text(
          initials,
          style: TextStyle(
            color: Colors.white,
            fontSize: radius * 0.6,
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
      // Take first 2 letters for 2-letter initials
      final firstLetter = words[0].substring(0, 1).toUpperCase();
      final secondLetter = words[1].substring(0, 1).toUpperCase();
      return firstLetter + secondLetter;
    }
  }

  Color _getAvatarColor(String name) {
    // Use consistent colors based on sender name
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
    
    // Use name hash to ensure consistent color for same sender
    final hash = name.hashCode;
    return colors[hash.abs() % colors.length];
  }
}
