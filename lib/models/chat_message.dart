

class ChatMessage {
  final String chatMessageId;
  final String senderId; // Référence à User
  final String receiverId; // Référence à User
  final String content;
  final String chatId; // Référence à Chat

  ChatMessage({
   required this.chatMessageId,
    required this.senderId,
    required this.receiverId,
    required this.content,
    required this.chatId,
  });

  Map<String, dynamic> toJson() => {
        'chatMessageId': chatMessageId,
        'senderId': senderId,
        'receiverId': receiverId,
        'content': content,
        'chatId': chatId,
      };

  factory ChatMessage.fromJson(Map<String, dynamic> json) => ChatMessage(
        chatMessageId: json['chatMessageId'],
        senderId: json['senderId'],
        receiverId: json['receiverId'],
        content: json['content'],
        chatId: json['chatId'],
      );
}