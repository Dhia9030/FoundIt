import 'package:flutter/foundation.dart' hide Category;
import 'package:foundita/models/lost_item.dart';
import 'package:foundita/models/item.dart';
import 'package:foundita/services/lost_item_service.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class LostItemProvider with ChangeNotifier {
  final LostItemService _lostItemService;
  
  bool _isLoading = false;
  String? _error;
  List<LostItem> _lostItems = [];

  LostItemProvider({required LostItemService lostItemService}) 
      : _lostItemService = lostItemService;

  // Getters
  bool get isLoading => _isLoading;
  String? get error => _error;
  List<LostItem> get lostItems => _lostItems;

  /// Reports a lost item with location and updates state
  Future<void> reportLostItem({
    required String userId,
    required String itemName,
    required Category type,
    required String description,
    required String color,
    required DateTime date,
    required XFile? imageFile,
    required double latitude,
    required double longitude,
    required DateTime lostDate,
  }) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      File? image;
      if (imageFile != null) {
        image = File(imageFile.path);
      }

      await _lostItemService.reportLostItem(
        itemName: itemName,
        type: type,
        description: description,
        color: color,
        date: date,
        imageFile: image,
        latitude: latitude,
        longitude: longitude,
        lostDate: lostDate, 
        userId: userId,
      );

      // Refresh the list after reporting
      await fetchLostItems();
    } catch (e) {
      _error = e.toString();
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Fetches all lost items
  Future<void> fetchLostItems() async {
    try {
      _isLoading = true;
      notifyListeners();

      // Get a single snapshot from the stream
      final items = await _lostItemService.getLostItems().first;
      _lostItems = items;
    } catch (e) {
      _error = e.toString();
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Fetches lost items by location
  Future<List<LostItem>> getLostItemsByLocation(String locationId) async {
    try {
      _isLoading = true;
      notifyListeners();

      final items = await _lostItemService.getLostItemsByLocation(locationId);
      return items;
    } catch (e) {
      _error = e.toString();
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Updates found status of an item
  Future<void> updateFoundStatus(String itemId, bool isFound) async {
    try {
      _isLoading = true;
      notifyListeners();

      await _lostItemService.updateFoundStatus(itemId, isFound);
      
      // Update local state
      final index = _lostItems.indexWhere((item) => item.itemId == itemId);
      if (index != -1) {
        _lostItems[index] = _lostItems[index].copyWith(isFound: isFound);
      }
    } catch (e) {
      _error = e.toString();
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Deletes a lost item
  Future<void> deleteLostItem(String itemId) async {
    try {
      _isLoading = true;
      notifyListeners();

      await _lostItemService.deleteLostItem(itemId);
      
      // Update local state
      _lostItems.removeWhere((item) => item.itemId == itemId);
    } catch (e) {
      _error = e.toString();
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}