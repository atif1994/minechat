import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:minechat/core/utils/helpers/app_spacing/app_spacing.dart';
import 'package:minechat/core/utils/helpers/app_styles/app_text_styles.dart';
import 'package:minechat/core/constants/app_colors/app_colors.dart';
import 'package:minechat/controller/channel_controller/channel_controller.dart';
import 'package:minechat/controller/chat_controller/chat_controller.dart';
import 'package:minechat/core/services/facebook_graph_api_service.dart';

class MessengerChannelWidget extends StatelessWidget {
  final ChannelController controller;

  const MessengerChannelWidget({
    super.key,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Facebook Messenger Channel Setup',
            style: AppTextStyles.bodyText(context).copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          AppSpacing.vertical(context, 0.02),
          
          // Connection Status
          _buildConnectionStatus(context),
          AppSpacing.vertical(context, 0.01),
          
          // Info about server-side integration
          _buildServerIntegrationInfo(context),
          AppSpacing.vertical(context, 0.02),
          
          // Facebook Pages Selection (if OAuth completed)
          Obx(() => controller.showPageSelector.value 
              ? _buildPageSelector(context) 
              : SizedBox.shrink()),
          
          // Action Buttons
          _buildConnectionButtons(context),
          AppSpacing.vertical(context, 0.02),
          
          // Test Connection Button (for development)
          _buildTestConnectionButton(context),
          AppSpacing.vertical(context, 0.02),
          
          // Manual Token Input (for current valid token)
          _buildManualTokenInput(context),
          AppSpacing.vertical(context, 0.02),
          
          // AI Control Buttons
          _buildAIControlButtons(context),
        ],
      ),
    );
  }

  Widget _buildConnectionStatus(BuildContext context) {
    return Obx(() => Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: controller.isFacebookConnected.value 
            ? Colors.green[50] 
            : Colors.blue[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: controller.isFacebookConnected.value 
              ? Colors.green[300]! 
              : Colors.blue[300]!,
        ),
      ),
      child: Row(
        children: [
          Icon(
            controller.isFacebookConnected.value 
                ? Icons.check_circle 
                : Icons.info,
            color: controller.isFacebookConnected.value 
                ? Colors.green 
                : Colors.blue,
          ),
          SizedBox(width: 12),
          Expanded(
            child: Text(
              controller.isFacebookConnected.value
                  ? 'Connected to Facebook Business Chat'
                  : 'Ready to Connect Facebook Business Chat',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: controller.isFacebookConnected.value 
                    ? Colors.green[800] 
                    : Colors.blue[800],
              ),
            ),
          ),
        ],
      ),
    ));
  }

  Widget _buildServerIntegrationInfo(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.blue[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.blue[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.cloud_done, color: Colors.blue[700], size: 20),
              SizedBox(width: 8),
              Text(
                'Server Integration Ready',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: Colors.blue[800],
                ),
              ),
            ],
          ),
          AppSpacing.vertical(context, 0.01),
          Text(
            'Your Facebook integration is already configured on the server. '
            'Click "Connect Facebook" to authenticate and start receiving real chats.',
            style: TextStyle(
              color: Colors.blue[700],
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPageSelector(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.orange[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.orange[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.pages, color: Colors.orange[700], size: 20),
              SizedBox(width: 8),
              Text(
                'Select Facebook Page',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: Colors.orange[800],
                ),
              ),
            ],
          ),
          AppSpacing.vertical(context, 0.01),
          Text(
            'Choose which Facebook page to connect for business chat:',
            style: TextStyle(
              color: Colors.orange[700],
              fontSize: 13,
            ),
          ),
          AppSpacing.vertical(context, 0.02),
          Obx(() => Column(
            children: controller.availablePages.map((page) {
              final isSelected = controller.selectedPageId.value == page['id'];
              return Container(
                margin: EdgeInsets.only(bottom: 8),
                child: ListTile(
                  leading: Icon(
                    isSelected ? Icons.radio_button_checked : Icons.radio_button_unchecked,
                    color: isSelected ? AppColors.primary : Colors.grey,
                  ),
                  title: Text(
                    page['name'] ?? 'Unknown Page',
                    style: TextStyle(fontWeight: FontWeight.w500),
                  ),
                  subtitle: Text(page['category'] ?? 'Business Page'),
                  trailing: isSelected 
                      ? ElevatedButton(
                          onPressed: () => _connectSelectedPage(context),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            foregroundColor: Colors.white,
                          ),
                          child: Text('Connect This Page'),
                        )
                      : null,
                  onTap: () {
                    controller.selectedPageId.value = page['id'];
                  },
                ),
              );
            }).toList(),
          )),
        ],
      ),
    );
  }

  Widget _buildConnectionButtons(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: controller.isFacebookConnected.value
                    ? controller.disconnectFacebook
                    : null,
                child: Text('Disconnect'),
              ),
            ),
            SizedBox(width: 12),
            Expanded(
              child: Obx(() => ElevatedButton(
                onPressed: controller.isConnectingFacebook.value || controller.isOAuthInProgress.value
                    ? null
                    : () => _startFacebookConnection(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                ),
                child: (controller.isConnectingFacebook.value || controller.isOAuthInProgress.value)
                    ? SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                    : Text('Connect Facebook'),
              )),
            ),
          ],
        ),
        AppSpacing.vertical(context, 0.02),
        // Info about direct connection
        Container(
          padding: EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.green[50],
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.green[200]!),
          ),
          child: Row(
            children: [
              Icon(Icons.info_outline, color: Colors.green[700], size: 20),
              SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Quick Connect: Use the provided token to instantly connect and view all your Facebook Messenger chats',
                  style: TextStyle(
                    color: Colors.green[800],
                    fontSize: 13,
                  ),
                ),
              ),
            ],
          ),
        ),
        AppSpacing.vertical(context, 0.02),
        // Direct connection button with provided token
        SizedBox(
          width: double.infinity,
          child: Obx(() => ElevatedButton.icon(
            onPressed: controller.isConnectingFacebook.value || controller.isOAuthInProgress.value
                ? null
                : _connectDirectlyWithToken,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green[600],
              foregroundColor: Colors.white,
              padding: EdgeInsets.symmetric(vertical: 16),
            ),
            icon: (controller.isConnectingFacebook.value || controller.isOAuthInProgress.value)
                ? SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                : Icon(Icons.rocket_launch, size: 20),
            label: (controller.isConnectingFacebook.value || controller.isOAuthInProgress.value)
                ? Text('Connecting...', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600))
                : Text(
                    '🚀 Connect Directly with Token & Go to Chat',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
          )),
        ),
      ],
    );
  }

  Widget _buildManualTokenInput(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.purple[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.purple[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.key, color: Colors.purple[700], size: 20),
              SizedBox(width: 8),
              Text(
                'Manual Token Input',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: Colors.purple[800],
                ),
              ),
            ],
          ),
          AppSpacing.vertical(context, 0.01),
          Text(
            'Enter your current valid Facebook Page Access Token. '
            'Get this from Facebook Business Suite or Graph API Explorer.',
            style: TextStyle(
              color: Colors.purple[700],
              fontSize: 13,
            ),
          ),
          AppSpacing.vertical(context, 0.02),
          TextField(
            controller: controller.facebookAccessTokenCtrl,
            decoration: InputDecoration(
              labelText: 'Facebook Page Access Token',
              hintText: 'EAAB... (paste your current valid token)',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              helperText: 'Token should start with "EAAB" and be about 200+ characters',
            ),
            maxLines: 3,
          ),
          AppSpacing.vertical(context, 0.02),
          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: () => _connectWithManualToken(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.purple[700],
                    foregroundColor: Colors.white,
                  ),
                  child: Text('Connect with Token'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTestConnectionButton(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.amber[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.amber[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.bug_report, color: Colors.amber[700], size: 20),
              SizedBox(width: 8),
              Text(
                'Test Connection (Development)',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: Colors.amber[800],
                ),
              ),
            ],
          ),
          AppSpacing.vertical(context, 0.01),
          Text(
            'Use this button to test Facebook connection with the provided token. '
            'Enter your Facebook Page ID first.',
            style: TextStyle(
              color: Colors.amber[700],
              fontSize: 13,
            ),
          ),
          AppSpacing.vertical(context, 0.02),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: controller.facebookPageIdCtrl,
                  decoration: InputDecoration(
                    labelText: 'Facebook Page ID',
                    hintText: 'Enter your Facebook Page ID',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ),
              SizedBox(width: 12),
              ElevatedButton(
                onPressed: () => _testFacebookConnection(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.amber[700],
                  foregroundColor: Colors.white,
                ),
                child: Text('Test Connect'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAIControlButtons(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton(
            onPressed: controller.isFacebookConnected.value
                ? controller.disconnectFacebook
                : null,
            child: Text('Disconnect'),
          ),
        ),
        SizedBox(width: 12),
        Expanded(
          child: Obx(() => ElevatedButton(
            onPressed: controller.isFacebookConnected.value
                ? () {
                    controller.isFacebookAIPaused.value = 
                        !controller.isFacebookAIPaused.value;
                  }
                : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: controller.isFacebookAIPaused.value
                  ? Colors.orange
                  : AppColors.primary,
              foregroundColor: Colors.white,
            ),
            child: Text(controller.isFacebookAIPaused.value
                ? 'Resume Facebook AI'
                : 'Pause Facebook AI'),
          )),
        ),
      ],
    );
  }

  void _startFacebookConnection(BuildContext context) async {
    try {
      // Show connection dialog
      Get.dialog(
        AlertDialog(
          title: Text('Connect Facebook Business Chat'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'To connect your Facebook Business Chat:',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
              SizedBox(height: 12),
              Text('1. Make sure you\'re logged into Facebook'),
              Text('2. Click "Start Connection" below'),
              Text('3. Complete Facebook authentication'),
              Text('4. Select your business page'),
              Text('5. All your Facebook chats will appear in the chat screen'),
              SizedBox(height: 12),
              Container(
                padding: EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.green[50],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.green[200]!),
                ),
                child: Row(
                  children: [
                    Icon(Icons.check_circle, color: Colors.green[700], size: 20),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'No tokens needed - server integration is ready!',
                        style: TextStyle(
                          color: Colors.green[700],
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
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
                _initiateFacebookOAuth();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
              ),
              child: Text('Start Connection'),
            ),
          ],
        ),
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to show connection dialog: $e',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  void _initiateFacebookOAuth() async {
    try {
      print('🚀 Starting Facebook OAuth flow...');
      
      // Start the Facebook OAuth flow
      await controller.startFacebookOAuth();
      
      Get.snackbar(
        'Facebook OAuth Started',
        'Please complete Facebook authentication in your browser. '
        'You will be redirected back to the app.',
        backgroundColor: Colors.blue,
        colorText: Colors.white,
        duration: Duration(seconds: 5),
      );
      
      // Wait a bit for OAuth to complete
      await Future.delayed(Duration(seconds: 3));
      
      // Check if OAuth completed and pages are loaded
      if (controller.availablePages.isNotEmpty) {
        print('✅ OAuth completed, pages loaded: ${controller.availablePages.length}');
        Get.snackbar(
          'OAuth Successful!',
          'Please select a Facebook page to connect.',
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );
      }
      
    } catch (e) {
      print('❌ Error in Facebook OAuth: $e');
      Get.snackbar(
        'OAuth Error',
        'Failed to start Facebook authentication: $e',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  void _connectSelectedPage(BuildContext context) async {
    try {
      final pageId = controller.selectedPageId.value;
      if (pageId.isEmpty) {
        Get.snackbar(
          'Error',
          'Please select a Facebook page first',
          backgroundColor: Colors.orange,
          colorText: Colors.white,
        );
        return;
      }

      print('🔗 Connecting to Facebook page: $pageId');
      
      // Connect to the selected page
      await controller.connectToFacebookPage(pageId);
      
      // After successful connection, refresh chats
      if (controller.isFacebookConnected.value) {
        final chatController = Get.find<ChatController>();
        await chatController.refreshFacebookChats();
        
        Get.snackbar(
          'Success!',
          'Facebook connected! All chats are now loaded in your chat screen.',
          backgroundColor: Colors.green,
          colorText: Colors.white,
          duration: Duration(seconds: 5),
        );
        
        // Navigate to chat screen to show the loaded chats
        Get.toNamed('/chat');
      }
      
    } catch (e) {
      print('❌ Error connecting to Facebook page: $e');
      Get.snackbar(
        'Connection Error',
        'Failed to connect to Facebook page: $e',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  void _testFacebookConnection() async {
    try {
      final pageId = controller.facebookPageIdCtrl.text.trim();
      if (pageId.isEmpty) {
        Get.snackbar(
          'Error',
          'Please enter your Facebook Page ID first',
          backgroundColor: Colors.orange,
          colorText: Colors.white,
        );
        return;
      }

      print('🧪 Testing Facebook connection with Page ID: $pageId');
      
      // Use the test connection method
      await controller.connectWithProvidedToken();
      
      // If successful, refresh chats
      if (controller.isFacebookConnected.value) {
        final chatController = Get.find<ChatController>();
        await chatController.refreshFacebookChats();
        
        Get.snackbar(
          'Test Success!',
          'Facebook connected successfully! All chats should now be loaded.',
          backgroundColor: Colors.green,
          colorText: Colors.white,
          duration: Duration(seconds: 5),
        );
        
        // Navigate to chat screen to show the loaded chats
        Get.toNamed('/chat');
      }
      
    } catch (e) {
      print('❌ Test connection failed: $e');
      Get.snackbar(
        'Test Failed',
        'Facebook connection test failed: $e',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  void _connectWithManualToken(BuildContext context) async {
    try {
      final pageId = controller.facebookPageIdCtrl.text.trim();
      final accessToken = controller.facebookAccessTokenCtrl.text.trim();
      
      if (pageId.isEmpty) {
        Get.snackbar(
          'Error',
          'Please enter your Facebook Page ID first',
          backgroundColor: Colors.orange,
          colorText: Colors.white,
        );
        return;
      }
      
      if (accessToken.isEmpty) {
        Get.snackbar(
          'Error',
          'Please enter your Facebook Page Access Token',
          backgroundColor: Colors.orange,
          colorText: Colors.white,
        );
        return;
      }

      if (!accessToken.startsWith('EAAB')) {
        Get.snackbar(
          'Invalid Token',
          'Facebook access tokens should start with "EAAB"',
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
        return;
      }

      print('🔑 Connecting with manual token for Page ID: $pageId');
      
      // Use the existing method to connect with token
      await controller.connectWithToken(accessToken);
      
      // If successful, refresh chats
      if (controller.isFacebookConnected.value) {
        final chatController = Get.find<ChatController>();
        await chatController.refreshFacebookChats();
        
        Get.snackbar(
          'Success!',
          'Facebook connected with manual token! All chats should now be loaded.',
          backgroundColor: Colors.green,
          colorText: Colors.white,
          duration: Duration(seconds: 5),
        );
        
        // Navigate to chat screen to show the loaded chats
        Get.toNamed('/chat');
      }
      
    } catch (e) {
      print('❌ Manual token connection failed: $e');
      Get.snackbar(
        'Connection Failed',
        'Failed to connect with manual token: $e',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  /// Direct connection method using the provided token
  void _connectDirectlyWithToken() async {
    try {
      // Use the new access token directly
      final accessToken = 'EAAU0kNg5hEMBPTfyfu1IyQTlMkfTrsF36p3Ipy0oRAo3MfeZAxVVDZA9ZC4ZB874XWxtQxBoPRNA8aJveBJWZBn7YqeQbAvsoHer25WGT0eKqQKTWaW82NvhRCZAZA29fPKw8pU8bUKW9VGlnQBGpGIFkrYIZCtlvweUXS2yGFvlDmFsgDUPfs79r8Cklc2wBLNMtVfk7rEZAq28JgEidZCEIcpTS4iaRZB6JrqiKZAu3N0ZBuA0KII59FykB3Op2JwZDZD';
      
      print('🚀 Connecting directly with NEW access token...');
      
      // First, get the user's pages to find the first available page
      final pagesResult = await FacebookGraphApiService.getUserPagesWithToken(accessToken);
      if (!pagesResult['success']) {
        throw Exception('Failed to fetch pages: ${pagesResult['error']}');
      }
      
      final pages = pagesResult['data']['data'] as List;
      if (pages.isEmpty) {
        throw Exception('No Facebook pages found for this token');
      }
      
      // Use the first available page
      final firstPage = pages.first;
      final pageId = firstPage['id'];
      final pageName = firstPage['name'];
      
      print('✅ Found page: $pageName (ID: $pageId)');
      
      // Set the page ID in the controller
      controller.facebookPageIdCtrl.text = pageId;
      
      // Connect using the token
      await controller.connectWithToken(accessToken);
      
      // If successful, refresh chats and navigate
      if (controller.isFacebookConnected.value) {
        final chatController = Get.find<ChatController>();
        await chatController.refreshFacebookChats();
        
        Get.snackbar(
          '🎉 Connected Successfully!',
          'Facebook Messenger connected to $pageName (ID: $pageId)! Loading all chats...',
          backgroundColor: Colors.green,
          colorText: Colors.white,
          duration: Duration(seconds: 4),
        );
        
        // Navigate to chat screen to show all loaded chats
        Get.toNamed('/chat');
      }
      
    } catch (e) {
      print('❌ Direct connection failed: $e');
      Get.snackbar(
        'Connection Failed',
        'Failed to connect: $e',
        backgroundColor: Colors.red,
        colorText: Colors.white,
        duration: Duration(seconds: 5),
      );
    }
  }
}
