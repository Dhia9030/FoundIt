import 'package:flutter/material.dart';

enum ItemType { lost, found }

class Item {
  final String id;
  final String title;
  final String description;
  final String location;
  final DateTime date;
  final String? imageUrl;
  final ItemType type;
  final String userId;
  
  Item({
    required this.id,
    required this.title,
    required this.description,
    required this.location,
    required this.date,
    this.imageUrl,
    required this.type,
    required this.userId,
  });
}

class ItemProvider extends ChangeNotifier {
  List<Item> _items = [];
  bool _isLoading = false;
  String? _error;
  
  List<Item> get items => _items;
  List<Item> get lostItems => _items.where((item) => item.type == ItemType.lost).toList();
  List<Item> get foundItems => _items.where((item) => item.type == ItemType.found).toList();
  bool get isLoading => _isLoading;
  String? get error => _error;
  
  Future<void> fetchItems() async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    
    try {
      // Simulate API call
      await Future.delayed(Duration(seconds: 1));
      
      // Mock data
      _items = [
        Item(
          id: '1',
          title: 'Lost Wallet',
          description: 'Black leather wallet with ID cards',
          location: 'Central Park',
          date: DateTime.now().subtract(Duration(days: 2)),
          type: ItemType.lost,
          userId: '123',
        ),
        Item(
          id: '2',
          title: 'Found Keys',
          description: 'Set of keys with a blue keychain',
          location: 'Main Street Coffee Shop',
          date: DateTime.now().subtract(Duration(days: 1)),
          type: ItemType.found,
          userId: '456',
        ),
      ];
      
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }
  
  Future<void> addItem(Item item) async {
    _isLoading = true;
    notifyListeners();
    
    try {
      // Simulate API call
      await Future.delayed(Duration(seconds: 1));
      
      _items.add(item);
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }
  
  List<Item> getUserItems(String userId) {
    return _items.where((item) => item.userId == userId).toList();
  }
}

