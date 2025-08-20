import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:minechat/controller/products_services_controller/products_services_controller.dart';
import 'package:minechat/core/constants/app_colors/app_colors.dart';
import 'package:minechat/core/utils/helpers/app_spacing/app_spacing.dart';
import 'package:minechat/core/widgets/signUp/signUp_textfield.dart';
import 'package:minechat/view/screens/setup/products_services_ai_testing_screen.dart';

import '../../../core/constants/app_assets/app_assets.dart';
import '../../../model/data/product_service_model.dart';
import 'dart:io';

class ProductsServicesScreen extends StatelessWidget {
  final ProductsServicesController controller;
  
  const ProductsServicesScreen({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        padding: AppSpacing.all(context, factor: 2),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 40),

            // Header
            Text(
              'Products and Services',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.grey[800],
              ),
            ),
            AppSpacing.vertical(context, 0.02),

            // Name Field
            SignupTextField(
              label: 'Name',
              hintText: 'Enter Name',
              prefixIcon: AppAssets.signupIconEmail,
              controller: controller.nameCtrl,
              errorText: controller.nameError,
              onChanged: (val) => controller.validateName(val),
            ),
            AppSpacing.vertical(context, 0.01),
            
            // Description Field
            SignupTextField(
              label: 'Description',
              hintText: 'Enter Description',
              prefixIcon: AppAssets.signupIconEmail,
              controller: controller.descriptionCtrl,
              errorText: controller.descriptionError,
              onChanged: (val) => controller.validateDescription(val),
            ),
            AppSpacing.vertical(context, 0.01),
            
            // Price Field
            SignupTextField(
              label: 'Price',
              hintText: 'Enter Price',
              prefixIcon: AppAssets.signupIconEmail,
              controller: controller.priceCtrl,
              errorText: controller.priceError,
              onChanged: (val) => controller.validatePrice(val),
            ),
            AppSpacing.vertical(context, 0.02),

            // Image Upload Section
            _buildImageUploadSection(context),
            AppSpacing.vertical(context, 0.02),

            // Add More Button
            Container(
              width: double.infinity,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.red[400]!),
                borderRadius: BorderRadius.circular(12),
              ),
              child: TextButton.icon(
                onPressed: () => controller.addProductService(),
                icon: Icon(Icons.add, color: Colors.red[400], size: 20),
                label: Text(
                  'Add More',
                  style: TextStyle(
                    color: Colors.red[400],
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
            AppSpacing.vertical(context, 0.02),

            // Products List
            Obx(() => Column(
              children: controller.productsServices.map((product) => _buildProductCard(product, controller, context)).toList(),
            )),

            // Action Buttons Row
            Row(
              children: [
                // Save Button
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey[400]!),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: TextButton(
                      onPressed: () => controller.saveAllProducts(),
                      child: Text(
                        'Save',
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                
                // Test AI Button
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.purple[400],
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: TextButton.icon(
                      onPressed: () => Get.to(() => ProductsServicesAITestingScreen(productsController: controller)),
                      icon: Icon(Icons.smart_toy, color: Colors.white, size: 20),
                      label: Text(
                        'Test AI',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImageUploadSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Upload picture',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Colors.grey[800],
              ),
            ),
            // Clear button (X icon)
            Obx(() => controller.selectedImage.value.isNotEmpty
              ? GestureDetector(
                  onTap: () => controller.selectedImage.value = '',
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.blue[300]!, style: BorderStyle.solid),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      Icons.close,
                      color: Colors.blue[600],
                      size: 16,
                    ),
                  ),
                )
              : const SizedBox.shrink()
            ),
          ],
        ),
        const SizedBox(height: 8),
        
        // Image Upload Area
        GestureDetector(
          onTap: () => _showImageUploadOptions(context),
          child: Obx(() => Container(
            width: double.infinity,
            height: 120,
            decoration: BoxDecoration(
              border: Border.all(
                color: Colors.red[300]!,
                style: BorderStyle.solid,
                width: 2,
              ),
              borderRadius: BorderRadius.circular(12),
              color: Colors.pink[50],
            ),
            child: controller.selectedImage.value.isNotEmpty
              ? ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: Image.file(
                    File(controller.selectedImage.value),
                    width: double.infinity,
                    height: 120,
                    fit: BoxFit.cover,
                  ),
                )
              : Stack(
                  children: [
                    // Background image icon
                    Center(
                      child: Icon(
                        Icons.landscape,
                        color: Colors.grey[400],
                        size: 60,
                      ),
                    ),
                    // Upload arrow icon
                    Positioned(
                      bottom: 8,
                      right: 8,
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: Colors.red[400],
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          Icons.keyboard_arrow_up,
                          color: Colors.white,
                          size: 16,
                        ),
                      ),
                    ),
                  ],
                ),
          )),
        ),
        const SizedBox(height: 8),
        
        // Choose photo button
        Container(
          width: double.infinity,
          decoration: BoxDecoration(
            color: Colors.purple[600],
            borderRadius: BorderRadius.circular(12),
          ),
          child: TextButton(
            onPressed: () => _showImageUploadOptions(context),
            child: Text(
              'Choose photo',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildProductCard(ProductServiceModel product, ProductsServicesController controller, BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey[300]!),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            product.name,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.grey[800],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            product.description,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Text(
                'Price: ${product.price}',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Colors.green[600],
                ),
              ),
              const SizedBox(width: 16),
              Text(
                'Category: ${product.category}',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          
          // Action Buttons
          Row(
            children: [
              Expanded(
                child: TextButton.icon(
                  onPressed: () => controller.loadForEdit(product),
                  icon: Icon(Icons.edit, color: Colors.blue, size: 16),
                  label: Text('Edit', style: TextStyle(color: Colors.blue, fontSize: 12)),
                ),
              ),
              Expanded(
                child: TextButton.icon(
                  onPressed: () => controller.deleteProductService(product.id),
                  icon: Icon(Icons.delete, color: Colors.red, size: 16),
                  label: Text('Remove', style: TextStyle(color: Colors.red, fontSize: 12)),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showImageUploadOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text('Choose from Gallery'),
                onTap: () {
                  Navigator.pop(context);
                  _selectImageFromGallery();
                },
              ),
              ListTile(
                leading: const Icon(Icons.camera_alt),
                title: const Text('Take a Photo'),
                onTap: () {
                  Navigator.pop(context);
                  _captureImageFromCamera();
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _selectImageFromGallery() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);
    
    if (image != null) {
      controller.selectedImage.value = image.path;
      Get.snackbar(
        'Success',
        'Image selected successfully!',
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
    }
  }

  void _captureImageFromCamera() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.camera);
    
    if (image != null) {
      controller.selectedImage.value = image.path;
      Get.snackbar(
        'Success',
        'Image captured successfully!',
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
    }
  }
}
