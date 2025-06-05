import 'package:cloud_firestore/cloud_firestore.dart';

class AppNotification {
  final String id;
  final String title;
  final String body;
  final String originalItemId;
  final String matchedItemId;
  final String type; // e.g., 'lost_item_found_match', 'found_item_lost_match'
  final DateTime timestamp;
  bool isRead;

  AppNotification({
    required this.id,
    required this.title,
    required this.body,
    required this.originalItemId,
    required this.matchedItemId,
    required this.type,
    required this.timestamp,
    this.isRead = false, 
  });

  factory AppNotification.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    final notificationData = data['data'] as Map<String, dynamic>? ?? {};

    return AppNotification(
      id: doc.id,
      title: data['title'] ?? 'New Notification',
      body: data['body'] ?? 'You have a new notification.',
      originalItemId: notificationData['originalItemId'] ?? '',
      matchedItemId: notificationData['matchedItemId'] ?? '',
      type: notificationData['type'] ?? 'general',
      timestamp: (data['timestamp'] as Timestamp?)?.toDate() ?? DateTime.now(),
      isRead: data['isRead'] ?? false, 
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'body': body,
      'data': { 
        'originalItemId': originalItemId,
        'matchedItemId': matchedItemId,
        'type': type,
      },
      'timestamp': Timestamp.fromDate(timestamp),
      'isRead': isRead,
    };
  }
}