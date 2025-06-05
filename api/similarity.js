// api/similarity-results.js
import admin from 'firebase-admin';

// Initialize Firebase Admin (only once)
if (!admin.apps.length) {
  admin.initializeApp({
    credential: admin.credential.cert({
      projectId: process.env.FIREBASE_PROJECT_ID,
      clientEmail: process.env.FIREBASE_CLIENT_EMAIL,
      privateKey: process.env.FIREBASE_PRIVATE_KEY?.replace(/\\n/g, '\n'),
    }),
  });
}

export default async function handler(req, res) {
  // Enable CORS
  res.setHeader('Access-Control-Allow-Origin', '*');
  res.setHeader('Access-Control-Allow-Methods', 'POST, OPTIONS');
  res.setHeader('Access-Control-Allow-Headers', 'Content-Type');

  if (req.method === 'OPTIONS') {
    return res.status(200).end();
  }

  if (req.method !== 'POST') {
    return res.status(405).json({ error: 'Method Not Allowed' });
  }

  const data = req.body;
  if (!data || !data.originalItemId || !Array.isArray(data.similarItemIds)) {
    console.error('Invalid request body:', data);
    return res.status(400).json({ error: 'Bad Request: Missing originalItemId or similarItemIds array.' });
  }

  const originalItemId = data.originalItemId;
  const similarItemIds = data.similarItemIds;

  console.log(`Received similarity results for original item: ${originalItemId}`);
  console.log('Similar items found:', similarItemIds);

  try {
    const ownerIdsToNotify = new Set();
    let originalItemOwnerId = null;
    let originalItemName = 'an item';

    const originalFoundItemDoc = await admin.firestore().collection('foundItems').doc(originalItemId).get();
    if (originalFoundItemDoc.exists && originalFoundItemDoc.data().userId) {
      originalItemOwnerId = originalFoundItemDoc.data().userId;
      originalItemName = originalFoundItemDoc.data().itemName || originalItemName;
      ownerIdsToNotify.add(originalItemOwnerId);
    } else {
      const originalLostItemDoc = await admin.firestore().collection('lostItems').doc(originalItemId).get();
      if (originalLostItemDoc.exists && originalLostItemDoc.data().userId) {
        originalItemOwnerId = originalLostItemDoc.data().userId;
        originalItemName = originalLostItemDoc.data().itemName || originalItemName;
        ownerIdsToNotify.add(originalItemOwnerId);
      } else {
        console.warn(`Original item ${originalItemId} not found or has no userId in either collection.`);
      }
    }

    for (const itemId of similarItemIds) {
      let itemDocRef = admin.firestore().collection('foundItems').doc(itemId);
      let itemDoc = await itemDocRef.get();

      if (itemDoc.exists && itemDoc.data().userId) {
        if (originalLostItemDoc && originalLostItemDoc.exists) {
        } else if (originalFoundItemDoc && originalFoundItemDoc.exists) {
            if (itemDoc.data().userId !== originalItemOwnerId) {
                ownerIdsToNotify.add(itemDoc.data().userId);
            }
        }
      } else {
        itemDocRef = admin.firestore().collection('lostItems').doc(itemId);
        itemDoc = await itemDocRef.get();

        if (itemDoc.exists && itemDoc.data().userId) {
          ownerIdsToNotify.add(itemDoc.data().userId);
        } else {
          console.warn(`Similar item ${itemId} not found or has no userId in either collection.`);
        }
      }
    }

    const notificationsToSend = [];
    ownerIdsToNotify.clear();

    let originalItemIsLost = false;
    let originalItemIsFound = false;
    if (originalLostItemDoc && originalLostItemDoc.exists) {
        originalItemIsLost = true;
    } else if (originalFoundItemDoc && originalFoundItemDoc.exists) {
        originalItemIsFound = true;
    }

    for (const itemId of similarItemIds) {
        const foundItemRef = admin.firestore().collection('foundItems').doc(itemId);
        const lostItemRef = admin.firestore().collection('lostItems').doc(itemId);

        const foundItemSnap = await foundItemRef.get();
        const lostItemSnap = await lostItemRef.get();

        if (foundItemSnap.exists && foundItemSnap.data().userId) {
            const foundItemOwnerId = foundItemSnap.data().userId;
            const foundItemName = foundItemSnap.data().itemName || 'an item';

            if (originalItemIsLost && originalItemOwnerId) {
                ownerIdsToNotify.add(originalItemOwnerId);
                notificationsToSend.push({
                    toUserId: originalItemOwnerId,
                    title: 'Possible Match Found!',
                    body: `A recently found item (${foundItemName}) might be similar to your lost item (${originalItemName}). Check it out!`,
                    data: { originalItemId: originalItemId, matchedItemId: itemId, type: 'lost_item_found_match' }
                });
            }
        } else if (lostItemSnap.exists && lostItemSnap.data().userId) {
            const lostItemOwnerId = lostItemSnap.data().userId;
            const lostItemName = lostItemSnap.data().itemName || 'an item';

            if (originalItemIsFound && originalItemOwnerId) {
                ownerIdsToNotify.add(lostItemOwnerId);
                notificationsToSend.push({
                    toUserId: lostItemOwnerId,
                    title: 'Possible Match Found!',
                    body: `A recently found item (${originalItemName}) might be similar to your lost item (${lostItemName}). Check it out!`,
                    data: { originalItemId: originalItemId, matchedItemId: itemId, type: 'found_item_lost_match' }
                });
            }
        }
    }

    for (const notification of notificationsToSend) {
      const userDoc = await admin.firestore().collection('users').doc(notification.toUserId).get();
      if (userDoc.exists && userDoc.data().fcmToken) {
        const fcmToken = userDoc.data().fcmToken;

        const message = {
          notification: {
            title: notification.title,
            body: notification.body,
          },
          data: notification.data,
          token: fcmToken,
        };

        try {
          await admin.messaging().send(message);
          console.log(`Notification sent to ${notification.toUserId} for match with ${notification.data.matchedItemId}`);
        } catch (error) {
          console.error(`Error sending notification to ${notification.toUserId}:`, error);
        }
      } else {
        console.warn(`User ${notification.toUserId} not found or no FCM token.`);
      }
    }

    res.status(200).json({ message: 'Similarity results processed and notifications sent.' });

  } catch (error) {
    console.error('Error processing similarity results:', error);
    res.status(500).json({ error: 'Internal Server Error: ' + error.message });
  }
}