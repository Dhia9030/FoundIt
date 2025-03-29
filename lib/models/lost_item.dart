

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
}