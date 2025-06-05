import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';
import 'package:foundita/providers/location_provider.dart';

class MapPickerScreen extends StatefulWidget {
  const MapPickerScreen({Key? key}) : super(key: key);

  @override
  _MapPickerScreenState createState() => _MapPickerScreenState();
}

class _MapPickerScreenState extends State<MapPickerScreen> {
  final MapController _mapController = MapController();
  LatLng? _selectedLocation;
  bool _isLoading = true;

  // Default map position (will be updated to user's location)
  LatLng _initialPosition = LatLng(48.8566, 2.3522); // Paris by default
  double _initialZoom = 14.0;

  @override
  void initState() {
    super.initState();
    _getUserLocation();
  }

  Future<void> _getUserLocation() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Get user's current location
      final locationProvider = Provider.of<LocationProvider>(context, listen: false);
      await locationProvider.getCurrentLocation();
      
      if (locationProvider.currentUserPosition != null) {
        final userPosition = locationProvider.currentUserPosition!;
        
        // Update initial position to user's location
        _initialPosition = LatLng(userPosition.latitude, userPosition.longitude);

        // Set the initial selected location to user's location
        setState(() {
          _selectedLocation = LatLng(userPosition.latitude, userPosition.longitude);
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error getting location: ${e.toString()}')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Select Item Location'),
        actions: [
          IconButton(
            icon: Icon(Icons.check),
            onPressed: _selectedLocation == null
                ? null
                : () {
                    // Convert from flutter_map's LatLng to a plain object for passing back
                    Navigator.of(context).pop({
                      'latitude': _selectedLocation!.latitude,
                      'longitude': _selectedLocation!.longitude,
                    });
                  },
          ),
        ],
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : Stack(
              children: [
                FlutterMap(
                  mapController: _mapController,
                  options: MapOptions(
                    initialCenter: _initialPosition,
                    initialZoom: _initialZoom,
                    onTap: (tapPosition, point) {
                      setState(() {
                        _selectedLocation = point;
                      });
                    },
                  ),
                  children: [
                    TileLayer(
                      urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                      userAgentPackageName: 'com.example.foundita',
                    ),
                    MarkerLayer(
                      markers: _selectedLocation == null
                          ? []
                          : [
                              Marker(
                                point: _selectedLocation!,
                                width: 40,
                                height: 40,
                                child: Icon(
                                  Icons.location_pin,
                                  color: Colors.red,
                                  size: 40,
                                ),
                              ),
                            ],
                    ),
                  ],
                ),
                Align(
                  alignment: Alignment.bottomCenter,
                  child: Container(
                    margin: EdgeInsets.all(16),
                    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black26,
                          blurRadius: 8,
                          offset: Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Text(
                      _selectedLocation == null
                          ? 'Tap on the map to select a location'
                          : 'Location selected: ${_selectedLocation!.latitude.toStringAsFixed(6)}, ${_selectedLocation!.longitude.toStringAsFixed(6)}',
                      style: TextStyle(fontSize: 16),
                    ),
                  ),
                ),
              ],
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final locationProvider = Provider.of<LocationProvider>(context, listen: false);
          await locationProvider.getCurrentLocation();
          
          if (locationProvider.currentUserPosition != null) {
            final position = locationProvider.currentUserPosition!;
            _mapController.move(
              LatLng(position.latitude, position.longitude),
              15.0,
            );
            setState(() {
              _selectedLocation = LatLng(position.latitude, position.longitude);
            });
          }
        },
        child: Icon(Icons.my_location),
      ),
    );
  }
}