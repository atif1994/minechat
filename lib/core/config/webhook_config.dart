/// Facebook Webhook Configuration
class WebhookConfig {
  // Your webhook endpoint
  static const String webhookUrl = "https://449a5e08-99f4-4100-9571-62eeba47fe54-00-3gozoz68wjgp4.spock.replit.dev/api/facebook/webhook";
  
  // Your webhook secret token
  static const String secretToken = "minechat_secret1994";
  
  // Webhook verification token (should match your Facebook app settings)
  static const String verifyToken = "minechat_verify_1994";
  
  // Webhook subscription fields (what events to listen for)
  static const List<String> subscriptionFields = [
    'messages',
    'messaging_postbacks',
    'messaging_optins',
    'messaging_deliveries',
    'messaging_reads',
  ];
  
  /// Get webhook configuration for Facebook app setup
  static Map<String, dynamic> getWebhookConfig() {
    return {
      'webhook_url': webhookUrl,
      'verify_token': verifyToken,
      'secret_token': secretToken,
      'subscription_fields': subscriptionFields,
      'app_id': '1465171591136323', // Your Facebook App ID
    };
  }
  
  /// Validate webhook signature (for security)
  static bool validateWebhookSignature(String signature, String payload) {
    // Implement webhook signature validation here
    // This ensures the webhook is actually from Facebook
    return true; // For now, always return true
  }
}
