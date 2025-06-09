import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'dart:io';
import 'package:foundita/models/item.dart' as foundita_item;
import 'package:foundita/models/lost_item.dart';
import 'package:foundita/services/location_service.dart';
import 'package:http/http.dart' as http;
import 'package:path/path.dart' as path;
import 'package:flutter/foundation.dart' hide Category;
import 'package:http_parser/http_parser.dart';
import 'dart:typed_data';

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
    required dynamic imageFile, // File or Uint8List
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

      // 2. Generate a new document reference to get the itemId
      final docRef = _lostItemsCollection.doc();
      final itemId = docRef.id;

      // 3. Create LostItem with the generated itemId
      final itemWithoutPhoto = LostItem(
        userId: userId,
        itemId: itemId,
        itemName: itemName,
        type: type,
        description: description,
        color: color,
        date: date,
        photo: '',
        isFound: false,
        locationId: locationId,
        lostDate: lostDate,
      );

      // 4. Upload image if provided
      String? photoUrl;
      if (imageFile != null) {
        if (imageFile is File) {
          photoUrl = await _uploadImage(imageFile);
        } else if (imageFile is Uint8List) {
          photoUrl = await _uploadImageBytes(imageFile, itemWithoutPhoto);
        } else {
          print('Unsupported image data type: ${imageFile.runtimeType}');
        }
      }

      // 5. Create the final LostItem with photoUrl
      final newItem = itemWithoutPhoto.copyWith(photo: photoUrl ?? '');

      // 6. Add to Firestore using the generated docRef
      await docRef.set(newItem.toJson());

      // 7. Add the item ID to the location
      await _locationService.addItemToLocation(locationId, itemId);

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
      request.headers['X-API-Key'] = _uploadapiKey;

      if (kIsWeb) {
        final bytes = await imageFile.readAsBytes();
        request.files.add(
          http.MultipartFile.fromBytes(
            'file',
            bytes,
            contentType: MediaType('image', 'png'),
          ),
        );
      } else {
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
        print('Error uploading image to backend: ${response.statusCode} - $responseBody');
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
      request.fields['post_type'] = 'lostitem ';
      request.fields['description'] = lostItem.description;
      request.fields['item_category'] = lostItem.type.toString();

      request.files.add(
        http.MultipartFile.fromBytes(
          'file',
          imageBytes,
          filename: 'image_${DateTime.now().millisecondsSinceEpoch}.jpg',
          contentType: MediaType('image', 'png'),
        ),
      );

      final response = await request.send();
      final responseBody = await response.stream.bytesToString();
      final jsonResponse = jsonDecode(responseBody);

      if (response.statusCode == 200) {
        return jsonResponse['image_url'] ?? '';
      } else {
        print('Error uploading image bytes to backend: ${response.statusCode} - $responseBody');
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