import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:minechat/core/services/webhook_test_service.dart';

/// Debug button to test webhook integration
class WebhookTestButton extends StatelessWidget {
  final WebhookTestService _testService = WebhookTestService();

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton(
      onPressed: () => _testWebhook(),
      backgroundColor: Colors.blue,
      child: Icon(Icons.webhook, color: Colors.white),
      tooltip: 'Test Webhook',
    );
  }

  Future<void> _testWebhook() async {
    try {
      print('🧪 Starting webhook test...');
      
      await _testService.testWebhookConnection();
      
      Get.snackbar(
        'Webhook Test',
        'Test message sent! Check console for details.',
        snackPosition: SnackPosition.TOP,
        duration: Duration(seconds: 3),
        backgroundColor: Colors.blue,
        colorText: Colors.white,
      );
    } catch (e) {
      print('❌ Webhook test failed: $e');
      
      Get.snackbar(
        'Webhook Test Failed',
        'Error: $e',
        snackPosition: SnackPosition.TOP,
        duration: Duration(seconds: 5),
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }
}
