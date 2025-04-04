class Chat {
  final String chatId;
  final List<String> participantIds; // Références aux Users
  final List<String>? messageIds; // Références aux messages

  Chat({
    required this.chatId,
    required this.participantIds,
    this.messageIds,
  });

  Map<String, dynamic> toJson() => {
        'chatId': chatId,
        'participantIds': participantIds,
        'messageIds': messageIds ?? [],
      };

  factory Chat.fromJson(Map<String, dynamic> json) => Chat(
        chatId: json['chatId'],
        participantIds: List<String>.from(json['participantIds']),
        messageIds: List<String>.from(json['messageIds'] ?? []),
      );
}