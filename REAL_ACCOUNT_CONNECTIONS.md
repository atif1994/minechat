# 🔗 Real Account Connections Guide

## **📋 Overview**
This guide shows you how to connect your real social media and messaging accounts to MineChat AI Assistant.

---

## **🌐 Website Integration (Ready to Use)**

### **✅ Already Working**
- **Widget Code Generation**: Automatically generates embeddable code
- **Custom Colors**: Choose from 8 different widget colors
- **Easy Integration**: Copy and paste code to your website

### **📝 How to Use**
1. Enter your website URL (e.g., `https://www.yourwebsite.com`)
2. Select widget color
3. Click "Generate" to create embed code
4. Copy the code and send to your web developer
5. The widget will appear on your website

---

## **📘 Facebook Messenger Integration**

### **🔧 Setup Requirements**
1. **Facebook Developer Account**
2. **Facebook App** (for API access)
3. **Facebook Page** (business page)
4. **Page Access Token**

### **📱 Step-by-Step Setup**

#### **Step 1: Create Facebook App**
1. Go to [Facebook Developers](https://developers.facebook.com/)
2. Click "Create App" → "Business" → "Next"
3. Fill in app details:
   - **App Name**: MineChat AI Assistant
   - **Contact Email**: Your email
4. Click "Create App"

#### **Step 2: Configure Facebook App**
1. In your app dashboard, go to "Settings" → "Basic"
2. Add your app domain
3. Go to "Products" → "Messenger" → "Set Up"
4. Generate a **Page Access Token**

#### **Step 3: Get Your Page ID**
1. Go to your Facebook Page
2. Click "About" in left sidebar
3. Scroll down to find **"Page ID"** (e.g., `123456789`)
4. Copy this ID

#### **Step 4: Connect in MineChat**
1. In MineChat app, go to **Setup** → **Channels**
2. Select **"Messenger"** from dropdown
3. Enter your **Facebook Page ID**
4. Click **"Connect Facebook"**

### **🔐 Required Permissions**
- `pages_messaging` - Send messages
- `pages_read_engagement` - Read page messages
- `pages_manage_metadata` - Manage page settings

---

## **📷 Instagram Integration (Coming Soon)**

### **🔧 Future Implementation**
- Instagram Business Account required
- Instagram Graph API integration
- Direct message handling
- Story and post interactions

### **📋 Requirements (When Available)**
1. Instagram Business Account
2. Facebook Page connected to Instagram
3. Instagram Graph API access
4. Business verification

---

## **📱 Telegram Integration (Coming Soon)**

### **🔧 Future Implementation**
- Telegram Bot API integration
- Custom bot creation
- Message handling
- Inline keyboards

### **📋 Requirements (When Available)**
1. Create Telegram Bot via @BotFather
2. Get Bot Token
3. Configure webhook
4. Handle bot commands

---

## **📞 WhatsApp Integration (Coming Soon)**

### **🔧 Future Implementation**
- WhatsApp Business API
- Message templates
- Media sharing
- Business verification

### **📋 Requirements (When Available)**
1. WhatsApp Business Account
2. Business verification
3. API access approval
4. Message template approval

---

## **💼 Slack Integration (Coming Soon)**

### **🔧 Future Implementation**
- Slack App creation
- OAuth 2.0 authentication
- Channel message handling
- Slash commands

### **📋 Requirements (When Available)**
1. Create Slack App
2. Configure OAuth scopes
3. Install app to workspace
4. Handle events and commands

---

## **💜 Viber Integration (Coming Soon)**

### **🔧 Future Implementation**
- Viber Bot API
- Public account creation
- Message handling
- Rich media support

### **📋 Requirements (When Available)**
1. Viber Public Account
2. Bot token generation
3. Webhook configuration
4. Message templates

---

## **🎮 Discord Integration (Coming Soon)**

### **🔧 Future Implementation**
- Discord Bot API
- Server management
- Channel messaging
- Slash commands

### **📋 Requirements (When Available)**
1. Create Discord Application
2. Generate Bot Token
3. Add bot to server
4. Configure permissions

---

## **🔧 Technical Implementation**

### **Required Packages**
Add these to your `pubspec.yaml`:

```yaml
dependencies:
  # Facebook Integration
  facebook_login: ^5.0.0
  
  # Telegram Integration
  telegram: ^1.0.0
  
  # WhatsApp Integration
  whatsapp_unilink: ^2.0.0
  
  # Slack Integration
  slack: ^1.0.0
  
  # Discord Integration
  discord: ^1.0.0
```

### **Environment Variables**
Create `.env` file:

```env
# Facebook
FACEBOOK_APP_ID=your_facebook_app_id
FACEBOOK_APP_SECRET=your_facebook_app_secret

# Telegram
TELEGRAM_BOT_TOKEN=your_telegram_bot_token

# WhatsApp
WHATSAPP_API_TOKEN=your_whatsapp_api_token

# Slack
SLACK_BOT_TOKEN=your_slack_bot_token
SLACK_SIGNING_SECRET=your_slack_signing_secret

# Discord
DISCORD_BOT_TOKEN=your_discord_bot_token
```

### **Firebase Functions**
For secure API calls, use Firebase Functions:

```javascript
// functions/src/channels/facebook.js
exports.connectFacebook = functions.https.onCall(async (data, context) => {
  // Verify user authentication
  if (!context.auth) {
    throw new functions.https.HttpsError('unauthenticated', 'User not authenticated');
  }
  
  // Connect to Facebook Graph API
  const { pageId, accessToken } = data;
  
  // Verify page ownership
  const response = await fetch(`https://graph.facebook.com/v18.0/${pageId}?access_token=${accessToken}`);
  const pageData = await response.json();
  
  // Save to Firestore
  await admin.firestore()
    .collection('channel_settings')
    .doc(context.auth.uid)
    .set({
      facebookPageId: pageId,
      facebookPageName: pageData.name,
      isFacebookConnected: true,
      updatedAt: admin.firestore.FieldValue.serverTimestamp()
    }, { merge: true });
    
  return { success: true, pageName: pageData.name };
});
```

---

## **🛡️ Security Best Practices**

### **✅ Do's**
- Use environment variables for API keys
- Implement OAuth 2.0 where possible
- Store tokens securely in Firebase
- Validate user permissions
- Use Firebase Functions for API calls

### **❌ Don'ts**
- Never expose API keys in client code
- Don't store sensitive data in local storage
- Avoid hardcoding credentials
- Don't skip user authentication
- Never trust client-side validation

---

## **📞 Support**

### **🔧 Troubleshooting**
1. **Facebook Connection Issues**
   - Verify Page ID is correct
   - Check app permissions
   - Ensure page is public

2. **API Rate Limits**
   - Implement rate limiting
   - Use webhooks efficiently
   - Cache responses

3. **Authentication Errors**
   - Verify OAuth flow
   - Check token expiration
   - Validate user permissions

### **📧 Contact**
For technical support:
- Email: support@minechat.ai
- Documentation: docs.minechat.ai
- GitHub Issues: github.com/minechat/issues

---

## **🚀 Next Steps**

1. **Start with Website Integration** (already working)
2. **Set up Facebook Messenger** (follow guide above)
3. **Wait for other platforms** (coming soon)
4. **Test thoroughly** before production use
5. **Monitor usage** and API limits

---

**🎯 Goal**: Connect all your business channels to one AI assistant for seamless customer support!
