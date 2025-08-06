import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:iconsax/iconsax.dart';
import 'package:image_picker/image_picker.dart';
import 'package:minechat/core/constants/app_assets/app_assets.dart';
import 'package:minechat/core/utils/extensions/app_gradient/app_gradient_extension.dart';
import 'package:minechat/core/utils/helpers/app_responsive/app_responsive.dart';
import 'package:minechat/core/utils/helpers/app_spacing/app_spacing.dart';
import 'package:permission_handler/permission_handler.dart';

class SignupProfileAvatarPicker extends StatefulWidget {
  final VoidCallback? onImagePicked;

  const SignupProfileAvatarPicker({super.key, this.onImagePicked});

  @override
  State<SignupProfileAvatarPicker> createState() =>
      _SignupProfileAvatarPickerState();
}

class _SignupProfileAvatarPickerState extends State<SignupProfileAvatarPicker> {
  File? _selectedImage;

  Future<bool> _requestStoragePermission() async {
    if (Platform.isIOS) {
      final status = await Permission.photos.request();
      if (status.isGranted) return true;
      if (status.isPermanentlyDenied) await openAppSettings();
      return false;
    } else if (Platform.isAndroid) {
      final sdkInt = (await Permission.storage.status).isGranted;
      final photoStatus = await Permission.photos.request();
      final storageStatus = await Permission.storage.request();
      if (photoStatus.isGranted || storageStatus.isGranted || sdkInt) {
        return true;
      }
      if (photoStatus.isPermanentlyDenied ||
          storageStatus.isPermanentlyDenied) {
        await openAppSettings();
      }
      return false;
    }
    return false;
  }

  Future<void> _pickImage() async {
    final hasPermission = await _requestStoragePermission();
    if (!hasPermission) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text("Storage permission required to pick image")),
      );
      return;
    }

    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery);
    if (picked != null) {
      setState(() {
        _selectedImage = File(picked.path);
      });
      if (widget.onImagePicked != null) widget.onImagePicked!();
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _pickImage,
      child: Container(
        width: AppResponsive.scaleSize(context, 100),
        height: AppResponsive.scaleSize(context, 100),
        decoration: BoxDecoration(shape: BoxShape.circle).withAppGradient,
        child: Stack(
          alignment: Alignment.center,
          children: [
            CircleAvatar(
              radius: AppResponsive.radius(context, factor: 6.3),
              backgroundColor: Colors.white,
              backgroundImage:
                  _selectedImage != null ? FileImage(_selectedImage!) : null,
              child: _selectedImage == null
                  ? SvgPicture.asset(AppAssets.logoMinechatSmall,
                      fit: BoxFit.cover)
                  : null,
            ),
            Positioned(
              bottom: 4,
              right: 4,
              child: Container(
                decoration:
                    const BoxDecoration(shape: BoxShape.circle).withAppGradient,
                padding: AppSpacing.all(context),
                child: Icon(Iconsax.gallery_add,
                    size: AppResponsive.iconSize(context), color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
