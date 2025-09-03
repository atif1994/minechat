import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:minechat/controller/products_services_controller/products_services_controller.dart';
import 'package:minechat/controller/theme_controller/theme_controller.dart';
import 'package:minechat/core/constants/app_colors/app_colors.dart';
import 'package:minechat/core/utils/extensions/app_gradient/app_gradient_extension.dart';
import 'package:minechat/core/utils/helpers/app_responsive/app_responsive.dart';
import 'package:minechat/core/utils/helpers/app_spacing/app_spacing.dart';
import 'package:minechat/core/utils/helpers/app_styles/app_text_styles.dart';
import 'package:minechat/core/widgets/signUp/signUp_textfield.dart';
import 'package:minechat/view/screens/setup/products_services_ai_testing_screen.dart';

import '../../../core/constants/app_assets/app_assets.dart';
import 'dart:io';

class ProductsServicesScreen extends StatelessWidget {
  final ProductsServicesController controller;

  const ProductsServicesScreen({super.key, required this.controller});

  Future<void> _pickMultipleFromGallery(void Function(String) onPicked) async {
    final picker = ImagePicker();
    try {
      final files = await picker.pickMultiImage(); // multi-select
      if (files.isNotEmpty) {
        for (final f in files) {
          onPicked(f.path);
        }
        Get.snackbar('Success', 'Images added',
            backgroundColor: Colors.green, colorText: Colors.white);
        return;
      }
    } catch (_) {
      // silently fall back
    }

    // Fallback: single
    final single = await picker.pickImage(source: ImageSource.gallery);
    if (single != null) onPicked(single.path);
  }

  @override
  Widget build(BuildContext context) {
    final themeController = Get.find<ThemeController>();
    final isDark = themeController.isDarkMode;
    return Scaffold(
      backgroundColor: isDark ? Color(0XFF0A0A0A) : Color(0XFFF4F6FC),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Text(
              'Products and Services',
              style: AppTextStyles.bodyText(context).copyWith(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),

            AppSpacing.vertical(context, 0.02),
            // Name Field
            SignupTextField(
              label: 'Name',
              hintText: 'Enter Name',
              controller: controller.nameCtrl,
              errorText: controller.nameError,
              onChanged: (val) => controller.validateName(val),
            ),
            AppSpacing.vertical(context, 0.02),

            // Description Field
            SignupTextField(
              label: 'Description',
              hintText: 'Enter Description',
              controller: controller.descriptionCtrl,
              errorText: controller.descriptionError,
              onChanged: (val) => controller.validateDescription(val),
            ),
            AppSpacing.vertical(context, 0.02),

            // Price Field
            SignupTextField(
              label: 'Price',
              hintText: 'Enter Price',
              controller: controller.priceCtrl,
              errorText: controller.priceError,
              onChanged: (val) => controller.validatePrice(val),
            ),
            AppSpacing.vertical(context, 0.02),

            // Image Upload Section
            _buildImageUploadSection(context),
            AppSpacing.vertical(context, 0.02),

            AppSpacing.vertical(context, 0.02),

            // Action Buttons Row
            Row(
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
                      onPressed: () => controller.saveAllProducts(),
                      child: Text(
                        'Save',
                        style: TextStyle(
                          color: isDark ? AppColors.white : AppColors.primary,
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
                      borderRadius: BorderRadius.circular(12),
                    ).withAppGradient,
                    child: TextButton.icon(
                      onPressed: () => Get.to(() =>
                          ProductsServicesAITestingScreen(
                              productsController: controller)),
                      icon: SvgPicture.asset(
                        "assets/images/icons/icon_setup_test_ai_button.svg",
                        width: 20,
                        height: 20,
                        colorFilter: const ColorFilter.mode(
                            Colors.white, BlendMode.srcIn),
                      ),
                      label: Text(
                        'Test AI',
                        style: const TextStyle(
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
        // Title + Clear button
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Upload picture',
              style: AppTextStyles.bodyText(context).copyWith(
                fontSize: 16,
                fontWeight: FontWeight.w400,
              ),
            ),
            Obx(() => controller.images.isNotEmpty
                ? GestureDetector(
                    onTap: controller.clearImages,
                    child: Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.blue[300]!),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child:
                          Icon(Icons.close, color: Colors.blue[600], size: 16),
                    ),
                  )
                : const SizedBox.shrink()),
          ],
        ),

        const SizedBox(height: 8),

        // If no images → big drop zone; else → grid + inline add tile
        Obx(() => controller.images.isEmpty
            ? _DropZone(
                onChoose: () => _showImageUploadOptions(
                  context,
                  onPicked: controller.addImagePath,
                ),
              )
            : _ImagesGrid(
                images: controller.images,
                onAddMore: () => _showImageUploadOptions(
                  context,
                  onPicked: controller.addImagePath,
                ),
                onRemove: controller.removeImageAt,
              )),

        const SizedBox(height: 12),

        // ALWAYS show this button (matches your screenshot)
        _AddMoreButton(
          onTap: () => _showImageUploadOptions(
            context,
            onPicked: controller.addImagePath,
          ),
        ),
      ],
    );
  }

