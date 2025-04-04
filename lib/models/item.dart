enum Category {
  electronics,
  clothing,
  documents,
  other,
}

class Item {
  final String itemId;
  final String itemName;
  final Category type;
  final String description;
  final String color;
  final DateTime date;
  final String photo;
  final bool isFound;
  final String locationId; // Référence à Location

  Item({
    required this.itemId,
    required this.itemName,
    required this.type,
    required this.description,
    required this.color,
    required this.date,
    required this.photo,
    this.isFound = false,
    required this.locationId,
  });

  Map<String, dynamic> toJson() => {
        'itemId': itemId,
        'itemName': itemName,
        'type': type.name,
        'description': description,
        'color': color,
        'date': date.toIso8601String(),
        'photo': photo,
        'isFound': isFound,
        'locationId': locationId,
      };

  factory Item.fromJson(Map<String, dynamic> json) => Item(
        itemId: json['itemId'],
        itemName: json['itemName'],
        type: Category.values.firstWhere((e) => e.name == json['type']),
        description: json['description'],
        color: json['color'],
        date: DateTime.parse(json['date']),
        photo: json['photo'],
        isFound: json['isFound'] ?? false,
        locationId: json['locationId'],
      );
}