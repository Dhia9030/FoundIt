import 'package:foundita/models/account_holder.dart';

class User extends AccountHolder {
  final bool isBanned;
  final String phoneNumber;
  final List<String>? postIds; // Références aux posts
  final List<String>? chatIds; // Références aux chats

  User({
    String? userId,
    required String name,
    required String email,
    required AuthMethod authMethod,
    required String password,
    List<String>? notificationIds,
    this.isBanned = false,
    required this.phoneNumber,
    this.postIds,
    this.chatIds,
  }) : super(
          userId: userId,
          name: name,
          email: email,
          authMethod: authMethod,
          password: password,
          notificationIds: notificationIds,
        );

  @override
  Map<String, dynamic> toJson() => {
        ...super.toJson(),
        'isBanned': isBanned,
        'phoneNumber': phoneNumber,
        'postIds': postIds ?? [],
        'chatIds': chatIds ?? [],
      };

  factory User.fromJson(Map<String, dynamic> json) => User(
        userId: json['userId'],
        name: json['name'],
        email: json['email'],
        authMethod: AuthMethod.values.firstWhere((e) => e.name == json['authMethod']),
        password: json['password'],
        notificationIds: List<String>.from(json['notificationIds'] ?? []),
        isBanned: json['isBanned'] ?? false,
        phoneNumber: json['phoneNumber'],
        postIds: List<String>.from(json['postIds'] ?? []),
        chatIds: List<String>.from(json['chatIds'] ?? []),
      );
}

