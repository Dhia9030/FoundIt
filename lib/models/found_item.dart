

import 'package:foundita/models/item.dart';

class FoundItem extends Item {
  final DateTime foundDate;

  FoundItem({
   required String itemId,
    required String itemName,
    required Category type,
    required String description,
    required String color,
    required DateTime date,
    required String photo,
    bool isFound = false,
    required String locationId,
    required this.foundDate,
  }) : super(
          itemId: itemId,
          itemName: itemName,
          type: type,
          description: description,
          color: color,
          date: date,
          photo: photo,
          isFound: isFound,
          locationId: locationId,
        );

  @override
  Map<String, dynamic> toJson() => {
        ...super.toJson(),
        'foundDate': foundDate.toIso8601String(),
      };

  factory FoundItem.fromJson(Map<String, dynamic> json) => FoundItem(
        itemId: json['itemId'],
        itemName: json['itemName'],
        type: Category.values.firstWhere((e) => e.name == json['type']),
        description: json['description'],
        color: json['color'],
        date: DateTime.parse(json['date']),
        photo: json['photo'],
        isFound: json['isFound'] ?? false,
        locationId: json['locationId'],
        foundDate: DateTime.parse(json['foundDate']),
      );
}