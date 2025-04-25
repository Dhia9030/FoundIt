

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
    required String userId, // Added userId parameter
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
        userId: userId, // Pass userId to super constructor
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
        userId: json['userId'], // Extract userId from JSON
        foundDate: DateTime.parse(json['foundDate']),
      );
      
  // Add copyWith method to FoundItem similar to LostItem
  FoundItem copyWith({
    String? itemId,
    String? itemName,
    Category? type,
    String? description,
    String? color,
    DateTime? date,
    String? photo,
    bool? isFound,
    String? locationId,
    String? userId, // Added userId parameter
    DateTime? foundDate,
  }) {
    return FoundItem(
      itemId: itemId ?? this.itemId,
      itemName: itemName ?? this.itemName,
      type: type ?? this.type,
      description: description ?? this.description,
      color: color ?? this.color,
      date: date ?? this.date,
      photo: photo ?? this.photo,
      isFound: isFound ?? this.isFound,
      locationId: locationId ?? this.locationId,
      userId: userId ?? this.userId, // Handle userId in copyWith
      foundDate: foundDate ?? this.foundDate,
    );
  }
}