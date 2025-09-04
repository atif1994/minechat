import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:minechat/controller/login_controller/login_controller.dart';
import 'package:minechat/core/constants/app_colors/app_colors.dart';
import 'package:minechat/core/utils/helpers/app_responsive/app_responsive.dart';
import 'package:minechat/core/utils/helpers/app_spacing/app_spacing.dart';
import 'package:minechat/core/utils/helpers/app_styles/app_text_styles.dart';
import 'package:minechat/core/widgets/account/account_profile_image_avatar.dart';

class ManageUserProfilesScreen extends StatelessWidget {
  const ManageUserProfilesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final login = Get.find<LoginController>();
    final scheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Manage User Profiles',
          style: AppTextStyles.bodyText(context).copyWith(
              fontSize: AppResponsive.scaleSize(context, 20),
              fontWeight: FontWeight.w600),
        ),
        elevation: 0,
      ),
      backgroundColor: scheme.surface,
      body: SafeArea(
        child: Obx(() {
          final u = login.currentUser.value;

          // For now we only show CURRENT USER (expand later)
          final cards = [
            _ProfileCardModel(
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
              isCurrent: true,
            ),
          ];

          final hasMultipleUsers = cards.length > 1;

          return Padding(
            padding: AppSpacing.all(context, factor: 2),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Create and manage user profiles for your team',
                    style: AppTextStyles.bodyText(context).copyWith(
                        fontSize: AppResponsive.scaleSize(context, 14))),
                AppSpacing.vertical(context, 0.02),

                // Add User button
                Align(
                  alignment: Alignment.centerLeft,
                  child: _ActionButton(
                    onPressed: () {
                      // TODO: push "Create User" flow
                      Get.snackbar('Coming soon', 'Add user UI will be added.');
                    },
                    label: 'Add User',
                    icon: Iconsax.profile_add,
                  ),
                ),
                AppSpacing.vertical(context, 0.02),

                // Cards
                Expanded(
                  child: ListView.separated(
                    itemCount: cards.length,
                    separatorBuilder: (_, __) =>
                        AppSpacing.vertical(context, 0.015),
                    itemBuilder: (_, i) => _ManageProfileCard(
                      model: cards[i],
                      hasMultipleUsers: hasMultipleUsers,
                      onSwitch: () {
                        Get.snackbar('Active',
                            'You are already using this user.'); // placeholder
                      },
                      onEdit: () {
                        Get.snackbar('Edit', 'Open edit profile screen.');
                      },
                      onDelete: () {
                        Get.snackbar(
                            'Delete', 'Delete user (to be implemented).');
                      },
                    ),
                  ),
                ),
              ],
            ),
          );
        }),
      ),
    );
  }
}

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
  final VoidCallback onSwitch;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _ManageProfileCard({
    required this.model,
    required this.hasMultipleUsers,
    required this.onSwitch,
    required this.onEdit,
    required this.onDelete,
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
          // avatar
          AccountProfileImageAvatar(
            imageUrl: model.photoURL,
            size: AppResponsive.radius(context, factor: 8),
          ),
          AppSpacing.vertical(context, 0.012),

          // name + crown if current
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

          // email
          Text(
            model.email,
            style: AppTextStyles.bodyText(context).copyWith(
              fontSize: AppResponsive.scaleSize(context, 12),
            ),
            textAlign: TextAlign.center,
          ),
          AppSpacing.vertical(context, 0.004),

          // role / title
          Text(
            model.roleOrTitle,
            style: AppTextStyles.hintText(context).copyWith(
              fontSize: AppResponsive.scaleSize(context, 12),
            ),
            textAlign: TextAlign.center,
          ),
          AppSpacing.vertical(context, 0.015),

          // Switch button → only if multiple users
          if (hasMultipleUsers)
            SizedBox(
              width: double.infinity,
              child: _ActionButton(
                onPressed: model.isCurrent ? null : onSwitch,
                label: model.isCurrent ? 'Current User' : 'Switch to User',
              ),
            ),

          if (hasMultipleUsers) AppSpacing.vertical(context, 0.012),

          // Edit + Delete row
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
