import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:get_storage/get_storage.dart';

import 'package:minechat/controller/dashboard_controller/dashboard_controlller.dart';
import 'package:minechat/controller/login_controller/login_controller.dart';
import 'package:minechat/controller/subscription_controller/subscription_controller.dart';
import 'package:minechat/controller/theme_controller/theme_controller.dart';
import 'package:minechat/controller/auth_controller/auth_controller.dart';
import 'package:minechat/controller/crm_controller/crm_controller.dart';
import 'package:minechat/controller/channel_controller/channel_controller.dart';
import 'package:minechat/controller/chat_controller/chat_controller.dart';
import 'package:minechat/core/services/otp_service/firestore_init.dart';
import 'package:minechat/core/utils/helpers/app_themes/app_theme.dart';
import 'package:minechat/core/router/app_pages.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  // Initialize Firebase App Check
  await FirebaseAppCheck.instance.activate(
    androidProvider: AndroidProvider.debug,
    appleProvider: AppleProvider.debug,
  );

  await GetStorage.init();

  // Controllers Initialization - Use permanent to prevent disposal
  // Initialize core controllers first
  Get.put(LoginController(), permanent: true);
  Get.put(AuthController(), permanent: true);
  Get.put(ThemeController(), permanent: true);
  
  // Initialize ChatController immediately since it's needed by ChatScreen
  print('🔄 Initializing ChatController...');
  try {
    Get.put(ChatController(), permanent: true);
    print('✅ ChatController initialized successfully');
  } catch (e) {
    print('❌ Error initializing ChatController: $e');
  }
  
  // Initialize other controllers after UI is ready
  WidgetsBinding.instance.addPostFrameCallback((_) {
    Get.put(DashboardController(), permanent: true);
    Get.put(SubscriptionController(), permanent: true);
    Get.put(CrmController(), permanent: true);
    Get.put(ChannelController(), permanent: true);
    
    print('✅ All controllers initialized successfully');
  });

  runApp(const MineChatApp());
}

class MineChatApp extends StatefulWidget {
  const MineChatApp({super.key});

  @override
  State<MineChatApp> createState() => _MineChatAppState();
}

class _MineChatAppState extends State<MineChatApp> {
  StreamSubscription? _linkSubscription;

  @override
  void initState() {
    super.initState();
    _setupDeepLinkHandling();
  }

  void _setupDeepLinkHandling() {
    // Handle initial deep link if app was opened with one
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _handleInitialDeepLink();
    });
  }

  void _handleInitialDeepLink() {
    // This will be called when the app is opened with a deep link
    // For now, we'll rely on the OAuth flow to handle the callback
  }



  void _handleDeepLink(Uri uri) {
    print('🔗 Deep link received: $uri');
    
    if (uri.scheme == 'minechat' && uri.host == 'facebook-oauth-callback') {
      final code = uri.queryParameters['code'];
      final state = uri.queryParameters['state'];
      
      if (code != null && state != null) {
        print('✅ OAuth callback received - code: $code, state: $state');
        
        // Handle OAuth callback
        try {
          final channelController = Get.find<ChannelController>();
          channelController.handleOAuthCallback(code, state);
        } catch (e) {
          print('❌ Error handling OAuth callback: $e');
        }
      }
    }
  }

  @override
  void dispose() {
    _linkSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ThemeController themeController = Get.find<ThemeController>();

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
