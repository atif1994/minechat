import 'dart:io';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../utils/image_parser.dart';

class EnhancedMessageBubble extends StatelessWidget {
  final String message;
  final bool isUser;
  final String timestamp;
  final bool isAI;

  const EnhancedMessageBubble({
    Key? key,
    required this.message,
    required this.isUser,
    required this.timestamp,
    this.isAI = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final imageUrls = ImageParser.extractImageUrls(message);
    final cleanText = ImageParser.removeImageUrls(message);
    
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        mainAxisAlignment: isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!isUser) ...[
            CircleAvatar(
              radius: 16,
              backgroundColor: isAI ? Colors.blue[100] : Colors.green[100],
              child: Icon(
                isAI ? Icons.smart_toy : Icons.person,
                size: 16,
                color: isAI ? Colors.blue[700] : Colors.green[700],
              ),
            ),
            const SizedBox(width: 8),
          ],
          
          Flexible(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: isUser ? Colors.blue[600] : Colors.grey[100],
                borderRadius: BorderRadius.circular(18).copyWith(
                  bottomLeft: isUser ? const Radius.circular(18) : const Radius.circular(4),
                  bottomRight: isUser ? const Radius.circular(4) : const Radius.circular(18),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Display images if any
                  if (imageUrls.isNotEmpty) ...[
                    _buildImageGrid(imageUrls),
                    if (cleanText.isNotEmpty) const SizedBox(height: 8),
                  ],
                  
                  // Display text content
                  if (cleanText.isNotEmpty)
                    Text(
                      cleanText,
                      style: TextStyle(
                        color: isUser ? Colors.white : Colors.black87,
                        fontSize: 14,
                      ),
                    ),
                  
                  const SizedBox(height: 4),
                  Text(
                    timestamp,
                    style: TextStyle(
                      color: isUser ? Colors.white70 : Colors.grey[600],
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ),
          ),
          
          if (isUser) ...[
            const SizedBox(width: 8),
            CircleAvatar(
              radius: 16,
              backgroundColor: Colors.blue[100],
              child: Icon(
                Icons.person,
                size: 16,
                color: Colors.blue[700],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildImageGrid(List<String> imageUrls) {
    if (imageUrls.isEmpty) return const SizedBox.shrink();
    
    if (imageUrls.length == 1) {
      return _buildSingleImage(imageUrls.first);
    } else {
      return _buildMultipleImages(imageUrls);
    }
  }

  Widget _buildSingleImage(String imageUrl) {
    return Container(
      constraints: const BoxConstraints(
        maxWidth: 200,
        maxHeight: 200,
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: _buildImageWidget(imageUrl),
      ),
    );
  }

  Widget _buildMultipleImages(List<String> imageUrls) {
    return Container(
      constraints: const BoxConstraints(
        maxWidth: 250,
        maxHeight: 300,
      ),
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 4,
          mainAxisSpacing: 4,
          childAspectRatio: 1,
        ),
        itemCount: imageUrls.length > 4 ? 4 : imageUrls.length,
        itemBuilder: (context, index) {
          return ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: _buildImageWidget(imageUrls[index]),
          );
        },
      ),
    );
  }

  Widget _buildImageWidget(String imageUrl) {
    if (imageUrl.startsWith('http')) {
      // Network image
      return CachedNetworkImage(
        imageUrl: imageUrl,
        fit: BoxFit.cover,
        placeholder: (context, url) => Container(
          color: Colors.grey[300],
          child: const Center(
            child: CircularProgressIndicator(),
          ),
        ),
        errorWidget: (context, url, error) => Container(
          color: Colors.grey[300],
          child: const Icon(
            Icons.error,
            color: Colors.red,
          ),
        ),
      );
    } else if (imageUrl.startsWith('file://')) {
      // Local file from file:// URL
      final filePath = imageUrl.replaceFirst('file://', '');
      return Image.file(
        File(filePath),
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) => Container(
          color: Colors.grey[300],
          child: const Icon(
            Icons.error,
            color: Colors.red,
          ),
        ),
      );
    } else {
      // Local asset or file path
      return Image.file(
        File(imageUrl),
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) => Container(
          color: Colors.grey[300],
          child: const Icon(
            Icons.error,
            color: Colors.red,
          ),
        ),
      );
    }
  }
}
