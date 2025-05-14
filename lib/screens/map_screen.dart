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
  String? _selectedSearchType;



  final FoundItemPopulated itemPopulated = FoundItemPopulated(
    itemId: 'test_12345',
    itemName: 'Black Leather Wallet',
    description: 'Found near central park bench, contains ID cards',
    foundDate: DateTime(2024, 3, 15, 14, 30),
    photo: "assets/images/google_logo.png",
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

  void _handleSearchTypeChange(String? newValue) {
    if (newValue == null) return;

    setState(() {
      _selectedSearchType = newValue;
      _isLoading = true; // Show loading indicator
    });

    _initializeMapData(); // Refetch data with new filter
  }

  Future<void> _initializeMapData() async {
    try {
      // Your dummy data
      print('Fetching data for filter: $_selectedSearchType');
      final List<FoundItemPopulated> items = [itemPopulated]; // Empty array for testing
      _itemMarkers = await _createItemMarkers(context, items);

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

  Future<List<Marker>> _createItemMarkers(
      BuildContext context, List<FoundItemPopulated> items) async
  {
    final markers = <Marker>[];

    for (final item in items) {
      try {
        markers.add(
          Marker(
            point: LatLng(item.latitude, item.longitude),
            width: 50,
            height: 50,
            child: GestureDetector(
              onTap: () => _showItemDetails(context, item),
              child: Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 2),
                  boxShadow: const [
                    BoxShadow(
                      color: Colors.black26,
                      blurRadius: 4,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
                child: ClipOval(
                  child: Image.asset(
                    item.photo.isNotEmpty ? item.photo : 'assets/images/facebook_logo.png',
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      print('Error loading image for item ${item.itemId}: $error');
                      return Container(
                        color: Colors.grey[200],
                        child: const Icon(
                          Icons.broken_image,
                          color: Colors.grey,
                          size: 30,
                        ),
                      );
                    },
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
          Positioned(
            top: 20,
            left: 20,
            right: 20,
            child: Container(
              height: 50,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.8),
                borderRadius: BorderRadius.circular(8.0),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                children: [
                  DropdownButton<String>(
                    value: _selectedSearchType ?? 'ariana', // Fallback to 'ariana' if null
                    icon: const Icon(Icons.arrow_drop_down),
                    underline: const SizedBox(),
                    items: const [
                      DropdownMenuItem(
                        value: 'ariana',
                        child: Text('Ariana'),
                      ),
                      DropdownMenuItem(
                        value: 'tunis',
                        child: Text('Tunis'),
                      ),
                      DropdownMenuItem(
                        value: 'beja',
                        child: Text('Beja'),
                      ),
                    ],
                    onChanged: _handleSearchTypeChange, // Connect to your handler
                  ),
                  const VerticalDivider(width: 1),
                  Expanded(
                    child: TextField(
                      decoration: InputDecoration(
                        hintText: 'Search for a place...',
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 12),
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.search),
                    onPressed: () {
                      // Handle search
                    },
                  ),
                ],
              ),
            ),
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
          // if (item.photo.isNotEmpty)
          //   SizedBox(
          //     height: 150,
          //     child: ImageFromBackend(blobName: item.photo, fit: BoxFit.cover),
          //   ),
          Row(
            children: [
              SizedBox(child: Image.asset("assets/images/google_logo.png"), height: 60,width: 60,),
              SizedBox(child: Image.asset("assets/images/google_logo.png"), height: 60,width: 60,),
            ],
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