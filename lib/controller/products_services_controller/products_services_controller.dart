import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:minechat/model/data/product_service_model.dart';
import 'package:minechat/controller/ai_assistant_controller/ai_assistant_controller.dart';
import 'package:minechat/core/services/firebase_storage_service.dart';
import 'dart:io';

class ProductsServicesController extends GetxController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorageService _storageService = FirebaseStorageService();

  // Loading States
  var isLoading = false.obs;
  var isSaving = false.obs;

  // Product/Service Controllers
  final nameCtrl = TextEditingController();
  final descriptionCtrl = TextEditingController();
  final priceCtrl = TextEditingController();

  // Error Messages
  var nameError = ''.obs;
  var descriptionError = ''.obs;
  var priceError = ''.obs;

  // Products List
  var productsServices = <ProductServiceModel>[].obs;

  // Selected Image for upload (reactive in controller, plain string in model)
  var selectedImage = ''.obs;

  // Editing state
  var isEditing = false.obs;
  var editingProductId = ''.obs;

  final images = <String>[].obs;

  @override
  void onInit() {
    super.onInit();
    print('🔍 ProductsServicesController initialized');
    print('🔍 Firestore instance: $_firestore');
    loadProductsServices();
  }

  @override
  void onClose() {
    nameCtrl.dispose();
    descriptionCtrl.dispose();
    priceCtrl.dispose();
    super.onClose();
  }

  // Manual migration method for testing
  Future<void> migrateAllProducts() async {
    print("🚀 Starting manual migration of all products...");
    await loadProductsServices();
    print("✅ Migration completed!");
  }

  Future<void> loadProductsServices() async {
    try {
      isLoading.value = true;
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        print("❌ No authenticated user found");
        return;
      }

      print("🔍 Loading products for user: ${user.uid}");
      
      final snapshot = await _firestore
          .collection('products_services')
          .where('userId', isEqualTo: user.uid)
          .get();

      final loadedProducts = <ProductServiceModel>[];
      
      for (final doc in snapshot.docs) {
        final data = doc.data();
        print("🔍 ===== FIRESTORE DOCUMENT DEBUG =====");
        print("🔍 Document ID: ${doc.id}");
        print("🔍 Raw Firestore data: $data");
        print("🔍 Images field type: ${data['images'].runtimeType}");
        print("🔍 Images field value: ${data['images']}");
        print("🔍 SelectedImage field type: ${data['selectedImage'].runtimeType}");
        print("🔍 SelectedImage field value: ${data['selectedImage']}");
        
        // Ensure the document ID is properly set
        data['id'] = doc.id;
        final product = ProductServiceModel.fromMap(data);
        
        print("📦 Loaded product: ${product.name} (ID: ${product.id})");
        print("🖼️ Product images array: ${product.images}");
        print("🖼️ Product images count: ${product.images.length}");
        print("🖼️ Product selectedImage: ${product.selectedImage}");
        print("🖼️ SelectedImage is null: ${product.selectedImage == null}");
        print("🖼️ SelectedImage is empty: ${product.selectedImage?.isEmpty ?? true}");
        
        // 🔄 AUTO-MIGRATION: Check if product has old local file paths
        bool needsMigration = false;
        List<String> localImagePaths = [];
        
        // Check images array for local paths
        for (String imagePath in product.images) {
          if (imagePath.startsWith('/data/') || imagePath.startsWith('file://')) {
            localImagePaths.add(imagePath);
            needsMigration = true;
            print("🔄 Found local image path in images array: $imagePath");
          }
        }
        
        // Check selectedImage for local path
        if (product.selectedImage != null && 
            (product.selectedImage!.startsWith('/data/') || product.selectedImage!.startsWith('file://'))) {
          localImagePaths.add(product.selectedImage!);
          needsMigration = true;
          print("🔄 Found local image path in selectedImage: ${product.selectedImage}");
        }
        
        if (needsMigration) {
          print("🚀 AUTO-MIGRATING product: ${product.name}");
          try {
            // Check if local files still exist before uploading
            final existingLocalPaths = <String>[];
            for (String path in localImagePaths) {
              if (File(path).existsSync()) {
                existingLocalPaths.add(path);
                print("✅ Local file exists: $path");
              } else {
                print("❌ Local file not found: $path");
              }
            }
            
            if (existingLocalPaths.isEmpty) {
              print("⚠️ No local files found for product ${product.name} - skipping migration");
              // Add product without images
              final productWithoutImages = ProductServiceModel(
                id: product.id,
                name: product.name,
                description: product.description,
                price: product.price,
                category: product.category,
                features: product.features,
                userId: product.userId,
                createdAt: product.createdAt,
                updatedAt: DateTime.now(),
                images: <String>[],
                selectedImage: null,
              );
              
              // Update in Firestore to clear old local paths
              await _firestore.collection('products_services').doc(product.id).update({
                'images': <String>[],
                'selectedImage': null,
                'updatedAt': DateTime.now(),
              });
              
              loadedProducts.add(productWithoutImages);
              continue;
            }
            
            // Upload existing local images to Firebase Storage
            final firebaseUrls = await _storageService.uploadImagesFromPaths(existingLocalPaths);
            print("✅ Uploaded ${firebaseUrls.length} images to Firebase Storage");
            
            // Update the product with Firebase URLs
            final updatedImages = <String>[];
            final updatedSelectedImage = product.selectedImage;
            
            // Replace local paths with Firebase URLs in images array
            for (String imagePath in product.images) {
              if (imagePath.startsWith('/data/') || imagePath.startsWith('file://')) {
                // Find corresponding Firebase URL
                final localIndex = localImagePaths.indexOf(imagePath);
                if (localIndex < firebaseUrls.length) {
                  updatedImages.add(firebaseUrls[localIndex]);
                  print("✅ Replaced local path with Firebase URL: ${firebaseUrls[localIndex]}");
                } else {
                  print("⚠️ No Firebase URL found for local path: $imagePath");
                }
              } else {
                // Keep existing Firebase URLs
                updatedImages.add(imagePath);
              }
            }
            
            // Update selectedImage if it was a local path
            String? newSelectedImage = updatedSelectedImage;
            if (updatedSelectedImage != null && 
                (updatedSelectedImage.startsWith('/data/') || updatedSelectedImage.startsWith('file://'))) {
              final localIndex = localImagePaths.indexOf(updatedSelectedImage);
              if (localIndex < firebaseUrls.length) {
                newSelectedImage = firebaseUrls[localIndex];
                print("✅ Updated selectedImage with Firebase URL: $newSelectedImage");
              }
            }
            
            // Create updated product
            final migratedProduct = ProductServiceModel(
              id: product.id,
              name: product.name,
              description: product.description,
              price: product.price,
              category: product.category,
              features: product.features,
              userId: product.userId,
              createdAt: product.createdAt,
              updatedAt: DateTime.now(),
              images: updatedImages,
              selectedImage: newSelectedImage,
            );
            
            // Update in Firestore
            await _firestore.collection('products_services').doc(product.id).update({
              'images': updatedImages,
              'selectedImage': newSelectedImage,
              'updatedAt': DateTime.now(),
            });
            
            print("✅ Successfully migrated product: ${product.name}");
            loadedProducts.add(migratedProduct);
            
          } catch (e) {
            print("❌ Error migrating product ${product.name}: $e");
            // Add original product if migration fails
            loadedProducts.add(product);
          }
        } else {
          print("✅ Product ${product.name} already uses Firebase Storage");
          loadedProducts.add(product);
        }
        
        print("🔍 ===== END FIRESTORE DEBUG =====");
      }

      // Filter out products with empty IDs to prevent errors
      final validProducts = loadedProducts.where((p) => p.id.isNotEmpty).toList();
      productsServices.value = validProducts;

      print("✅ Loaded ${productsServices.length} valid products for user: ${user.uid}");
      print("📦 Products list updated - triggering UI refresh");
      
      // Log any products with empty IDs that were filtered out
      final emptyIdProducts = loadedProducts.where((p) => p.id.isEmpty).toList();
      if (emptyIdProducts.isNotEmpty) {
        print("⚠️ Filtered out ${emptyIdProducts.length} products with empty IDs");
        for (final product in emptyIdProducts) {
          print("⚠️ Product with empty ID: ${product.name}");
        }
      }
    } catch (e) {
      print('❌ Error loading products: $e');
      Get.snackbar('Error', 'Failed to load products: ${e.toString()}');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> addProductService() async {
    if (!_validateForm()) return;

    try {
      isSaving.value = true;
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        Get.snackbar('Error', 'User not authenticated');
        return;
      }

      print('🔍 Starting product save process...');
      print('🔍 User authenticated: ${user.uid}');
      print('🔍 User email: ${user.email}');

      final product = ProductServiceModel(
        id: '',
        // Will be set by Firestore
        name: nameCtrl.text.trim(),
        description: descriptionCtrl.text.trim(),
        price: priceCtrl.text.trim(),
        category: '',
        features: '',
        userId: user.uid,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        selectedImage:
            selectedImage.value.isNotEmpty ? selectedImage.value : null,
      );

      print("📤 Adding product to Firestore: ${product.toMap()}");
      print("🔍 User ID: ${user.uid}");
      print("🔍 Collection: products_services");

      // Add timeout and retry logic
      DocumentReference? docRef;
      int retryCount = 0;
      const maxRetries = 3;

      // Upload images to Firebase Storage first
      List<String> uploadedImageUrls = [];
      if (images.isNotEmpty) {
        print('📤 Uploading ${images.length} images to Firebase Storage...');
        uploadedImageUrls = await _storageService.uploadImagesFromPaths(images.toList());
        print('✅ Uploaded ${uploadedImageUrls.length} images successfully');
      }

      // Build payload with Firebase Storage URLs
      final payload = product.toMap()
        ..['images'] = uploadedImageUrls
        ..['selectedImage'] = uploadedImageUrls.isNotEmpty
            ? uploadedImageUrls.first
            : null;

      // Add with retries (unchanged outer logic)
      while (retryCount < maxRetries) {
        try {
          print("🔄 Attempt ${retryCount + 1} of $maxRetries");
          docRef = await _firestore
              .collection('products_services')
              .add(payload)
              .timeout(const Duration(seconds: 30));
          print("✅ Product saved successfully on attempt ${retryCount + 1}");
          break;
        } catch (e) {
          retryCount++;
          print("❌ Attempt $retryCount failed: $e");
          if (retryCount >= maxRetries) {
            rethrow;
          }
          // Wait before retrying
          await Future.delayed(Duration(seconds: retryCount * 2));
        }
      }

      // Add the new product to the list with the correct ID
      if (docRef != null) {
        final newProduct = product.copyWith(id: docRef.id);
        productsServices.add(newProduct);
        print("✅ Product added to local list with ID: ${docRef.id}");

        // Verify the document was actually saved
        try {
          final savedDoc = await docRef.get();
          if (savedDoc.exists) {
            print("✅ Document verified in Firestore");
            print("📄 Document data: ${savedDoc.data()}");
            print("🔍 Document path: ${savedDoc.reference.path}");
          } else {
            print("❌ Document not found in Firestore");
          }
        } catch (e) {
          print("❌ Error verifying document: $e");
        }
      } else {
        throw Exception("Failed to get document reference");
      }

      clearForm();
      Get.snackbar('Success', 'Product added successfully!');
      print("✅ Product added with ID: ${docRef.id}");

      // Refresh AI Assistant's knowledge data
      try {
        Get.find<AIAssistantController>().refreshKnowledgeData();
      } catch (e) {
        print('⚠️ Error refreshing AI knowledge: $e');
      }
    } catch (e) {
      print('❌ Error adding product: $e');
      print('❌ Error type: ${e.runtimeType}');
      print('❌ Error details: ${e.toString()}');

      if (e.toString().contains('permission')) {
        Get.snackbar('Permission Error',
            'You don\'t have permission to save products. Please check your Firebase rules.');
      } else if (e.toString().contains('network')) {
        Get.snackbar('Network Error',
            'Please check your internet connection and try again.');
      } else {
        Get.snackbar('Error', 'Failed to add product: $e');
      }
    } finally {
      isSaving.value = false;
    }
  }

  Future<void> updateProductService(String productId) async {
    if (!_validateForm()) return;

    // Validate product ID
    if (productId.isEmpty) {
      print("❌ Cannot update product: Empty product ID");
      Get.snackbar('Error', 'Cannot update product: Invalid product ID');
      return;
    }

    try {
      isSaving.value = true;
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        Get.snackbar('Error', 'User not authenticated');
        return;
      }

      // Upload new images to Firebase Storage if any
      List<String> uploadedImageUrls = [];
      if (images.isNotEmpty) {
        print('📤 Uploading ${images.length} images to Firebase Storage for update...');
        uploadedImageUrls = await _storageService.uploadImagesFromPaths(images.toList());
        print('✅ Uploaded ${uploadedImageUrls.length} images successfully');
      }

      final updatedData = {
        'name': nameCtrl.text.trim(),
        'description': descriptionCtrl.text.trim(),
        'price': priceCtrl.text.trim(),
        'category': '',
        'features': '',
        'updatedAt': FieldValue.serverTimestamp(),
        'images': uploadedImageUrls,
        'selectedImage': uploadedImageUrls.isNotEmpty
            ? uploadedImageUrls.first
            : null,
      };

      print("📤 Updating product $productId with data: $updatedData");

      await _firestore
          .collection('products_services')
          .doc(productId)
          .update(updatedData);

      // Update the product in the list
      final index = productsServices.indexWhere((p) => p.id == productId);
      if (index != -1) {
        final updatedProduct = productsServices[index].copyWith(
          name: nameCtrl.text.trim(),
          description: descriptionCtrl.text.trim(),
          price: priceCtrl.text.trim(),
          category: '',
          features: '',
          updatedAt: DateTime.now(),
          selectedImage: selectedImage.value,
        );
        productsServices[index] = updatedProduct;
      }

      clearForm();
      isEditing.value = false;
      editingProductId.value = '';
      Get.snackbar('Success', 'Product updated successfully!');
      print("✅ Product updated: $productId");

      // Refresh AI Assistant's knowledge data
      try {
        Get.find<AIAssistantController>().refreshKnowledgeData();
      } catch (e) {
        print('⚠️ Error refreshing AI knowledge: $e');
      }
    } catch (e) {
      print('❌ Error updating product: $e');
      Get.snackbar('Error', 'Failed to update product');
    } finally {
      isSaving.value = false;
    }
  }

  Future<void> deleteProductService(String productId) async {
    try {
      // Validate product ID
      if (productId.isEmpty) {
        print("❌ Cannot delete product: Empty product ID");
        Get.snackbar('Error', 'Cannot delete product: Invalid product ID');
        return;
      }

      print("🗑 Deleting product: $productId");
      
      // Check if product exists in Firestore first
      final docRef = _firestore.collection('products_services').doc(productId);
      final docSnapshot = await docRef.get();
      
      if (!docSnapshot.exists) {
        print("⚠️ Product not found in Firestore, removing from local list only");
        productsServices.removeWhere((p) => p.id == productId);
        Get.snackbar('Success', 'Product removed from local list');
        return;
      }

      // Delete from Firestore
      await docRef.delete();
      
      // Remove from local list
      productsServices.removeWhere((p) => p.id == productId);
      Get.snackbar('Success', 'Product deleted successfully!');
      print("✅ Product deleted: $productId");

      // Refresh AI Assistant's knowledge data
      try {
        Get.find<AIAssistantController>().refreshKnowledgeData();
      } catch (e) {
        print('⚠️ Error refreshing AI knowledge: $e');
      }
    } catch (e) {
      print('❌ Error deleting product: $e');
      Get.snackbar('Error', 'Failed to delete product: ${e.toString()}');
    }
  }

  void loadForEdit(ProductServiceModel product) async {
    // Validate product ID before proceeding
    if (product.id.isEmpty) {
      print("❌ Cannot edit product: Empty product ID");
      Get.snackbar('Error', 'Cannot edit product: Invalid product ID');
      return;
    }

    nameCtrl.text = product.name;
    descriptionCtrl.text = product.description;
    priceCtrl.text = product.price;

    selectedImage.value = product.selectedImage ?? '';
    images.clear();

    // Try to load images array from Firestore (safe even if not present)
    try {
      if (product.id.isNotEmpty) {
        final snap = await _firestore
            .collection('products_services')
            .doc(product.id)
            .get();
        final data = snap.data();
        if (data != null && data['images'] is List) {
          images.assignAll((data['images'] as List).whereType<String>());
        } else if (product.selectedImage != null &&
            product.selectedImage!.isNotEmpty) {
          // fallback: seed list with legacy single image
          images.assignAll([product.selectedImage!]);
        }
      }
    } catch (e) {
      print("⚠️ Error loading product images: $e");
      // fallback, no crash
      if (product.selectedImage != null && product.selectedImage!.isNotEmpty) {
        images.assignAll([product.selectedImage!]);
      }
    }

    isEditing.value = true;
    editingProductId.value = product.id;
    print(
        "✏️ Loaded product for edit: ${product.toMap()} | images: ${images.length}");
  }

  // Method to handle save/update based on editing state
  Future<void> saveOrUpdateProduct() async {
    if (isEditing.value) {
      await updateProductService(editingProductId.value);
    } else {
      await saveAllProducts();
    }
  }

  void clearForm() {
    nameCtrl.clear();
    descriptionCtrl.clear();
    priceCtrl.clear();
    selectedImage.value = '';
    images.clear();

    // Clear errors
    nameError.value = '';
    descriptionError.value = '';
    priceError.value = '';

    print("🧹 Form cleared");
  }

  // Method to manually refresh products list
  Future<void> refreshProducts() async {
    print("🔄 Manually refreshing products list...");
    await loadProductsServices();
  }

  Future<void> saveAllProducts() async {
    if (!_validateForm()) {
      print("❌ Form validation failed - cannot save");
      Get.snackbar('Error', 'Please fill all required fields');
      return;
    }

    try {
      isSaving.value = true;
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        Get.snackbar('Error', 'User not authenticated');
        return;
      }

      print('🔍 Starting direct save process...');
      print('🔍 Form data validation: ${_validateForm()}');

      // Create product from current form data
      final product = ProductServiceModel(
        id: '',
        // Will be set by Firestore
        name: nameCtrl.text.trim(),
        description: descriptionCtrl.text.trim(),
        price: priceCtrl.text.trim(),
        category: '',
        features: '',
        userId: user.uid,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        selectedImage:
            selectedImage.value.isNotEmpty ? selectedImage.value : null,
      );

      print("📤 Saving product to Firestore: ${product.toMap()}");
      print("🔍 User ID: ${user.uid}");
      print("🔍 Collection: products_services");

      // Upload images to Firebase Storage first
      List<String> uploadedImageUrls = [];
      if (images.isNotEmpty) {
        print('📤 Uploading ${images.length} images to Firebase Storage...');
        uploadedImageUrls = await _storageService.uploadImagesFromPaths(images.toList());
        print('✅ Uploaded ${uploadedImageUrls.length} images successfully');
      }

      // Save directly to Firestore with Firebase Storage URLs
      final payload = product.toMap()
        ..['images'] = uploadedImageUrls
        ..['selectedImage'] = uploadedImageUrls.isNotEmpty
            ? uploadedImageUrls.first
            : null;

      final docRef = await _firestore
          .collection('products_services')
          .add(payload)
          .timeout(const Duration(seconds: 30));

      print("✅ Product saved successfully with ID: ${docRef.id}");

      // Verify the document was actually saved
      try {
        final savedDoc = await docRef.get();
        if (savedDoc.exists) {
          print("✅ Document verified in Firestore");
          print("📄 Document data: ${savedDoc.data()}");
          print("🔍 Document path: ${savedDoc.reference.path}");
        } else {
          print("❌ Document not found in Firestore");
        }
      } catch (e) {
        print("❌ Error verifying document: $e");
      }

      // Add the new product to the local list immediately
      final newProduct = product.copyWith(id: docRef.id);
      productsServices.add(newProduct);
      print("✅ Product added to local list: ${newProduct.name} (ID: ${newProduct.id})");

      // Clear the form after successful save
      clearForm();

      // Refresh the products list from Firestore to ensure consistency
      await loadProductsServices();

      // Force a UI update
      productsServices.refresh();
      print("🔄 Forced UI refresh after save");

      Get.snackbar('Success', 'Product saved successfully!');
      print("✅ Product saved to Firestore with ID: ${docRef.id}");

      // Refresh AI Assistant's knowledge data
      try {
        Get.find<AIAssistantController>().refreshKnowledgeData();
      } catch (e) {
        print('⚠️ Error refreshing AI knowledge: $e');
      }
    } catch (e) {
      print('❌ Error saving product: $e');
      print('❌ Error type: ${e.runtimeType}');
      print('❌ Error details: ${e.toString()}');

      if (e.toString().contains('permission')) {
        Get.snackbar('Permission Error',
            'You don\'t have permission to save products. Please check your Firebase rules.');
      } else if (e.toString().contains('network')) {
        Get.snackbar('Network Error',
            'Please check your internet connection and try again.');
      } else {
        Get.snackbar('Error', 'Failed to save product: $e');
      }
    } finally {
      isSaving.value = false;
    }
  }

  // Validation methods
  bool _validateForm() {
    bool isValid = true;

    // Required fields
    if (nameCtrl.text.trim().isEmpty) {
      nameError.value = 'Name is required';
      isValid = false;
    } else {
      nameError.value = '';
    }

    if (descriptionCtrl.text.trim().isEmpty) {
      descriptionError.value = 'Description is required';
      isValid = false;
    } else {
      descriptionError.value = '';
    }

    if (priceCtrl.text.trim().isEmpty) {
      priceError.value = 'Price is required';
      isValid = false;
    } else {
      priceError.value = '';
    }

    print("✅ Form validation result: $isValid");
    return isValid;
  }

  void validateName(String value) {
    if (value.trim().isEmpty) {
      nameError.value = 'Name is required';
    } else {
      nameError.value = '';
    }
  }

  void validateDescription(String value) {
    if (value.trim().isEmpty) {
      descriptionError.value = 'Description is required';
    } else {
      descriptionError.value = '';
    }
  }

  void validatePrice(String value) {
    if (value.trim().isEmpty) {
      priceError.value = 'Price is required';
    } else {
      priceError.value = '';
    }
  }

  void addImagePath(String path) {
    if (path.isNotEmpty) images.add(path);
  }

  void removeImageAt(int index) {
    if (index >= 0 && index < images.length) images.removeAt(index);
  }

  void clearImages() => images.clear();

  Future<void> testFirestoreConnection() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        print('❌ No authenticated user found');
        Get.snackbar('Error', 'No authenticated user found');
        return;
      }

      print('🔍 Testing Firestore connection...');
      print('🔍 User ID: ${user.uid}');

      // Test 1: Simple document creation with timeout
      final testData = {
        'test': true,
        'userId': user.uid,
        'timestamp': DateTime.now().toIso8601String(),
      };

      print('📝 Creating test document...');
      final testDoc = await _firestore
          .collection('test')
          .add(testData)
          .timeout(const Duration(seconds: 30));
      print('✅ Test document created: ${testDoc.id}');

      // Test 2: Try to create a product document
      final testProduct = {
        'name': 'Test Product',
        'description': 'Test Description',
        'price': '0.00',
        'category': 'Test',
        'features': 'Test Features',
        'userId': user.uid,
        'createdAt': DateTime.now().toIso8601String(),
        'updatedAt': DateTime.now().toIso8601String(),
        'selectedImage': '',
      };

      print('📝 Creating test product...');
      final productDoc = await _firestore
          .collection('products_services')
          .add(testProduct)
          .timeout(const Duration(seconds: 30));
      print('✅ Test product created: ${productDoc.id}');

      // Test 3: Verify the document exists
      final docSnapshot = await productDoc.get();
      if (docSnapshot.exists) {
        print('✅ Document verified in Firestore');
        print('📄 Document data: ${docSnapshot.data()}');
      } else {
        print('❌ Document not found in Firestore');
      }

      // Clean up test data
      await testDoc.delete();
      await productDoc.delete();
      print('🧹 Test data cleaned up');

      print('🎉 All Firestore tests passed!');
      Get.snackbar('Success', 'Firestore connection test passed!');
    } catch (e) {
      print('❌ Firestore test failed: $e');
      print('❌ Error type: ${e.runtimeType}');
      print('❌ Error details: ${e.toString()}');

      if (e.toString().contains('timeout')) {
        Get.snackbar('Error',
            'Firestore connection timeout. Check your internet connection.');
      } else if (e.toString().contains('permission')) {
        Get.snackbar('Error', 'Permission denied. Check your Firestore rules.');
      } else {
        Get.snackbar('Error', 'Firestore test failed: $e');
      }
    }
  }
}
