class Location {
  final String id;
  final double latitude;
  final double longitude;
  final List<String>? itemIds; // Références aux items

  Location({
    required this.id,
    required this.latitude,
    required this.longitude,
    this.itemIds,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'latitude': latitude,
        'longitude': longitude,
        'itemIds': itemIds ?? [],
      };

  factory Location.fromJson(Map<String, dynamic> json) => Location(
        id: json['id'],
        latitude: json['latitude'],
        longitude: json['longitude'],
        itemIds: List<String>.from(json['itemIds'] ?? []),
      );
}