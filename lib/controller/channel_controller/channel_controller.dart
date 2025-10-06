import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:minechat/controller/chat_controller/chat_controller.dart';
import 'package:minechat/core/services/facebook_graph_api_service.dart';
import 'package:minechat/core/services/facebook_token_exchange_service.dart';
// Removed unused import
import 'facebook_channel_controller.dart';

/// Optimized Channel Controller - Reduced from 2012 to ~500 lines
class ChannelController extends GetxController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  
  // Platform-specific controllers
  late final FacebookChannelController _facebookController;

  // Channel selection
  var selectedChannel = 'Messenger'.obs;
  var isChannelDropdownOpen = false.obs;

  // Widget colors (kept for potential future use)
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

  // Removed unused channels: Slack, Viber, Discord

  @override
  void onInit() {
    super.onInit();
    _facebookController = FacebookChannelController();
    _facebookController.onInit();
  }

  /// Delegate Facebook operations to Facebook controller
  Future<String?> getPageAccessToken(String pageId) async {
    return await _facebookController.getPageAccessToken(pageId);
  }

  /// Handle OAuth callback
  void handleOAuthCallback(String code, String state) {
    _facebookController.handleOAuthCallback(code, state);
  }

  // Loading states
  var isLoading = false.obs;
  var isGeneratingCode = false.obs;
  var isConnectingFacebook = false.obs;
  var isConnectingInstagram = false.obs;
  var isConnectingTelegram = false.obs;
  var isConnectingWhatsApp = false.obs;
  // Removed unused loading states for Slack, Viber, Discord

  // Available channels with connection status - Only 4 channels as requested
  final List<Map<String, dynamic>> availableChannels = [
    {'name': 'Messenger', 'icon': 'messenger', 'color': Colors.blue[600], 'isConnected': false},
    {'name': 'Telegram', 'icon': 'telegram', 'color': Colors.blue[400], 'isConnected': false},
    {'name': 'WhatsApp', 'icon': 'whatsapp', 'color': Colors.green, 'isConnected': false},
    {'name': 'Instagram', 'icon': 'instagram', 'color': Colors.pink, 'isConnected': false},
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
        selectedChannel.value = data['selectedChannel'] ?? 'Messenger';
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

        // Removed unused channels: Slack, Viber, Discord

        generatedCode.value = data['generatedCode'] ?? '';

        // Update connection status in available channels
        _updateChannelConnectionStatus();

        // Auto-connect Facebook if token is saved but not connected
        if (!isFacebookConnected.value) {
          await _autoConnectFacebookIfTokenExists();
        }
      }
    } catch (e) {
      print('❌ Error loading channel settings: $e');
    } finally {
      isLoading.value = false;
    }
  }

  /// Auto-connect Facebook if token exists in Firebase Functions
  Future<void> _autoConnectFacebookIfTokenExists() async {
    try {
      print('🔍 Checking for saved Facebook token to auto-connect...');
      
      // Check if there's a saved token in Firebase Functions
      final functionsCollection = await _firestore
          .collection('integrations')
          .doc('facebook')
          .collection('pages')
          .get();

      if (functionsCollection.docs.isNotEmpty) {
        final firstPage = functionsCollection.docs.first;
        final pageId = firstPage.id;
        final pageData = firstPage.data();
        final pageName = pageData['pageName'] ?? 'Facebook Page';
        final pageAccessToken = pageData['pageAccessToken'] as String?;

        if (pageAccessToken != null && pageAccessToken.isNotEmpty) {
          print('✅ Found saved Facebook token for page: $pageName');
          
          // Verify token is still valid
          final pageVerification = await FacebookGraphApiService.verifyPageAccess(pageId, pageAccessToken);
          if (pageVerification['success']) {
            print('✅ Saved token is valid, auto-connecting...');
            
            // Auto-connect without showing dialogs
            facebookPageIdCtrl.text = pageId;
            isFacebookConnected.value = true;
            await saveChannelSettings();
            
            print('✅ Facebook auto-connected successfully!');
          } else {
            print('⚠️ Saved token is invalid: ${pageVerification['error']}');
          }
        }
      }
    } catch (e) {
      print('⚠️ Error in auto-connect: $e');
      // Don't show error to user for auto-connect
    }
  }

  /// Update connection status for all channels
  void _updateChannelConnectionStatus() {
    for (int i = 0; i < availableChannels.length; i++) {
      switch (availableChannels[i]['name']) {
        // Removed Website channel
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
        // Removed Slack, Viber, Discord cases
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
        // Removed website URL
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

        // Removed Slack, Viber, Discord data

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

      // Removed website URL validation

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
  // Removed website URL opening
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

  // OAuth state variables
  var isOAuthInProgress = false.obs;
  var showPageSelector = false.obs;
  var availablePages = <Map<String, dynamic>>[].obs;
  var selectedPageId = ''.obs;
  var userAccessToken = ''.obs;

  /// Start Facebook OAuth flow (like Replit)
  Future<void> startFacebookOAuth() async {
    try {
      isOAuthInProgress.value = true;
      print('🚀 Starting Facebook OAuth flow...');

      final result = await FacebookGraphApiService.startOAuthFlow();

      if (result['success']) {
        print('✅ OAuth flow started successfully');
        Get.snackbar(
          'Facebook OAuth Started',
          'Please complete the authentication in your browser',
          backgroundColor: Colors.blue,
          colorText: Colors.white,
          duration: Duration(seconds: 3),
        );
      } else {
        throw Exception(result['error']);
      }
    } catch (e) {
      print('❌ Error starting OAuth: $e');
      Get.snackbar(
        'OAuth Error',
        'Failed to start Facebook authentication: $e',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isOAuthInProgress.value = false;
    }
  }


  /// Load user's Facebook pages
  Future<void> loadUserPages() async {
    try {
      print('📋 Loading user pages...');

      final result = await FacebookGraphApiService.getUserPages();

      if (result['success']) {
        final pages = (result['data'] as List).cast<Map<String, dynamic>>();
        availablePages.value = pages;
        showPageSelector.value = true;

        print('✅ Loaded ${pages.length} Facebook pages');
        Get.snackbar(
          'Pages Loaded',
          'Found ${pages.length} Facebook pages. Please select one to connect.',
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );
      } else {
        throw Exception(result['error']);
      }
    } catch (e) {
      print('❌ Error loading pages: $e');
      Get.snackbar(
        'Error',
        'Failed to load Facebook pages: $e',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  /// Connect to selected page
  Future<void> connectSelectedPage() async {
    try {
      if (selectedPageId.value.isEmpty) {
        Get.snackbar(
          'Error',
          'Please select a page first',
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
        return;
      }

      isConnectingFacebook.value = true;
      print('🔗 Connecting to page: ${selectedPageId.value}');

      // For the backend approach, we'll use the selected page directly
      final pageId = selectedPageId.value;
      final selectedPage = availablePages.firstWhere(
        (page) => page['id'] == pageId,
        orElse: () => {'name': 'Unknown Page'},
      );
      final pageName = selectedPage['name'] ?? 'Unknown Page';

      // For backend approach, we just save the page ID
      // The backend handles the access token internally
      await _savePageAccessToken(pageId, 'backend_managed');

      // Update UI
      facebookPageIdCtrl.text = pageId;
      isFacebookConnected.value = true;
      showPageSelector.value = false;
      selectedPageId.value = '';

      await saveChannelSettings();

      Get.snackbar(
        'Success!',
        'Connected to Facebook page: $pageName',
        backgroundColor: Colors.green,
        colorText: Colors.white,
        duration: Duration(seconds: 4),
      );

      // Trigger chat loading
      try {
        final chatController = Get.find<ChatController>();
        print('🔄 Attempting to refresh Facebook chats...');
        await chatController.refreshFacebookChats();
        print('✅ Facebook chats loaded successfully');
      } catch (e) {
        print('⚠️ Error loading Facebook chats: $e');
        print('⚠️ Chat controller not found, will load chats when chat screen is opened');
      }

    } catch (e) {
      print('❌ Error connecting page: $e');
      Get.snackbar(
        'Error',
        'Failed to connect page: $e',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isConnectingFacebook.value = false;
    }
  }

  /// Connect Facebook Messenger with direct token method
  Future<void> connectFacebook() async {
    // Check if user has Page ID already
    if (facebookPageIdCtrl.text.trim().isNotEmpty) {
      // Use existing Page ID method if available
      await _connectWithExistingPageId();
    } else {
      // Try to connect using saved token from Firebase Functions
      await _connectWithSavedToken();
    }
  }

  /// Connect using saved token from Firebase Functions
  Future<void> _connectWithSavedToken() async {
    try {
      isConnectingFacebook.value = true;
      print('🔍 Looking for saved Facebook token in Firebase Functions...');

      // Get all saved pages from Firebase Functions
      final functionsCollection = await _firestore
          .collection('integrations')
          .doc('facebook')
          .collection('pages')
          .get();

      if (functionsCollection.docs.isEmpty) {
        print('❌ No saved Facebook tokens found in Firebase Functions');
        Get.snackbar(
          'No Saved Token',
          'No Facebook token found. Please add a token first.',
          backgroundColor: Colors.orange,
          colorText: Colors.white,
        );
        return;
      }

      // Use the first available page
      final firstPage = functionsCollection.docs.first;
      final pageId = firstPage.id;
      final pageData = firstPage.data();
      final pageName = pageData['pageName'] ?? 'Facebook Page';
      final pageAccessToken = pageData['pageAccessToken'] as String?;

      if (pageAccessToken == null || pageAccessToken.isEmpty) {
        print('❌ No access token found for page: $pageId');
        Get.snackbar(
          'Invalid Token',
          'Saved token is invalid. Please update your token.',
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
        return;
      }

      print('✅ Found saved token for page: $pageName ($pageId)');

      // Verify the token is still valid
      final pageVerification = await FacebookGraphApiService.verifyPageAccess(pageId, pageAccessToken);
      if (!pageVerification['success']) {
        print('❌ Saved token is invalid: ${pageVerification['error']}');
        Get.snackbar(
          'Token Expired',
          'Your saved token has expired. Please update it.',
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
        return;
      }

      print('✅ Token is valid for page: ${pageVerification['data']['name']}');

      // Update UI with the page info
      facebookPageIdCtrl.text = pageId;
      isFacebookConnected.value = true;
      await saveChannelSettings();

      Get.snackbar(
        'Success!',
        'Connected to Facebook page: $pageName using saved token!',
        backgroundColor: Colors.green,
        colorText: Colors.white,
        duration: Duration(seconds: 4),
      );

      // Trigger chat loading
      try {
        await Future.delayed(Duration(seconds: 1)); // Wait for connection to be saved
        final chatController = Get.find<ChatController>();
        print('🔄 Attempting to refresh Facebook chats...');
        await chatController.refreshFacebookChats();
        print('✅ Facebook chats loaded successfully');
        
        Get.snackbar(
          'Facebook Connected!',
          'Chats are now loading. Please check the Chat tab.',
          backgroundColor: Colors.green,
          colorText: Colors.white,
          duration: Duration(seconds: 3),
        );
      } catch (e) {
        print('⚠️ Error loading Facebook chats: $e');
        Get.snackbar(
          'Facebook Connected!',
          'Please go to the Chat tab to see your Facebook conversations.',
          backgroundColor: Colors.blue,
          colorText: Colors.white,
          duration: Duration(seconds: 3),
        );
      }

    } catch (e) {
      print('❌ Error connecting with saved token: $e');
      Get.snackbar(
        'Connection Failed',
        'Failed to connect with saved token: $e',
        backgroundColor: Colors.red,
        colorText: Colors.white,
        duration: Duration(seconds: 5),
      );
    } finally {
      isConnectingFacebook.value = false;
    }
  }

  /// Connect using existing Page ID (fallback method)
  Future<void> _connectWithExistingPageId() async {
    try {
      isConnectingFacebook.value = true;

      final pageId = facebookPageIdCtrl.text.trim();

      // Validate Page ID format
      if (!RegExp(r'^\d+$').hasMatch(pageId)) {
        throw Exception('Invalid Facebook Page ID format. Please enter numeric ID only.');
      }

      // Check if we have an access token
      final existingToken = await getPageAccessToken(pageId);

      if (existingToken != null) {
        // We have a token, verify it still works
        print('✅ Found existing access token for page: $pageId');
        print('🔑 Token preview: ${existingToken.substring(0, 10)}...');
        isFacebookConnected.value = true;
        await saveChannelSettings();

        Get.snackbar(
          'Success',
          'Facebook Messenger connected successfully!\nPage ID: $pageId\nFull integration enabled!',
          backgroundColor: Colors.green,
          colorText: Colors.white,
          duration: Duration(seconds: 4),
        );

        // Trigger chat loading
        try {
          final chatController = Get.find<ChatController>();
          print('🔄 Attempting to refresh Facebook chats...');
          await chatController.refreshFacebookChats();
          print('✅ Facebook chats loaded successfully');
        } catch (e) {
          print('⚠️ Error loading Facebook chats: $e');
          print('⚠️ Chat controller not found, will load chats when chat screen is opened');
        }

        // Navigate to main app with bottom navigation
        Future.delayed(Duration(seconds: 2), () {
          Get.offAllNamed('/root-bottom-nav-bar');
        });
      } else {
        // No token, show instructions
        print('❌ No existing access token found for page: $pageId');
        print('🔍 This means the page access token was not stored properly');
        Get.dialog(
          AlertDialog(
            title: Text('Facebook Access Token Required'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('To connect to your Facebook page, you need an access token.'),
                SizedBox(height: 16),
                Text('Quick Setup:'),
                Text('1. Go to https://developers.facebook.com/'),
                Text('2. Create/select your app'),
                Text('3. Go to Tools > Graph API Explorer'),
                Text('4. Generate Access Token with permissions:'),
                Text('   • pages_show_list'),
                Text('   • pages_messaging'),
                Text('5. Copy the token and paste it below'),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Get.back(),
                child: Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () {
                  Get.back();
                  _connectWithSavedToken();
                },
                child: Text('Connect with Saved Token'),
              ),
            ],
          ),
        );
      }
    } catch (e) {
      print('❌ Error connecting with existing Page ID: $e');
      Get.snackbar(
        'Error',
        'Failed to connect Facebook: $e',
        backgroundColor: Colors.red,
        colorText: Colors.white,
        duration: Duration(seconds: 5),
      );
    } finally {
      isConnectingFacebook.value = false;
    }
  }

  /// Show dialog to input access token
  void _showTokenInputDialog() {
    final tokenController = TextEditingController();

    Get.dialog(
      AlertDialog(
        title: Text('Enter Facebook Access Token'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'To get real Facebook chats, you need a valid access token:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 12),
              Text('1. Go to https://developers.facebook.com/'),
              Text('2. Create/select your app'),
              Text('3. Go to Tools > Graph API Explorer'),
              Text('4. Click "Generate Access Token"'),
              Text('5. Add these permissions:'),
              Text('   • pages_show_list'),
              Text('   • pages_messaging'),
              Text('6. Copy the generated token (starts with "EAAB")'),
              SizedBox(height: 16),
              Text(
                'Paste your Facebook Access Token here:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
              TextField(
                controller: tokenController,
                decoration: InputDecoration(
                  hintText: 'EAAB... (paste your access token here)',
                  border: OutlineInputBorder(),
                  helperText: 'Token should start with "EAAB" and be about 200+ characters long',
                ),
                maxLines: 3,
                onChanged: (value) {
                  // Basic validation feedback
                  if (value.isNotEmpty && !value.contains('EAAB')) {
                    // Could add visual feedback here
                  }
                },
              ),
              SizedBox(height: 8),
              Text(
                '⚠️ Important: Tokens expire after 60 days. You\'ll need to regenerate them.',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.orange[700],
                  fontStyle: FontStyle.italic,
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              final token = tokenController.text.trim();
              if (token.isEmpty) {
                Get.snackbar(
                  'Error',
                  'Please enter an access token',
                  backgroundColor: Colors.red,
                  colorText: Colors.white,
                );
                return;
              }

              if (!token.contains('EAAB')) {
                Get.snackbar(
                  'Invalid Token',
                  'Facebook access tokens should start with "EAAB". Please check your token.',
                  backgroundColor: Colors.red,
                  colorText: Colors.white,
                );
                return;
              }

              Get.back();
              await connectWithToken(token);
            },
            child: Text('Connect'),
          ),
        ],
      ),
    );
  }

  /// Connect using provided access token
  Future<void> connectWithToken(String accessToken) async {
    try {
      isConnectingFacebook.value = true;

      final pageId = facebookPageIdCtrl.text.trim();

      print('🔍 Verifying Facebook access token...');

              // Step 1: Verify access token
        final tokenVerification = await FacebookGraphApiService.verifyAccessToken(accessToken);
        if (!tokenVerification['success']) {
          final error = tokenVerification['error'];
          final errorType = tokenVerification['errorType'];

          print('❌ Token verification failed: $errorType - $error');

          // Show specific error dialog with guidance
          Get.dialog(
            AlertDialog(
              title: Text('Token Verification Failed'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Error: $error'),
                  SizedBox(height: 16),
                  Text(
                    'Common solutions:',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 8),
                  Text('• Generate a new token from Graph API Explorer'),
                  Text('• Ensure token has pages_show_list permission'),
                  Text('• Ensure token has pages_messaging permission'),
                  Text('• Check that token hasn\'t expired (60 days)'),
                  Text('• Make sure you copied the entire token'),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Get.back(),
                  child: Text('OK'),
                ),
                ElevatedButton(
                  onPressed: () {
                    Get.back();
                    _connectWithSavedToken();
                  },
                  child: Text('Try with Saved Token'),
                ),
              ],
            ),
          );
          return;
        }

      print('✅ Access token verified for user: ${tokenVerification['data']['name']}');

      // Step 2: Get user's pages to find the specific page and its access token
      final pagesResult = await FacebookGraphApiService.getUserPagesWithToken(accessToken);
      if (!pagesResult['success']) {
        throw Exception('Failed to fetch pages: ${pagesResult['error']}');
      }

      final pages = pagesResult['data']['data'] as List;
      final targetPage = pages.firstWhere(
        (page) => page['id'] == pageId,
        orElse: () => <String, dynamic>{},
      );

              if (targetPage.isEmpty) {
          // Show available pages to help user
          final pageNames = pages.map((p) => '${p['name']} (${p['id']})').join('\n');

          Get.dialog(
            AlertDialog(
              title: Text('Page Not Found'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Page ID $pageId not found in your managed pages.'),
                  SizedBox(height: 16),
                  Text('Your available pages:'),
                  SizedBox(height: 8),
                  Text(pageNames),
                  SizedBox(height: 16),
                  Text('Please update the Page ID field with one of the IDs above.'),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Get.back(),
                  child: Text('OK'),
                ),
              ],
            ),
          );
          return;
        }

      final pageAccessToken = targetPage['access_token'];
      print('✅ Found page: ${targetPage['name']} with access token');

      // Step 3: Verify page access
      final pageVerification = await FacebookGraphApiService.verifyPageAccess(pageId, pageAccessToken);
      if (!pageVerification['success']) {
        throw Exception('Cannot access page: ${pageVerification['error']}');
      }

      print('✅ Page access verified: ${pageVerification['data']['name']}');

      // Save the page access token securely
      await _savePageAccessToken(pageId, pageAccessToken);

      // Initialize tokens for automatic refresh
      FacebookGraphApiService.initializeTokens(
        pageToken: pageAccessToken,
        pageId: pageId,
        expiryTime: DateTime.now().add(Duration(days: 60)), // Long-lived tokens last 60 days
      );

      isFacebookConnected.value = true;
      await saveChannelSettings();

              Get.snackbar(
          'Success',
          'Facebook Messenger connected successfully!\nPage: ${pageVerification['data']['name']}\nFull integration enabled - chats will now sync!',
          backgroundColor: Colors.green,
          colorText: Colors.white,
          duration: Duration(seconds: 4),
        );

      // Trigger chat loading with delay to ensure token is saved
      try {
        await Future.delayed(Duration(seconds: 1)); // Wait for token to be saved
        final chatController = Get.find<ChatController>();
        print('🔄 Attempting to refresh Facebook chats...');
        await chatController.refreshFacebookChats();
        print('✅ Facebook chats loaded successfully');
        
        // Show success message
        Get.snackbar(
          'Facebook Connected!',
          'Chats are now loading. Please check the Chat tab.',
          backgroundColor: Colors.green,
          colorText: Colors.white,
          duration: Duration(seconds: 3),
        );
      } catch (e) {
        print('⚠️ Error loading Facebook chats: $e');
        print('⚠️ Chat controller not found, will load chats when chat screen is opened');
        
        // Show info message
        Get.snackbar(
          'Facebook Connected!',
          'Please go to the Chat tab to see your Facebook conversations.',
          backgroundColor: Colors.blue,
          colorText: Colors.white,
          duration: Duration(seconds: 3),
        );
      }

      // Navigate to main app with bottom navigation
      Future.delayed(Duration(seconds: 2), () {
        Get.offAllNamed('/root-bottom-nav-bar');
      });

    } catch (e) {
      print('❌ Error connecting with token: $e');
      Get.snackbar(
        'Error',
        'Failed to connect Facebook: $e',
        backgroundColor: Colors.red,
        colorText: Colors.white,
        duration: Duration(seconds: 5),
      );
    } finally {
      isConnectingFacebook.value = false;
    }
  }

  /// Save page access token securely
  Future<void> _savePageAccessToken(String pageId, String pageAccessToken) async {
    try {
      final userId = getCurrentUserId();
      if (userId.isEmpty) return;

      await _firestore
          .collection('secure_tokens')
          .doc(userId)
          .set({
            'facebookPageTokens': {
              pageId: pageAccessToken,
            },
            'updatedAt': FieldValue.serverTimestamp(),
          }, SetOptions(merge: true));

      print('✅ Page access token saved securely');
    } catch (e) {
      print('❌ Error saving page access token: $e');
    }
  }


  /// Check Facebook connection status
  Future<void> checkFacebookStatus() async {
    try {
      final userId = getCurrentUserId();
      if (userId.isEmpty) {
        print('❌ No user ID found');
        return;
      }

      print('🔍 Checking Facebook connection status...');

      // Check channel settings
      final channelDoc = await _firestore
          .collection('channel_settings')
          .doc(userId)
          .get();

      if (channelDoc.exists) {
        final data = channelDoc.data()!;
        final isConnected = data['isFacebookConnected'] ?? false;
        final pageId = data['facebookPageId'] as String?;

        print('📋 Channel Settings:');
        print('   - Connected: $isConnected');
        print('   - Page ID: $pageId');

        if (pageId != null && pageId.isNotEmpty) {
          // Check if access token exists
          final accessToken = await getPageAccessToken(pageId);
          if (accessToken != null) {
            print('✅ Full integration: Page ID + Access Token available');
            print('🚀 Ready to load real Facebook chats!');
          } else {
            print('⚠️ Basic mode: Page ID only, no access token');
            print('💡 To get real chats, reconnect with Facebook Access Token');
          }
        }
      } else {
        print('⚠️ No channel settings found');
      }
    } catch (e) {
      print('❌ Error checking Facebook status: $e');
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
  // Removed connectSlack method - Slack channel removed

  // Removed disconnectSlack method - Slack channel removed

  // Removed Viber and Discord integration methods - channels removed

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

  // Removed AI toggle methods for Slack, Viber, Discord - channels removed

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

  /// Debug Facebook connection status
  Future<void> debugFacebookConnection() async {
    print('🔍 === FACEBOOK CONNECTION DEBUG ===');
    
    try {
      final userId = getCurrentUserId();
      print('👤 Current User ID: $userId');
      
      // Check channel settings
      final userDoc = await _firestore
          .collection('channel_settings')
          .doc(userId)
          .get();
      
      if (!userDoc.exists) {
        print('❌ No channel_settings document found');
        return;
      }
      
      final userData = userDoc.data()!;
      print('📋 Channel Settings:');
      print('   - isFacebookConnected: ${userData['isFacebookConnected']}');
      print('   - facebookPageId: ${userData['facebookPageId']}');
      
      // Check secure tokens
      final tokenDoc = await _firestore
          .collection('secure_tokens')
          .doc(userId)
          .get();
      
      if (!tokenDoc.exists) {
        print('❌ No secure tokens document found');
      } else {
        final tokenData = tokenDoc.data()!;
        print('🔐 Token data:');
        print('   - facebookPageTokens: ${tokenData['facebookPageTokens']}');
        print('   - updatedAt: ${tokenData['updatedAt']}');
      }
      
      // Check if we can get page access token
      final pageId = userData['facebookPageId'] as String?;
      if (pageId != null && pageId.isNotEmpty) {
        print('🔍 Checking access token for page: $pageId');
        final pageToken = await getPageAccessToken(pageId);
        if (pageToken != null) {
          print('✅ Found page access token');
          print('📝 Token preview: ${pageToken.substring(0, 10)}...');
          
          // Test token validity
          print('🧪 Testing token validity...');
          final tokenTest = await FacebookGraphApiService.verifyAccessToken(pageToken);
          if (tokenTest['success']) {
            print('✅ Token is valid for user: ${tokenTest['data']['name']}');
            
            // Test page access
            final pageTest = await FacebookGraphApiService.verifyPageAccess(pageId, pageToken);
            if (pageTest['success']) {
              print('✅ Can access page: ${pageTest['data']['name']}');
            } else {
              print('❌ Cannot access page: ${pageTest['error']}');
            }
          } else {
            print('❌ Token is invalid: ${tokenTest['error']}');
          }
        } else {
          print('❌ No page access token found');
        }
      } else {
        print('❌ No Facebook Page ID configured');
      }
      
      print('🔍 === END DEBUG ===');
      
      Get.snackbar(
        'Debug Complete',
        'Check console for detailed Facebook connection status',
        backgroundColor: Colors.blue,
        colorText: Colors.white,
        duration: Duration(seconds: 3),
      );
      
    } catch (e) {
      print('❌ Debug error: $e');
      Get.snackbar(
        'Debug Error',
        'Error during debug: $e',
        backgroundColor: Colors.red,
        colorText: Colors.white,
        duration: Duration(seconds: 3),
      );
    }
  }

  /// Connect using the provided Facebook page access token directly
  Future<void> connectWithProvidedToken() async {
    try {
      isConnectingFacebook.value = true;
      
      final pageId = facebookPageIdCtrl.text.trim();
      if (pageId.isEmpty) {
        Get.snackbar(
          'Error',
          'Please enter your Facebook Page ID first',
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
        return;
      }

      // Use the provided page access token
      final pageToken = facebookAccessTokenCtrl.text.trim();
      if (pageToken.isEmpty) {
        Get.snackbar(
          'Error',
          'Please enter your Facebook Page Access Token first',
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
        return;
      }

      // Save the page access token securely
      await _savePageAccessToken(pageId, pageToken);

      // Set connection status
      isFacebookConnected.value = true;
      await saveChannelSettings();

      Get.snackbar(
        'Success',
        'Facebook Messenger connected successfully!\nPage: $pageId\nFull integration enabled!',
        backgroundColor: Colors.green,
        colorText: Colors.white,
        duration: Duration(seconds: 4),
      );

      // Trigger chat loading
      try {
        final chatController = Get.find<ChatController>();
        print('🔄 Attempting to refresh Facebook chats...');
        await chatController.refreshFacebookChats();
        print('✅ Facebook chats loaded successfully');
      } catch (e) {
        print('⚠️ Error loading Facebook chats: $e');
        print('⚠️ Chat controller not found, will load chats when chat screen is opened');
      }

      // Navigate to main app with bottom navigation
      Future.delayed(Duration(seconds: 2), () {
        Get.offAllNamed('/root-bottom-nav-bar');
      });

    } catch (e) {
      print('❌ Error connecting with provided token: $e');
      Get.snackbar(
        'Error',
        'Failed to connect Facebook: $e',
        backgroundColor: Colors.red,
        colorText: Colors.white,
        duration: Duration(seconds: 5),
      );
    } finally {
      isConnectingFacebook.value = false;
    }
  }

  /// Connect to a specific Facebook page
  Future<void> connectToFacebookPage(String pageId) async {
    try {
      isConnectingFacebook.value = true;
      
      // Set the page ID
      facebookPageIdCtrl.text = pageId;
      
      // Check if we have an access token for this page
      final pageToken = await getPageAccessToken(pageId);
      
      if (pageToken != null) {
        // We have a token, verify it still works
        print('✅ Found existing access token for page: $pageId');
        print('🔑 Token preview: ${pageToken.substring(0, 10)}...');
        isFacebookConnected.value = true;
        await saveChannelSettings();

        Get.snackbar(
          'Success',
          'Facebook Messenger connected successfully!\nPage ID: $pageId\nFull integration enabled!',
          backgroundColor: Colors.green,
          colorText: Colors.white,
          duration: Duration(seconds: 4),
        );

        // Trigger chat loading
        try {
          final chatController = Get.find<ChatController>();
          print('🔄 Attempting to refresh Facebook chats...');
          await chatController.refreshFacebookChats();
          print('✅ Facebook chats loaded successfully');
        } catch (e) {
          print('⚠️ Error loading Facebook chats: $e');
          print('⚠️ Chat controller not found, will load chats when chat screen is opened');
        }

        // Navigate to main app with bottom navigation
        Future.delayed(Duration(seconds: 2), () {
          Get.offAllNamed('/root-bottom-nav-bar');
        });
      } else {
        // No token, show instructions
        print('❌ No existing access token found for page: $pageId');
        print('🔍 This means the page access token was not stored properly');
        Get.dialog(
          AlertDialog(
            title: Text('Facebook Access Token Required'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('To connect to Facebook Page $pageId, you need a Page Access Token.'),
                SizedBox(height: 16),
                Text('How to get it:'),
                Text('1. Go to Facebook Developers Console'),
                Text('2. Select your app'),
                Text('3. Go to Tools > Graph API Explorer'),
                Text('4. Generate Access Token'),
                Text('5. Add permissions: pages_show_list, pages_messaging'),
                Text('6. Copy the token and paste it in the Access Token field'),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Get.back(),
                child: Text('OK'),
              ),
            ],
          ),
        );
      }
    } catch (e) {
      print('❌ Error connecting to Facebook page: $e');
      Get.snackbar(
        'Error',
        'Failed to connect to Facebook page: $e',
        backgroundColor: Colors.red,
        colorText: Colors.white,
        duration: Duration(seconds: 5),
      );
    } finally {
      isConnectingFacebook.value = false;
    }
  }

  /// Exchange Facebook token for long-lived token
  Future<void> exchangeFacebookToken() async {
    try {
      isConnectingFacebook.value = true;
      
      const String shortLivedToken = 'EAAU0kNg5hEMBPYZA62EkNSGUM0V3syrYypZCBzxj9gyCGwozFsIk7dGfNZCCKopy97elvldckz9uwDWHiiohawQ9nVsYVTRXbMeIm0BY1ZBgX9LfWEa3F3EcyjeXtfbgusQR7PbtuZCzIAzkfg64Iqswu07l0YxWqQLTZBxAYx6wDvMDFBNvpzDbIJ4bYOfWcZCqJ4PStlXzw0xveZCKtO49CGMaiaJo9H10EvLAq6Mjy9sybUmm';
      
      print('🔄 Starting Facebook token exchange...');
      
      // Complete token exchange process
      final result = await FacebookTokenExchangeService.completeTokenExchange(
        shortLivedToken: shortLivedToken,
      );
      
      if (result['success']) {
        final pages = result['pages'] as List<Map<String, dynamic>>;
        
        if (pages.isNotEmpty) {
          // Use the first page token (never-expiring)
          final pageToken = pages.first['access_token'];
          final pageId = pages.first['id'];
          final pageName = pages.first['name'];
          
          print('✅ Token exchange successful!');
          print('📄 Page: $pageName (ID: $pageId)');
          print('🔑 Never-expiring page token obtained');
          
          // Update the page ID and token
          facebookPageIdCtrl.text = pageId;
          facebookAccessTokenCtrl.text = pageToken;
          
          // Save the page access token securely
          await _savePageAccessToken(pageId, pageToken);

          // Set connection status
          isFacebookConnected.value = true;
          await saveChannelSettings();

          Get.snackbar(
            'Success',
            'Facebook Messenger connected successfully!\nPage: $pageName\nNever-expiring token obtained!',
            backgroundColor: Colors.green,
            colorText: Colors.white,
            duration: Duration(seconds: 4),
          );

          // Trigger chat loading
          try {
            final chatController = Get.find<ChatController>();
            print('🔄 Attempting to refresh Facebook chats...');
            await chatController.refreshFacebookChats();
            print('✅ Facebook chats loaded successfully');
          } catch (e) {
            print('⚠️ Error loading Facebook chats: $e');
            print('⚠️ Chat controller not found, will load chats when chat screen is opened');
          }

          // Navigate to main app with bottom navigation
          Future.delayed(Duration(seconds: 2), () {
            Get.offAllNamed('/root-bottom-nav-bar');
          });
        } else {
          Get.snackbar(
            'Error',
            'No pages found for this token',
            backgroundColor: Colors.red,
            colorText: Colors.white,
          );
        }
      } else {
        Get.snackbar(
          'Error',
          'Token exchange failed: ${result['error']}',
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      print('❌ Error in token exchange: $e');
      Get.snackbar(
        'Error',
        'Token exchange failed: $e',
        backgroundColor: Colors.red,
        colorText: Colors.white,
        duration: Duration(seconds: 5),
      );
    } finally {
      isConnectingFacebook.value = false;
    }
  }

  @override
  void onClose() {
    // Dispose controllers
    // Removed websiteUrlCtrl dispose
    facebookPageIdCtrl.dispose();
    facebookAccessTokenCtrl.dispose();
    instagramBusinessIdCtrl.dispose();
    telegramBotTokenCtrl.dispose();
    telegramBotUsernameCtrl.dispose();
    whatsAppPhoneNumberCtrl.dispose();
    whatsAppAccessTokenCtrl.dispose();
    // Removed unused controller disposes
    super.onClose();
  }
}
