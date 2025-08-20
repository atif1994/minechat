// core/widgets/edit_profile/edit_profile_avatar_picker.dart
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:minechat/controller/theme_controller/theme_controller.dart';
import 'package:permission_handler/permission_handler.dart';

import 'package:minechat/core/constants/app_assets/app_assets.dart';
import 'package:minechat/core/utils/extensions/app_gradient/app_gradient_extension.dart';
import 'package:minechat/core/utils/helpers/app_responsive/app_responsive.dart';
import 'package:minechat/core/utils/helpers/app_spacing/app_spacing.dart';

class EditProfileAvatarPicker extends StatefulWidget {
  final String? initialImageUrl;
  final void Function(File file)? onImageSelected;
  final String overlaySvgPath;

  const EditProfileAvatarPicker({
    super.key,
    this.initialImageUrl,
    this.onImageSelected,
    this.overlaySvgPath = AppAssets.accountEditUserProfile, // your camera SVG
  });

  @override
  State<EditProfileAvatarPicker> createState() =>
      _EditProfileAvatarPickerState();
}

class _EditProfileAvatarPickerState extends State<EditProfileAvatarPicker> {
  File? _selectedImage;

  Future<bool> _requestStoragePermission() async {
    final photos = await Permission.photos.request();
    final storage = await Permission.storage.request();
    if (photos.isGranted || storage.isGranted) return true;
    if (photos.isPermanentlyDenied || storage.isPermanentlyDenied) {
      await openAppSettings();
    }
    return false;
  }

  Future<void> _pick() async {
    if (!await _requestStoragePermission()) return;
    final picked = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (picked == null) return;
    final file = File(picked.path);
    setState(() => _selectedImage = file);
    widget.onImageSelected?.call(file);
  }

  @override
  Widget build(BuildContext context) {
    final size = AppResponsive.scaleSize(context, 100);
    final radius = AppResponsive.radius(context, factor: 6.3);
    final hasNetwork = (widget.initialImageUrl ?? '').isNotEmpty;
    final showNetwork = _selectedImage == null && hasNetwork;
    final themeController = Get.find<ThemeController>();
    final isDark = themeController.isDarkMode;

    return GestureDetector(
      onTap: _pick,
      child: Container(
        width: size,
        height: size,
        decoration: const BoxDecoration(shape: BoxShape.circle).withAppGradient,
        child: Stack(
          alignment: Alignment.center,
          children: [
            // white ring bg
            CircleAvatar(
                radius: radius,
                backgroundColor:
                    isDark ? const Color(0XFF0A0A0A) : const Color(0XFFF4F6FC)),

            // picked image
            if (_selectedImage != null)
              ClipOval(
                child: Image.file(
                  _selectedImage!,
                  width: size,
                  height: size,
                  fit: BoxFit.cover,
                ),
              ),

            // network image with spinner overlay (NO setState here)
            if (showNetwork)
              ClipOval(
                child: SizedBox(
                  width: size - 5,
                  height: size - 5,
                  child: Image.network(
                    widget.initialImageUrl!,
                    fit: BoxFit.cover,
                    frameBuilder: (context, child, frame, wasSyncLoaded) {
                      // while frame == null, image is still loading
                      if (wasSyncLoaded || frame != null) return child;
                      return Stack(
                        alignment: Alignment.center,
                        children: [
                          child, // keeps layout size
                          const SizedBox(
                            width: 28,
                            height: 28,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          ),
                        ],
                      );
                    },
                    errorBuilder: (_, __, ___) => const SizedBox.shrink(),
                  ),
                ),
              ),

            // placeholder logo
            if (!hasNetwork && _selectedImage == null)
              SvgPicture.asset(AppAssets.logoMinechatSmall, fit: BoxFit.cover),

            // bottom-right svg button
            Positioned(
              bottom: 4,
              right: 4,
              child: Container(
                decoration:
                    const BoxDecoration(shape: BoxShape.circle).withAppGradient,
                padding: AppSpacing.all(context),
                child: SvgPicture.asset(
                  widget.overlaySvgPath,
                  width: AppResponsive.iconSize(context),
                  height: AppResponsive.iconSize(context),
                  colorFilter:
                      const ColorFilter.mode(Colors.white, BlendMode.srcIn),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
