import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'dart:io';
import 'package:foundita/models/item.dart' as foundita_item;
import 'package:foundita/models/lost_item.dart';
import 'package:foundita/services/location_service.dart';
import 'package:http/http.dart' as http; // Import the http package
import 'package:path/path.dart' as path; // For getting filename
import 'package:flutter/foundation.dart' hide Category;
import 'package:http_parser/http_parser.dart'; // For MediaType
import 'dart:typed_data'; // For Uint8List

class LostItemService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final LocationService _locationService;
  final String _uploadImageUrl = dotenv.env['BACKEND_UPLOAD_URL']!;
  final String _uploadapiKey = dotenv.env['UPLOAD_API_KEY']!;

  LostItemService({required LocationService locationService})
      : _locationService = locationService;

  // Reference to the lost items collection
  CollectionReference get _lostItemsCollection =>
      _firestore.collection('lostItems');

  /// Reports a new lost item to Firestore with location
  /// Returns the document ID of the newly created item
  Future<String> reportLostItem({
    required String itemName,
    required foundita_item.Category type,
    required String description,
    required String color,
    required DateTime date,
    required dynamic imageFile, // Changed to dynamic
    required double latitude,
    required double longitude,
    required DateTime lostDate,
    required String userId,
  }) async {
    try {
      print(
          "Reporting lost item from service: $itemName, type: $type, description: $description, color: $color, date: $date, latitude: $latitude, longitude: $longitude, lostDate: $lostDate");
      // 1. Create or get location
      String locationId = await _locationService.addLocation(
        latitude: latitude,
        longitude: longitude,
      );
      // 3. Create a new LostItem
      final ItemWithoutPhoto = LostItem(
        userId: userId,
        itemId: '', // Will be set by Firestore
        itemName: itemName,
        type: type,
        description: description,
        color: color,
        date: date,
        photo: '', // Will be set after image upload'',
        isFound: false,
        locationId: locationId,
        lostDate: lostDate,
      );

      // 2. Upload image if provided
      String? photoUrl;
      if (imageFile != null) {
        if (imageFile is File) {
          print('Uploading image ...');
          photoUrl = await _uploadImage(imageFile);
        } else if (imageFile is Uint8List) {
          photoUrl = await _uploadImageBytes(imageFile, ItemWithoutPhoto);
        } else {
          print('Unsupported image data type: ${imageFile.runtimeType}');
        }
      }
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

  /// Uploads an image to the Python backend and returns the blob name
  Future<String> _uploadImage(File imageFile) async {
    try {
      final uri = Uri.parse(_uploadImageUrl);
      final request = http.MultipartRequest('POST', uri);
      print("the api key is $_uploadapiKey");
      request.headers['X-API-Key'] = _uploadapiKey;

      if (kIsWeb) {
        print("k is web : ${kIsWeb}");
        // For web, read the file as bytes
        final bytes = await imageFile.readAsBytes();
        request.files.add(
          http.MultipartFile.fromBytes(
            'file',
            bytes,
            contentType:
                MediaType('image', 'png'), // Adjust content type if needed
          ),
        );
      } else {
        print("k is web : ${kIsWeb}");
        // For mobile, use fromPath (dart:io is available)
        request.files.add(
          await http.MultipartFile.fromPath(
            'file',
            imageFile.path,
            filename: path.basename(imageFile.path),
          ),
        );
      }

      final response = await request.send();
      final responseBody = await response.stream.bytesToString();
      final jsonResponse = jsonDecode(responseBody);

      if (response.statusCode == 200 && jsonResponse['status'] == 'success') {
        return jsonResponse['image_url'] ?? '';
      } else {
        print(
            'Error uploading image to backend: ${response.statusCode} - $responseBody');
        throw Exception('Failed to upload image to backend');
      }
    } catch (e) {
      print('Error uploading image: $e');
      rethrow;
    }
  }

  Future<String> _uploadImageBytes(
    Uint8List imageBytes,
    LostItem lostItem,
  ) async {
    try {
      final uri = Uri.parse(_uploadImageUrl);
      final request = http.MultipartRequest('POST', uri);
      request.headers['X-API-Key'] = _uploadapiKey;

      // Extract fields from LostItem
      request.fields['user_id'] = lostItem.userId;
      request.fields['post_id'] = lostItem.itemId;
      request.fields['post_type'] = lostItem.type.toString();
      request.fields['description'] = lostItem.description;
      request.fields['item_category'] =
          lostItem.type.toString(); // Adjust if needed

      request.files.add(
        http.MultipartFile.fromBytes(
          'file',
          imageBytes,
          filename: 'image_${DateTime.now().millisecondsSinceEpoch}.jpg',
          contentType:
              MediaType('image', 'png'), // Adjust content type if needed
        ),
      );

      final response = await request.send();
      final responseBody = await response.stream.bytesToString();
      final jsonResponse = jsonDecode(responseBody);

      if (response.statusCode == 200) {
        return jsonResponse['image_url'] ?? '';
      } else {
        print(
            'Error uploading image bytes to backend: ${response.statusCode} - $responseBody');
        throw Exception('Failed to upload image bytes to backend');
      }
    } catch (e) {
      print('❌ Error uploading image bytes: $e');
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
