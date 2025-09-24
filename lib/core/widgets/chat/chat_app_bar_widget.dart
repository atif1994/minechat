import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:minechat/controller/theme_controller/theme_controller.dart';
import 'package:minechat/core/constants/app_assets/app_assets.dart';
import 'package:minechat/core/constants/app_colors/app_colors.dart';
import 'package:minechat/core/utils/extensions/app_gradient/app_gradient_extension.dart';
import 'package:minechat/core/utils/helpers/app_responsive/app_responsive.dart';
import 'package:minechat/core/utils/helpers/app_styles/app_text_styles.dart';

/// Reusable chat app bar widget
class ChatAppBarWidget extends StatefulWidget implements PreferredSizeWidget {
  final String contactName;
  final String? profileImageUrl;
  final VoidCallback? onBackPressed;
  final VoidCallback? onProfileTap;
  final VoidCallback? onAITap;
  final VoidCallback? onMoreTap;

  const ChatAppBarWidget({
    Key? key,
    required this.contactName,
    this.profileImageUrl,
    this.onBackPressed,
    this.onProfileTap,
    this.onAITap,
    this.onMoreTap,
  }) : super(key: key);

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  State<ChatAppBarWidget> createState() => _ChatAppBarWidgetState();
}

class _ChatAppBarWidgetState extends State<ChatAppBarWidget> {
  // 0 = AI (left), 1 = Person (right)
  int _selected = 0;

