import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:io';
import 'package:flutter/foundation.dart' hide Category;
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:geolocator/geolocator.dart';
import 'package:foundita/models/item.dart';
import 'package:foundita/models/found_item.dart';
import 'package:foundita/models/location.dart';
import 'package:foundita/services/location_service.dart';
import 'package:foundita/providers/location_provider.dart';
import 'package:latlong2/latlong.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:http_parser/http_parser.dart';
import 'package:path/path.dart' as path;

class FoundItemService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final LocationService _locationService;
  final String _uploadImageUrl = dotenv.env['BACKEND_UPLOAD_URL']!;
  final String _uploadapiKey = dotenv.env['UPLOAD_API_KEY']!;
  final String _storageUrl = dotenv.env['STORAGE_URL'] ?? "";
  final String _storageApiKey = dotenv.env['STORAGE_API_KEY'] ?? "";
  CollectionReference get _foundItemsCollection =>
      _firestore.collection('foundItems');
  CollectionReference get _locationsCollection =>
      _firestore.collection('locations');

  FoundItemService({required LocationService locationService})
      : _locationService = locationService;

  Future<String> reportFoundItem({
    required String itemName,
    required Category type,
    required String description,
    required String color,
    required DateTime date,
    required dynamic imageData,
    required double latitude,
    required double longitude,
    required DateTime foundDate,
    required String userId,
  }) async
  {
    try {
      String? photoUrl;

      if (imageData != null) {
        if (imageData is File) {
          photoUrl = await _uploadImage(imageData);
        } else if (imageData is Uint8List) {
          photoUrl = await _uploadImageBytes(imageData);
        } else {
          print("Unsupported image data type: ${imageData.runtimeType}");
          photoUrl = null;
        }
      }

      String locationId;
      Location? location =
          await _locationService.getLocationByCoordinates(latitude, longitude);
      if (location != null) {
        locationId = location.id;
      } else {
        locationId = await _locationService.addLocation(
          latitude: latitude,
          longitude: longitude,
        );
      }

      final newItem = FoundItem(
        userId: userId,
        itemId: '',
        itemName: itemName,
        type: type,
        description: description,
        color: color,
        date: date,
        photo: photoUrl ?? '',
        locationId: locationId,
        foundDate: foundDate,
        isFound: true,
      );

      final docRef = await _foundItemsCollection.add(newItem.toJson());

      await docRef.update({'itemId': docRef.id});

      await _locationService.addItemToLocation(locationId, docRef.id);

      print('✅ Item reported successfully with ID: ${docRef.id}');
      return docRef.id;
    } catch (e) {
      print('❌ Error reporting found item to Firestore/Storage: $e');
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
        // For web, read the file as bytes
        final bytes = await imageFile.readAsBytes();
        request.files.add(
          http.MultipartFile.fromBytes(
            'file',
            bytes,
            contentType: MediaType('image','png'), // Adjust content type if needed
           
          ),
        );
      } else {
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
        return jsonResponse['blob_name'];
      } else {
        print('Error uploading image to backend: ${response.statusCode} - $responseBody');
        throw Exception('Failed to upload image to backend');
      }
    } catch (e) {
      print('Error uploading image: $e');
      rethrow;
    }
  }


 Future<String> _uploadImageBytes(Uint8List imageBytes) async {
    try {
      final uri = Uri.parse(_uploadImageUrl);
      final request = http.MultipartRequest('POST', uri);
      request.headers['X-API-Key'] = _uploadapiKey;
      request.files.add(
        http.MultipartFile.fromBytes(
          'file',
          imageBytes,
          filename: 'image_${DateTime.now().millisecondsSinceEpoch}.jpg',
           contentType: MediaType('image','png'), // Adjust content type if needed
        ),
      );

      final response = await request.send();
      final responseBody = await response.stream.bytesToString();
      final jsonResponse = jsonDecode(responseBody);

      if (response.statusCode == 200 && jsonResponse['status'] == 'success') {
        return jsonResponse['blob_name'];
      } else {
        print('Error uploading image bytes to backend: ${response.statusCode} - $responseBody');
        throw Exception('Failed to upload image bytes to backend');
      }
    } catch (e) {
      print('❌ Error uploading image bytes: $e');
      rethrow;
    }
  }
  Future<List<FoundItem>> getAllFoundItems() async {
    try {
      final snapshot = await _foundItemsCollection.get();
      return snapshot.docs.map((doc) => FoundItem.fromJson(doc.data() as Map<String, dynamic>)).toList();
      
    } catch (e) {
      print('❌ Error fetching all found items: $e');
      rethrow;
    }
  }
  
  Future<List<FoundItemPopulated>> getAllPopulatedFoundItems() async
  {
    try {
      final snapshot = await _foundItemsCollection.get();
      final items_list = snapshot.docs.map((doc) => FoundItem.fromJson(doc.data() as Map<String, dynamic>)).toList();
      final List<FoundItemPopulated> items_populated = await Future.wait(items_list.map((item) => item.convertTo()));
      return items_populated;
    } catch (e) {
      print('❌ Error fetching all found items: $e');
      rethrow;
    }
  }

  Future<List<FoundItemPopulated>> getPopulatedItemsByLocation(String targetLocationId) async {
    try {
      // 1. Get the target location first
      final targetLocation = await _locationService.getLocationById(targetLocationId);
      if (targetLocation == null) {
        throw Exception('Target location not found');
      }
      if (targetLocation.latitude == null || targetLocation.longitude == null) {
        throw Exception('Target location coordinates are missing');
      }

      // 2. Get all items safely
      final itemsSnapshot = await _foundItemsCollection.get();
      final itemLocationIds = await getAllFoundItems().then((items) => items.map((item) => item.locationId).toSet());

      // 4. Get all related locations in one batch
      final locations = await Future.wait(
          itemLocationIds.map((id) => _locationService.getLocationById(id!))
      );

      // 5. Create location map for quick lookup
      final locationMap = {
        for (var loc in locations.whereType<Location>()) loc.id: loc
      };

      // 6. Filter items that have locations within 50km
      final filteredItems = itemsSnapshot.docs.where((doc) {
        final item = FoundItem.fromJson(doc.data() as Map<String, dynamic>);
        final itemLocation = locationMap[item.locationId];

        if (itemLocation == null ||
            itemLocation.latitude == null ||
            itemLocation.longitude == null) return false;

        final distance = Geolocator.distanceBetween(
          targetLocation.latitude,
          targetLocation.longitude,
          itemLocation.latitude!,
          itemLocation.longitude!,
        );

        return distance < 50;
      }).toList();

      // 7. Convert to populated items
      final List<FoundItemPopulated> populatedItems = await Future.wait(
          filteredItems.map((doc) async {
            final item = FoundItem.fromJson(doc.data() as Map<String, dynamic>);
            return item.convertTo();
          })
      );

      return populatedItems;
    } catch (e) {
      print('❌ Error fetching nearby items: $e');
      rethrow;
    }
  }

  Future<Uint8List> getImage(String blobName) async {
    try {
      if (_storageUrl.isEmpty) {
        print('❌ STORAGE_URL is not set in .env file');
        return Uint8List(0);
      }
      final imageUrl = '$_storageUrl/download/$blobName';

      final response = await http.get(
        Uri.parse(imageUrl),
        headers: {'X-API-Key': _storageApiKey});

      if (response.statusCode == 200) {
        print('image fetched with response : ${response.bodyBytes}');
        return response.bodyBytes;
      } else {
        print('❌ Error fetching image: ${response.statusCode} - ${response.reasonPhrase}');
        return Uint8List(0);
      }
    } catch (e) {
      print('❌ Error fetching image from storage: $e');
      rethrow;
    }
  }
}