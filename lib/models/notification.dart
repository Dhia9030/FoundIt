

class Notification {
  final String notificationId;
  final String message;
  final DateTime timeStamp;
  final String accountHolderId; // Référence à AccountHolder

  Notification({
   required this.notificationId,
    required this.message,
    required this.timeStamp,
    required this.accountHolderId,
  });

  Map<String, dynamic> toJson() => {
        'notificationId': notificationId,
        'message': message,
        'timeStamp': timeStamp.toIso8601String(),
        'accountHolderId': accountHolderId,
      };

  factory Notification.fromJson(Map<String, dynamic> json) => Notification(
        notificationId: json['notificationId'],
        message: json['message'],
        timeStamp: DateTime.parse(json['timeStamp']),
        accountHolderId: json['accountHolderId'],
      );
}