const functions = require('firebase-functions');
const admin = require('firebase-admin');
admin.initializeApp();

exports.sendChatNotification = functions.firestore
  .document('workspaces/{workspaceId}/channels/{channelId}/messages/{messageId}')
  .onCreate(async (snap, context) => {
    try {
      const message = snap.data();
      const senderId = message.senderId;
      
      // Get channel details
      const channelSnap = await admin.firestore()
        .doc(`workspaces/${context.params.workspaceId}/channels/${context.params.channelId}`)
        .get();
      const channel = channelSnap.data();
      
      // Get sender details
      const senderSnap = await admin.firestore()
        .doc(`users/${senderId}`)
        .get();
      const sender = senderSnap.data();
      
      // Get recipients' FCM tokens
      const tokens = [];
      for (const memberId of channel.members) {
        if (memberId !== senderId) { // Don't send to sender
          const userSnap = await admin.firestore()
            .doc(`users/${memberId}`)
            .get();
          const userData = userSnap.data();
          if (userData.fcmToken) {
            tokens.push(userData.fcmToken);
          }
        }
      }
      
      if (tokens.length === 0) return;
      
      // Send notification
      const notification = {
        title: `New message in ${channel.name}`,
        body: `${sender.firstName}: ${message.content}`,
      };
      
      const payload = {
        notification,
        data: {
          type: 'chat',
          channelId: context.params.channelId,
          workspaceId: context.params.workspaceId,
        },
        tokens,
      };
      
      await admin.messaging().sendMulticast(payload);
    } catch (error) {
      console.error('Error sending notification:', error);
    }
}); 
const admin = require('firebase-admin');
admin.initializeApp();

exports.sendChatNotification = functions.firestore
  .document('workspaces/{workspaceId}/channels/{channelId}/messages/{messageId}')
  .onCreate(async (snap, context) => {
    try {
      const message = snap.data();
      const senderId = message.senderId;
      
      // Get channel details
      const channelSnap = await admin.firestore()
        .doc(`workspaces/${context.params.workspaceId}/channels/${context.params.channelId}`)
        .get();
      const channel = channelSnap.data();
      
      // Get sender details
      const senderSnap = await admin.firestore()
        .doc(`users/${senderId}`)
        .get();
      const sender = senderSnap.data();
      
      // Get recipients' FCM tokens
      const tokens = [];
      for (const memberId of channel.members) {
        if (memberId !== senderId) { // Don't send to sender
          const userSnap = await admin.firestore()
            .doc(`users/${memberId}`)
            .get();
          const userData = userSnap.data();
          if (userData.fcmToken) {
            tokens.push(userData.fcmToken);
          }
        }
      }
      
      if (tokens.length === 0) return;
      
      // Send notification
      const notification = {
        title: `New message in ${channel.name}`,
        body: `${sender.firstName}: ${message.content}`,
      };
      
      const payload = {
        notification,
        data: {
          type: 'chat',
          channelId: context.params.channelId,
          workspaceId: context.params.workspaceId,
        },
        tokens,
      };
      
      await admin.messaging().sendMulticast(payload);
    } catch (error) {
      console.error('Error sending notification:', error);
    }
});