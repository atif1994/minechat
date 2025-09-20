import 'package:flutter/material.dart';
import 'package:get/get.dart';

class SafeSnackbar {
  /// Safely show a snackbar with null checks
  static void show({
    required String title,
    required String message,
    SnackPosition position = SnackPosition.BOTTOM,
    Color? backgroundColor,
    Color? colorText,
    Duration? duration,
  }) {
    try {
      // Check if GetX is properly initialized
      if (Get.isRegistered<GetMaterialController>()) {
        Get.snackbar(
          title,
          message,
          snackPosition: position,
          backgroundColor: backgroundColor,
          colorText: colorText,
          duration: duration,
        );
      } else {
        // Fallback to print if GetX is not ready
        print('Snackbar: $title - $message');
      }
    } catch (e) {
      // Fallback to print if snackbar fails
      print('Snackbar Error: $title - $message');
      print('Error: $e');
    }
  }

  /// Show success snackbar
  static void success(String message, {String title = 'Success'}) {
    show(
      title: title,
      message: message,
      backgroundColor: Colors.green,
      colorText: Colors.white,
    );
  }

  /// Show error snackbar
  static void error(String message, {String title = 'Error'}) {
    show(
      title: title,
      message: message,
      backgroundColor: Colors.red,
      colorText: Colors.white,
    );
  }

  /// Show warning snackbar
  static void warning(String message, {String title = 'Warning'}) {
    show(
      title: title,
      message: message,
      backgroundColor: Colors.orange,
      colorText: Colors.white,
    );
  }

  /// Show info snackbar
  static void info(String message, {String title = 'Info'}) {
    show(
      title: title,
      message: message,
      backgroundColor: Colors.blue,
      colorText: Colors.white,
    );
  }
}


