import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:minechat/model/data/product_service_model.dart';
import 'package:minechat/controller/ai_assistant_controller/ai_assistant_controller.dart';

class ProductsServicesController extends GetxController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Loading States
  var isLoading = false.obs;
  var isSaving = false.obs;

  // Product/Service Controllers
  final nameCtrl = TextEditingController();
  final descriptionCtrl = TextEditingController();
  final priceCtrl = TextEditingController();
  final categoryCtrl = TextEditingController();
  final featuresCtrl = TextEditingController();

  // Error Messages
  var nameError = ''.obs;
  var descriptionError = ''.obs;
  var priceError = ''.obs;
  var categoryError = ''.obs;
  var featuresError = ''.obs;

  // Products List
  var productsServices = <ProductServiceModel>[].obs;
  
  // Selected Image for upload
  var selectedImage = ''.obs;

  // Editing state
  var isEditing = false.obs;
  var editingProductId = ''.obs;

  @override
  void onInit() {
    super.onInit();
    loadProductsServices();
  }

  @override
  void onClose() {
    nameCtrl.dispose();
    descriptionCtrl.dispose();
    priceCtrl.dispose();
    categoryCtrl.dispose();
    featuresCtrl.dispose();
    super.onClose();
  }

  Future<void> loadProductsServices() async {
    try {
      isLoading.value = true;
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return;

      final snapshot = await _firestore
          .collection('products_services')
          .where('userId', isEqualTo: user.uid)
          .get();

      productsServices.value = snapshot.docs
          .map((doc) => ProductServiceModel.fromMap({
                'id': doc.id,
                ...doc.data(),
              }))
          .toList();
    } catch (e) {
      print('Error loading products: $e');
      Get.snackbar('Error', 'Failed to load products');
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

      final product = ProductServiceModel(
        id: '', // Will be set by Firestore
        name: nameCtrl.text.trim(),
        description: descriptionCtrl.text.trim(),
        price: priceCtrl.text.trim(),
        category: categoryCtrl.text.trim(),
        features: featuresCtrl.text.trim(),
        userId: user.uid,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        selectedImage: selectedImage,
      );

      final docRef = await _firestore.collection('products_services').add(product.toMap());
      
      // Add the new product to the list with the correct ID
      final newProduct = product.copyWith(id: docRef.id);
      productsServices.add(newProduct);

      _clearForm();
      Get.snackbar('Success', 'Product added successfully!');
      // Refresh AI Assistant's knowledge data
      try {
        Get.find<AIAssistantController>().refreshKnowledgeData();
      } catch (e) {
        print('Error refreshing AI knowledge: $e');
      }
    } catch (e) {
      print('Error adding product: $e');
      Get.snackbar('Error', 'Failed to add product');
    } finally {
      isSaving.value = false;
    }
  }

  Future<void> updateProductService(String productId) async {
    if (!_validateForm()) return;

    try {
      isSaving.value = true;
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        Get.snackbar('Error', 'User not authenticated');
        return;
      }

      final updatedData = {
        'name': nameCtrl.text.trim(),
        'description': descriptionCtrl.text.trim(),
        'price': priceCtrl.text.trim(),
        'category': categoryCtrl.text.trim(),
        'features': featuresCtrl.text.trim(),
        'updatedAt': DateTime.now().toIso8601String(),
      };

      await _firestore.collection('products_services').doc(productId).update(updatedData);
      
      // Update the product in the list
      final index = productsServices.indexWhere((p) => p.id == productId);
      if (index != -1) {
        final updatedProduct = productsServices[index].copyWith(
          name: nameCtrl.text.trim(),
          description: descriptionCtrl.text.trim(),
          price: priceCtrl.text.trim(),
          category: categoryCtrl.text.trim(),
          features: featuresCtrl.text.trim(),
          updatedAt: DateTime.now(),
        );
        productsServices[index] = updatedProduct;
      }

      _clearForm();
      isEditing.value = false;
      editingProductId.value = '';
      Get.snackbar('Success', 'Product updated successfully!');
      // Refresh AI Assistant's knowledge data
      try {
        Get.find<AIAssistantController>().refreshKnowledgeData();
      } catch (e) {
        print('Error refreshing AI knowledge: $e');
      }
    } catch (e) {
      print('Error updating product: $e');
      Get.snackbar('Error', 'Failed to update product');
    } finally {
      isSaving.value = false;
    }
  }

  Future<void> deleteProductService(String productId) async {
    try {
      await _firestore.collection('products_services').doc(productId).delete();
      productsServices.removeWhere((p) => p.id == productId);
      Get.snackbar('Success', 'Product deleted successfully!');
      // Refresh AI Assistant's knowledge data
      try {
        Get.find<AIAssistantController>().refreshKnowledgeData();
      } catch (e) {
        print('Error refreshing AI knowledge: $e');
      }
    } catch (e) {
      print('Error deleting product: $e');
      Get.snackbar('Error', 'Failed to delete product');
    }
  }

  void loadForEdit(ProductServiceModel product) {
    nameCtrl.text = product.name;
    descriptionCtrl.text = product.description;
    priceCtrl.text = product.price;
    categoryCtrl.text = product.category;
    featuresCtrl.text = product.features;
    selectedImage.value = product.selectedImage?.value ?? '';
    
    isEditing.value = true;
    editingProductId.value = product.id;
  }

  void _clearForm() {
    nameCtrl.clear();
    descriptionCtrl.clear();
    priceCtrl.clear();
    categoryCtrl.clear();
    featuresCtrl.clear();
    selectedImage.value = '';
    
    // Clear errors
    nameError.value = '';
    descriptionError.value = '';
    priceError.value = '';
    categoryError.value = '';
    featuresError.value = '';
  }

  Future<void> saveAllProducts() async {
    try {
      isSaving.value = true;
      Get.snackbar('Success', 'All products saved successfully!');
    } catch (e) {
      print('Error saving products: $e');
      Get.snackbar('Error', 'Failed to save products');
    } finally {
      isSaving.value = false;
    }
  }

  // Validation methods
  bool _validateForm() {
    bool isValid = true;

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

    if (categoryCtrl.text.trim().isEmpty) {
      categoryError.value = 'Category is required';
      isValid = false;
    } else {
      categoryError.value = '';
    }

    if (featuresCtrl.text.trim().isEmpty) {
      featuresError.value = 'Features are required';
      isValid = false;
    } else {
      featuresError.value = '';
    }

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

  void validateCategory(String value) {
    if (value.trim().isEmpty) {
      categoryError.value = 'Category is required';
    } else {
      categoryError.value = '';
    }
  }

  void validateFeatures(String value) {
    if (value.trim().isEmpty) {
      featuresError.value = 'Features are required';
    } else {
      featuresError.value = '';
    }
  }
}
