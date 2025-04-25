import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'dart:io';
import 'package:foundita/models/item.dart';
import 'package:foundita/models/lost_item.dart';
import 'package:foundita/services/location_service.dart';

class LostItemService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final LocationService _locationService;

  LostItemService({required LocationService locationService}) 
      : _locationService = locationService;

  // Reference to the lost items collection
  CollectionReference get _lostItemsCollection => 
      _firestore.collection('lostItems');

  /// Reports a new lost item to Firestore with location
  /// Returns the document ID of the newly created item
  Future<String> reportLostItem({
    required String itemName,
    required Category type,
    required String description,
    required String color,
    required DateTime date,
    required File? imageFile,
    required double latitude,
    required double longitude,
    required DateTime lostDate, 
    required String userId,
  }) async {
    try {
      // 1. Create or get location
      String locationId = await _locationService.addLocation(
        latitude: latitude,
        longitude: longitude,
      );

      // 2. Upload image if provided
      String? photoUrl;
      if (imageFile != null) {
        photoUrl = await _uploadImage(imageFile);
      }

      // 3. Create a new LostItem
      final newItem = LostItem(
        userId: userId, 
        itemId: '', // Will be set by Firestore
        itemName: itemName,
        type: type,
        description: description,
        color: color,
        date: date,
        photo: photoUrl ?? '',
        locationId: locationId,
        lostDate: lostDate,
      );

      // 4. Add to Firestore and get document reference
      final docRef = await _lostItemsCollection.add(newItem.toJson());

      // 5. Update the item with the generated ID
      await docRef.update({'itemId': docRef.id});

      // 6. Add the item ID to the location
      await _locationService.addItemToLocation(locationId, docRef.id);

      return docRef.id;
    } catch (e) {
      print('Error reporting lost item: $e');
      rethrow;
    }
  }

  /// Uploads an image to Firebase Storage and returns the download URL
  Future<String> _uploadImage(File imageFile) async {
    try {
      // Create a unique filename
      final String fileName = 'lost_items/${DateTime.now().millisecondsSinceEpoch}.jpg';
      
      // Upload the file
      final Reference storageRef = _storage.ref().child(fileName);
      final UploadTask uploadTask = storageRef.putFile(imageFile);
      final TaskSnapshot snapshot = await uploadTask;
      
      // Get the download URL
      return await snapshot.ref.getDownloadURL();
    } catch (e) {
      print('Error uploading image: $e');
      rethrow;
    }
  }

  /// Gets a stream of all lost items
  Stream<List<LostItem>> getLostItems() {
    return _lostItemsCollection
        .orderBy('date', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => LostItem.fromJson(doc.data() as Map<String, dynamic>))
            .toList());
  }

  /// Gets a single lost item by ID
  Future<LostItem?> getLostItemById(String itemId) async {
    try {
      final doc = await _lostItemsCollection.doc(itemId).get();
      if (doc.exists) {
        return LostItem.fromJson(doc.data() as Map<String, dynamic>);
      }
      return null;
    } catch (e) {
      print('Error getting lost item: $e');
      rethrow;
    }
  }

  /// Updates the found status of a lost item
  Future<void> updateFoundStatus(String itemId, bool isFound) async {
    try {
      await _lostItemsCollection.doc(itemId).update({'isFound': isFound});
    } catch (e) {
      print('Error updating found status: $e');
      rethrow;
    }
  }

  /// Deletes a lost item and removes it from location
  Future<void> deleteLostItem(String itemId) async {
    try {
      // First get the item to find its location
      final item = await getLostItemById(itemId);
      if (item != null) {
        // Remove item from its location
        await _locationService.removeItemFromLocation(item.locationId, itemId);
      }

      // Then delete the item
      await _lostItemsCollection.doc(itemId).delete();
    } catch (e) {
      print('Error deleting lost item: $e');
      rethrow;
    }
  }

  /// Gets lost items by location ID
  Future<List<LostItem>> getLostItemsByLocation(String locationId) async {
    try {
      final snapshot = await _lostItemsCollection
          .where('locationId', isEqualTo: locationId)
          .get();
      return snapshot.docs
          .map((doc) => LostItem.fromJson(doc.data() as Map<String, dynamic>))
          .toList();
    } catch (e) {
      print('Error getting lost items by location: $e');
      rethrow;
    }
  }
}