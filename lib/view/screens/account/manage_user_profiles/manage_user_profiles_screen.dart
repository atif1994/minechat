import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:iconsax/iconsax.dart';
import 'package:minechat/controller/accounts_controller/manage_user_controller.dart';
import 'package:minechat/controller/login_controller/login_controller.dart';
import 'package:minechat/core/constants/app_colors/app_colors.dart';
import 'package:minechat/core/router/app_routes.dart';
import 'package:minechat/core/utils/helpers/app_responsive/app_responsive.dart';
import 'package:minechat/core/utils/helpers/app_spacing/app_spacing.dart';
import 'package:minechat/core/utils/helpers/app_styles/app_text_styles.dart';
import 'package:minechat/core/widgets/account/account_profile_image_avatar.dart';
import 'package:minechat/model/data/accounts/manage_user_model.dart';

class ManageUserProfilesScreen extends StatelessWidget {
  const ManageUserProfilesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final login = Get.find<LoginController>();
    final scheme = Theme.of(context).colorScheme;

    // controller for CRUD + stream
    final managed = Get.isRegistered<ManageUserController>()
        ? Get.find<ManageUserController>()
        : Get.put(ManageUserController(), permanent: true);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Manage User Profiles',
          style: AppTextStyles.bodyText(context).copyWith(
            fontSize: AppResponsive.scaleSize(context, 20),
            fontWeight: FontWeight.w600,
          ),
        ),
        elevation: 0,
      ),
      backgroundColor: scheme.surface,
      body: SafeArea(
        child: Obx(() {
          final u = login.currentUser.value;

          // ----- OWNER (current user) "card" -----
          final active = managed.activeProfile.value;
          final ownerIsCurrent = active == null;

          final ownerHeader = _ManageProfileCard(
            model: _ProfileCardModel(
              uid: u?.uid ?? '',
              name: u?.name ?? 'User',
              email: u?.email ?? '',
              roleOrTitle: u?.position?.isNotEmpty == true
                  ? u!.position!
                  : (u?.accountType == 'admin'
                      ? 'Admin'
                      : u?.accountType == 'business'
                          ? 'Business'
                          : 'User'),
              photoURL: u?.photoURL ?? '',
              isCurrent: ownerIsCurrent,
            ),
            hasMultipleUsers: true,
            onSwitch:
                ownerIsCurrent ? null : () => managed.clearSwitchedProfile(),
            onEdit: () {
              Get.toNamed(AppRoutes.adminEditProfile);
            },

            onDelete: () {
              Get.defaultDialog(
                title: 'Not allowed',
                middleText:
                    'The admin profile can’t be deleted from this screen.',
                textConfirm: 'OK',
                confirmTextColor: Colors.white,
                onConfirm: Get.back,
              );
            },

            isOwnerHeader: true, // we’ll let the card render its action row too
          );

          return Padding(
            padding: AppSpacing.all(context, factor: 2),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Create and manage user profiles for your team',
                  style: AppTextStyles.bodyText(context).copyWith(
                    fontSize: AppResponsive.scaleSize(context, 14),
                  ),
                ),
                AppSpacing.vertical(context, 0.02),

                // Add User button (same style component)
                Align(
                  alignment: Alignment.centerLeft,
                  child: _ActionButton(
                    onPressed: () => Get.toNamed(AppRoutes.addUserProfile),
                    label: 'Add User',
                    icon: Iconsax.profile_add,
                  ),
                ),
                AppSpacing.vertical(context, 0.02),

                // current owner card
                ownerHeader,
                AppSpacing.vertical(context, 0.02),

                // managed users list (stream)
                // inside build() -> for the managed list:
                Expanded(
                  child: Obx(() {
                    final items = managed.profiles;
                    if (items.isEmpty) {
                      return Center(
                        child: Text(
                          "No managed users yet.\nTap 'Add User' to create one.",
                          textAlign: TextAlign.center,
                          style: AppTextStyles.hintText(context),
                        ),
                      );
                    }

                    final activeId = managed.activeProfile.value?.id;

                    return ListView.separated(
                      itemCount: items.length,
                      separatorBuilder: (_, __) =>
                          AppSpacing.vertical(context, 0.015),
                      itemBuilder: (_, i) {
                        final m = items[i];
                        final isActive = m.id == activeId;

                        return _ManageProfileCard(
                          model: _ProfileCardModel(
                            uid: m.id,
                            name: m.name,
                            email: m.email,
                            roleOrTitle: m.roleTitle,
                            photoURL: m.photoURL ?? '',
                            isCurrent: isActive, // reflect current switch state
                          ),
                          hasMultipleUsers: true,
                          // Switch logic:
                          onSwitch: isActive
                              ? null
                              : () => managed.switchToProfile(m),
                          // Edit/Delete enabled only for managed (not owner header)
                          onEdit: () => _openEditDialog(context, m),
                          onDelete: () => _confirmDelete(m, managed),
                          isOwnerHeader: false,
                        );
                      },
                    );
                  }),
                ),
              ],
            ),
          );
        }),
      ),
    );
  }

  void _confirmDelete(ManageUserModel m, ManageUserController c) {
    Get.defaultDialog(
      title: 'Delete profile?',
      middleText: 'Are you sure you want to delete ${m.name}?',
      textCancel: 'Cancel',
      textConfirm: 'Delete',
      confirmTextColor: Colors.white,
      onConfirm: () {
        Get.back();
        c.deleteProfile(m);
      },
    );
  }

  void _openEditDialog(BuildContext context, ManageUserModel m) {
    final nameCtrl = TextEditingController(text: m.name);
    final emailCtrl = TextEditingController(text: m.email);
    final roleCtrl = TextEditingController(text: m.roleTitle);
    final phoneCtrl = TextEditingController(text: m.phone ?? '');
    final formKey = GlobalKey<FormState>();
    final c = Get.find<ManageUserController>();

    File? pickedImage;

    Get.dialog(
      Dialog(
        child: Padding(
          padding: AppSpacing.all(context, factor: 2),
          child: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // avatar + change button (keeps your minimal dialog style)
                AccountProfileImageAvatar(
                  imageUrl: m.photoURL ?? '',
                  size: AppResponsive.radius(context, factor: 8),
                ),
                AppSpacing.vertical(context, 0.008),
                TextButton.icon(
                  onPressed: () async {
                    final x = await ImagePicker().pickImage(
                      source: ImageSource.gallery,
                      imageQuality: 75,
                    );
                    if (x != null) {
                      pickedImage = File(x.path);
                      Get.snackbar(
                        'Photo selected',
                        'It will be updated when you save.',
                      );
                    }
                  },
                  icon: const Icon(Iconsax.gallery_add),
                  label: const Text('Change photo'),
                ),
                AppSpacing.vertical(context, 0.012),

                _TField(
                  controller: nameCtrl,
                  label: 'Full name',
                  validator: (v) =>
                      (v == null || v.trim().isEmpty) ? 'Required' : null,
                ),
                AppSpacing.vertical(context, 0.012),
                _TField(
                  controller: emailCtrl,
                  label: 'Email',
                  keyboardType: TextInputType.emailAddress,
                  validator: (v) {
                    final t = v?.trim() ?? '';
                    if (t.isEmpty) return 'Required';
                    final ok = RegExp(
                      r'^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$',
                    ).hasMatch(t);
                    return ok ? null : 'Invalid email';
                  },
                ),
                AppSpacing.vertical(context, 0.012),
                _TField(
                  controller: roleCtrl,
                  label: 'Role / Title',
                  validator: (v) =>
                      (v == null || v.trim().isEmpty) ? 'Required' : null,
                ),
                AppSpacing.vertical(context, 0.012),
                _TField(
                  controller: phoneCtrl,
                  label: 'Phone (optional)',
                  keyboardType: TextInputType.phone,
                ),
                AppSpacing.vertical(context, 0.02),

                Row(
                  children: [
                    Expanded(
                      child: _ActionButton(
                        onPressed: () => Get.back(),
                        label: 'Cancel',
                        labelColor: AppColors.error,
                      ),
                    ),
                    AppSpacing.horizontal(context, 0.02),
                    Expanded(
                      child: _ActionButton(
                        onPressed: () {
                          if (!formKey.currentState!.validate()) return;
                          final updated = m.copyWith(
                            name: nameCtrl.text,
                            email: emailCtrl.text,
                            roleTitle: roleCtrl.text,
                            phone: phoneCtrl.text.trim().isEmpty
                                ? null
                                : phoneCtrl.text,
                          );
                          c.updateProfile(updated, image: pickedImage);
                        },
                        label: 'Save',
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
      barrierDismissible: false,
    );
  }
}

/* ====== helper widgets/types kept same as your design ====== */

class _ProfileCardModel {
  final String uid;
  final String name;
  final String email;
  final String roleOrTitle;
  final String photoURL;
  final bool isCurrent;

  _ProfileCardModel({
    required this.uid,
    required this.name,
    required this.email,
    required this.roleOrTitle,
    required this.photoURL,
    this.isCurrent = false,
  });
}

class _ManageProfileCard extends StatelessWidget {
  final _ProfileCardModel model;
  final bool hasMultipleUsers;
  final VoidCallback? onSwitch;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;
  final bool isOwnerHeader;

  const _ManageProfileCard({
    required this.model,
    required this.hasMultipleUsers,
    required this.onSwitch,
    required this.onEdit,
    required this.onDelete,
    this.isOwnerHeader = false,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final radius =
        BorderRadius.circular(AppResponsive.radius(context, factor: 2));

    return Container(
      decoration: BoxDecoration(
        color: scheme.surface,
        borderRadius: radius,
        border: Border.all(
          color: model.isCurrent ? AppColors.primary : const Color(0xFFEBEDF0),
          width: model.isCurrent ? 1.5 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: scheme.onSurface.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: AppSpacing.all(context, factor: 2),
      child: Column(
        children: [
          AccountProfileImageAvatar(
            imageUrl: model.photoURL,
            size: AppResponsive.radius(context, factor: 8),
          ),
          AppSpacing.vertical(context, 0.012),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                model.name,
                style: AppTextStyles.bodyText(context).copyWith(
                  fontSize: AppResponsive.scaleSize(context, 16),
                  fontWeight: FontWeight.w600,
                ),
              ),
              if (model.isCurrent) ...[
                AppSpacing.horizontal(context, 0.01),
                const Icon(
                  Iconsax.crown_1,
                  size: 18,
                  color: AppColors.primary,
                ),
              ],
            ],
          ),
          AppSpacing.vertical(context, 0.004),
          Text(
            model.email,
            style: AppTextStyles.bodyText(context).copyWith(
              fontSize: AppResponsive.scaleSize(context, 12),
            ),
            textAlign: TextAlign.center,
          ),
          AppSpacing.vertical(context, 0.004),
          Text(
            model.roleOrTitle,
            style: AppTextStyles.hintText(context).copyWith(
              fontSize: AppResponsive.scaleSize(context, 12),
            ),
            textAlign: TextAlign.center,
          ),
          AppSpacing.vertical(context, 0.015),

          // ✅ SWITCH/CURRENT button (design you had earlier)
          if (hasMultipleUsers)
            SizedBox(
              width: double.infinity,
              child: _ActionButton(
                onPressed: model.isCurrent ? null : onSwitch,
                label: model.isCurrent
                    ? 'Current User'
                    : (isOwnerHeader ? 'Switch to Admin' : 'Switch to User'),
              ),
            ),

          AppSpacing.vertical(context, 0.012),

          // ✅ Show action row for both managed users *and* owner header.
          // For the owner, the callbacks you passed decide the behavior.
          Row(
            children: [
              Expanded(
                child: _ActionButton(
                  onPressed: onEdit,
                  label: 'Edit',
                  icon: Iconsax.edit_2,
                ),
              ),
              AppSpacing.horizontal(context, 0.02),
              Expanded(
                child: _ActionButton(
                  onPressed: onDelete,
                  label: 'Delete',
                  labelColor: AppColors.error,
                  icon: Iconsax.trash,
                  iconColor: AppColors.error,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final String label;
  final Color? labelColor;
  final IconData? icon; // optional
  final Color? iconColor;
  final VoidCallback? onPressed; // nullable for disabled

  const _ActionButton({
    required this.label,
    this.labelColor,
    this.icon,
    this.iconColor,
    this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final style = OutlinedButton.styleFrom(
      foregroundColor: scheme.onSurface,
      side: BorderSide(color: scheme.onSurface.withOpacity(.2)),
      padding: EdgeInsets.symmetric(
        horizontal: AppResponsive.scaleSize(context, 18),
        vertical: AppResponsive.scaleSize(context, 10),
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppResponsive.radius(context)),
      ),
    );

    final labelWidget = Text(
      label,
      style: AppTextStyles.bodyText(context).copyWith(
        fontSize: AppResponsive.scaleSize(context, 14),
        fontWeight: FontWeight.w600,
        color: labelColor,
      ),
    );

    return icon != null
        ? OutlinedButton.icon(
            onPressed: onPressed,
            icon: Icon(icon, color: iconColor),
            label: labelWidget,
            style: style,
          )
        : OutlinedButton(
            onPressed: onPressed,
            style: style,
            child: labelWidget,
          );
  }
}

class _TField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final TextInputType? keyboardType;
  final String? Function(String?)? validator;

  const _TField({
    required this.controller,
    required this.label,
    this.keyboardType,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      validator: validator,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppResponsive.radius(context)),
        ),
      ),
    );
  }
}
