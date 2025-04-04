

//hedhi juste esta3meltha bsh ntesti lfront badlouha wa9t tabdew

class MockNotification {



  final String id;
  final String type; // 'FOUND_YOUR_ITEM' or 'LOOKING_FOR_ITEM'
  final String itemId;
  final String senderId;
  final String receiverId;
  final DateTime timestamp;
  final bool isRead;
  final String? conversationId;

  MockNotification({
    required this.id,
    required this.type,
    required this.itemId,
    required this.senderId,
    required this.receiverId,
    required this.timestamp,
    this.isRead = false,
    this.conversationId,
  });
}