import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:minechat/controller/dashboard_controller/dashboard_controlller.dart';
import 'package:minechat/controller/login_controller/login_controller.dart';
import 'package:minechat/core/constants/app_assets/app_assets.dart';
import 'package:minechat/core/utils/helpers/app_responsive/app_responsive.dart';
import 'package:minechat/core/utils/helpers/app_spacing/app_spacing.dart';
import 'package:minechat/core/widgets/dashboard/dashboard_appbar.dart';
import 'package:minechat/core/widgets/dashboard/dashboard_header.dart';
import 'package:minechat/core/widgets/dashboard/dashboard_faq_card.dart';
import 'package:minechat/core/widgets/dashboard/dashboard_messages_per_hour_card.dart';
import 'package:minechat/core/widgets/dashboard/dashboard_messages_sent_card.dart';
import 'package:minechat/core/widgets/dashboard/dashboard_stat_grid.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  @override
  void initState() {
    super.initState();
    // Ensure the controller is available exactly once.
    if (!Get.isRegistered<DashboardController>()) {
      Get.put(DashboardController(), permanent: true);
    }

    Get.find<LoginController>().hydrateFromAuthIfNeeded();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0XFFf4f6fc),
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(kToolbarHeight),
        child: Obx(
          () {
            final login = Get.find<LoginController>();
            final url = login.currentUser.value?.photoURL ?? '';
            final ImageProvider avatarProvider = url.isNotEmpty
                ? NetworkImage(url)
                : const AssetImage(AppAssets.minechatProfileAvatarLogoDummy);
            return DashboardAppBar(
              brandMarkPng: AppAssets.minechatDashboard,
              notificationIconSvg: AppAssets.dashboardNotification,
              chatbotPng: AppAssets.minechatChatbot,
              avatarImage: avatarProvider,
              hasUnreadNotifications: true,
              onTapNotifications: () {},
              onTapChatbot: () {},
              onTapAvatar: () {},
            );
          },
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: AppSpacing.all(context, factor: 2)
              .copyWith(top: AppResponsive.scaleSize(context, 8)),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              DashboardHeader(),
              AppSpacing.vertical(context, 0.02),
              DashboardStatGrid(),
              AppSpacing.vertical(context, 0.01),
              DashboardMessagesSentCard(),
              AppSpacing.vertical(context, 0.01),
              DashboardFaqCard(),
              AppSpacing.vertical(context, 0.01),
              DashboardMessagesPerHourCard(),
            ],
          ),
        ),
      ),
    );
  }
}
