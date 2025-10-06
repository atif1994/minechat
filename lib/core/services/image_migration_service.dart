import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:minechat/core/services/firebase_storage_service.dart';

class ImageMigrationService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseStorageService _storageService = FirebaseStorageService();

  /// Migrate all products with local image paths to Firebase Storage
  Future<void> migrateAllProducts() async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        print('❌ No authenticated user for migration');
        Get.snackbar('Error', 'User not authenticated');
        return;
      }

      print('🔄 Starting image migration for user: ${user.uid}');

      // Get all products for the current user
      final snapshot = await _firestore
          .collection('products_services')
          .where('userId', isEqualTo: user.uid)
          .get();

      print('📦 Found ${snapshot.docs.length} products to migrate');

      int migratedCount = 0;
      int errorCount = 0;

      for (final doc in snapshot.docs) {
        try {
          final data = doc.data();
          final productId = doc.id;
          
          print('🔄 Migrating product: ${data['name']} (ID: $productId)');

          // Check if product has local image paths
          final images = (data['images'] as List<dynamic>?) ?? [];
          final selectedImage = data['selectedImage'] as String?;

          bool hasLocalImages = false;
          List<String> localImagePaths = [];

          // Check images array
          for (final image in images) {
            if (image is String && !image.startsWith('http')) {
              hasLocalImages = true;
              localImagePaths.add(image);
            }
          }

          // Check selectedImage
          if (selectedImage != null && !selectedImage.startsWith('http')) {
            hasLocalImages = true;
            if (!localImagePaths.contains(selectedImage)) {
              localImagePaths.add(selectedImage);
            }
          }

          if (!hasLocalImages) {
            print('✅ Product already has Firebase Storage URLs, skipping');
            continue;
          }

          print('📤 Found ${localImagePaths.length} local images to migrate');

          // Upload local images to Firebase Storage
          List<String> uploadedUrls = [];
          for (final localPath in localImagePaths) {
            if (File(localPath).existsSync()) {
              final url = await _storageService.uploadImage(File(localPath));
              if (url != null) {
                uploadedUrls.add(url);
                print('✅ Uploaded: $localPath -> $url');
              } else {
                print('❌ Failed to upload: $localPath');
                errorCount++;
              }
            } else {
              print('⚠️ Local file not found: $localPath');
              errorCount++;
            }
          }

          if (uploadedUrls.isNotEmpty) {
            // Update the product with Firebase Storage URLs
            await _firestore.collection('products_services').doc(productId).update({
              'images': uploadedUrls,
              'selectedImage': uploadedUrls.isNotEmpty ? uploadedUrls.first : null,
              'migratedAt': FieldValue.serverTimestamp(),
            });

            print('✅ Product migrated successfully');
            migratedCount++;
          } else {
            print('❌ No images could be uploaded for this product');
            errorCount++;
          }

        } catch (e) {
          print('❌ Error migrating product ${doc.id}: $e');
          errorCount++;
        }
      }

      print('🎉 Migration completed!');
      print('✅ Migrated: $migratedCount products');
      print('❌ Errors: $errorCount products');

      Get.snackbar(
        'Migration Complete',
        'Migrated $migratedCount products successfully. $errorCount errors occurred.',
        backgroundColor: migratedCount > 0 ? Colors.green : Colors.orange,
        colorText: Colors.white,
        duration: Duration(seconds: 5),
      );

    } catch (e) {
      print('❌ Migration failed: $e');
      Get.snackbar('Migration Failed', 'Error: ${e.toString()}');
    }
  }

  /// Check if a product needs migration
  bool _needsMigration(Map<String, dynamic> productData) {
    final images = (productData['images'] as List<dynamic>?) ?? [];
    final selectedImage = productData['selectedImage'] as String?;

    // Check if any image is a local path
    for (final image in images) {
      if (image is String && !image.startsWith('http')) {
        return true;
      }
    }

    if (selectedImage != null && !selectedImage.startsWith('http')) {
      return true;
    }

    return false;
  }

  /// Get migration statistics
  Future<Map<String, int>> getMigrationStats() async {
    try {
      final user = _auth.currentUser;
      if (user == null) return {'total': 0, 'needsMigration': 0, 'migrated': 0};

      final snapshot = await _firestore
          .collection('products_services')
          .where('userId', isEqualTo: user.uid)
          .get();

      int total = snapshot.docs.length;
      int needsMigration = 0;
      int migrated = 0;

      for (final doc in snapshot.docs) {
        final data = doc.data();
        if (_needsMigration(data)) {
          needsMigration++;
        } else {
          migrated++;
        }
      }

      return {
        'total': total,
        'needsMigration': needsMigration,
        'migrated': migrated,
      };
    } catch (e) {
      print('❌ Error getting migration stats: $e');
      return {'total': 0, 'needsMigration': 0, 'migrated': 0};
    }
  }
}
