 import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';
import 'package:foundita/models/found_item.dart';
import 'package:foundita/providers/found_item_provider.dart';
import 'package:foundita/providers/location_provider.dart';
import 'package:foundita/models/location.dart';

class FoundItemsMapPage extends StatefulWidget {
  const FoundItemsMapPage({Key? key}) : super(key: key);

  @override
  State<FoundItemsMapPage> createState() => _FoundItemsMapPageState();
}

class _FoundItemsMapPageState extends State<FoundItemsMapPage> {
  final MapController _mapController = MapController();
  LatLng _initialPosition = LatLng(36.8065, 10.1815);
  double _initialZoom = 10.0;
  List<Marker> _foundItemMarkers = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadFoundItemsAndLocations();
  }

  Future<void> _loadFoundItemsAndLocations() async {
    setState(() {
      _isLoading = true;
    });
    try {
      final foundItemProvider =
          Provider.of<FoundItemProvider>(context, listen: false);
      await foundItemProvider.fetchFoundItems();

      final locationProvider =
          Provider.of<LocationProvider>(context, listen: false);
      await locationProvider
          .fetchAllLocations();

      List<Marker> markers = [];
      for (final foundItem in foundItemProvider.foundItems) {
        final location = locationProvider.locations.firstWhere(
          (loc) => loc.id == foundItem.locationId,
          orElse: () =>
              Location(id: '', latitude: 0.0, longitude: 0.0, itemIds: []),
        );

        if (location.latitude != null && location.longitude != null) {
          markers.add(
            Marker(
              point: LatLng(location.latitude!, location.longitude!),
              width: 40,
              height: 40,
              child: GestureDetector(
                onTap: () {
                  _showItemDetails(context, foundItem);
                },
                child: const Icon(
                  Icons.location_pin,
                  color: Colors.blue,
                  size: 40,
                ),
              ),
            ),
          );
        }
      }
      setState(() {
        _foundItemMarkers = markers;
        _isLoading = false;
      });

      if (_foundItemMarkers.isNotEmpty) {
        _mapController.move(_foundItemMarkers.first.point, 12.0);
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading found items: ${e.toString()}')),
      );
    }
  }

  void _showItemDetails(BuildContext context, FoundItem item) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Text('Found Item Details',
                  style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 10),
              Text('Description: ${item.description}',
                  style: Theme.of(context).textTheme.bodyLarge),
              const SizedBox(height: 10),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: const Text('View Details'),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Found Items Location'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : FlutterMap(
              mapController: _mapController,
              options: MapOptions(
                initialCenter: _initialPosition,
                initialZoom: _initialZoom,
              ),
              children: [
                TileLayer(
                  urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                  userAgentPackageName: 'com.example.foundita',
                ),
                MarkerLayer(
                  markers: _foundItemMarkers,
                ),
              ],
            ),
    );
  }
}
