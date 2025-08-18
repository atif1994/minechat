import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:image_picker/image_picker.dart';
import 'package:minechat/controller/product_controller/product_controller.dart';
import 'package:minechat/core/constants/app_colors/app_colors.dart';
import 'package:minechat/core/utils/helpers/app_spacing/app_spacing.dart';
import 'package:minechat/core/widgets/signUp/signUp_textfield.dart';
import 'package:minechat/view/screens/setup/ai_testing_screen.dart';

import '../../../core/constants/app_assets/app_assets.dart';
import '../../../model/data/product_model.dart';

class ProductsServicesScreen extends StatelessWidget {
  const ProductsServicesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(ProductController());

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

            // Products List
            Obx(() => Column(
              children: controller.products.map((product) => _buildProductCard(product, controller, context)).toList(),
            )),

            // Add More Button
            Container(
              width: double.infinity,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.red[400]!),
                borderRadius: BorderRadius.circular(12),
              ),
              child: TextButton.icon(
                onPressed: () => controller.addNewProduct(),
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

            // Action Buttons
            _buildActionButtons(controller, context),
          ],
        ),
      ),
    );
  }

  Widget _buildProductCard(ProductModel product, ProductController controller, BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey[300]!),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          SignupTextField(
            label: 'Name',
            hintText: 'Enter Name',
            prefixIcon: AppAssets.signupIconEmail,
            controller: product.nameCtrl,
            errorText: product.nameError,
            onChanged: (val) => product.nameError.value = controller.validateProductName(val) ? '' : 'Product name is required',
          ),
          AppSpacing.vertical(context, 0.01),
          SignupTextField(
            label: 'Description',
            hintText: 'Enter Description',
            prefixIcon: AppAssets.signupIconEmail,
            controller: product.descriptionCtrl,
            errorText: product.descriptionError,
            onChanged: (val) => product.descriptionError.value = controller.validateProductDescription(val) ? '' : 'Description is required',
          ),
          AppSpacing.vertical(context, 0.01),
          SignupTextField(
            label: 'Price',
            hintText: 'Enter Price',
            prefixIcon: AppAssets.signupIconEmail,
            controller: product.priceCtrl,
            errorText: product.priceError,
            onChanged: (val) => product.priceError.value = controller.validateProductPrice(val) ? '' : 'Price is required',
          ),
          AppSpacing.vertical(context, 0.01),
          _buildImageUploadSection(product),
          AppSpacing.vertical(context, 0.01),
          Row(
            children: [
              Expanded(
                child: TextButton.icon(
                  onPressed: () => controller.removeProduct(product),
                  icon: Icon(Icons.delete, color: Colors.red),
                  label: Text('Remove', style: TextStyle(color: Colors.red)),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildImageUploadSection(ProductModel product) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Upload picture',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Colors.grey[800],
          ),
        ),
        const SizedBox(height: 8),
        GestureDetector(
          onTap: () {
            _showImageUploadOptions(product);
          },
          child: Container(
            width: double.infinity,
            height: 100,
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey[300]!, style: BorderStyle.solid),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.image,
                  size: 30,
                  color: Colors.grey[400],
                ),
                const SizedBox(height: 8),
                Obx(() => Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.red[400],
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Text(
                    product.selectedImage.value.isNotEmpty
                        ? product.selectedImage.value
                        : 'Choose photo',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                      fontSize: 12,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                )),
              ],
            ),
          ),
        ),
      ],
    );
  }

  void _showImageUploadOptions(ProductModel product) {
    showModalBottomSheet(
      context: Get.context!,
      builder: (BuildContext context) {
        return Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Choose Image Source',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey[800],
                ),
              ),
              const SizedBox(height: 20),
              ListTile(
                leading: Icon(Icons.photo_library, color: Colors.blue),
                title: Text('Gallery'),
                onTap: () {
                  Navigator.pop(context);
                  _selectImageFromGallery(product);
                },
              ),
              ListTile(
                leading: Icon(Icons.camera_alt, color: Colors.green),
                title: Text('Camera'),
                onTap: () {
                  Navigator.pop(context);
                  _captureImageFromCamera(product);
                },
              ),
              const SizedBox(height: 10),
            ],
          ),
        );
      },
    );
  }

  void _selectImageFromGallery(ProductModel product) async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );

      if (image != null) {
        product.selectedImage.value = image.name;
        Get.snackbar(
          'Success',
          'Image selected for product',
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to select image: $e',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  void _captureImageFromCamera(ProductModel product) async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(
        source: ImageSource.camera,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );

      if (image != null) {
        product.selectedImage.value = image.name;
        Get.snackbar(
          'Success',
          'Image captured for product',
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to capture image: $e',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  Widget _buildActionButtons(ProductController controller, BuildContext context) {
    return Row(
      children: [
        // Save Button
        Expanded(
          child: Container(
            height: 48,
            decoration: BoxDecoration(
              border: Border.all(color: AppColors.primary),
              borderRadius: BorderRadius.circular(12),
            ),
            child: TextButton(
              onPressed: () {
                if (controller.validateAllProducts()) {
                  Get.snackbar(
                    'Success',
                    'Products saved successfully!',
                    backgroundColor: Colors.green,
                    colorText: Colors.white,
                  );
                } else {
                  Get.snackbar(
                    'Validation Error',
                    'Please fill all required fields',
                    backgroundColor: Colors.red,
                    colorText: Colors.white,
                  );
                }
              },
              child: const Text(
                'Save',
                style: TextStyle(
                  color: AppColors.primary,
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
            height: 48,
            decoration: BoxDecoration(
              color: AppColors.primary,
              borderRadius: BorderRadius.circular(12),
            ),
            child: TextButton.icon(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const AITestingScreen()),
                );
              },
              icon: const Icon(
                Icons.smart_toy,
                color: Colors.white,
                size: 20,
              ),
              label: const Text(
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
    );
  }
}
