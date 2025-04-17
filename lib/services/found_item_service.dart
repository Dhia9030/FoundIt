import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/foundation.dart' hide Category;
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:geolocator/geolocator.dart';
import 'package:foundita/models/item.dart';
import 'package:foundita/models/found_item.dart'; 
import 'package:foundita/models/location.dart'; 
import 'package:foundita/services/location_service.dart';
import 'package:foundita/providers/location_provider.dart'; 
import 'package:latlong2/latlong.dart';

class FoundItemService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final LocationService _locationService; 


  CollectionReference get _foundItemsCollection =>
      _firestore.collection('foundItems');

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
  }) async {
    try {

      String? photoUrl;
      String? imageFileName;

      if (imageData != null) {
        imageFileName =
            'found_items/${userId}_${DateTime.now().millisecondsSinceEpoch}.jpg';

        if (imageData is File) {
          photoUrl = await _uploadImage(imageData, imageFileName);
        } else if (imageData is Uint8List) {
          photoUrl = await _uploadImageBytes(imageData, imageFileName);
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


  Future<String> _uploadImage(File imageFile, String fileName) async {
    try {
      final Reference storageRef = _storage.ref().child(fileName);
      print('☁️ Uploading image file to: ${storageRef.fullPath}');
      final UploadTask uploadTask = storageRef.putFile(imageFile);
      final TaskSnapshot snapshot = await uploadTask;
      final String downloadUrl = await snapshot.ref.getDownloadURL();
      print('☁️ Image file uploaded successfully: $downloadUrl');
      return downloadUrl;
    } catch (e) {
      print('❌ Error uploading image file: $e');
      rethrow;
    }
  }

  Future<String> _uploadImageBytes(Uint8List imageBytes, String fileName) async {
    try {
      final Reference storageRef = _storage.ref().child(fileName);
      print('☁️ Uploading image bytes to: ${storageRef.fullPath}');
      final UploadTask uploadTask = storageRef.putData(
          imageBytes, SettableMetadata(contentType: 'image/jpeg'));
      final TaskSnapshot snapshot = await uploadTask;
      final String downloadUrl = await snapshot.ref.getDownloadURL();
      print('☁️ Image bytes uploaded successfully: $downloadUrl');
      return downloadUrl;
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
}