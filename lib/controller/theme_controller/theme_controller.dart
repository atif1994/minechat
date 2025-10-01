import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:get_storage/get_storage.dart';

import '../../core/utils/helpers/app_themes/app_theme.dart';

class ThemeController extends GetxController {
  final _storage = GetStorage();
  final RxBool _isDarkMode = false.obs;
  
  // Cache theme data to avoid repeated calculations
  ThemeData? _cachedLightTheme;
  ThemeData? _cachedDarkTheme;

  bool get isDarkMode => _isDarkMode.value;

  ThemeData get theme {
    if (isDarkMode) {
      _cachedDarkTheme ??= AppTheme.darkTheme;
      return _cachedDarkTheme!;
    } else {
      _cachedLightTheme ??= AppTheme.lightTheme;
      return _cachedLightTheme!;
    }
  }

  @override
  void onInit() {
    super.onInit();
    _isDarkMode.value = _storage.read('isDarkMode') ?? false;
    Get.changeThemeMode(isDarkMode ? ThemeMode.dark : ThemeMode.light);
  }

  void toggleTheme() {
    _isDarkMode.value = !isDarkMode;
    _storage.write('isDarkMode', isDarkMode);
    Get.changeThemeMode(isDarkMode ? ThemeMode.dark : ThemeMode.light);
  }
}
