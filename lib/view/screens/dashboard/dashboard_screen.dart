import 'package:flutter/material.dart';
import 'package:minechat/core/constants/app_assets/app_assets.dart';
import 'package:minechat/core/widgets/dashboard/dashboard_appbar.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: DashboardAppBar(
        brandMarkSvg: AppAssets.minechatDashboard,
        notificationIconSvg: AppAssets.dashboardNotification,
        chatbotSvg: AppAssets.mineChatCamera,
        avatarImage: const AssetImage(AppAssets.minechatLogoDummy),
        hasUnreadNotifications: true,
        onTapNotifications: () {},
        onTapChatbot: () {},
        onTapAvatar: () {},
      ),
      body: Center(
        child: Text("This is Dashboard"),
      ),
    );
  }
}
