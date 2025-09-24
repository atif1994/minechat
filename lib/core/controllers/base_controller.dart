import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';

/// Base controller with common functionality
abstract class BaseController extends GetxController {
  // Common loading states
  final RxBool isLoading = false.obs;
  final RxBool isSaving = false.obs;
  final RxBool isUploading = false.obs;
  
  // Common error handling
  final RxString errorMessage = ''.obs;
  final RxBool hasError = false.obs;

  @override
  void onInit() {
    super.onInit();
    initializeController();
  }

  @override
  void onClose() {
    disposeControllers();
    super.onClose();
  }

  /// Initialize controller - override in child classes
  void initializeController() {}

  /// Get current user ID
  String getCurrentUserId() {
    return FirebaseAuth.instance.currentUser?.uid ?? '';
  }

  /// Set loading state
  void setLoading(bool loading) {
    isLoading.value = loading;
  }

  /// Set saving state
  void setSaving(bool saving) {
    isSaving.value = saving;
  }

  /// Set uploading state
  void setUploading(bool uploading) {
    isUploading.value = uploading;
  }

  /// Set error state
  void setError(String error) {
    errorMessage.value = error;
    hasError.value = true;
  }

  /// Clear error state
  void clearError() {
    errorMessage.value = '';
    hasError.value = false;
  }

  /// Show error snackbar
  void showError(String message) {
    Get.snackbar(
      'Error',
      message,
      snackPosition: SnackPosition.TOP,
      backgroundColor: Colors.red,
      colorText: Colors.white,
      duration: const Duration(seconds: 3),
    );
  }

  /// Show success snackbar
  void showSuccess(String message) {
    Get.snackbar(
      'Success',
      message,
      snackPosition: SnackPosition.TOP,
      backgroundColor: Colors.green,
      colorText: Colors.white,
      duration: const Duration(seconds: 2),
    );
  }

  /// Show info snackbar
  void showInfo(String message) {
    Get.snackbar(
      'Info',
      message,
      snackPosition: SnackPosition.TOP,
      backgroundColor: Colors.blue,
      colorText: Colors.white,
      duration: const Duration(seconds: 2),
    );
  }

  /// Dispose text controllers - override in child classes
  void disposeControllers() {}

  /// Validate email
  bool isValidEmail(String email) {
    return GetUtils.isEmail(email);
  }

  /// Validate phone number
  bool isValidPhone(String phone) {
    return GetUtils.isPhoneNumber(phone);
  }

  /// Validate required field
  bool isRequired(String value) {
    return value.trim().isNotEmpty;
  }

  /// Validate minimum length
  bool hasMinLength(String value, int minLength) {
    return value.trim().length >= minLength;
  }

  /// Validate maximum length
  bool hasMaxLength(String value, int maxLength) {
    return value.trim().length <= maxLength;
  }
}

/// Base form controller with validation
abstract class BaseFormController extends BaseController {
  // Form validation state
  final RxBool isFormValid = false.obs;
  
  /// Validate form - override in child classes
  bool validateForm() {
    return isFormValid.value;
  }

  /// Reset form - override in child classes
  void resetForm() {
    clearError();
    isFormValid.value = false;
  }

  /// Submit form - override in child classes
  Future<void> submitForm() async {
    if (!validateForm()) {
      showError('Please fill in all required fields');
      return;
    }
    
    setSaving(true);
    try {
      await performSubmit();
    } catch (e) {
      showError('Failed to submit: ${e.toString()}');
    } finally {
      setSaving(false);
    }
  }

  /// Perform actual submit - override in child classes
  Future<void> performSubmit() async {}
}

/// Base list controller for managing lists
abstract class BaseListController<T> extends BaseController {
  final RxList<T> items = <T>[].obs;
  final RxString searchQuery = ''.obs;
  final RxBool isRefreshing = false.obs;

  /// Load items - override in child classes
  Future<void> loadItems() async {
    setLoading(true);
    try {
      await performLoadItems();
    } catch (e) {
      showError('Failed to load items: ${e.toString()}');
    } finally {
      setLoading(false);
    }
  }

  /// Perform actual loading - override in child classes
  Future<void> performLoadItems() async {}

  /// Refresh items
  Future<void> refreshItems() async {
    isRefreshing.value = true;
    await loadItems();
    isRefreshing.value = false;
  }

  /// Search items
  void searchItems(String query) {
    searchQuery.value = query;
    // Override in child classes to implement search logic
  }

  /// Add item
  void addItem(T item) {
    items.add(item);
  }

  /// Remove item
  void removeItem(T item) {
    items.remove(item);
  }

  /// Update item
  void updateItem(T oldItem, T newItem) {
    final index = items.indexOf(oldItem);
    if (index != -1) {
      items[index] = newItem;
    }
  }

  /// Clear all items
  void clearItems() {
    items.clear();
  }
}
