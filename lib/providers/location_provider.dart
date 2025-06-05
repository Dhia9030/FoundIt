import 'package:flutter/foundation.dart';
import 'package:foundita/models/location.dart';
import 'package:foundita/services/location_service.dart';
import 'package:geolocator/geolocator.dart';

class LocationProvider with ChangeNotifier {
  final LocationService _locationService;
  
  bool _isLoading = false;
  String? _error;
  List<Location> _locations = [];
  Position? _currentUserPosition;

  LocationProvider({required LocationService locationService}) 
      : _locationService = locationService;

  // Getters
  bool get isLoading => _isLoading;
  String? get error => _error;
  List<Location> get locations => _locations;
  Position? get currentUserPosition => _currentUserPosition;

  /// Fetches all locations
  Future<void> fetchAllLocations() async {
    try {
      _isLoading = true;
      notifyListeners();

      _locations = await _locationService.getAllLocations();
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Fetches locations with items
  Future<void> fetchLocationsWithItems() async {
    try {
      _isLoading = true;
      notifyListeners();

      _locations = await _locationService.getLocationsWithItems();
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Gets a location by ID
  Future<Location?> getLocationById(String locationId) async {
    try {
      return await _locationService.getLocationById(locationId);
    } catch (e) {
      _error = e.toString();
      return null;
    }
  }

  /// Adds a new location
  Future<String> addLocation({
    required double latitude,
    required double longitude,
  }) async {
    try {
      _isLoading = true;
      notifyListeners();

      final locationId = await _locationService.addLocation(
        latitude: latitude,
        longitude: longitude,
      );

      // Refresh locations after adding
      await fetchAllLocations();

      return locationId;
    } catch (e) {
      _error = e.toString();
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Get current user location
  Future<Position> getCurrentLocation() async {
    try {
      _isLoading = true;
      notifyListeners();

      // Check if location services are enabled
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        throw Exception('Location services are disabled.');
      }

      // Check for location permissions
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          throw Exception('Location permissions are denied');
        }
      }
      
      if (permission == LocationPermission.deniedForever) {
        throw Exception('Location permissions are permanently denied, cannot request permissions.');
      }

      // Get the current position
      _currentUserPosition = await Geolocator.getCurrentPosition();
      return _currentUserPosition!;
    } catch (e) {
      _error = e.toString();
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Add item to location
  Future<void> addItemToLocation(String locationId, String itemId) async {
    try {
      await _locationService.addItemToLocation(locationId, itemId);
      // Refresh the locations
      await fetchAllLocations();
    } catch (e) {
      _error = e.toString();
      rethrow;
    }
  }

  /// Remove item from location
  Future<void> removeItemFromLocation(String locationId, String itemId) async {
    try {
      await _locationService.removeItemFromLocation(locationId, itemId);
      // Refresh the locations
      await fetchAllLocations();
    } catch (e) {
      _error = e.toString();
      rethrow;
    }
  }
}