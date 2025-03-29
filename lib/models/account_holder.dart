enum AuthMethod {
  google,
  facebook,
  email,
}

class AccountHolder {
  final String userId;
  final String name;
  final String email;
  final AuthMethod authMethod;
  final String password;
  final List<String>? notificationIds; // Références aux notifications

  AccountHolder({
    this.userId,
    required this.name,
    required this.email,
    required this.authMethod,
    required this.password,
    this.notificationIds,
  });

  Map<String, dynamic> toJson() => {
        'userId': userId,
        'name': name,
        'email': email,
        'authMethod': authMethod.name,
        'password': password,
        'notificationIds': notificationIds ?? [],
      };

  factory AccountHolder.fromJson(Map<String, dynamic> json) => AccountHolder(
        userId: json['userId'],
        name: json['name'],
        email: json['email'],
        authMethod: AuthMethod.values.firstWhere((e) => e.name == json['authMethod']),
        password: json['password'],
        notificationIds: List<String>.from(json['notificationIds'] ?? []),
      );
}