

class Post {
  final String postId;
  final DateTime date;
  final bool status;
  final bool isSpam;
  final String creatorId; // Référence à User
  final String? moderatorId; // Référence à Administrator (optionnel)
  final String itemId; // Référence à Item

  Post({
    this.postId,
    required this.date,
    required this.status,
    this.isSpam = false,
    required this.creatorId,
    this.moderatorId,
    required this.itemId,
  });

  Map<String, dynamic> toJson() => {
        'postId': postId,
        'date': date.toIso8601String(),
        'status': status,
        'isSpam': isSpam,
        'creatorId': creatorId,
        'moderatorId': moderatorId,
        'itemId': itemId,
      };

  factory Post.fromJson(Map<String, dynamic> json) => Post(
        postId: json['postId'],
        date: DateTime.parse(json['date']),
        status: json['status'],
        isSpam: json['isSpam'] ?? false,
        creatorId: json['creatorId'],
        moderatorId: json['moderatorId'],
        itemId: json['itemId'],
      );
}