import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:minechat/model/data/product_model.dart';

class ProductController extends GetxController {
  var products = <ProductModel>[].obs;
  var isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    // Add initial product if empty
    if (products.isEmpty) {
      addNewProduct();
    }
  }

  void addNewProduct() {
    final newProduct = ProductModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      nameCtrl: TextEditingController(),
      descriptionCtrl: TextEditingController(),
      priceCtrl: TextEditingController(),
      nameError: ''.obs,
      descriptionError: ''.obs,
      priceError: ''.obs,
      selectedImage: ''.obs,
    );
    products.add(newProduct);
  }

  void removeProduct(ProductModel product) {
    products.remove(product);
    // Ensure at least one product remains
    if (products.isEmpty) {
      addNewProduct();
    }
  }

  bool validateProductName(String value) {
    if (value.trim().isEmpty) {
      return false;
    }
    return true;
  }

  bool validateProductDescription(String value) {
    if (value.trim().isEmpty) {
      return false;
    }
    return true;
  }

  bool validateProductPrice(String value) {
    if (value.trim().isEmpty) {
      return false;
    }
    return true;
  }

  bool validateAllProducts() {
    bool isValid = true;
    
    for (var product in products) {
      if (!validateProductName(product.name)) {
        product.nameError.value = 'Product name is required';
        isValid = false;
      } else {
        product.nameError.value = '';
      }
      
      if (!validateProductDescription(product.description)) {
        product.descriptionError.value = 'Description is required';
        isValid = false;
      } else {
        product.descriptionError.value = '';
      }
      
      if (!validateProductPrice(product.price)) {
        product.priceError.value = 'Price is required';
        isValid = false;
      } else {
        product.priceError.value = '';
      }
    }
    
    return isValid;
  }

  @override
  void onClose() {
    // Dispose all controllers
    for (var product in products) {
      product.nameCtrl.dispose();
      product.descriptionCtrl.dispose();
      product.priceCtrl.dispose();
    }
    super.onClose();
  }
}
