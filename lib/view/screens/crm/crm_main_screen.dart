import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:minechat/controller/crm_controller/crm_controller.dart';
import 'package:minechat/controller/auth_controller/auth_controller.dart';
import 'package:minechat/core/constants/app_colors/app_colors.dart';
import 'crm_leads_screen.dart';
import 'crm_opportunities_screen.dart';

class CrmMainScreen extends StatefulWidget {
  const CrmMainScreen({super.key});

  @override
  State<CrmMainScreen> createState() => _CrmMainScreenState();
}

class _CrmMainScreenState extends State<CrmMainScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final CrmController crmController = Get.put(CrmController());

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.gray,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'CRM > Leads > Opportunities',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
              ),
            ),
            const Text(
              'CRM',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
          ],
        ),
        bottom: TabBar(
          controller: _tabController,
          labelColor: AppColors.primary,
          unselectedLabelColor: Colors.grey,
          indicatorColor: AppColors.primary,
          tabs: const [
            Tab(text: 'Leads'),
            Tab(text: 'Opportunities'),
          ],
        ),
        actions: [
          IconButton(
            onPressed: () {
              // Debug: Check current user
              final auth = Get.find<AuthController>();
              print('🔍 Current user: ${auth.currentUser.value?.email}');
              print('🔍 User ID: ${auth.currentUserId}');
              
              // Force refresh
              crmController.refreshData();
            },
            icon: const Icon(Icons.refresh, color: AppColors.primary),
          ),
          IconButton(
            onPressed: () {
              Get.toNamed('/add-lead');
            },
            icon: const Icon(Icons.add, color: AppColors.primary),
          ),
        ],
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          CrmLeadsScreen(),
          CrmOpportunitiesScreen(),
        ],
      ),
    );
  }
}