  @override
  Widget build(BuildContext context) {
    final themeController = Get.find<ThemeController>();
    final isDark = themeController.isDarkMode;

    return AppBar(
      backgroundColor:
          isDark ? const Color(0XFF1D1D1D) : const Color(0XFFFFFFFF),
      elevation: 0,
      leading: IconButton(
        icon:
            Icon(Icons.arrow_back, color: isDark ? Colors.white : Colors.black),
        onPressed: widget.onBackPressed ?? () => Get.back(),
      ),
      title: Row(
        children: [
          Stack(
            children: [
              CircleAvatar(
                radius: 20,
                backgroundImage: widget.profileImageUrl?.isNotEmpty == true
                    ? NetworkImage(widget.profileImageUrl!)
                    : null,
                onBackgroundImageError: (_, __) {},
                child: widget.profileImageUrl?.isEmpty != false
                    ? Text(
                        (widget.contactName.isNotEmpty
                                ? widget.contactName[0]
                                : '?')
                            .toUpperCase(),
                        style: AppTextStyles.bodyText(context).copyWith(
                          fontSize: AppResponsive.scaleSize(context, 20),
                          fontWeight: FontWeight.w600,
                        ),
                      )
                    : null,
              ),
              Positioned(
                bottom: 0,
                right: 0,
                child: SvgPicture.asset(
                  AppAssets.socialMessengerLight,
                  height: 16,
                  width: 16,
                ),
              ),
            ],
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.contactName,
                  style: AppTextStyles.bodyText(context).copyWith(
                    fontSize: AppResponsive.scaleSize(context, 14),
                    fontWeight: FontWeight.w600,
                  ),
                ),
                // Keep "View profile" tap behavior, but it’s also on the toggle (right side)
                GestureDetector(
                  onTap: widget.onProfileTap ??
                      () => Get.snackbar('Info', 'Viewing profile...'),
                  child: Text(
                    'View profile',
                    style: AppTextStyles.hintText(context).copyWith(
                      fontSize: AppResponsive.scaleSize(context, 12),
                      color: const Color(0XFF1677FF),
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      actions: [
        _AIVsPersonToggle(
          selected: _selected,
          onSelectAI: () {
            setState(() => _selected = 0);
            (widget.onAITap ??
                () => Get.snackbar('Info', 'AI Assistant toggled...'))();
          },
          onSelectPerson: () {
            setState(() => _selected = 1);
            (widget.onProfileTap ??
                () => Get.snackbar('Info', 'Viewing profile...'))();
          },
        ),
        PopupMenuButton<String>(
          icon: Icon(Icons.more_vert,
              color: isDark ? Colors.white : Colors.black),
          onSelected: (value) {
            switch (value) {
              case 'add_to_group':
                Get.snackbar('Info', 'Add to group...');
                break;
              case 'follow_up':
                Get.snackbar('Info', 'Follow-up later...');
                break;
              case 'block':
                Get.snackbar('Info', 'Block contact...');
                break;
              case 'delete':
                Get.snackbar('Info', 'Delete conversation...');
                break;
            }
          },
          itemBuilder: (context) => [
            PopupMenuItem(
              value: 'add_to_group',
              child: Text(
                'Add To Group',
                style: AppTextStyles.bodyText(context).copyWith(
                    fontSize: AppResponsive.scaleSize(context, 12),
                    fontWeight: FontWeight.w400),
              ),
            ),
            PopupMenuItem(
                value: 'follow_up',
                child: Text(
                  'Follow-up Later',
                  style: AppTextStyles.bodyText(context).copyWith(
                      fontSize: AppResponsive.scaleSize(context, 12),
                      fontWeight: FontWeight.w400),
                )),
            PopupMenuItem(
                value: 'block',
                child: Text(
                  'Block Contact',
                  style: AppTextStyles.bodyText(context).copyWith(
                      fontSize: AppResponsive.scaleSize(context, 12),
                      fontWeight: FontWeight.w400),
                )),
            PopupMenuItem(
                value: 'delete',
                child: Text(
                  'Delete Conversation',
                  style: AppTextStyles.bodyText(context).copyWith(
                      fontSize: AppResponsive.scaleSize(context, 12),
                      fontWeight: FontWeight.w400),
                )),
          ],
        ),
        const SizedBox(width: 8),
      ],
    );
  }
}

/// Toggle styled like the screenshots: pill container with a gradient-filled
/// circular thumb on the selected side.
class _AIVsPersonToggle extends StatelessWidget {
  final int selected; // 0 = AI, 1 = Person
  final VoidCallback onSelectAI;
  final VoidCallback onSelectPerson;

  const _AIVsPersonToggle({
    Key? key,
    required this.selected,
    required this.onSelectAI,
    required this.onSelectPerson,
  }) : super(key: key);

  LinearGradient get _grad => const LinearGradient(
        colors: [
          AppColors.primary,
          AppColors.secondary,
          AppColors.tertiary,
        ],
        begin: Alignment.bottomCenter,
        end: Alignment.topCenter,
      );

  @override
  Widget build(BuildContext context) {
    final themeController = Get.find<ThemeController>();
    final isDark = themeController.isDarkMode;
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 6),
      decoration: BoxDecoration(
        color: isDark ? Color(0XFFFFFFFF).withOpacity(0.08) : Color(0XFFFFFFFF),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(
            color: isDark
                ? Color(0xFFFFFFFF).withOpacity(0.12)
                : Color(0XFFF4F6FC)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // AI side
          _ToggleCircle(
            isSelected: selected == 0,
            grad: _grad,
            icon: Icons.smart_toy,
            onTap: onSelectAI,
          ),
          const SizedBox(width: 10),
          // Person side
          _ToggleCircle(
            isSelected: selected == 1,
            grad: _grad,
            icon: Icons.person,
            onTap: onSelectPerson,
          ),
        ],
      ),
    );
  }
}

class _ToggleCircle extends StatelessWidget {
  final bool isSelected;
  final LinearGradient grad;
  final IconData icon;
  final VoidCallback onTap;

  const _ToggleCircle({
    Key? key,
    required this.isSelected,
    required this.grad,
    required this.icon,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final double size = 34;

    return InkWell(
      borderRadius: BorderRadius.circular(999),
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        curve: Curves.easeOut,
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: isSelected ? grad : null,
          color: isSelected ? null : Colors.white,
        ),
        child: Icon(
          icon,
          size: 18,
          color: isSelected ? Colors.white : const Color(0xFF9AA3B2),
        ),
      ),
    );
  }
}
