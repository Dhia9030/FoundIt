

import 'package:foundita/models/account_holder.dart';

class Administrator extends AccountHolder {
  final List<String>? moderatedPostIds; // Références aux posts modérés

  Administrator({
    String? userId,
    required String name,
    required String email,
    required AuthMethod authMethod,
    required String password,
    List<String>? notificationIds,
    this.moderatedPostIds,
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
        'moderatedPostIds': moderatedPostIds ?? [],
      };

  factory Administrator.fromJson(Map<String, dynamic> json) => Administrator(
        userId: json['userId'],
        name: json['name'],
        email: json['email'],
        authMethod: AuthMethod.values.firstWhere((e) => e.name == json['authMethod']),
        password: json['password'],
        notificationIds: List<String>.from(json['notificationIds'] ?? []),
        moderatedPostIds: List<String>.from(json['moderatedPostIds'] ?? []),
      );
}