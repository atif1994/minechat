import * as functions from 'firebase-functions';
import * as admin from 'firebase-admin';
import express from 'express';

const app = express();

// Initialize Firebase Admin
admin.initializeApp();

// Facebook webhook verification
app.get('/webhook', (req: any, res: any) => {
  const mode = req.query['hub.mode'];
  const token = req.query['hub.verify_token'];
  const challenge = req.query['hub.challenge'];

  // Your verify token (should match what you set in Facebook App settings)
  const VERIFY_TOKEN = 'your_verify_token_here';

  if (mode === 'subscribe' && token === VERIFY_TOKEN) {
    console.log('Webhook verified');
    res.status(200).send(challenge);
  } else {
    console.log('Webhook verification failed');
    res.sendStatus(403);
  }
});

// Handle incoming messages from Facebook
app.post('/webhook', (req: any, res: any) => {
  const body = req.body;

  // Check if this is a page subscription
  if (body.object === 'page') {
    // Process each entry
    body.entry.forEach((entry: any) => {
      const pageId = entry.id;
      // const timeOfEvent = entry.time;

      // Process each messaging event
      if (entry.messaging) {
        entry.messaging.forEach((event: any) => {
          if (event.message && !event.message.is_echo) {
            // This is a message from a user
            handleIncomingMessage(event, pageId);
          } else if (event.delivery) {
            // Message delivery confirmation
            console.log('Message delivered:', event.delivery);
          } else if (event.read) {
            // Message read confirmation
            console.log('Message read:', event.read);
          }
        });
      }
    });

    res.status(200).send('EVENT_RECEIVED');
  } else {
    res.sendStatus(404);
  }
});

// Handle incoming messages
async function handleIncomingMessage(event: any, pageId: string) {
  try {
    const senderId = event.sender.id;
    const recipientId = event.recipient.id;
    const message = event.message;
    const timestamp = event.timestamp;

    console.log('📨 New message received:', {
      senderId,
      recipientId,
      message: message.text,
      timestamp
    });

    // Get the conversation ID (thread ID)
    const conversationId = event.message?.thread_id || `t_${senderId}_${pageId}`;

    // Find the user who owns this page
    const userQuery = await admin.firestore()
      .collection('channel_settings')
      .where('facebookPageId', '==', pageId)
      .limit(1)
      .get();

    if (userQuery.empty) {
      console.log('❌ No user found for page:', pageId);
      return;
    }

    const userDoc = userQuery.docs[0];
    const userId = userDoc.id;

    // Store the message in Firebase for real-time updates
    await admin.firestore()
      .collection('user_messages')
      .doc(userId)
      .collection('messages')
      .add({
        conversationId: conversationId,
        text: message.text || '',
        isFromUser: true,
        platform: 'Facebook',
        senderId: senderId,
        senderName: `Facebook User ${senderId}`,
        timestamp: admin.firestore.FieldValue.serverTimestamp(),
        createdAt: new Date().toISOString(),
        facebookMessageId: message.mid,
        pageId: pageId,
      });

    // Update conversation info
    await admin.firestore()
      .collection('user_conversations')
      .doc(userId)
      .collection('conversations')
      .doc(conversationId)
      .set({
        conversationId: conversationId,
        contactName: `Facebook User ${senderId}`,
        lastMessage: message.text || '',
        platform: 'Facebook',
        unreadCount: admin.firestore.FieldValue.increment(1),
        lastUpdate: admin.firestore.FieldValue.serverTimestamp(),
        updatedAt: new Date().toISOString(),
        pageId: pageId,
        senderId: senderId,
      }, { merge: true });

    console.log('✅ Message stored for real-time updates');

    // Optional: Send auto-reply
    // await sendAutoReply(pageId, senderId, conversationId);

  } catch (error) {
    console.error('❌ Error handling incoming message:', error);
  }
}

// Optional: Send auto-reply function (currently unused)
/*
async function sendAutoReply(pageId: string, senderId: string, conversationId: string) {
  try {
    // Get page access token from secure storage
    const userQuery = await admin.firestore()
      .collection('channel_settings')
      .where('facebookPageId', '==', pageId)
      .limit(1)
      .get();

    if (userQuery.empty) return;

    const userDoc = userQuery.docs[0];
    const userId = userDoc.id;

    // Get page access token
    const tokenDoc = await admin.firestore()
      .collection('secure_tokens')
      .doc(userId)
      .get();

    if (!tokenDoc.exists) return;

    const tokenData = tokenDoc.data();
    const pageAccessToken = tokenData?.facebookPageTokens?.[pageId];

    if (!pageAccessToken) return;

    // Send auto-reply
    const response = await fetch(`https://graph.facebook.com/v18.0/me/messages?access_token=${pageAccessToken}`, {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
      },
      body: JSON.stringify({
        recipient: { id: senderId },
        message: { text: 'Thank you for your message! We\'ll get back to you soon.' },
      }),
    });

    if (response.ok) {
      console.log('✅ Auto-reply sent');
    } else {
      console.log('❌ Failed to send auto-reply:', await response.text());
    }

  } catch (error) {
    console.error('❌ Error sending auto-reply:', error);
  }
}
*/

// Export the Express app as a Cloud Function
export const facebookWebhook = functions.https.onRequest(app);
