import 'dart:io';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';

/// Widget for displaying media messages (images, voice, etc.)
class MediaMessageBubbleWidget extends StatelessWidget {
  final Map<String, dynamic> message;
  final bool isFromUser;

  const MediaMessageBubbleWidget({
    Key? key,
    required this.message,
    required this.isFromUser,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final messageType = message['type'] as String?;
    
    print('🎤 MediaMessageBubbleWidget: Processing message type: $messageType');
    print('🎤 Full message data: $message');
    print('🎤 Is from user: $isFromUser');
    
    switch (messageType) {
      case 'image':
        print('🎤 Routing to image message builder');
        return _buildImageMessage(context);
      case 'voice':
        print('🎤 Routing to voice message builder');
        return _buildVoiceMessage(context);
      default:
        print('🎤 ERROR: Unknown message type: $messageType');
        return const SizedBox.shrink();
    }
  }

  Widget _buildImageMessage(BuildContext context) {
    final imagePath = message['imagePath'] as String?;
    final imageUrl = message['imageUrl'] as String?;
    final isSending = message['isSending'] as bool? ?? false;
    
    // Use imageUrl for Facebook images, imagePath for local images
    final finalImagePath = imageUrl ?? imagePath;
    
    print('🖼️ MediaMessageBubbleWidget: Building image message');
    print('🖼️ Image path: $imagePath');
    print('🖼️ Image URL: $imageUrl');
    print('🖼️ Final image path: $finalImagePath');
    print('🖼️ Is sending: $isSending');
    print('🖼️ Is from user: $isFromUser');
    print('🖼️ Message type: ${message['type']}');
    print('🖼️ Full message data: $message');
    print('🖼️ Is network image: ${finalImagePath?.startsWith('http')}');
    print('🖼️ Will use CachedNetworkImage: ${finalImagePath?.startsWith('http')}');
    print('🖼️ Will use Image.file: ${finalImagePath != null && !finalImagePath.startsWith('http')}');
    
    if (finalImagePath == null) {
      print('🖼️ No image path or URL found, returning empty widget');
      return const SizedBox.shrink();
    }

    // Check if it's a local file or network URL
    final isNetworkImage = finalImagePath.startsWith('http');
    print('🖼️ Is network image: $isNetworkImage');
    
    if (!isNetworkImage) {
      final file = File(finalImagePath);
      final fileExists = file.existsSync();
      print('🖼️ Local file exists: $fileExists');
      print('🖼️ File size: ${fileExists ? file.lengthSync() : 'N/A'} bytes');
      
      if (!fileExists) {
        print('🖼️ ERROR: Local image file does not exist!');
        return Container(
          constraints: const BoxConstraints(
            maxWidth: 150,
            maxHeight: 150,
          ),
          decoration: BoxDecoration(
            color: Colors.red[100],
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.red, width: 2),
          ),
          child: const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.error, color: Colors.red, size: 24),
                SizedBox(height: 4),
                Text(
                  'Image\nNot Found',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.red,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        );
      }
    }

    return Container(
      margin: EdgeInsets.only(
        left: isFromUser ? 0 : 50,
        right: isFromUser ? 50 : 0,
        bottom: 8,
      ),
      child: Column(
        crossAxisAlignment: isFromUser 
            ? CrossAxisAlignment.end 
            : CrossAxisAlignment.start,
        children: [
          // Image container
          Container(
            constraints: const BoxConstraints(
              maxWidth: 150,
              maxHeight: 150,
            ),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              color: isFromUser 
                  ? const Color(0xFF007AFF) 
                  : const Color(0xFFE5E5EA),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Stack(
                children: [
                  // Image
                  if (finalImagePath.startsWith('http'))
                    CachedNetworkImage(
                      imageUrl: finalImagePath,
                      fit: BoxFit.cover,
                      memCacheWidth: 300,
                      memCacheHeight: 300,
                      maxWidthDiskCache: 600,
                      maxHeightDiskCache: 600,
                      fadeInDuration: Duration(milliseconds: 200),
                      fadeOutDuration: Duration(milliseconds: 100),
                      placeholder: (context, url) => Container(
                        color: Colors.grey[300],
                        child: const Center(
                          child: SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 1.5,
                              valueColor: AlwaysStoppedAnimation<Color>(Colors.grey),
                            ),
                          ),
                        ),
                      ),
                      errorWidget: (context, url, error) {
                        print('🖼️ ERROR: CachedNetworkImage failed to load: $error');
                        print('🖼️ ERROR: URL was: $url');
                        return Container(
                          color: Colors.red[100],
                          child: const Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.broken_image,
                                  color: Colors.red,
                                  size: 32,
                                ),
                                SizedBox(height: 4),
                                Text(
                                  'Failed to\nLoad Image',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    color: Colors.red,
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    )
                  else
                    Image.file(
                      File(finalImagePath),
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        print('🖼️ Image.file error: $error');
                        print('🖼️ File path: $finalImagePath');
                        print('🖼️ File exists: ${File(finalImagePath).existsSync()}');
                        print('🖼️ File size: ${File(finalImagePath).existsSync() ? File(finalImagePath).lengthSync() : 'N/A'} bytes');
                        
                        return Container(
                          constraints: const BoxConstraints(
                            maxWidth: 150,
                            maxHeight: 150,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.red[100],
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.red, width: 2),
                          ),
                          child: const Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.broken_image,
                                  color: Colors.red,
                                  size: 32,
                                ),
                                SizedBox(height: 4),
                                Text(
                                  'Failed to\nLoad Image',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    color: Colors.red,
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  
                  // Loading indicator for sending messages
                  if (isSending) ...[
                    Container(
                      color: Colors.black54,
                      child: const Center(
                        child: CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      ),
                    ),
                    // Debug info
                    Positioned(
                      top: 8,
                      left: 8,
                      child: Container(
                        padding: EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: Colors.red,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          'SENDING',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                  
                  // Debug info for image loading
                  Positioned(
                    bottom: 8,
                    right: 8,
                    child: Container(
                      padding: EdgeInsets.all(2),
                      decoration: BoxDecoration(
                        color: Colors.blue,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        isFromUser ? 'USER' : 'OTHER',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 8,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  
                  // Play button overlay for images (optional)
                  Positioned(
                    top: 8,
                    right: 8,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: Colors.black54,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Icon(
                        Icons.photo,
                        color: Colors.white,
                        size: 16,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          
          // Timestamp
          const SizedBox(height: 4),
          Text(
            _formatTimestamp(message['timestamp']),
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVoiceMessage(BuildContext context) {
    final audioPath = message['audioPath'] as String?;
    final isSending = message['isSending'] as bool? ?? false;
    
    print('🎤 MediaMessageBubbleWidget: Building voice message');
    print('🎤 Audio path: $audioPath');
    print('🎤 Is sending: $isSending');
    print('🎤 Is from user: $isFromUser');
    print('🎤 Message type: ${message['type']}');
    print('🎤 Full message data: $message');
    
    if (audioPath == null) {
      print('🎤 ERROR: No audio path found for voice message');
      return const SizedBox.shrink();
    }

    return Container(
      margin: EdgeInsets.only(
        left: isFromUser ? 0 : 50,
        right: isFromUser ? 50 : 0,
        bottom: 8,
      ),
      child: Column(
        crossAxisAlignment: isFromUser 
            ? CrossAxisAlignment.end 
            : CrossAxisAlignment.start,
        children: [
          // Voice message container
          Container(
            constraints: const BoxConstraints(
              maxWidth: 250,
              minHeight: 50,
            ),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              color: isFromUser 
                  ? const Color(0xFF007AFF) 
                  : const Color(0xFFE5E5EA),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Play/Pause button
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: isFromUser ? Colors.white : Colors.black,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.play_arrow,
                    color: isFromUser ? const Color(0xFF007AFF) : Colors.white,
                    size: 24,
                  ),
                ),
                
                const SizedBox(width: 12),
                
                // Waveform visualization (simplified)
                Expanded(
                  child: Container(
                    height: 30,
                    child: CustomPaint(
                      painter: VoiceWaveformPainter(
                        color: isFromUser ? Colors.white : Colors.black,
                      ),
                    ),
                  ),
                ),
                
                // Duration
                const SizedBox(width: 8),
                Text(
                  '0:15', // This should be calculated from actual audio duration
                  style: TextStyle(
                    color: isFromUser ? Colors.white : Colors.black,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                
                // Loading indicator for sending
                if (isSending) ...[
                  const SizedBox(width: 8),
                  const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  ),
                ],
              ],
            ),
          ),
          
          // Timestamp
          const SizedBox(height: 4),
          Text(
            _formatTimestamp(message['timestamp']),
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  String _formatTimestamp(String? timestamp) {
    if (timestamp == null) return '';
    
    try {
      final dateTime = DateTime.parse(timestamp);
      final now = DateTime.now();
      final difference = now.difference(dateTime);
      
      if (difference.inMinutes < 1) {
        return 'Just now';
      } else if (difference.inHours < 1) {
        return '${difference.inMinutes}m ago';
      } else if (difference.inDays < 1) {
        return '${difference.inHours}h ago';
      } else {
        return '${dateTime.day}/${dateTime.month}';
      }
    } catch (e) {
      return '';
    }
  }
}

/// Custom painter for voice waveform visualization
class VoiceWaveformPainter extends CustomPainter {
  final Color color;

  VoiceWaveformPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 2
      ..strokeCap = StrokeCap.round;

    final centerY = size.height / 2;
    final barWidth = 3.0;
    final spacing = 2.0;
    
    // Generate random heights for waveform bars
    final random = DateTime.now().millisecondsSinceEpoch;
    for (int i = 0; i < (size.width / (barWidth + spacing)).floor(); i++) {
      final height = (20 + (random + i) % 20).toDouble();
      final x = i * (barWidth + spacing);
      
      canvas.drawLine(
        Offset(x, centerY - height / 2),
        Offset(x, centerY + height / 2),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
