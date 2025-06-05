// models/conversation.dart
import 'package:cloud_firestore/cloud_firestore.dart';

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

  Map<String, dynamic> toMap() => {
    'id': id,
    'notificationId': notificationId,
    'participant1Id': participant1Id,
    'participant2Id': participant2Id,
    'itemId': itemId,
    'messages': messages.map((m) => m.toMap()).toList(),
    'createdAt': createdAt,
    'updatedAt': updatedAt,
  };

  factory Conversation.fromMap(Map<String, dynamic> map) {
    return Conversation(
      id: map['id'] ?? '',
      notificationId: map['notificationId'] ?? '',
      participant1Id: map['participant1Id'] ?? '',
      participant2Id: map['participant2Id'] ?? '',
      itemId: map['itemId'] ?? '',
      messages: (map['messages'] as List<dynamic>?)
          ?.map((m) => Message.fromMap(m as Map<String, dynamic>))
          .toList() ?? [],
      createdAt: (map['createdAt'] as Timestamp).toDate(),
      updatedAt: (map['updatedAt'] as Timestamp).toDate(),
    );
  }
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

  Map<String, dynamic> toMap() => {
    'id': id,
    'senderId': senderId,
    'content': content,
    'timestamp': timestamp,
    'status': status.name,
  };

  factory Message.fromMap(Map<String, dynamic> map) {
    return Message(
      id: map['id'] ?? '',
      senderId: map['senderId'] ?? '',
      content: map['content'] ?? '',
      timestamp: (map['timestamp'] as Timestamp).toDate(),
      status: MessageStatus.values.firstWhere(
        (e) => e.name == map['status'],
        orElse: () => MessageStatus.sent,
      ),
    );
  }
}

enum MessageStatus {
  sent,
  delivered,
  read,
}