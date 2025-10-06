import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:minechat/core/constants/app_colors/app_colors.dart';
import 'package:minechat/core/utils/extensions/app_gradient/app_gradient_extension.dart';
import 'package:minechat/core/utils/helpers/app_responsive/app_responsive.dart';
import 'package:minechat/core/utils/helpers/app_styles/app_text_styles.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'dart:io';

class ImageUploadSection extends StatelessWidget {
  final List<String> images;
  final Function(String) onAddImage;
  final Function(int) onRemoveImage;
  final VoidCallback onClearImages;
  final bool isDark;

  const ImageUploadSection({
    super.key,
    required this.images,
    required this.onAddImage,
    required this.onRemoveImage,
    required this.onClearImages,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
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
            if (images.isNotEmpty)
              GestureDetector(
                onTap: onClearImages,
                child: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.blue[300]!),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(Icons.close, color: Colors.blue[600], size: 16),
                ),
              ),
          ],
        ),
        const SizedBox(height: 8),

        // Image display or upload area
        Obx(() => images.isEmpty
            ? _DropZone(onChoose: () => _showImageUploadOptions(context, onAddImage))
            : _ImagesGrid(
                images: images,
                onAddMore: () => _showImageUploadOptions(context, onAddImage),
                onRemove: onRemoveImage,
              )),

        const SizedBox(height: 12),

        // Add More Button
        _AddMoreButton(
          onTap: () => _showImageUploadOptions(context, onAddImage),
        ),
      ],
    );
  }

  void _showImageUploadOptions(BuildContext context, Function(String) onPicked) {
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
                  final img = await picker.pickImage(source: ImageSource.gallery);
                  if (img != null) onPicked(img.path);
                },
              ),
              ListTile(
                leading: const Icon(Icons.camera_alt),
                title: const Text('Take a Photo'),
                onTap: () async {
                  Navigator.pop(context);
                  final picker = ImagePicker();
                  final img = await picker.pickImage(source: ImageSource.camera);
                  if (img != null) onPicked(img.path);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _pickMultipleFromGallery(Function(String) onPicked) async {
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
    } catch (_) {
      // silently fall back
    }

    // Fallback: single
    final single = await picker.pickImage(source: ImageSource.gallery);
    if (single != null) onPicked(single.path);
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
    return GridView.builder(
      itemCount: images.length + 1,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 1.5,
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
                child: _buildImageWidget(path),
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

  Widget _buildImageWidget(String path) {
    // Check if it's a URL or local file path
    if (path.startsWith('http')) {
      // Firebase Storage URL - use CachedNetworkImage
      return CachedNetworkImage(
        imageUrl: path,
        width: double.infinity,
        height: double.infinity,
        fit: BoxFit.cover,
        placeholder: (context, url) => Container(
          color: Colors.grey[200],
          child: const Center(
            child: SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
          ),
        ),
        errorWidget: (context, url, error) => Container(
          color: Colors.grey[200],
          child: const Icon(Icons.error, color: Colors.red),
        ),
      );
    } else {
      // Local file path - use Image.file
      return Image.file(
        File(path),
        width: double.infinity,
        height: double.infinity,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return Container(
            color: Colors.grey[200],
            child: const Icon(Icons.error, color: Colors.red),
          );
        },
      );
    }
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
