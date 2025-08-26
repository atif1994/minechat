import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ChannelController extends GetxController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Channel selection
  var selectedChannel = 'Website'.obs;
  var isChannelDropdownOpen = false.obs;

  // Website channel
  final websiteUrlCtrl = TextEditingController();
  var selectedWidgetColor = 'green'.obs;
  var generatedCode = ''.obs;

  // Messenger channel
  var isFacebookConnected = false.obs;
  var isFacebookAIPaused = false.obs;
  final facebookPageIdCtrl = TextEditingController();

  // Loading states
  var isLoading = false.obs;
  var isGeneratingCode = false.obs;
  var isConnectingFacebook = false.obs;

  // Available channels
  final List<Map<String, dynamic>> availableChannels = [
    {'name': 'Website', 'icon': '🌐', 'color': Colors.blue},
    {'name': 'Messenger', 'icon': '💬', 'color': Colors.blue[600]},
    {'name': 'Instagram', 'icon': '📷', 'color': Colors.pink},
    {'name': 'Telegram', 'icon': '📱', 'color': Colors.blue[400]},
    {'name': 'WhatsApp', 'icon': '📞', 'color': Colors.green},
    {'name': 'Slack', 'icon': '💼', 'color': Colors.purple},
    {'name': 'Viber', 'icon': '💜', 'color': Colors.purple[600]},
    {'name': 'Discord', 'icon': '🎮', 'color': Colors.indigo},
  ];

  // Widget colors
  final List<Map<String, dynamic>> widgetColors = [
    {'name': 'red', 'color': Colors.red},
    {'name': 'orange', 'color': Colors.orange},
    {'name': 'purple', 'color': Colors.purple},
    {'name': 'red2', 'color': Colors.red[700]},
    {'name': 'green', 'color': Colors.green},
    {'name': 'brightPurple', 'color': Colors.purple[300]},
    {'name': 'blue', 'color': Colors.blue},
    {'name': 'darkBlue', 'color': Colors.blue[800]},
  ];

  @override
  void onInit() {
    super.onInit();
    print('🔍 ChannelController initialized');
    loadChannelSettings();
  }

  String getCurrentUserId() {
    return FirebaseAuth.instance.currentUser?.uid ?? '';
  }

  /// Load existing channel settings
  Future<void> loadChannelSettings() async {
    try {
      isLoading.value = true;
      final userId = getCurrentUserId();
      if (userId.isEmpty) return;

      final doc = await _firestore
          .collection('channel_settings')
          .doc(userId)
          .get();

      if (doc.exists) {
        final data = doc.data()!;
        selectedChannel.value = data['selectedChannel'] ?? 'Website';
        websiteUrlCtrl.text = data['websiteUrl'] ?? '';
        selectedWidgetColor.value = data['widgetColor'] ?? 'green';
        isFacebookConnected.value = data['isFacebookConnected'] ?? false;
        isFacebookAIPaused.value = data['isFacebookAIPaused'] ?? false;
        facebookPageIdCtrl.text = data['facebookPageId'] ?? '';
        generatedCode.value = data['generatedCode'] ?? '';
      }
    } catch (e) {
      print('❌ Error loading channel settings: $e');
    } finally {
      isLoading.value = false;
    }
  }

  /// Save channel settings
  Future<void> saveChannelSettings() async {
    try {
      isLoading.value = true;
      final userId = getCurrentUserId();
      if (userId.isEmpty) throw Exception("User not authenticated");

      final data = {
        'selectedChannel': selectedChannel.value,
        'websiteUrl': websiteUrlCtrl.text.trim(),
        'widgetColor': selectedWidgetColor.value,
        'isFacebookConnected': isFacebookConnected.value,
        'isFacebookAIPaused': isFacebookAIPaused.value,
        'facebookPageId': facebookPageIdCtrl.text.trim(),
        'generatedCode': generatedCode.value,
        'userId': userId,
        'updatedAt': DateTime.now().toIso8601String(),
      };

      await _firestore
          .collection('channel_settings')
          .doc(userId)
          .set(data, SetOptions(merge: true));

      Get.snackbar(
        'Success',
        'Channel settings saved successfully!',
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
    } catch (e) {
      print('❌ Error saving channel settings: $e');
      Get.snackbar(
        'Error',
        'Failed to save channel settings: $e',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }

  /// Generate website widget code
  Future<void> generateWebsiteCode() async {
    try {
      isGeneratingCode.value = true;
      
      if (websiteUrlCtrl.text.trim().isEmpty) {
        Get.snackbar(
          'Error',
          'Please enter a website URL first',
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
        return;
      }

      // Generate a simple widget code
      final color = widgetColors.firstWhere(
        (c) => c['name'] == selectedWidgetColor.value,
        orElse: () => widgetColors.first,
      )['color'] as Color;

      final colorHex = '#${color.value.toRadixString(16).substring(2)}';
      
      final code = '''
<!-- MineChat AI Assistant Widget -->
<div id="minechat-widget" style="position: fixed; bottom: 20px; right: 20px; z-index: 1000;">
  <div style="background-color: $colorHex; color: white; padding: 15px; border-radius: 10px; cursor: pointer; box-shadow: 0 4px 12px rgba(0,0,0,0.15);">
    <div style="display: flex; align-items: center; gap: 10px;">
      <span style="font-size: 20px;">🤖</span>
      <span style="font-weight: 600;">Chat with AI</span>
    </div>
  </div>
</div>

<script>
document.getElementById('minechat-widget').addEventListener('click', function() {
  // Open chat interface
  window.open('https://minechat.ai/chat?url=${Uri.encodeComponent(websiteUrlCtrl.text.trim())}', '_blank');
});
</script>
''';

      generatedCode.value = code;
      
      Get.snackbar(
        'Success',
        'Website widget code generated!',
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
    } catch (e) {
      print('❌ Error generating code: $e');
      Get.snackbar(
        'Error',
        'Failed to generate code: $e',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isGeneratingCode.value = false;
    }
  }

  /// Copy generated code to clipboard
  void copyGeneratedCode() {
    if (generatedCode.value.isNotEmpty) {
      // In a real app, you'd use Clipboard.setData
      Get.snackbar(
        'Copied!',
        'Widget code copied to clipboard',
        backgroundColor: Colors.blue,
        colorText: Colors.white,
        duration: Duration(seconds: 2),
      );
    }
  }

  /// Connect Facebook
  Future<void> connectFacebook() async {
    try {
      isConnectingFacebook.value = true;
      
      // Check if user has entered Facebook Page ID
      if (facebookPageIdCtrl.text.trim().isEmpty) {
        Get.snackbar(
          'Error',
          'Please enter your Facebook Page ID first',
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
        return;
      }

      // TODO: Implement real Facebook Graph API connection
      // You'll need to:
      // 1. Add facebook_login package to pubspec.yaml
      // 2. Configure Facebook App in Facebook Developer Console
      // 3. Use Facebook Graph API to verify page ownership
      
      // For now, simulate the connection
      await Future.delayed(Duration(seconds: 2));
      
      // Verify page ID format (basic validation)
      final pageId = facebookPageIdCtrl.text.trim();
      if (!RegExp(r'^\d+$').hasMatch(pageId)) {
        throw Exception('Invalid Facebook Page ID format');
      }
      
      isFacebookConnected.value = true;
      
      // Save to Firebase
      await saveChannelSettings();
      
      Get.snackbar(
        'Success',
        'Facebook Page connected successfully!\nPage ID: $pageId',
        backgroundColor: Colors.green,
        colorText: Colors.white,
        duration: Duration(seconds: 4),
      );
    } catch (e) {
      print('❌ Error connecting Facebook: $e');
      Get.snackbar(
        'Error',
        'Failed to connect Facebook: $e',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isConnectingFacebook.value = false;
    }
  }

  /// Disconnect Facebook
  Future<void> disconnectFacebook() async {
    try {
      isConnectingFacebook.value = true;
      
      // Simulate Facebook disconnection
      await Future.delayed(Duration(seconds: 1));
      
      isFacebookConnected.value = false;
      isFacebookAIPaused.value = false;
      facebookPageIdCtrl.clear();
      
      Get.snackbar(
        'Success',
        'Facebook disconnected successfully!',
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
    } catch (e) {
      print('❌ Error disconnecting Facebook: $e');
      Get.snackbar(
        'Error',
        'Failed to disconnect Facebook: $e',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isConnectingFacebook.value = false;
    }
  }

  /// Toggle Facebook AI pause
  void toggleFacebookAI() {
    isFacebookAIPaused.value = !isFacebookAIPaused.value;
    Get.snackbar(
      'Success',
      isFacebookAIPaused.value 
        ? 'Facebook AI paused' 
        : 'Facebook AI resumed',
      backgroundColor: Colors.green,
      colorText: Colors.white,
    );
  }

  /// Select channel
  void selectChannel(String channelName) {
    selectedChannel.value = channelName;
    isChannelDropdownOpen.value = false;
  }

  /// Toggle channel dropdown
  void toggleChannelDropdown() {
    isChannelDropdownOpen.value = !isChannelDropdownOpen.value;
  }

  /// Select widget color
  void selectWidgetColor(String colorName) {
    selectedWidgetColor.value = colorName;
  }

  @override
  void onClose() {
    websiteUrlCtrl.dispose();
    facebookPageIdCtrl.dispose();
    super.onClose();
  }
}
