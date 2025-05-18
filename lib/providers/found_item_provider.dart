import 'dart:io' as io;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart' hide Category;
import 'package:flutter/material.dart';
import 'package:foundita/providers/location_provider.dart';
import 'package:foundita/services/found_item_service.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:geolocator/geolocator.dart';
import 'package:foundita/models/item.dart';
import 'package:foundita/models/found_item.dart';
import 'package:foundita/models/location.dart';

class FoundItemProvider with ChangeNotifier {
  final FoundItemService _foundItemService;
  final LocationProvider _locationProvider;

  bool _isLoading = false;
  String? _error;
  List<FoundItem> _foundItems = [];
  List<FoundItemPopulated> _populatedItems = [];
  Uint8List imageFile = Uint8List(0);

  FoundItemProvider({
    required FoundItemService foundItemService,
    required LocationProvider locationProvider,
  })  : _foundItemService = foundItemService,
        _locationProvider = locationProvider;

  bool get isLoading => _isLoading;
  String? get error => _error;
  List<FoundItem> get foundItems => _foundItems;
  List<FoundItemPopulated> get populatedItems => _populatedItems;

  Future<bool> reportFoundItem({
    required String userId,
    required String itemName,
    required Category type,
    required String description,
    required String color,
    required DateTime date,
    required XFile? imageFile,
    required double latitude,
    required double longitude,
    required DateTime foundDate,
  }) async
  {
    _isLoading = true;
    _error = null;
    notifyListeners();
    bool success = false;

    try {
      dynamic imageData;
      if (imageFile != null) {
        if (kIsWeb) {
          imageData = await imageFile.readAsBytes();
        } else {
          try {
            imageData = io.File(imageFile.path);
          } catch (e) {
            print('Error creating File object: $e');
            imageData = await imageFile.readAsBytes();
          }
        }
      }

      await _foundItemService.reportFoundItem(
        itemName: itemName,
        type: type,
        description: description,
        color: color,
        date: date,
        imageData: imageData,
        latitude: latitude,
        longitude: longitude,
        foundDate: foundDate,
        userId: userId,
      );

      await fetchFoundItems();
      success = true;
    } catch (e) {
      print('Error in reportFoundItem: $e');
      _error = e.toString();
      success = false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
    return success;
  }

  Future<void> fetchFoundItems() async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      _foundItems = await _foundItemService.getAllFoundItems();
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchPopulatedItems() async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      _populatedItems = await _foundItemService.getAllPopulatedFoundItems();
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchPopulatedItemsByLocation(String locationId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      _populatedItems = await _foundItemService.getPopulatedItemsByLocation(locationId);
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchImage(String blobName) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      imageFile = await _foundItemService.getImage(blobName);
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
