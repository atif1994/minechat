import 'package:get/get.dart';

import 'package:minechat/view/screens/splash/splash_screen.dart';
import 'package:minechat/view/screens/onboarding/onboarding_screen.dart';
import 'package:minechat/view/screens/login/login_screen.dart';
import 'package:minechat/view/screens/signUp/business_account_form.dart';
import 'package:minechat/view/screens/signUp/admin_user_form.dart';
import 'package:minechat/view/screens/otp/otp_screen.dart';
import 'package:minechat/view/screens/root_bottom_navigation/root_bottom_nav_scree.dart';
import 'package:minechat/view/screens/dashboard/dashboard_screen.dart';
import 'package:minechat/view/screens/forgot_password/forgot_password_screen.dart';
import 'package:minechat/view/screens/forgot_password/new_password_screen.dart';
import 'package:minechat/view/screens/account/account_screen.dart';
import 'package:minechat/view/screens/edit_profile/admin_edit_profile_screen.dart';
import 'package:minechat/view/screens/edit_profile/business_edit_profile_screen.dart';
import 'package:minechat/view/screens/subscription/subscription_screen.dart';
import 'package:minechat/view/screens/chat/chat_screen.dart';
import 'package:minechat/view/screens/chat/chat_conversation_screen.dart';
import 'package:minechat/view/screens/crm/crm_main_screen.dart';
import 'package:minechat/view/screens/crm/crm_leads_screen.dart';
import 'package:minechat/view/screens/crm/crm_opportunities_screen.dart';
import 'package:minechat/view/screens/crm/add_lead_screen.dart';
import 'package:minechat/controller/crm_controller/add_lead_controller.dart';

import 'app_routes.dart';

class AppPages {
  AppPages._();

  static const initial = AppRoutes.splash;

  static final routes = <GetPage>[
    GetPage(name: AppRoutes.splash, page: () => const SplashScreen()),
    GetPage(name: AppRoutes.onboarding, page: () => const OnboardingScreen()),
    GetPage(name: AppRoutes.login, page: () => const LoginScreen()),
    GetPage(
        name: AppRoutes.businessSignup,
        page: () => const SignupBusinessAccount(email: '')),
    GetPage(
        name: AppRoutes.adminSignup, page: () => const SignupAdminAccount()),
    GetPage(name: AppRoutes.otp, page: () => const OtpScreen()),
    GetPage(name: AppRoutes.rootBottomNav, page: () => RootBottomNavScreen()),
    GetPage(name: AppRoutes.dashboard, page: () => const DashboardScreen()),
    GetPage(
        name: AppRoutes.forgotPassword,
        page: () => const ForgotPasswordScreen()),
    GetPage(name: AppRoutes.newPassword, page: () => const NewPasswordScreen()),
    GetPage(name: AppRoutes.account, page: () => const AccountScreen()),
    GetPage(
        name: AppRoutes.adminEditProfile, page: () => AdminEditProfileScreen()),
    GetPage(
        name: AppRoutes.businessEditProfile,
        page: () => BusinessEditProfileScreen()),
    GetPage(
      name: AppRoutes.subscription,
      page: () => const SubscriptionScreen(),
    ),
    GetPage(name: AppRoutes.chat, page: () => ChatScreen()),
    GetPage(
        name: AppRoutes.chatConversation,
        page: () => ChatConversationScreen(chat: Get.arguments)),
    
    // CRM Pages
    GetPage(name: AppRoutes.crmMain, page: () => const CrmMainScreen()),
    GetPage(name: AppRoutes.crmLeads, page: () => CrmLeadsScreen()),
    GetPage(name: AppRoutes.crmOpportunities, page: () => CrmOpportunitiesScreen()),
    GetPage(
      name: AppRoutes.addLead, 
      page: () => const AddLeadScreen(),
      binding: BindingsBuilder(() {
        Get.lazyPut<AddLeadController>(() => AddLeadController());
      }),
    ),
  ];
}
