import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:minechat/controller/theme_controller/theme_controller.dart';
import 'package:minechat/core/constants/app_colors/app_colors.dart';
import 'package:minechat/core/utils/helpers/app_responsive/app_responsive.dart';
import 'package:minechat/core/utils/helpers/app_styles/app_text_styles.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:cached_network_image/cached_network_image.dart';

/// Reusable message bubble widget for chat conversations
class MessageBubbleWidget extends StatelessWidget {
  final String message;
  final String timestamp;
  final bool isFromUser;
  final bool isAI;
  final bool isPending;
  final String? error;
  final Widget? avatar;

  const MessageBubbleWidget({
    Key? key,
    required this.message,
    required this.timestamp,
    required this.isFromUser,
    this.isAI = false,
    this.isPending = false,
    this.error,
    this.avatar,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final themeController = Get.find<ThemeController>();
    final isDark = themeController.isDarkMode;
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisAlignment:
            isFromUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Avatar only for incoming messages (left side)
          if (!isFromUser) ...[
            avatar ?? _buildDefaultAvatar(),
            const SizedBox(width: 8),
          ],

          // Message bubble
          Flexible(
            child: Column(
              crossAxisAlignment: isFromUser
                  ? CrossAxisAlignment.end
                  : CrossAxisAlignment.start,
              children: [
                Container(
                  constraints: BoxConstraints(
                    maxWidth: MediaQuery.of(context).size.width * 0.7,
                  ),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: isFromUser
                        ? isDark
                            ? const Color(0XFF1D1D1D)
                            : const Color(0xFFE1E1EB)
                        : isDark
                            ? const Color(0XFF454545)
                            : const Color(0xFFFFFFFF),
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(
                          isFromUser ? AppResponsive.radius(context) : 0),
                      topRight: Radius.circular(
                          isFromUser ? 0 : AppResponsive.radius(context)),
                      bottomLeft:
                          Radius.circular(AppResponsive.radius(context)),
                      bottomRight:
                          Radius.circular(AppResponsive.radius(context)),
                    ),
                  ),
                  child: _buildMessageContent(context),
                ),
                const SizedBox(height: 2),
                Padding(
                  padding: EdgeInsets.only(
                    left: isFromUser ? 8 : 0,
                    right: isFromUser ? 0 : 8,
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(timestamp,
                          style: AppTextStyles.hintText(context).copyWith(
                              fontSize: AppResponsive.scaleSize(context, 12),
                              fontWeight: FontWeight.w400,
                              color: Color(0XFFA8AEBF))),
                      if (isPending) ...[
                        SizedBox(width: 4),
                        Icon(
                          Icons.schedule,
                          size: 12,
                          color: Colors.orange,
                        ),
                      ],
                      if (error != null) ...[
                        SizedBox(width: 4),
                        Icon(
                          Icons.error_outline,
                          size: 12,
                          color: Colors.red,
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Avatar only for outgoing messages (right side)
          if (isFromUser) ...[
            const SizedBox(width: 8),
            avatar ?? _buildDefaultAvatar(),
          ],
        ],
      ),
    );
  }

  Widget _buildMessageContent(BuildContext context) {
    final themeController = Get.find<ThemeController>();
    final isDark = themeController.isDarkMode;
    
    // Check if message contains markdown formatting or images
    final hasMarkdown = message.contains('**') || 
                       message.contains('*') || 
                       message.contains('![') ||
                       message.contains('[') ||
                       message.contains('#');
    
    print('📝 Message content: $message');
    print('📝 Has markdown: $hasMarkdown');
    
    // Special handling for AI product listings
    if (message.contains('Here are some products available') && message.contains('![')) {
      print('🛍️ AI product listing detected');
      return _buildProductListing(context);
    }
    
    if (hasMarkdown) {
      print('📝 Rendering as markdown');
      try {
        return MarkdownBody(
          data: message,
          styleSheet: MarkdownStyleSheet(
            p: AppTextStyles.bodyText(context).copyWith(
              fontSize: AppResponsive.scaleSize(context, 14),
              fontWeight: FontWeight.w400,
              height: 1.3,
              color: isFromUser 
                  ? (isDark ? Colors.white : Colors.black87)
                  : (isDark ? Colors.white : Colors.black87),
            ),
            strong: AppTextStyles.bodyText(context).copyWith(
              fontSize: AppResponsive.scaleSize(context, 14),
              fontWeight: FontWeight.bold,
              color: isFromUser 
                  ? (isDark ? Colors.white : Colors.black87)
                  : (isDark ? Colors.white : Colors.black87),
            ),
            em: AppTextStyles.bodyText(context).copyWith(
              fontSize: AppResponsive.scaleSize(context, 14),
              fontStyle: FontStyle.italic,
              color: isFromUser 
                  ? (isDark ? Colors.white : Colors.black87)
                  : (isDark ? Colors.white : Colors.black87),
            ),
            listBullet: AppTextStyles.bodyText(context).copyWith(
              fontSize: AppResponsive.scaleSize(context, 14),
              color: isFromUser 
                  ? (isDark ? Colors.white : Colors.black87)
                  : (isDark ? Colors.white : Colors.black87),
            ),
          ),
          imageBuilder: (uri, title, alt) {
            print('🖼️ Markdown image builder called: $uri');
            return _buildImageWidget(uri.toString(), title, alt);
          },
          onTapLink: (text, href, title) {
            // Handle link taps if needed
            print('Link tapped: $href');
          },
        );
      } catch (e) {
        print('❌ Markdown parsing error: $e');
        // Fallback to plain text
        return Text(
          message,
          style: AppTextStyles.bodyText(context).copyWith(
            fontSize: AppResponsive.scaleSize(context, 14),
            fontWeight: FontWeight.w400,
            height: 1.3,
          ),
        );
      }
    } else {
      // Plain text message
      print('📝 Rendering as plain text');
      return Text(
        message,
        style: AppTextStyles.bodyText(context).copyWith(
          fontSize: AppResponsive.scaleSize(context, 14),
          fontWeight: FontWeight.w400,
          height: 1.3,
        ),
      );
    }
  }

  Widget _buildProductListing(BuildContext context) {
    final themeController = Get.find<ThemeController>();
    final isDark = themeController.isDarkMode;
    
    // Parse the product listing manually
    final lines = message.split('\n');
    final products = <Map<String, String>>[];
    Map<String, String>? currentProduct;
    
    for (final line in lines) {
      if (line.trim().isEmpty) continue;
      
      if (line.startsWith('**') && line.endsWith('**')) {
        // Product name
        if (currentProduct != null) {
          products.add(currentProduct);
        }
        currentProduct = {
          'name': line.replaceAll('**', '').trim(),
          'description': '',
          'price': '',
          'image': '',
        };
      } else if (line.contains('**Description:**')) {
        currentProduct?['description'] = line.replaceAll('**Description:**', '').trim();
      } else if (line.contains('**Price:**')) {
        currentProduct?['price'] = line.replaceAll('**Price:**', '').trim();
      } else if (line.contains('**Image:**')) {
        final imageLine = line.replaceAll('**Image:**', '').trim();
        final imageMatch = RegExp(r'!\[.*?\]\((.*?)\)').firstMatch(imageLine);
        if (imageMatch != null) {
          currentProduct?['image'] = imageMatch.group(1) ?? '';
        }
      }
    }
    
    if (currentProduct != null) {
      products.add(currentProduct);
    }
    
    print('🛍️ Parsed ${products.length} products');
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header
        Text(
          'Hi! Here are some products available through Minechat AI:',
          style: AppTextStyles.bodyText(context).copyWith(
            fontSize: AppResponsive.scaleSize(context, 14),
            fontWeight: FontWeight.w400,
            height: 1.3,
          ),
        ),
        SizedBox(height: 16),
        // Products
        ...products.map((product) => _buildProductCard(context, product)).toList(),
        SizedBox(height: 16),
        // Footer
        Text(
          'If you have any questions about these products or need further assistance, feel free to ask!',
          style: AppTextStyles.bodyText(context).copyWith(
            fontSize: AppResponsive.scaleSize(context, 14),
            fontWeight: FontWeight.w400,
            height: 1.3,
          ),
        ),
      ],
    );
  }

  Widget _buildProductCard(BuildContext context, Map<String, String> product) {
    final themeController = Get.find<ThemeController>();
    final isDark = themeController.isDarkMode;
    
    return Container(
      margin: EdgeInsets.only(bottom: 16),
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isDark ? Colors.grey[800] : Colors.grey[100],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isDark ? Colors.grey[700]! : Colors.grey[300]!,
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Product name
          Text(
            product['name'] ?? '',
            style: AppTextStyles.bodyText(context).copyWith(
              fontSize: AppResponsive.scaleSize(context, 16),
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 8),
          // Product image
          if (product['image']?.isNotEmpty == true) ...[
            _buildImage(product['image']!),
            SizedBox(height: 8),
          ],
          // Description
          if (product['description']?.isNotEmpty == true) ...[
            Text(
              'Description: ${product['description']}',
              style: AppTextStyles.bodyText(context).copyWith(
                fontSize: AppResponsive.scaleSize(context, 14),
                fontWeight: FontWeight.w400,
              ),
            ),
            SizedBox(height: 4),
          ],
          // Price
          if (product['price']?.isNotEmpty == true)
            Text(
              'Price: ${product['price']}',
              style: AppTextStyles.bodyText(context).copyWith(
                fontSize: AppResponsive.scaleSize(context, 14),
                fontWeight: FontWeight.bold,
                color: Colors.green,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildImageWidget(String imagePath, String? title, String? alt) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (title != null && title.isNotEmpty)
            Padding(
              padding: EdgeInsets.only(bottom: 4),
              child: Text(
                title,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
            ),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: _buildImage(imagePath),
          ),
          if (alt != null && alt.isNotEmpty)
            Padding(
              padding: EdgeInsets.only(top: 4),
              child: Text(
                alt,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                  fontStyle: FontStyle.italic,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildImage(String imagePath) {
    print('🖼️ Loading image: $imagePath');
    
    // Handle different image path types
    if (imagePath.startsWith('http')) {
      // Network image
      print('🌐 Network image detected');
      return CachedNetworkImage(
        imageUrl: imagePath,
        fit: BoxFit.cover,
        placeholder: (context, url) => Container(
          height: 200,
          color: Colors.grey[300],
          child: Center(child: CircularProgressIndicator()),
        ),
        errorWidget: (context, url, error) {
          print('❌ Network image error: $error');
          return Container(
            height: 200,
            color: Colors.grey[300],
            child: Icon(Icons.error, color: Colors.red),
          );
        },
      );
    } else if (imagePath.startsWith('/data/') || imagePath.startsWith('file://')) {
      // Local file image
      print('📁 Local file image detected');
      final file = File(imagePath);
      print('📁 File exists: ${file.existsSync()}');
      print('📁 File path: ${file.path}');
      
      return Image.file(
        file,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          print('❌ Local file error: $error');
          return Container(
            height: 200,
            color: Colors.grey[300],
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.image_not_supported, color: Colors.grey),
                Text('Image not found', style: TextStyle(color: Colors.grey)),
                Text('Path: $imagePath', style: TextStyle(color: Colors.grey, fontSize: 10)),
              ],
            ),
          );
        },
      );
    } else {
      // Try as asset
      print('📦 Asset image detected');
      return Image.asset(
        imagePath,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          print('❌ Asset error: $error');
          return Container(
            height: 200,
            color: Colors.grey[300],
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.image_not_supported, color: Colors.grey),
                Text('Image not found', style: TextStyle(color: Colors.grey)),
                Text('Path: $imagePath', style: TextStyle(color: Colors.grey, fontSize: 10)),
              ],
            ),
          );
        },
      );
    }
  }

  Widget _buildDefaultAvatar() {
    return CircleAvatar(
      radius: 16,
      backgroundColor: AppColors.primary,
      child: Icon(
        isAI ? Icons.smart_toy : Icons.person,
        color: Colors.white,
        size: 16,
      ),
    );
  }
}
