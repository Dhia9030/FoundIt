import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:foundita/models/item.dart';
import 'package:foundita/services/found_item_service.dart';
import 'package:foundita/widgets/image_widget.dart';
import 'package:intl/intl.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';
import 'package:foundita/models/found_item.dart';

class FoundItemsMapPage extends StatefulWidget {
  const FoundItemsMapPage({super.key});

  @override
  State<FoundItemsMapPage> createState() => _FoundItemsMapPageState();
}



class _FoundItemsMapPageState extends State<FoundItemsMapPage> {
  final MapController _mapController = MapController();
  List<Marker> _itemMarkers = [];
  bool _isLoading = true;

  final FoundItemPopulated itemPopulated = FoundItemPopulated(
    itemId: 'test_12345',
    itemName: 'Black Leather Wallet',
    description: 'Found near central park bench, contains ID cards',
    foundDate: DateTime(2024, 3, 15, 14, 30),
    photo: "assets/images/facebook_logo.png",
    type: Category.clothing, // Assuming Category enum exists
    color: 'Black',
    date: DateTime(2024, 3, 15),
    locationId: 'loc_nyc_123',
    userId: 'user_john_doe',
    latitude: 40.785091, // Central Park coordinates
    longitude: -73.968285,
    isFound: true,
  );

  @override
  void initState() {
    super.initState();
    _initializeMapData();
    print('initial');
  }

  Future<void> _initializeMapData() async {
    try {
      // Your dummy data
      print('initializing map data...');
      final List<FoundItemPopulated> items = [itemPopulated]; // Empty array for testing
      _itemMarkers = await _createItemMarkers(items);

      // Wait for the first frame to complete
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          // If there are markers, center on the first one; otherwise, use default location
          if (_itemMarkers.isNotEmpty) {
            _mapController.move(_itemMarkers.first.point, 12.0);
          } else {
            _mapController.move(LatLng(36.8065, 10.1815), 10.0); // Default center
          }
        }
      });
    } catch (e) {
      print('Error initializing map data: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${e.toString()}')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<List<Marker>> _createItemMarkers(List<FoundItemPopulated> items) async {
    final markers = <Marker>[];

    for (final item in items) {
      try {
        markers.add(
          Marker(
            point: LatLng(item.latitude, item.longitude),
            width: 60,
            height: 60,
            child: GestureDetector(
              onTap: () => _showItemDetails(context, item),
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black26,
                      blurRadius: 5,
                      offset: Offset(0, 2),
                    )
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: item.photo.isNotEmpty
                      ? ImageFromBackend(
                    blobName: item.photo,
                    fit: BoxFit.cover,
                  )
                      : Container(
                    color: Colors.grey[200],
                    child: Icon(Icons.help_outline, color: Colors.grey[600]),
                  ),
                ),
              ),
            ),
          ),
        );
      } catch (e) {
        print('Error creating marker for item ${item.itemId}: $e');
      }
    }
    return markers;
  }

  void _showItemDetails(BuildContext context, FoundItemPopulated item) {
    showModalBottomSheet(
      context: context,
      builder: (context) => ItemDetailsPreview(item: item),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Found Items Map')),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Stack(
        children: [
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: LatLng(36.8065, 10.1815),
              initialZoom: 10.0,
              onMapReady: () {
                if (_itemMarkers.isEmpty) {
                  _mapController.move(LatLng(36.8065, 10.1815), 10.0);
                } else {
                  _mapController.move(_itemMarkers.first.point, 12.0);
                }
              },
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.example.foundita',
                errorTileCallback: (tile, error, stackTrace) {
                  print('Tile loading error: $error');
                },
              ),
              MarkerLayer(markers: _itemMarkers),
            ],
          ),
          if (_itemMarkers.isEmpty)
            Center(
              child: Container(
                padding: const EdgeInsets.all(16.0),
                color: Colors.black54,
                child: const Text(
                  'No found items available',
                  style: TextStyle(color: Colors.white, fontSize: 18),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class ItemDetailsPreview extends StatelessWidget {
  final FoundItemPopulated item;

  const ItemDetailsPreview({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(item.itemName, style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 10),
          if (item.photo.isNotEmpty)
            SizedBox(
              height: 150,
              child: ImageFromBackend(blobName: item.photo, fit: BoxFit.cover),
            ),
          const SizedBox(height: 10),
          Text(item.description, style: Theme.of(context).textTheme.bodyMedium),
          const SizedBox(height: 10),
          Text('Found on: ${DateFormat.yMMMd().format(item.foundDate)}'),
        ],
      ),
    );
  }
}

class TestMapPage extends StatelessWidget {
  const TestMapPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Test Map')),
      body: FlutterMap(
        options: MapOptions(
          initialCenter: LatLng(36.8065, 10.1815), // Default center: Tunis, Tunisia
          initialZoom: 10.0,
          onMapReady: () {
            print('Map is ready');
          },
        ),
        children: [
          TileLayer(
            urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
            userAgentPackageName: 'com.example.foundita',
            errorTileCallback: (tile, error, stackTrace) {
              print('Tile loading error at ${tile.coordinates}: $error');
            },
            tileBuilder: (context, widget, tile) {
              if (tile.imageInfo == null) {
                return Container(
                  color: Colors.grey,
                  child: const Center(child: Text('Failed to load tile')),
                );
              }
              return widget;
            },
          ),
        ],
      ),
    );
  }
}