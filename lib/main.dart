import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:get_storage/get_storage.dart';
import 'package:minechat/controller/dashboard_controller/dashboard_controlller.dart';
import 'package:minechat/controller/login_controller/login_controller.dart';
import 'package:minechat/controller/theme_controller/theme_controller.dart';
import 'package:minechat/controller/auth_controller/auth_controller.dart';
import 'package:minechat/core/services/otp_service/firestore_init.dart';
import 'package:minechat/core/utils/helpers/app_themes/app_theme.dart';
import 'package:minechat/core/router/app_pages.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  unawaited(FirestoreInitializer.initializeCollections().catchError(
      (e) => print('Background Firebase Collection Initialization Error: $e')));

  await GetStorage.init();

  // Controllers Initialization
  Get.put(LoginController());
  Get.put(DashboardController());
  Get.put(AuthController());

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
          initialRoute: AppPages.initial,
          getPages: AppPages.routes,
        ));
  }
}
