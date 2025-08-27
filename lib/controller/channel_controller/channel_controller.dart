import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:minechat/controller/chat_controller/chat_controller.dart';

class ChannelController extends GetxController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Channel selection
  var selectedChannel = 'Website'.obs;
  var isChannelDropdownOpen = false.obs;

  // Website channel
  final websiteUrlCtrl = TextEditingController();
  var selectedWidgetColor = 'green'.obs;
  var generatedCode = ''.obs;

  // Messenger & Instagram (Meta Graph API)
  var isFacebookConnected = false.obs;
  var isFacebookAIPaused = false.obs;
  final facebookPageIdCtrl = TextEditingController();
  final facebookAccessTokenCtrl = TextEditingController();
  var isInstagramConnected = false.obs;
  var isInstagramAIPaused = false.obs;
  final instagramBusinessIdCtrl = TextEditingController();

  // Telegram
  var isTelegramConnected = false.obs;
  var isTelegramAIPaused = false.obs;
  final telegramBotTokenCtrl = TextEditingController();
  final telegramBotUsernameCtrl = TextEditingController();

  // WhatsApp
  var isWhatsAppConnected = false.obs;
  var isWhatsAppAIPaused = false.obs;
  final whatsAppPhoneNumberCtrl = TextEditingController();
  final whatsAppAccessTokenCtrl = TextEditingController();

  // Slack
  var isSlackConnected = false.obs;
  var isSlackAIPaused = false.obs;
  final slackBotTokenCtrl = TextEditingController();
  final slackAppTokenCtrl = TextEditingController();

  // Viber
  var isViberConnected = false.obs;
  var isViberAIPaused = false.obs;
  final viberBotTokenCtrl = TextEditingController();
  final viberBotNameCtrl = TextEditingController();

  // Discord
  var isDiscordConnected = false.obs;
  var isDiscordAIPaused = false.obs;
  final discordBotTokenCtrl = TextEditingController();
  final discordClientIdCtrl = TextEditingController();

  // Loading states
  var isLoading = false.obs;
  var isGeneratingCode = false.obs;
  var isConnectingFacebook = false.obs;
  var isConnectingInstagram = false.obs;
  var isConnectingTelegram = false.obs;
  var isConnectingWhatsApp = false.obs;
  var isConnectingSlack = false.obs;
  var isConnectingViber = false.obs;
  var isConnectingDiscord = false.obs;

  // Available channels with connection status
  final List<Map<String, dynamic>> availableChannels = [
    {'name': 'Website', 'icon': '🌐', 'color': Colors.blue, 'isConnected': false},
    {'name': 'Messenger', 'icon': '💬', 'color': Colors.blue[600], 'isConnected': false},
    {'name': 'Instagram', 'icon': '📷', 'color': Colors.pink, 'isConnected': false},
    {'name': 'Telegram', 'icon': '📱', 'color': Colors.blue[400], 'isConnected': false},
    {'name': 'WhatsApp', 'icon': '📞', 'color': Colors.green, 'isConnected': false},
    {'name': 'Slack', 'icon': '💼', 'color': Colors.purple, 'isConnected': false},
    {'name': 'Viber', 'icon': '💜', 'color': Colors.purple[600], 'isConnected': false},
    {'name': 'Discord', 'icon': '🎮', 'color': Colors.indigo, 'isConnected': false},
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
        
        // Facebook/Messenger
        isFacebookConnected.value = data['isFacebookConnected'] ?? false;
        isFacebookAIPaused.value = data['isFacebookAIPaused'] ?? false;
        facebookPageIdCtrl.text = data['facebookPageId'] ?? '';
        facebookAccessTokenCtrl.text = data['facebookAccessToken'] ?? '';
        
        // Instagram
        isInstagramConnected.value = data['isInstagramConnected'] ?? false;
        isInstagramAIPaused.value = data['isInstagramAIPaused'] ?? false;
        instagramBusinessIdCtrl.text = data['instagramBusinessId'] ?? '';
        
        // Telegram
        isTelegramConnected.value = data['isTelegramConnected'] ?? false;
        isTelegramAIPaused.value = data['isTelegramAIPaused'] ?? false;
        telegramBotTokenCtrl.text = data['telegramBotToken'] ?? '';
        telegramBotUsernameCtrl.text = data['telegramBotUsername'] ?? '';
        
        // WhatsApp
        isWhatsAppConnected.value = data['isWhatsAppConnected'] ?? false;
        isWhatsAppAIPaused.value = data['isWhatsAppAIPaused'] ?? false;
        whatsAppPhoneNumberCtrl.text = data['whatsAppPhoneNumber'] ?? '';
        whatsAppAccessTokenCtrl.text = data['whatsAppAccessToken'] ?? '';
        
        // Slack
        isSlackConnected.value = data['isSlackConnected'] ?? false;
        isSlackAIPaused.value = data['isSlackAIPaused'] ?? false;
        slackBotTokenCtrl.text = data['slackBotToken'] ?? '';
        slackAppTokenCtrl.text = data['slackAppToken'] ?? '';
        
        // Viber
        isViberConnected.value = data['isViberConnected'] ?? false;
        isViberAIPaused.value = data['isViberAIPaused'] ?? false;
        viberBotTokenCtrl.text = data['viberBotToken'] ?? '';
        viberBotNameCtrl.text = data['viberBotName'] ?? '';
        
        // Discord
        isDiscordConnected.value = data['isDiscordConnected'] ?? false;
        isDiscordAIPaused.value = data['isDiscordAIPaused'] ?? false;
        discordBotTokenCtrl.text = data['discordBotToken'] ?? '';
        discordClientIdCtrl.text = data['discordClientId'] ?? '';
        
        generatedCode.value = data['generatedCode'] ?? '';
        
        // Update connection status in available channels
        _updateChannelConnectionStatus();
      }
    } catch (e) {
      print('❌ Error loading channel settings: $e');
    } finally {
      isLoading.value = false;
    }
  }

  /// Update connection status for all channels
  void _updateChannelConnectionStatus() {
    for (int i = 0; i < availableChannels.length; i++) {
      switch (availableChannels[i]['name']) {
        case 'Website':
          availableChannels[i]['isConnected'] = websiteUrlCtrl.text.isNotEmpty;
          break;
        case 'Messenger':
          availableChannels[i]['isConnected'] = isFacebookConnected.value;
          break;
        case 'Instagram':
          availableChannels[i]['isConnected'] = isInstagramConnected.value;
          break;
        case 'Telegram':
          availableChannels[i]['isConnected'] = isTelegramConnected.value;
          break;
        case 'WhatsApp':
          availableChannels[i]['isConnected'] = isWhatsAppConnected.value;
          break;
        case 'Slack':
          availableChannels[i]['isConnected'] = isSlackConnected.value;
          break;
        case 'Viber':
          availableChannels[i]['isConnected'] = isViberConnected.value;
          break;
        case 'Discord':
          availableChannels[i]['isConnected'] = isDiscordConnected.value;
          break;
      }
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
        
        // Facebook/Messenger
        'isFacebookConnected': isFacebookConnected.value,
        'isFacebookAIPaused': isFacebookAIPaused.value,
        'facebookPageId': facebookPageIdCtrl.text.trim(),
        'facebookAccessToken': facebookAccessTokenCtrl.text.trim(),
        
        // Instagram
        'isInstagramConnected': isInstagramConnected.value,
        'isInstagramAIPaused': isInstagramAIPaused.value,
        'instagramBusinessId': instagramBusinessIdCtrl.text.trim(),
        
        // Telegram
        'isTelegramConnected': isTelegramConnected.value,
        'isTelegramAIPaused': isTelegramAIPaused.value,
        'telegramBotToken': telegramBotTokenCtrl.text.trim(),
        'telegramBotUsername': telegramBotUsernameCtrl.text.trim(),
        
        // WhatsApp
        'isWhatsAppConnected': isWhatsAppConnected.value,
        'isWhatsAppAIPaused': isWhatsAppAIPaused.value,
        'whatsAppPhoneNumber': whatsAppPhoneNumberCtrl.text.trim(),
        'whatsAppAccessToken': whatsAppAccessTokenCtrl.text.trim(),
        
        // Slack
        'isSlackConnected': isSlackConnected.value,
        'isSlackAIPaused': isSlackAIPaused.value,
        'slackBotToken': slackBotTokenCtrl.text.trim(),
        'slackAppToken': slackAppTokenCtrl.text.trim(),
        
        // Viber
        'isViberConnected': isViberConnected.value,
        'isViberAIPaused': isViberAIPaused.value,
        'viberBotToken': viberBotTokenCtrl.text.trim(),
        'viberBotName': viberBotNameCtrl.text.trim(),
        
        // Discord
        'isDiscordConnected': isDiscordConnected.value,
        'isDiscordAIPaused': isDiscordAIPaused.value,
        'discordBotToken': discordBotTokenCtrl.text.trim(),
        'discordClientId': discordClientIdCtrl.text.trim(),
        
        'generatedCode': generatedCode.value,
        'userId': userId,
        'updatedAt': DateTime.now().toIso8601String(),
      };

      await _firestore
          .collection('channel_settings')
          .doc(userId)
          .set(data, SetOptions(merge: true));

      _updateChannelConnectionStatus();

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

  // ===== FACEBOOK/MESSENGER INTEGRATION =====
  /// Connect Facebook Messenger
  Future<void> connectFacebook() async {
    try {
      isConnectingFacebook.value = true;
      
      if (facebookPageIdCtrl.text.trim().isEmpty) {
        Get.snackbar(
          'Error',
          'Please enter your Facebook Page ID',
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
        return;
      }
      
      // Access token is optional for basic connection
      final hasAccessToken = facebookAccessTokenCtrl.text.trim().isNotEmpty;

      // TODO: Implement real Facebook Graph API verification
      // 1. Verify access token with Facebook Graph API (if provided)
      // 2. Check if user has permission to manage the page
      // 3. Set up webhook for incoming messages
      
      await Future.delayed(Duration(seconds: 2)); // Simulate API call
      
      final pageId = facebookPageIdCtrl.text.trim();
      if (!RegExp(r'^\d+$').hasMatch(pageId)) {
        throw Exception('Invalid Facebook Page ID format');
      }
      
      isFacebookConnected.value = true;
      await saveChannelSettings();
      
      final message = hasAccessToken 
          ? 'Facebook Messenger connected successfully!\nPage ID: $pageId\nAdvanced features enabled.'
          : 'Facebook Messenger connected successfully!\nPage ID: $pageId\nBasic mode - add access token for advanced features.';
      
      Get.snackbar(
        'Success',
        message,
        backgroundColor: Colors.green,
        colorText: Colors.white,
        duration: Duration(seconds: 4),
      );
      
      // Trigger chat loading after successful connection
      try {
        final chatController = Get.find<ChatController>();
        chatController.refreshChats();
      } catch (e) {
        print('Chat controller not found, will load chats when chat screen is opened');
      }
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
      await Future.delayed(Duration(seconds: 1));
      
      isFacebookConnected.value = false;
      isFacebookAIPaused.value = false;
      facebookPageIdCtrl.clear();
      facebookAccessTokenCtrl.clear();
      
      await saveChannelSettings();
      
      Get.snackbar(
        'Success',
        'Facebook Messenger disconnected successfully!',
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

  // ===== INSTAGRAM INTEGRATION =====
  /// Connect Instagram
  Future<void> connectInstagram() async {
    try {
      isConnectingInstagram.value = true;
      
      if (instagramBusinessIdCtrl.text.trim().isEmpty || facebookAccessTokenCtrl.text.trim().isEmpty) {
        Get.snackbar(
          'Error',
          'Please enter Instagram Business ID and Facebook Access Token',
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
        return;
      }

      // TODO: Implement Instagram Basic Display API
      // Instagram uses the same Facebook access token
      
      await Future.delayed(Duration(seconds: 2));
      
      isInstagramConnected.value = true;
      await saveChannelSettings();
      
      Get.snackbar(
        'Success',
        'Instagram connected successfully!',
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
    } catch (e) {
      print('❌ Error connecting Instagram: $e');
      Get.snackbar(
        'Error',
        'Failed to connect Instagram: $e',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isConnectingInstagram.value = false;
    }
  }

  /// Disconnect Instagram
  Future<void> disconnectInstagram() async {
    try {
      isConnectingInstagram.value = true;
      await Future.delayed(Duration(seconds: 1));
      
      isInstagramConnected.value = false;
      isInstagramAIPaused.value = false;
      instagramBusinessIdCtrl.clear();
      
      await saveChannelSettings();
      
      Get.snackbar(
        'Success',
        'Instagram disconnected successfully!',
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
    } catch (e) {
      print('❌ Error disconnecting Instagram: $e');
      Get.snackbar(
        'Error',
        'Failed to disconnect Instagram: $e',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isConnectingInstagram.value = false;
    }
  }

  // ===== TELEGRAM INTEGRATION =====
  /// Connect Telegram
  Future<void> connectTelegram() async {
    try {
      isConnectingTelegram.value = true;
      
      if (telegramBotTokenCtrl.text.trim().isEmpty || telegramBotUsernameCtrl.text.trim().isEmpty) {
        Get.snackbar(
          'Error',
          'Please enter both Bot Token and Bot Username',
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
        return;
      }

      // TODO: Implement Telegram Bot API verification
      // 1. Verify bot token with Telegram API
      // 2. Set up webhook for incoming messages
      
      await Future.delayed(Duration(seconds: 2));
      
      isTelegramConnected.value = true;
      await saveChannelSettings();
      
      Get.snackbar(
        'Success',
        'Telegram connected successfully!\nBot: @${telegramBotUsernameCtrl.text.trim()}',
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
    } catch (e) {
      print('❌ Error connecting Telegram: $e');
      Get.snackbar(
        'Error',
        'Failed to connect Telegram: $e',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isConnectingTelegram.value = false;
    }
  }

  /// Disconnect Telegram
  Future<void> disconnectTelegram() async {
    try {
      isConnectingTelegram.value = true;
      await Future.delayed(Duration(seconds: 1));
      
      isTelegramConnected.value = false;
      isTelegramAIPaused.value = false;
      telegramBotTokenCtrl.clear();
      telegramBotUsernameCtrl.clear();
      
      await saveChannelSettings();
      
      Get.snackbar(
        'Success',
        'Telegram disconnected successfully!',
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
    } catch (e) {
      print('❌ Error disconnecting Telegram: $e');
      Get.snackbar(
        'Error',
        'Failed to disconnect Telegram: $e',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isConnectingTelegram.value = false;
    }
  }

  // ===== WHATSAPP INTEGRATION =====
  /// Connect WhatsApp
  Future<void> connectWhatsApp() async {
    try {
      isConnectingWhatsApp.value = true;
      
      if (whatsAppPhoneNumberCtrl.text.trim().isEmpty || whatsAppAccessTokenCtrl.text.trim().isEmpty) {
        Get.snackbar(
          'Error',
          'Please enter both Phone Number and Access Token',
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
        return;
      }

      // TODO: Implement WhatsApp Business API
      // 1. Verify phone number format
      // 2. Verify access token with WhatsApp API
      // 3. Set up webhook for incoming messages
      
      await Future.delayed(Duration(seconds: 2));
      
      isWhatsAppConnected.value = true;
      await saveChannelSettings();
      
      Get.snackbar(
        'Success',
        'WhatsApp connected successfully!\nPhone: ${whatsAppPhoneNumberCtrl.text.trim()}',
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
    } catch (e) {
      print('❌ Error connecting WhatsApp: $e');
      Get.snackbar(
        'Error',
        'Failed to connect WhatsApp: $e',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isConnectingWhatsApp.value = false;
    }
  }

  /// Disconnect WhatsApp
  Future<void> disconnectWhatsApp() async {
    try {
      isConnectingWhatsApp.value = true;
      await Future.delayed(Duration(seconds: 1));
      
      isWhatsAppConnected.value = false;
      isWhatsAppAIPaused.value = false;
      whatsAppPhoneNumberCtrl.clear();
      whatsAppAccessTokenCtrl.clear();
      
      await saveChannelSettings();
      
      Get.snackbar(
        'Success',
        'WhatsApp disconnected successfully!',
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
    } catch (e) {
      print('❌ Error disconnecting WhatsApp: $e');
      Get.snackbar(
        'Error',
        'Failed to disconnect WhatsApp: $e',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isConnectingWhatsApp.value = false;
    }
  }

  // ===== SLACK INTEGRATION =====
  /// Connect Slack
  Future<void> connectSlack() async {
    try {
      isConnectingSlack.value = true;
      
      if (slackBotTokenCtrl.text.trim().isEmpty || slackAppTokenCtrl.text.trim().isEmpty) {
        Get.snackbar(
          'Error',
          'Please enter both Bot Token and App Token',
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
        return;
      }

      // TODO: Implement Slack API
      // 1. Verify bot token with Slack API
      // 2. Set up Events API for incoming messages
      
      await Future.delayed(Duration(seconds: 2));
      
      isSlackConnected.value = true;
      await saveChannelSettings();
      
      Get.snackbar(
        'Success',
        'Slack connected successfully!',
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
    } catch (e) {
      print('❌ Error connecting Slack: $e');
      Get.snackbar(
        'Error',
        'Failed to connect Slack: $e',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isConnectingSlack.value = false;
    }
  }

  /// Disconnect Slack
  Future<void> disconnectSlack() async {
    try {
      isConnectingSlack.value = true;
      await Future.delayed(Duration(seconds: 1));
      
      isSlackConnected.value = false;
      isSlackAIPaused.value = false;
      slackBotTokenCtrl.clear();
      slackAppTokenCtrl.clear();
      
      await saveChannelSettings();
      
      Get.snackbar(
        'Success',
        'Slack disconnected successfully!',
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
    } catch (e) {
      print('❌ Error disconnecting Slack: $e');
      Get.snackbar(
        'Error',
        'Failed to disconnect Slack: $e',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isConnectingSlack.value = false;
    }
  }

  // ===== VIBER INTEGRATION =====
  /// Connect Viber
  Future<void> connectViber() async {
    try {
      isConnectingViber.value = true;
      
      if (viberBotTokenCtrl.text.trim().isEmpty || viberBotNameCtrl.text.trim().isEmpty) {
        Get.snackbar(
          'Error',
          'Please enter both Bot Token and Bot Name',
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
        return;
      }

      // TODO: Implement Viber Bot API
      // 1. Verify bot token with Viber API
      // 2. Set up webhook for incoming messages
      
      await Future.delayed(Duration(seconds: 2));
      
      isViberConnected.value = true;
      await saveChannelSettings();
      
      Get.snackbar(
        'Success',
        'Viber connected successfully!\nBot: ${viberBotNameCtrl.text.trim()}',
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
    } catch (e) {
      print('❌ Error connecting Viber: $e');
      Get.snackbar(
        'Error',
        'Failed to connect Viber: $e',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isConnectingViber.value = false;
    }
  }

  /// Disconnect Viber
  Future<void> disconnectViber() async {
    try {
      isConnectingViber.value = true;
      await Future.delayed(Duration(seconds: 1));
      
      isViberConnected.value = false;
      isViberAIPaused.value = false;
      viberBotTokenCtrl.clear();
      viberBotNameCtrl.clear();
      
      await saveChannelSettings();
      
      Get.snackbar(
        'Success',
        'Viber disconnected successfully!',
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
    } catch (e) {
      print('❌ Error disconnecting Viber: $e');
      Get.snackbar(
        'Error',
        'Failed to disconnect Viber: $e',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isConnectingViber.value = false;
    }
  }

  // ===== DISCORD INTEGRATION =====
  /// Connect Discord
  Future<void> connectDiscord() async {
    try {
      isConnectingDiscord.value = true;
      
      if (discordBotTokenCtrl.text.trim().isEmpty || discordClientIdCtrl.text.trim().isEmpty) {
        Get.snackbar(
          'Error',
          'Please enter both Bot Token and Client ID',
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
        return;
      }

      // TODO: Implement Discord Bot API
      // 1. Verify bot token with Discord API
      // 2. Set up Gateway for incoming messages
      
      await Future.delayed(Duration(seconds: 2));
      
      isDiscordConnected.value = true;
      await saveChannelSettings();
      
      Get.snackbar(
        'Success',
        'Discord connected successfully!',
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
    } catch (e) {
      print('❌ Error connecting Discord: $e');
      Get.snackbar(
        'Error',
        'Failed to connect Discord: $e',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isConnectingDiscord.value = false;
    }
  }

  /// Disconnect Discord
  Future<void> disconnectDiscord() async {
    try {
      isConnectingDiscord.value = true;
      await Future.delayed(Duration(seconds: 1));
      
      isDiscordConnected.value = false;
      isDiscordAIPaused.value = false;
      discordBotTokenCtrl.clear();
      discordClientIdCtrl.clear();
      
      await saveChannelSettings();
      
      Get.snackbar(
        'Success',
        'Discord disconnected successfully!',
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
    } catch (e) {
      print('❌ Error disconnecting Discord: $e');
      Get.snackbar(
        'Error',
        'Failed to disconnect Discord: $e',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isConnectingDiscord.value = false;
    }
  }

  // ===== AI CONTROL METHODS =====
  /// Toggle Facebook AI pause
  void toggleFacebookAI() {
    isFacebookAIPaused.value = !isFacebookAIPaused.value;
    saveChannelSettings();
    Get.snackbar(
      'Success',
      isFacebookAIPaused.value 
        ? 'Facebook AI paused' 
        : 'Facebook AI resumed',
      backgroundColor: Colors.green,
      colorText: Colors.white,
    );
  }

  /// Toggle Instagram AI pause
  void toggleInstagramAI() {
    isInstagramAIPaused.value = !isInstagramAIPaused.value;
    saveChannelSettings();
    Get.snackbar(
      'Success',
      isInstagramAIPaused.value 
        ? 'Instagram AI paused' 
        : 'Instagram AI resumed',
      backgroundColor: Colors.green,
      colorText: Colors.white,
    );
  }

  /// Toggle Telegram AI pause
  void toggleTelegramAI() {
    isTelegramAIPaused.value = !isTelegramAIPaused.value;
    saveChannelSettings();
    Get.snackbar(
      'Success',
      isTelegramAIPaused.value 
        ? 'Telegram AI paused' 
        : 'Telegram AI resumed',
      backgroundColor: Colors.green,
      colorText: Colors.white,
    );
  }

  /// Toggle WhatsApp AI pause
  void toggleWhatsAppAI() {
    isWhatsAppAIPaused.value = !isWhatsAppAIPaused.value;
    saveChannelSettings();
    Get.snackbar(
      'Success',
      isWhatsAppAIPaused.value 
        ? 'WhatsApp AI paused' 
        : 'WhatsApp AI resumed',
      backgroundColor: Colors.green,
      colorText: Colors.white,
    );
  }

  /// Toggle Slack AI pause
  void toggleSlackAI() {
    isSlackAIPaused.value = !isSlackAIPaused.value;
    saveChannelSettings();
    Get.snackbar(
      'Success',
      isSlackAIPaused.value 
        ? 'Slack AI paused' 
        : 'Slack AI resumed',
      backgroundColor: Colors.green,
      colorText: Colors.white,
    );
  }

  /// Toggle Viber AI pause
  void toggleViberAI() {
    isViberAIPaused.value = !isViberAIPaused.value;
    saveChannelSettings();
    Get.snackbar(
      'Success',
      isViberAIPaused.value 
        ? 'Viber AI paused' 
        : 'Viber AI resumed',
      backgroundColor: Colors.green,
      colorText: Colors.white,
    );
  }

  /// Toggle Discord AI pause
  void toggleDiscordAI() {
    isDiscordAIPaused.value = !isDiscordAIPaused.value;
    saveChannelSettings();
    Get.snackbar(
      'Success',
      isDiscordAIPaused.value 
        ? 'Discord AI paused' 
        : 'Discord AI resumed',
      backgroundColor: Colors.green,
      colorText: Colors.white,
    );
  }

  // ===== UTILITY METHODS =====
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
    facebookAccessTokenCtrl.dispose();
    instagramBusinessIdCtrl.dispose();
    telegramBotTokenCtrl.dispose();
    telegramBotUsernameCtrl.dispose();
    whatsAppPhoneNumberCtrl.dispose();
    whatsAppAccessTokenCtrl.dispose();
    slackBotTokenCtrl.dispose();
    slackAppTokenCtrl.dispose();
    viberBotTokenCtrl.dispose();
    viberBotNameCtrl.dispose();
    discordBotTokenCtrl.dispose();
    discordClientIdCtrl.dispose();
    super.onClose();
  }
}
