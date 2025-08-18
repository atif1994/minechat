import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:minechat/core/utils/helpers/app_responsive/app_responsive.dart';

class DashboardAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String brandMarkPng;
  final String notificationIconSvg;
  final String chatbotPng;
  final ImageProvider avatarImage;

  final VoidCallback? onTapNotifications;
  final VoidCallback? onTapChatbot;
  final VoidCallback? onTapAvatar;

  final bool hasUnreadNotifications;

  const DashboardAppBar({
    super.key,
    required this.brandMarkPng,
    required this.notificationIconSvg,
    required this.chatbotPng,
    required this.avatarImage,
    this.onTapNotifications,
    this.onTapChatbot,
    this.onTapAvatar,
    this.hasUnreadNotifications = true,
  });

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    // Responsive sizing
    final double hPad = AppResponsive.screenWidth(context) * 0.04;
    final double brandHeight = AppResponsive.scaleSize(context, 22);
    final double bellSize = AppResponsive.scaleSize(context, 26);
    final double unreadDot = AppResponsive.scaleSize(context, 8);
    final double botIcon = AppResponsive.scaleSize(context, 34);
    final double botRadius = AppResponsive.radius(context, factor: 0.9);
    final double avatar = AppResponsive.scaleSize(context, 28);
    final double gapSm = AppResponsive.scaleSize(context, 10);
    final double gapMd = AppResponsive.scaleSize(context, 14);

    return Material(
      color: Colors.white,
      elevation: 0,
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: hPad),
          child: SizedBox(
            height: kToolbarHeight,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                /// LEADING — brand mark (SVG that already includes the text)
                Image.asset(
                  brandMarkPng,
                  height: brandHeight,
                  fit: BoxFit.contain,
                ),

                /// TRAILING — bell, chatbot, avatar
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Notification bell with unread dot
                    Stack(
                      clipBehavior: Clip.none,
                      children: [
                        GestureDetector(
                          onTap: onTapNotifications,
                          child: SvgPicture.asset(
                            notificationIconSvg,
                            height: bellSize,
                            fit: BoxFit.contain,
                          ),
                        ),
                        if (hasUnreadNotifications)
                          Positioned(
                            right: -2,
                            top: -2,
                            child: Container(
                              width: unreadDot,
                              height: unreadDot,
                              decoration: BoxDecoration(
                                color: const Color(0xFFE11D48), // red dot
                                shape: BoxShape.circle,
                                border:
                                    Border.all(color: Colors.white, width: 2),
                              ),
                            ),
                          ),
                      ],
                    ),
                    SizedBox(width: gapMd),

                    // Chatbot gradient button
                    InkWell(
                      onTap: onTapChatbot,
                      borderRadius: BorderRadius.circular(botRadius),
                      child: Image.asset(
                        chatbotPng,
                        height: botIcon,
                        width: botIcon,
                      ),
                    ),
                    SizedBox(width: gapSm),

                    // Profile avatar
                    InkWell(
                      onTap: onTapAvatar,
                      child: CircleAvatar(
                        radius: avatar / 2,
                        backgroundImage: avatarImage,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
