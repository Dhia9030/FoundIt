import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart' hide Category;
import 'package:foundita/models/item.dart';
import 'package:foundita/services/found_item_service.dart';
import 'package:foundita/services/location_service.dart';

class FoundItem extends Item {
  final DateTime foundDate;
  CollectionReference get _locationsCollection =>
      FirebaseFirestore.instance.collection('locations');
  
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
  Future<FoundItemPopulated> convertTo() async {
    final locationDoc =
    await _locationsCollection.doc(locationId).get();
    final locationData = locationDoc.data() as Map<String, dynamic>;
    final FoundItemService _foundItemService = FoundItemService(locationService: LocationService());
    final imageData = await _foundItemService.getImage(photo);


    return FoundItemPopulated(
      itemId: itemId,
      itemName: itemName,
      type: type,
      description: description,
      color: color,
      date: date,
      photo: photo,
      isFound: isFound,
      locationId: locationId,
      userId: userId,
      foundDate: foundDate,
      latitude: locationData['latitude'],
      longitude: locationData['longitude'],
      imageData: imageData,
    );
  }

}

class FoundItemPopulated extends ItemPopulated {
  final DateTime foundDate;

  FoundItemPopulated({
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
    required double latitude,
    required double longitude,
    required Uint8List imageData,
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
    latitude: latitude,
    longitude: longitude,
    userId: userId,
    imageData: imageData,
  );

  @override
  Map<String, dynamic> toJson() => {
    ...super.toJson(),
    'foundDate': foundDate.toIso8601String(),
  };

  static Future<FoundItemPopulated> fromFoundItem(FoundItem item) async {
    final locationDoc = await FirebaseFirestore.instance
        .collection('locations')
        .doc(item.locationId)
        .get();

    final locationData = locationDoc.data() as Map<String, dynamic>;

    final imageData =
    await FoundItemService(locationService: LocationService()).getImage(item.photo);

    return FoundItemPopulated(
      itemId: item.itemId,
      itemName: item.itemName,
      type: item.type,
      description: item.description,
      color: item.color,
      date: item.date,
      photo: item.photo,
      isFound: item.isFound,
      locationId: item.locationId,
      userId: item.userId,
      foundDate: item.foundDate,
      latitude: locationData['latitude'],
      longitude: locationData['longitude'],
      imageData: imageData,
    );
  }

  factory FoundItemPopulated.fromJson(Map<String, dynamic> json) => FoundItemPopulated(
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
    latitude: json['latitude'],
    longitude: json['longitude'],
    imageData: Uint8List(0),
  );

  // Add copyWith method to FoundItem similar to LostItem
  FoundItemPopulated copyWith({
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
    double? latitude,
    double? longitude,
  }) {
    return FoundItemPopulated(
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
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      imageData: imageData ?? this.imageData,
    );
  }

}