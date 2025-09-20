import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:minechat/controller/products_services_controller/products_services_controller.dart';
import 'package:minechat/controller/theme_controller/theme_controller.dart';
import 'package:minechat/core/constants/app_colors/app_colors.dart';
import 'package:minechat/core/utils/helpers/app_spacing/app_spacing.dart';
import 'package:minechat/core/utils/helpers/app_styles/app_text_styles.dart';
import 'package:minechat/core/widgets/action_buttons/action_buttons.dart';
import 'package:minechat/core/widgets/form_section/form_section.dart' as CustomForm;
import 'package:minechat/core/widgets/image_upload_section/image_upload_section.dart';
import 'package:minechat/core/widgets/products_grid/products_grid.dart';
import 'package:minechat/model/data/product_service_model.dart';
import 'package:minechat/view/screens/setup/products_services_ai_testing_screen.dart';

class ProductsServicesScreen extends StatefulWidget {
  final ProductsServicesController controller;

  const ProductsServicesScreen({super.key, required this.controller});

  @override
  State<ProductsServicesScreen> createState() => _ProductsServicesScreenState();
}

class _ProductsServicesScreenState extends State<ProductsServicesScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      widget.controller.loadProductsServices();
    });
  }

  Future<void> _pickMultipleFromGallery(void Function(String) onPicked) async {
    final picker = ImagePicker();
    try {
      final files = await picker.pickMultiImage();
      if (files.isNotEmpty) {
        for (final f in files) {
          onPicked(f.path);
        }
        Get.snackbar('Success', 'Images added',
            backgroundColor: Colors.green, colorText: Colors.white);
        return;
      }
    } catch (_) {}
    final single = await picker.pickImage(source: ImageSource.gallery);
    if (single != null) onPicked(single.path);
  }

  @override
  Widget build(BuildContext context) {
    // Always provide a themeController safely
    ThemeController themeController;
    try {
      themeController = Get.find<ThemeController>();
    } catch (_) {
      themeController = Get.put(ThemeController(), permanent: true);
    }
    final isDark = themeController.isDarkMode;

    return Scaffold(
      backgroundColor: isDark ? const Color(0XFF0A0A0A) : const Color(0XFFF4F6FC),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                'Products and Services',
                style: AppTextStyles.bodyText(context).copyWith(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            
            // Scrollable content
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 4),

                    // Your Products Section
                    _buildYourProductsSection(context, isDark),
                    const SizedBox(height: 30),

                    // Add/Edit Product Section
                    _buildAddNewProductSection(context, isDark),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildYourProductsSection(BuildContext context, bool isDark) {
    return Obx(() {
      if (widget.controller.productsServices.isEmpty) {
        return const SizedBox.shrink();
      }
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'Your Products ',
            style: AppTextStyles.bodyText(context).copyWith(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: isDark ? AppColors.white : AppColors.secondary,
            ),
          ),
          AppSpacing.vertical(context, 0.015),
          ProductsGrid(
            products: widget.controller.productsServices,
            isDark: isDark,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            onEdit: (product) => widget.controller.loadForEdit(product),
            onDelete: (product) => _showDeleteConfirmation(context, product),
          ),
        ],
      );
    });
  }

  Widget _buildAddNewProductSection(BuildContext context, bool isDark) {
    return Obx(() {
      final isEditing = widget.controller.isEditing.value;
      return CustomForm.FormSection(
        title: isEditing ? 'Edit Product' : 'Add New Product',
        isDark: isDark,
        fields: [
          CustomForm.CustomFormField.textField(
            label: 'Name',
            hintText: 'Enter Name',
            controller: widget.controller.nameCtrl,
            errorText: widget.controller.nameError.value.isNotEmpty
                ? widget.controller.nameError.value
                : null,
            onChanged: widget.controller.validateName,
          ),
          CustomForm.CustomFormField.textField(
            label: 'Description',
            hintText: 'Enter Description',
            controller: widget.controller.descriptionCtrl,
            errorText: widget.controller.descriptionError.value.isNotEmpty
                ? widget.controller.descriptionError.value
                : null,
            onChanged: widget.controller.validateDescription,
          ),
          CustomForm.CustomFormField.textField(
            label: 'Price',
            hintText: 'Enter Price',
            controller: widget.controller.priceCtrl,
            errorText: widget.controller.priceError.value.isNotEmpty
                ? widget.controller.priceError.value
                : null,
            onChanged: widget.controller.validatePrice,
          ),
          CustomForm.CustomFormField(
            widget: ImageUploadSection(
              images: widget.controller.images,
              isDark: isDark,
              onAddImage: widget.controller.addImagePath,
              onRemoveImage: widget.controller.removeImageAt,
              onClearImages: widget.controller.clearImages,
            ),
          ),
        ],
        actionButtons: [
          ActionButtons(
            key: ValueKey('action_buttons_${isEditing ? 'edit' : 'add'}'),
            primaryLabel: isEditing ? 'Update' : 'Save',
            secondaryLabel: isEditing ? null : 'Test AI',
            isDark: isDark,
            isEditing: isEditing,
            isLoading: widget.controller.isSaving.value,
            onPrimary: widget.controller.saveOrUpdateProduct,
            onSecondary: isEditing
                ? () {
              widget.controller.clearForm();
              widget.controller.isEditing.value = false;
              widget.controller.editingProductId.value = '';
            }
                : () => Get.to(() =>
                ProductsServicesAITestingScreen(productsController: widget.controller)),
          ),
        ],
      );
    });
  }

  void _showDeleteConfirmation(BuildContext context, ProductServiceModel product) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Delete Product'),
          content: Text('Are you sure you want to delete "${product.name}"?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                widget.controller.deleteProductService(product.id);
              },
              child: const Text('Delete', style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
  }
}
