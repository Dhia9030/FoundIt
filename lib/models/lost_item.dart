import 'package:foundita/models/item.dart';

class LostItem extends Item {
  final DateTime lostDate;

  LostItem({
    required String itemId,
    required String itemName,
    required Category type,
    required String description,
    required String color,
    required DateTime date,
    required String photo,
    bool isFound = false,
    required String locationId,
    required this.lostDate,
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
        'lostDate': lostDate.toIso8601String(),
      };

  factory LostItem.fromJson(Map<String, dynamic> json) => LostItem(
        itemId: json['itemId'],
        itemName: json['itemName'],
        type: Category.values.firstWhere((e) => e.name == json['type']),
        description: json['description'],
        color: json['color'],
        date: DateTime.parse(json['date']),
        photo: json['photo'],
        isFound: json['isFound'] ?? false,
        locationId: json['locationId'],
        lostDate: DateTime.parse(json['lostDate']),
      );
  LostItem copyWith({
    String? itemId,
    String? itemName,
    Category? type,
    String? description,
    String? color,
    DateTime? date,
    String? photo,
    bool? isFound,
    String? locationId,
    DateTime? lostDate,
  }) {
    return LostItem(
      itemId: itemId ?? this.itemId,
      itemName: itemName ?? this.itemName,
      type: type ?? this.type,
      description: description ?? this.description,
      color: color ?? this.color,
      date: date ?? this.date,
      photo: photo ?? this.photo,
      isFound: isFound ?? this.isFound,
      locationId: locationId ?? this.locationId,
      lostDate: lostDate ?? this.lostDate,
    );
  }
}
