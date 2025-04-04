// models/lost_item.dart
import 'package:google_maps_flutter/google_maps_flutter.dart';

class LostItem {
  final String title;
  final String description;
  final LatLng location;
  final String? imageUrl;

  LostItem({
    required this.title,
    required this.description,
    required this.location,
    this.imageUrl,
  });
}