import 'package:flutter/foundation.dart' hide Category ;
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:foundita/models/item.dart';
import 'package:foundita/providers/found_item_provider.dart';
import 'package:foundita/services/found_item_service.dart';
import 'package:foundita/services/location_service.dart';
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
  Widget? imageWidget;
  late final FoundItemProvider _foundItemsProvider;

  final FoundItemPopulated itemPopulated = FoundItemPopulated(
    itemId: 'test_12345',
    itemName: 'Black Leather Wallet',
    description: 'Found near central park bench, contains ID cards',
    foundDate: DateTime(2024, 3, 15, 14, 30),
    photo: "assets/images/google_logo.png",
    type: Category.clothing,
    color: 'Black',
    date: DateTime(2024, 3, 15),
    locationId: 'loc_nyc_123',
    userId: 'user_john_doe',
    latitude: 40.785091,
    longitude: -73.968285,
    isFound: true,
    imageData: Uint8List(0),
  );

  final FoundItemPopulated itemPopulated2 = FoundItemPopulated(
    itemId: 'test_67890',
    itemName: 'Black Leather Wallet',
    description: 'Found near central park bench, contains ID cards',
    foundDate: DateTime(2024, 3, 15, 14, 30),
    photo: "assets/images/facebook_logo.png",
    type: Category.clothing,
    color: 'Black',
    date: DateTime(2024, 3, 15),
    locationId: 'loc_nyc_123',
    userId: 'user_john_doe',
    latitude: 41.785091,
    longitude: -72.968285,
    isFound: true,
    imageData: Uint8List(0),
  );

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _foundItemsProvider = Provider.of<FoundItemProvider>(context, listen: false);

      _initializeMapData();
    });
  }

  void _handleSearchTypeChange(String? newValue) {
    if (newValue == null) return;
    setState(() {
      _selectedSearchType = newValue;
      _isLoading = true;
    });
    _initializeMapData();
  }

  Future<void> _initializeMapData() async {
    try {
      final List<FoundItemPopulated> items = [itemPopulated2, itemPopulated];
      await _foundItemsProvider.fetchPopulatedItems();
      final List<FoundItemPopulated> fetchedItems = _foundItemsProvider.populatedItems;
      _itemMarkers = await _createItemMarkers(context, fetchedItems);

      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          if (_itemMarkers.isNotEmpty) {
            _mapController.move(_itemMarkers.first.point, 12.0);
          } else {
            _mapController.move(LatLng(36.8065, 10.1815), 10.0);
          }
        }
      });
    } catch (e) {
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

  Future<List<Marker>> _createItemMarkers(BuildContext context, List<FoundItemPopulated> items) async {
    final markers = <Marker>[];
    for (final item in items) {
      try {
        markers.add(
          Marker(
            point: LatLng(item.latitude, item.longitude),
            width: 50,
            height: 50,
            child: GestureDetector(
              onTap: () => _showItemDetailsModal(context, item),
              child: Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 2),
                  boxShadow: const [
                    BoxShadow(color: Colors.black26, blurRadius: 4, offset: Offset(0, 2)),
                  ],
                ),
                child: ClipOval(
                  child: Image.memory(
                    item.imageData,
                    fit: BoxFit.cover, // or contain / fill / etc.
                  ),
                  // child: Image.asset(
                  //   item.photo.isNotEmpty ? item.photo : 'assets/images/facebook_logo.png',
                  //   fit: BoxFit.cover,
                  //   errorBuilder: (context, error, stackTrace) => Container(
                  //     color: Colors.grey[200],
                  //     child: const Icon(Icons.broken_image, color: Colors.grey, size: 30),
                  //   ),
                  // ),
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

  void _showItemDetailsModal(BuildContext context, FoundItemPopulated item) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.45,
        minChildSize: 0.45,
        maxChildSize: 0.45,
        expand: false,
        builder: (context, scrollController) => Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              Expanded(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    /// 🖼️ Image on the left
                    Container(
                      width: 120,
                      height: 120,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        color: Colors.grey[200],
                      ),
                      clipBehavior: Clip.antiAlias,
                      child: Image.memory(
                        item.imageData,
                        fit: BoxFit.cover,
                      ),
                    ),
                    const SizedBox(width: 16),

                    /// 📝 Text info on the right
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item.itemName,
                            style: Theme.of(context).textTheme.titleLarge,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            item.description,
                            style: Theme.of(context).textTheme.bodyMedium,
                            maxLines: 3,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Found on: ${DateFormat.yMMMd().format(item.foundDate)}',
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              /// 📦 Spacer and Claim button at bottom
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => _showClaimItemDialog(context, item),
                  child: const Text('Claim This Item'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }


  void _showClaimItemDialog(BuildContext context, FoundItemPopulated item) {
    showDialog(
      context: context,
      builder: (context) {
        final TextEditingController _controller = TextEditingController();
        return AlertDialog(
          title: const Text('Describe Your Claim'),
          content: TextField(
            controller: _controller,
            maxLines: 5,
            decoration: const InputDecoration(
              hintText: 'Describe the item and why you think it belongs to you...',
              border: OutlineInputBorder(),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                final message = _controller.text.trim();
                if (message.isNotEmpty) {
                  // send request logic here
                  print("Sending claim request: $message, to user : ${item.userId}");
                  Navigator.of(context).pop();
                }
              },
              child: const Text('Send Request'),
            )
          ],
        );
      },
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
                    value: _selectedSearchType ?? 'ariana',
                    icon: const Icon(Icons.arrow_drop_down),
                    underline: const SizedBox(),
                    items: const [
                      DropdownMenuItem(value: 'ariana', child: Text('Ariana')),
                      DropdownMenuItem(value: 'tunis', child: Text('Tunis')),
                      DropdownMenuItem(value: 'beja', child: Text('Beja')),
                    ],
                    onChanged: _handleSearchTypeChange,
                  ),
                  const VerticalDivider(width: 1),
                  Expanded(
                    child: TextField(
                      decoration: InputDecoration(
                        hintText: 'Search for a place...',
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(horizontal: 12),
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.search),
                    onPressed: () {},
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