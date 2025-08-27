# 📘 Facebook Messenger Setup Guide

## 🎯 **Why You Need a Facebook Page ID**

Facebook Messenger integration requires a **Facebook Page** (not your personal account) because:

- ✅ **Business Verification**: Facebook requires business pages for API access
- ✅ **Messenger Features**: Only pages can have Messenger integration
- ✅ **API Permissions**: Personal accounts cannot use Messenger API
- ✅ **Professional Use**: Pages are designed for business communication

## 📱 **Step-by-Step Setup**

### **Step 1: Create a Facebook Page**

#### **Option A: Create New Page**
1. **Go to [facebook.com](https://facebook.com)**
2. **Log in** to your personal account
3. **Click the menu icon** (☰) in top left
4. **Click "Pages"** → **"Create New Page"**
5. **Fill in details:**
   ```
   Page Name: "My Business" (or your business name)
   Category: Business/Brand
   Description: Brief description of your business
   ```
6. **Click "Create Page"**

#### **Option B: Use Existing Page**
If you already have a Facebook page for your business, skip to Step 2.

### **Step 2: Find Your Page ID**

1. **Go to your Facebook Page**
2. **Click "About"** in the left sidebar
3. **Scroll down** to find **"Page ID"**
4. **Copy the number** (example: `123456789012345`)

**Visual Guide:**
```
┌─────────────────────────────────────┐
│ Facebook Page                       │
├─────────────────────────────────────┤
│ [Home] [About] [Posts] [Photos]     │
├─────────────────────────────────────┤
│ About                               │
│                                     │
│ Page Info                           │
│ • Category: Business                │
│ • Page ID: 123456789012345  ← Copy this!
│ • Created: January 2024             │
│                                     │
└─────────────────────────────────────┘
```

### **Step 3: Create Facebook Developer App**

1. **Go to [developers.facebook.com](https://developers.facebook.com)**
2. **Click "Get Started"** or **"Log In"**
3. **Click "Create App"**
4. **Choose app type:**
   ```
   Select: "Business"
   App Name: "MineChat Integration"
   Contact Email: your@email.com
   ```
5. **Click "Create App"**

### **Step 4: Add Messenger Product**

1. **In your app dashboard**, find **"Add Product"**
2. **Click "Messenger"** → **"Set Up"**
3. **Under "Access Tokens"**, click **"Generate Token"**
4. **Select your Facebook Page** from dropdown
5. **Copy the generated token** (starts with `EAAB...`)

**Visual Guide:**
```
┌─────────────────────────────────────┐
│ Facebook Developer Dashboard        │
├─────────────────────────────────────┤
│ Products                            │
│ ┌─────────────────────────────────┐ │
│ │ Messenger                       │ │
│ │ [Set Up]                        │ │
│ └─────────────────────────────────┘ │
│                                     │
│ Access Tokens                       │
│ ┌─────────────────────────────────┐ │
│ │ Page: My Business               │ │
│ │ Token: EAABwB... ← Copy this!   │ │
│ │ [Generate Token]                │ │
│ └─────────────────────────────────┘ │
└─────────────────────────────────────┘
```

### **Step 5: Connect in MineChat**

1. **Open your MineChat app**
2. **Go to Setup → Channels → Messenger**
3. **Enter your credentials:**
   ```
   Facebook Page ID: 123456789012345
   Access Token: EAABwB...
   ```
4. **Click "Connect Facebook"**

## 🔧 **Troubleshooting**

### **Common Issues:**

#### **1. "Page ID not found"**
- ✅ Make sure you're looking at the **Page** (not your personal profile)
- ✅ Check the "About" section of your page
- ✅ Page ID is a long number (10-15 digits)

#### **2. "Invalid access token"**
- ✅ Make sure you generated the token for the correct page
- ✅ Token should start with "EAAB"
- ✅ Don't include extra spaces or characters

#### **3. "Permission denied"**
- ✅ Make sure you're the admin of the Facebook page
- ✅ Verify your developer account is verified
- ✅ Check that Messenger product is added to your app

### **Required Permissions:**

Your Facebook app needs these permissions:
```
pages_messaging
pages_read_engagement  
pages_manage_metadata
```

## 🎯 **What Happens After Connection**

### **Incoming Messages:**
1. Customer sends message to your Facebook page
2. Facebook sends webhook to your MineChat app
3. Your AI assistant processes the message
4. AI response sent back to customer via Facebook

### **Features You Get:**
- ✅ **Real-time messaging** with customers
- ✅ **AI auto-responses** using your business knowledge
- ✅ **Message history** in your MineChat dashboard
- ✅ **Pause/resume** AI responses
- ✅ **Unified chat** with other platforms

## 💡 **Pro Tips**

### **Best Practices:**
1. **Use a business email** for your developer account
2. **Keep your access token secure** (don't share it)
3. **Test with a few messages** before going live
4. **Monitor your AI responses** and adjust as needed

### **Security:**
- 🔒 Access tokens are stored securely in Firebase
- 🔒 Only you can access your page's messages
- 🔒 Facebook handles all customer data securely

## 🚀 **Next Steps**

After connecting Facebook:

1. **Test the connection** by sending a message to your page
2. **Configure your AI assistant** with business information
3. **Add other platforms** (Telegram, WhatsApp, etc.)
4. **Monitor performance** and optimize responses

## 📞 **Need Help?**

### **Facebook Resources:**
- [Facebook Pages Help](https://www.facebook.com/help/pages)
- [Facebook Developer Docs](https://developers.facebook.com/docs/messenger-platform)
- [Facebook Business Support](https://www.facebook.com/business/help)

### **MineChat Support:**
- Check the main integration guide
- Review error messages in the app
- Contact support if issues persist

---

**🎯 Ready to connect Facebook Messenger? Follow these steps and you'll be chatting with customers in no time!**
