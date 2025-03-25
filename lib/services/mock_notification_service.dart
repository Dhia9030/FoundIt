import '../models/mock_notification.dart';

class MockNotificationService {
  List<MockNotification> getMockNotifications() {
    return [
      MockNotification(
        id: 'notif_1',
        type: 'FOUND_YOUR_ITEM',
        itemId: 'item_123',
        senderId: 'user2',
        receiverId: 'user1',
        timestamp: DateTime.now().subtract(Duration(hours: 1)),
        conversationId: 'conv_1',
      ),
      MockNotification(
        id: 'notif_2',
        type: 'LOOKING_FOR_ITEM',
        itemId: 'item_456',
        senderId: 'user3',
        receiverId: 'user1',
        timestamp: DateTime.now().subtract(Duration(minutes: 30)),
      ),
      MockNotification(
        id: 'notif_3',
        type: 'FOUND_YOUR_ITEM',
        itemId: 'item_789',
        senderId: 'user4',
        receiverId: 'user1',
        timestamp: DateTime.now().subtract(Duration(minutes: 15)),
      ),
      MockNotification(
        id: 'notif_4',
        type: 'LOOKING_FOR_ITEM',
        itemId: 'item_101',
        senderId: 'user5',
        receiverId: 'user1',
        timestamp: DateTime.now().subtract(Duration(minutes: 5)),
      ),
    ];
  }
}