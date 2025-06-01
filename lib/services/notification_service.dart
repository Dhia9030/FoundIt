import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import '../models/app_notification.dart';

class NotificationService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;


  Future<void> updateFCMTokenForUser(String userId) async {
    String? token = await _firebaseMessaging.getToken();
    if (token != null) {
      print('FCM Token for user $userId: $token');
      // Store or update the FCM token in your 'users' collection
      await _firestore.collection('users').doc(userId).set(
        {'fcmToken': token},
        SetOptions(merge: true),
      );
    }
  }


  Stream<List<AppNotification>> getUserNotifications(String userId) {
    // Notifications will be stored in a subcollection under each user's document
    return _firestore
        .collection('users')
        .doc(userId)
        .collection('notifications')
        .orderBy('timestamp', descending: true) 
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => AppNotification.fromFirestore(doc))
            .toList());
  }
  Future<void> markNotificationAsRead(
      String userId, String notificationId) async {
    try {
      await _firestore
          .collection('users')
          .doc(userId)
          .collection('notifications')
          .doc(notificationId)
          .update({'isRead': true});
      print('Notification $notificationId for user $userId marked as read.');
    } catch (e) {
      print('Error marking notification as read: $e');
    }
  }

  Future<void> addNotificationToFirestore(
      String userId, Map<String, dynamic> data) async {
    try {
      await _firestore
          .collection('users')
          .doc(userId)
          .collection('notifications')
          .add({
        'title': data['notification']?['title'] ?? 'New Notification',
        'body': data['notification']?['body'] ?? 'You have a new message.',
        'data': data['data'], 
        'timestamp': FieldValue.serverTimestamp(),
        'isRead': false,
      });
      print('Notification added to Firestore for user $userId.');
    } catch (e) {
      print('Error adding notification to Firestore: $e');
    }
  }
}
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  print("Handling a background message: ${message.messageId}");

  String? userId = FirebaseAuth.instance.currentUser?.uid; 

  if (userId != null) {
    await FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .collection('notifications')
        .add({
      'title': message.notification?.title ?? 'No Title',
      'body': message.notification?.body ?? 'No Body',
      'data':
          message.data,
      'timestamp': FieldValue.serverTimestamp(),
      'isRead': false,
    });
    print('Background notification saved to Firestore for user $userId.');
  } else {
    print(
        'Could not get user ID for background message. Notification not saved.');
  }
}
