import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:minechat/core/constants/app_colors/app_colors.dart';
import 'package:minechat/core/utils/helpers/app_styles/app_text_styles.dart';
import 'package:minechat/model/data/product_service_model.dart';
import 'package:minechat/core/services/firebase_storage_service.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'dart:io';

class ProductCard extends StatelessWidget {
  final ProductServiceModel product;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;
  final bool isDark;

  const ProductCard({
    super.key,
    required this.product,
    this.onEdit,
    this.onDelete,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? Color(0XFF1A1A1A) : Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Product Image
          Expanded(
            flex: 3,
            child: Container(
              width: double.infinity,
              decoration: BoxDecoration(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                color: Colors.grey[100],
              ),
              child: ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                child: _buildProductImage(),
              ),
            ),
          ),
          
          // Product Details
          Expanded(
            flex: 2,
            child: Padding(
              padding: const EdgeInsets.all(8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Product Name
                  Flexible(
                    child: Text(
                      product.name,
                      style: AppTextStyles.bodyText(context).copyWith(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: isDark ? AppColors.white : AppColors.secondary,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(height: 2),
                  
                  // Product Description
                  Flexible(
                    child: Text(
                      product.description,
                      style: AppTextStyles.bodyText(context).copyWith(
                        fontSize: 11,
                        color: Colors.grey[600],
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(height: 4),
                  
                  // Price and Actions Row
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Price
                      Flexible(
                        child: Text(
                          '\$${product.price}',
                          style: AppTextStyles.bodyText(context).copyWith(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: AppColors.primary,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      
                      // Action Buttons
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // Edit Button
                          if (onEdit != null)
                            GestureDetector(
                              onTap: onEdit,
                              child: Container(
                                padding: const EdgeInsets.all(4),
                                decoration: BoxDecoration(
                                  color: Colors.blue.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Icon(
                                  Icons.edit,
                                  size: 14,
                                  color: Colors.blue[600],
                                ),
                              ),
                            ),
                          if (onEdit != null && onDelete != null) const SizedBox(width: 4),
                          
                          // Delete Button
                          if (onDelete != null)
                            GestureDetector(
                              onTap: onDelete,
                              child: Container(
                                padding: const EdgeInsets.all(4),
                                decoration: BoxDecoration(
                                  color: Colors.red.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Icon(
                                  Icons.delete,
                                  size: 14,
                                  color: Colors.red[600],
                                ),
                              ),
                            ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProductImage() {
    print("🔍 ===== DEBUGGING PRODUCT IMAGE =====");
    print("🔍 Product Name: ${product.name}");
    print("🔍 Product ID: ${product.id}");
    print("🔍 Images array length: ${product.images.length}");
    print("🔍 Images array content: ${product.images}");
    print("🔍 SelectedImage: ${product.selectedImage}");
    print("🔍 SelectedImage is null: ${product.selectedImage == null}");
    print("🔍 SelectedImage is empty: ${product.selectedImage?.isEmpty ?? true}");
    
    // Try to get the first image from the images list or fallback to selectedImage
    String? imagePath;
    if (product.images.isNotEmpty) {
      imagePath = product.images.first;
      print("✅ Using first image from images list: $imagePath");
      print("✅ Image URL length: ${imagePath.length}");
      print("✅ Image URL starts with http: ${imagePath.startsWith('http')}");
    } else if (product.selectedImage != null && product.selectedImage!.isNotEmpty) {
      imagePath = product.selectedImage;
      print("✅ Using selectedImage: $imagePath");
      print("✅ SelectedImage URL length: ${imagePath?.length ?? 0}");
      print("✅ SelectedImage starts with http: ${imagePath?.startsWith('http') ?? false}");
    } else {
      print("❌ No images found - both images array and selectedImage are empty/null");
    }

    print("🔍 Final imagePath: $imagePath");
    print("🔍 ImagePath is null: ${imagePath == null}");
    print("🔍 ImagePath is empty: ${imagePath?.isEmpty ?? true}");
    print("🔍 ===== END DEBUGGING =====");

    if (imagePath != null && imagePath.isNotEmpty) {
      // Check if it's a Firebase Storage URL or local file path
      if (imagePath.startsWith('http')) {
        // Firebase Storage URL - use CachedNetworkImage
        print("🌐 Firebase Storage URL detected: $imagePath");
        _testImageUrl(imagePath); // Test the URL
        return CachedNetworkImage(
          imageUrl: imagePath,
          width: double.infinity,
          height: double.infinity,
          fit: BoxFit.cover,
          placeholder: (context, url) {
            print("⏳ LOADING IMAGE: $url");
            print("⏳ URL length: ${url.length}");
            print("⏳ URL valid: ${Uri.tryParse(url) != null}");
            return _buildLoadingPlaceholder();
          },
          errorWidget: (context, url, error) {
            print("❌ ERROR LOADING IMAGE:");
            print("❌ URL: $url");
            print("❌ Error: $error");
            print("❌ Error type: ${error.runtimeType}");
            print("❌ URL length: ${url.length}");
            print("❌ URL starts with https: ${url.startsWith('https')}");
            print("❌ URL contains firebase: ${url.contains('firebase')}");
            return _buildPlaceholderImage();
          },
        );
      } else {
        // Local file path - use Image.file
        return Image.file(
          File(imagePath),
          width: double.infinity,
          height: double.infinity,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            return _buildPlaceholderImage();
          },
        );
      }
    } else {
      return _buildPlaceholderImage();
    }
  }

  Widget _buildPlaceholderImage() {
    return Container(
      color: Colors.grey[200],
      child: const Center(
        child: Icon(
          Icons.image,
          size: 40,
          color: Colors.grey,
        ),
      ),
    );
  }

  Widget _buildLoadingPlaceholder() {
    return Container(
      color: Colors.grey[200],
      child: const Center(
        child: SizedBox(
          width: 20,
          height: 20,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            valueColor: AlwaysStoppedAnimation<Color>(Colors.grey),
          ),
        ),
      ),
    );
  }

  Widget _buildTestImageWidget(String imageUrl) {
    print("🧪 Testing image URL: $imageUrl");
    return Container(
      color: Colors.blue[100],
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.image, size: 40, color: Colors.blue),
          const SizedBox(height: 8),
          Text(
            'Testing Image',
            style: TextStyle(fontSize: 12, color: Colors.blue[700]),
          ),
          const SizedBox(height: 4),
          Text(
            imageUrl.length > 50 ? '${imageUrl.substring(0, 50)}...' : imageUrl,
            style: TextStyle(fontSize: 8, color: Colors.blue[600]),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  // Test method to verify URL accessibility
  Future<void> _testImageUrl(String? url) async {
    if (url == null || url.isEmpty) {
      print("🧪 ❌ URL is null or empty");
      return;
    }
    
    print("🧪 ===== TESTING IMAGE URL =====");
    print("🧪 URL: $url");
    print("🧪 URL length: ${url.length}");
    print("🧪 URL starts with https: ${url.startsWith('https')}");
    print("🧪 URL contains firebase: ${url.contains('firebase')}");
    print("🧪 URL contains firebasestorage: ${url.contains('firebasestorage')}");
    print("🧪 URL contains googleapis: ${url.contains('googleapis')}");
    print("🧪 URL contains alt=media: ${url.contains('alt=media')}");
    print("🧪 URL contains token: ${url.contains('token=')}");
    
    try {
      final uri = Uri.parse(url);
      print("🧪 Parsed URI: $uri");
      print("🧪 URI scheme: ${uri.scheme}");
      print("🧪 URI host: ${uri.host}");
      print("🧪 URI path: ${uri.path}");
      print("🧪 URI query: ${uri.query}");
    } catch (e) {
      print("🧪 ❌ Error parsing URL: $e");
    }
    print("🧪 ===== END URL TEST =====");
  }
}
