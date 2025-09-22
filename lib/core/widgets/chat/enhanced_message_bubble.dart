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
    print('🖼️ EnhancedMessageBubble: Processing message: ${message.length} chars');
    print('🖼️ Message preview: ${message.length > 100 ? message.substring(0, 100) + '...' : message}');
    
    final imageUrls = ImageParser.extractImageUrls(message);
    final cleanText = ImageParser.removeImageUrls(message);
    
    print('🖼️ EnhancedMessageBubble: Found ${imageUrls.length} images');
    print('🖼️ Image URLs: $imageUrls');
    print('🖼️ Clean text length: ${cleanText.length}');
    print('🖼️ Clean text preview: ${cleanText.length > 50 ? cleanText.substring(0, 50) + '...' : cleanText}');
    
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
    print('🖼️ _buildImageGrid called with ${imageUrls.length} images');
    if (imageUrls.isEmpty) {
      print('🖼️ No images to display in grid');
      return Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.yellow[100],
          border: Border.all(color: Colors.orange),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          'DEBUG: No images detected in message',
          style: TextStyle(
            color: Colors.orange[800],
            fontSize: 12,
            fontWeight: FontWeight.bold,
          ),
        ),
      );
    }
    
    if (imageUrls.length == 1) {
      print('🖼️ Building single image: ${imageUrls.first}');
      return _buildSingleImage(imageUrls.first);
    } else {
      print('🖼️ Building multiple images: $imageUrls');
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
    print('🖼️ Building image widget for: $imageUrl');
    
    if (imageUrl.startsWith('http')) {
      // Network image
      print('🖼️ Loading network image: $imageUrl');
      return CachedNetworkImage(
        imageUrl: imageUrl,
        fit: BoxFit.cover,
        placeholder: (context, url) => Container(
          color: Colors.grey[300],
          child: const Center(
            child: CircularProgressIndicator(),
          ),
        ),
        errorWidget: (context, url, error) {
          print('🖼️ Network image error: $error');
          return Container(
            color: Colors.grey[300],
            child: const Icon(
              Icons.error,
              color: Colors.red,
            ),
          );
        },
      );
    } else if (imageUrl.startsWith('file://')) {
      // Local file from file:// URL
      final filePath = imageUrl.replaceFirst('file://', '');
      print('🖼️ Loading local file: $filePath');
      
      // Check if file exists
      final file = File(filePath);
      if (!file.existsSync()) {
        print('🖼️ File does not exist: $filePath');
        return Container(
          color: Colors.grey[200],
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.image_outlined,
                color: Colors.grey,
                size: 24,
              ),
              const SizedBox(height: 4),
              Text(
                'Image not available',
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 10,
                ),
              ),
            ],
          ),
        );
      }
      
      return Image.file(
        file,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          print('🖼️ File image error: $error');
          return Container(
            color: Colors.grey[200],
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.image_outlined,
                  color: Colors.grey,
                  size: 24,
                ),
                const SizedBox(height: 4),
                Text(
                  'Cannot load image',
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 10,
                  ),
                ),
              ],
            ),
          );
        },
      );
    } else {
      // Local asset or file path
      print('🖼️ Loading direct file path: $imageUrl');
      
      // Check if file exists first
      final file = File(imageUrl);
      if (!file.existsSync()) {
        print('🖼️ Direct file does not exist: $imageUrl');
        return Container(
          color: Colors.grey[200],
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.image_outlined,
                color: Colors.grey,
                size: 24,
              ),
              const SizedBox(height: 4),
              Text(
                'Image not available',
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 10,
                ),
              ),
            ],
          ),
        );
      }
      
      return Image.file(
        file,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          print('🖼️ Direct file error: $error');
          return Container(
            color: Colors.grey[200],
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.image_outlined,
                  color: Colors.grey,
                  size: 24,
                ),
                const SizedBox(height: 4),
                Text(
                  'Cannot load image',
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 10,
                  ),
                ),
              ],
            ),
          );
        },
      );
    }
  }
}
