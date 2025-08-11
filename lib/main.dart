import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:get_storage/get_storage.dart';
import 'package:minechat/controller/login_controller/login_controller.dart';
import 'package:minechat/controller/theme_controller/theme_controller.dart';
import 'package:minechat/core/utils/helpers/app_themes/app_theme.dart';
import 'package:minechat/view/screens/dashboard/dashboard_screen.dart';
import 'package:minechat/view/screens/forgot_password/forgot_password_screen.dart';
import 'package:minechat/view/screens/login/login_screen.dart';
import 'package:minechat/view/screens/onboarding/onboarding_screen.dart';
import 'package:minechat/view/screens/otp/otp_screen.dart';
import 'package:minechat/view/screens/root_bottom_navigation/root_bottom_nav_scree.dart';
import 'package:minechat/view/screens/splash/splash_screen.dart';
import 'package:minechat/view/screens/signUp/business_account_form.dart';
import 'package:minechat/view/screens/signUp/admin_user_form.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  await GetStorage.init();

  // Controllers Initialization
  Get.put(LoginController());

  runApp(const MineChatApp());
}

class MineChatApp extends StatelessWidget {
  const MineChatApp({super.key});

  @override
  Widget build(BuildContext context) {
    final ThemeController themeController = Get.put(ThemeController());

    return Obx(() => GetMaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'minechat.ai',
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          themeMode:
              themeController.isDarkMode ? ThemeMode.dark : ThemeMode.light,
          initialRoute: '/',
          getPages: [
            GetPage(name: '/', page: () => const SplashScreen()),
            GetPage(name: '/onboarding', page: () => const OnboardingScreen()),
            GetPage(name: '/login', page: () => const LoginScreen()),
            GetPage(
                name: '/business-signup',
                page: () => const SignupBusinessAccount(email: '')),
            GetPage(
                name: '/admin-signup', page: () => const SignupAdminAccount()),
            GetPage(name: '/otp', page: () => const OtpScreen()),
            GetPage(
                name: '/root-bottom-nav-bar',
                page: () => RootBottomNavScreen()),
            GetPage(name: '/dashboard', page: () => const DashboardScreen()),
            GetPage(
                name: '/forgot-password',
                page: () => const ForgotPasswordScreen()),
          ],
          home: const SplashScreen(),
        ));
  }
}
