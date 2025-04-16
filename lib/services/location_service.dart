import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:foundita/models/location.dart';

class LocationService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Reference to the locations collection
  CollectionReference get _locationsCollection => 
      _firestore.collection('locations');

  /// Adds a new location to Firestore
  /// Returns the document ID of the newly created location
  Future<String> addLocation({
    required double latitude,
    required double longitude,
  }) async {
    try {
      // Create a new Location
      final newLocation = Location(
        id: '', // Will be set by Firestore
        latitude: latitude,
        longitude: longitude,
        itemIds: [],
      );

      // Add to Firestore and get document reference
      final docRef = await _locationsCollection.add(newLocation.toJson());

      // Update the location with the generated ID
      await docRef.update({'id': docRef.id});

      return docRef.id;
    } catch (e) {
      print('Error adding location: $e');
      rethrow;
    }
  }

  /// Gets a location by ID
  Future<Location?> getLocationById(String locationId) async {
    try {
      final doc = await _locationsCollection.doc(locationId).get();
      if (doc.exists) {
        return Location.fromJson(doc.data() as Map<String, dynamic>);
      }
      return null;
    } catch (e) {
      print('Error getting location: $e');
      rethrow;
    }
  }

  /// Gets all locations
  Future<List<Location>> getAllLocations() async {
    try {
      final snapshot = await _locationsCollection.get();
      return snapshot.docs
          .map((doc) => Location.fromJson(doc.data() as Map<String, dynamic>))
          .toList();
    } catch (e) {
      print('Error getting all locations: $e');
      rethrow;
    }
  }

  /// Gets all locations with lost items
  Future<List<Location>> getLocationsWithItems() async {
    try {
      final snapshot = await _locationsCollection
          .where('itemIds', isNotEqualTo: [])
          .get();
      return snapshot.docs
          .map((doc) => Location.fromJson(doc.data() as Map<String, dynamic>))
          .toList();
    } catch (e) {
      print('Error getting locations with items: $e');
      rethrow;
    }
  }

  /// Updates a location by adding an item ID to it
  Future<void> addItemToLocation(String locationId, String itemId) async {
    try {
      // Get the current location
      final location = await getLocationById(locationId);
      if (location == null) {
        throw Exception('Location not found');
      }

      // Add the item ID to the list
      final updatedItemIds = [...(location.itemIds ?? []), itemId];

      // Update the location
      await _locationsCollection.doc(locationId).update({
        'itemIds': updatedItemIds,
      });
    } catch (e) {
      print('Error adding item to location: $e');
      rethrow;
    }
  }

  /// Removes an item ID from a location
  Future<void> removeItemFromLocation(String locationId, String itemId) async {
    try {
      // Get the current location
      final location = await getLocationById(locationId);
      if (location == null) {
        throw Exception('Location not found');
      }

      // Remove the item ID from the list
      final updatedItemIds = location.itemIds?.where((id) => id != itemId).toList() ?? [];

      // Update the location
      await _locationsCollection.doc(locationId).update({
        'itemIds': updatedItemIds,
      });
    } catch (e) {
      print('Error removing item from location: $e');
      rethrow;
    }
  }
}