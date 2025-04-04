// models/conversation.dart
class Conversation {
  final String id;
  final String notificationId;
  final String participant1Id;
  final String participant2Id;
  final String itemId;
  final List<Message> messages;
  final DateTime createdAt;
  final DateTime updatedAt;

  Conversation({
    required this.id,
    required this.notificationId,
    required this.participant1Id,
    required this.participant2Id,
    required this.itemId,
    this.messages = const [],
    required this.createdAt,
    required this.updatedAt,
  });
}

class Message {
  final String id;
  final String senderId;
  final String content;
  final DateTime timestamp;
  final MessageStatus status;

  Message({
    required this.id,
    required this.senderId,
    required this.content,
    required this.timestamp,
    this.status = MessageStatus.sent,
  });
}

enum MessageStatus {
  sent,
  delivered,
  read,
}