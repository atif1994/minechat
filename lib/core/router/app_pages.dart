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
  ];
}