  void _showImageUploadOptions(BuildContext context,
      {required void Function(String path) onPicked}) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.collections),
                title: const Text('Choose multiple from Gallery'),
                onTap: () async {
                  Navigator.pop(context);
                  await _pickMultipleFromGallery(onPicked);
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text('Choose from Gallery'),
                onTap: () async {
                  Navigator.pop(context);
                  final picker = ImagePicker();
                  final img =
                      await picker.pickImage(source: ImageSource.gallery);
                  if (img != null) onPicked(img.path);
                },
              ),
              ListTile(
                leading: const Icon(Icons.camera_alt),
                title: const Text('Take a Photo'),
                onTap: () async {
                  Navigator.pop(context);
                  final picker = ImagePicker();
                  final img =
                      await picker.pickImage(source: ImageSource.camera);
                  if (img != null) onPicked(img.path);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Future<String?> _pickFromGallery() async {
    final picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);
    if (image == null) return null;
    Get.snackbar('Success', 'Image selected',
        backgroundColor: Colors.green, colorText: Colors.white);
    return image.path;
  }

  Future<String?> _pickFromCamera() async {
    final picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.camera);
    if (image == null) return null;
    Get.snackbar('Success', 'Image captured',
        backgroundColor: Colors.green, colorText: Colors.white);
    return image.path;
  }
}

class _DropZone extends StatelessWidget {
  const _DropZone({required this.onChoose});

  final VoidCallback onChoose;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onChoose,
      child: DottedBorder(
        color: AppColors.primary,
        strokeWidth: 2,
        dashPattern: const [6, 3],
        borderType: BorderType.RRect,
        radius: const Radius.circular(12),
        child: Container(
          width: double.infinity,
          height: 170,
          color: AppColors.primary.withValues(alpha: 0.1),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SvgPicture.asset(
                "assets/images/icons/icon_setup_picture_upload.svg",
                // or your path
                height: 80,
                width: 80,
              ),
              const SizedBox(height: 12),
              Container(
                width: 180,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(30),
                ).withAppGradient,
                child: TextButton(
                  onPressed: onChoose,
                  child: const Text(
                    'Choose photo',
                    style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                        fontSize: 14),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ImagesGrid extends StatelessWidget {
  const _ImagesGrid({
    required this.images,
    required this.onAddMore,
    required this.onRemove,
  });

  final List<String> images;
  final VoidCallback onAddMore;
  final void Function(int index) onRemove;

  @override
  Widget build(BuildContext context) {
    // Grid of existing images + one "Add More" tile at the end
    return GridView.builder(
      itemCount: images.length + 1,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 1.5, // wide tiles to mimic screenshot
      ),
      itemBuilder: (context, index) {
        final isAddTile = index == images.length;
        if (isAddTile) {
          return GestureDetector(
            onTap: onAddMore,
            child: DottedBorder(
              color: AppColors.primary,
              strokeWidth: 2,
              dashPattern: const [6, 3],
              borderType: BorderType.RRect,
              radius: const Radius.circular(12),
              child: Container(
                alignment: Alignment.center,
                color: AppColors.primary.withValues(alpha: 0.1),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.add, color: AppColors.primary),
                    const SizedBox(width: 6),
                    Text(
                      'Add More',
                      style: AppTextStyles.bodyText(context).copyWith(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w400,
                          fontSize: AppResponsive.scaleSize(context, 8)),
                    ),
                  ],
                ),
              ),
            ),
          );
        }

        // Image tile with remove X
        final path = images[index];
        return Stack(
          children: [
            DottedBorder(
              color: AppColors.primary,
              strokeWidth: 2,
              dashPattern: const [6, 3],
              borderType: BorderType.RRect,
              radius: const Radius.circular(12),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.file(
                  File(path),
                  width: double.infinity,
                  height: double.infinity,
                  fit: BoxFit.cover,
                ),
              ),
            ),
            Positioned(
              top: 8,
              right: 8,
              child: InkWell(
                onTap: () => onRemove(index),
                child: Container(
                  width: 28,
                  height: 28,
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.55),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.close, color: Colors.white, size: 18),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

class _AddMoreButton extends StatelessWidget {
  const _AddMoreButton({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return OutlinedButton.icon(
      onPressed: onTap,
      style: OutlinedButton.styleFrom(
        side: const BorderSide(color: AppColors.primary, width: 1.4),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      ),
      icon: const Icon(Icons.add, color: AppColors.primary),
      label: Text(
        'Add More',
        style: AppTextStyles.bodyText(context).copyWith(
          color: AppColors.primary,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
