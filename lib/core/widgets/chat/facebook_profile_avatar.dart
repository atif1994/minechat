import 'package:flutter/material.dart';

class FacebookProfileAvatar extends StatelessWidget {
  final String userId;
  final String displayName;
  final double radius;
  final bool isFromUser;

  const FacebookProfileAvatar({
    Key? key,
    required this.userId,
    required this.displayName,
    this.radius = 16,
    this.isFromUser = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Facebook profile pictures often fail due to privacy settings or API restrictions
    // For now, always use initials to avoid the 400 errors and provide a consistent experience
    return _buildInitialsAvatar();
  }

  Widget _buildInitialsAvatar() {
    final initials = _getInitials(displayName);
    final avatarColor = _getAvatarColor(displayName, isFromUser);
    
    return CircleAvatar(
      radius: radius,
      backgroundColor: avatarColor,
      child: Text(
        initials,
        style: TextStyle(
          color: Colors.white,
          fontSize: radius * 0.6,
          fontWeight: FontWeight.bold,
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
      return (words[0].substring(0, 1) + words[1].substring(0, 1)).toUpperCase();
    }
  }

  Color _getAvatarColor(String name, bool isFromUser) {
    // Use consistent colors based on sender name, not isFromUser flag
    // This ensures the same sender always gets the same color
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
