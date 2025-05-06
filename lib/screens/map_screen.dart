 import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:foundita/services/found_item_service.dart';
import 'package:foundita/services/location_service.dart';
import 'package:foundita/widgets/found_item_details_widget.dart';
import 'package:foundita/widgets/image_widget.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';
import 'package:foundita/models/found_item.dart';
import 'package:foundita/providers/found_item_provider.dart';
import 'package:foundita/providers/location_provider.dart';
import 'package:foundita/models/location.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'dart:developer';
import 'package:cloud_firestore/cloud_firestore.dart';


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
    // final _foundItemService = FoundItemService(locationService: LocationService());
    // final items = _foundItemService.getAllFoundItems();
    // print(items);
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
      await locationProvider.fetchAllLocations();

      List<Marker> markers = [];
      for (final foundItem in foundItemProvider.foundItems) {
        final location = locationProvider.locations.firstWhere(
          (loc) => loc.id == foundItem.locationId,
          orElse: () =>
              Location(id: '', latitude: 0.0, longitude: 0.0, itemIds: []),
        );
        final headers = {'X-API-Key': dotenv.env['DOWNLOAD_KEY']!};
        if(!headers.containsKey('X-API-Key')) {
          throw Exception('API key not found in headers.');
        } else {
          log('API key found in headers.');
        }

        if (location.latitude != null && location.longitude != null) {
          markers.add(
            Marker(
              point: LatLng(location.latitude!, location.longitude!),
              width: 50,
              height: 50,
              child: GestureDetector(
                onTap: () {
                  _showItemDetails(context, foundItem);
                },
                child: SizedBox(
  width: 50,
  height: 50,
  child: ClipRRect(
    borderRadius: BorderRadius.circular(8.0),
    child: foundItem.photo.isNotEmpty
        ? ImageFromBackend(blobName: foundItem.photo, fit: BoxFit.cover)
        : const Icon(Icons.photo_library, color: Colors.grey, size: 20),
  ),
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
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _mapController.move(_foundItemMarkers.first.point, 12.0);
        });
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
            if (item.photo.isNotEmpty)
              Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  SizedBox(
                    height: 150,
                    child: ImageFromBackend(blobName: item.photo, fit: BoxFit.cover),
                  ),
                  const SizedBox(height: 10),
                ],
              ),
            Text('Name: ${item.itemName}',
                style: Theme.of(context).textTheme.bodyLarge),
            const SizedBox(height: 5),
            Text('Description: ${item.description}',
                style: Theme.of(context).textTheme.bodyMedium),
            const SizedBox(height: 5),
            Text('Color: ${item.color}',
                style: Theme.of(context).textTheme.bodyMedium),
            const SizedBox(height: 10),
            ElevatedButton(
  onPressed: () {
    Navigator.pop(context); // Close the bottom sheet
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => FoundItemDetailsScreen(item: item),
      ),
    );
    print('View Details for ${item.itemId}');
  },
  child: const Text('View Full Details'),
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


 class TestFirebaseFetchWidget extends StatefulWidget {
   const TestFirebaseFetchWidget({super.key});

   @override
   State<TestFirebaseFetchWidget> createState() => _TestFirebaseFetchWidgetState();
 }

 class _TestFirebaseFetchWidgetState extends State<TestFirebaseFetchWidget> {
   final FirestoreService _firestoreService = FirestoreService();
   List<FoundItem> _items = [];
   bool _isLoading = true;
   String _error = '';

   @override
   void initState() {
     super.initState();
     _loadItems();
   }

   Future<void> _loadItems() async {
     try {
       final items = await _firestoreService.fetchLostItems();
       setState(() {
         _items = items;
         _isLoading = false;
       });
     } catch (e) {
       setState(() {
         _error = e.toString();
         _isLoading = false;
       });
     }
   }

   @override
   Widget build(BuildContext context) {
     return Scaffold(
       appBar: AppBar(title: const Text('Firebase Data Test')),
       body: _isLoading
           ? const Center(child: CircularProgressIndicator())
           : _error.isNotEmpty
           ? Center(child: Text('Error: $_error'))
           : ListView.builder(
         itemCount: _items.length,
         itemBuilder: (context, index) {
           final item = _items[index];
           return ListTile(
             title: Text(item.itemName),
             subtitle: Text(item.description),
             trailing: Text(item.isFound ? 'Found' : 'Lost'),
             onTap: () => _showItemDetails(item),
           );
         },
       ),
     );
   }

   void _showItemDetails(FoundItem item) {
     showDialog(
       context: context,
       builder: (context) => AlertDialog(
         title: Text(item.itemName),
         content: SingleChildScrollView(
           child: Column(
             crossAxisAlignment: CrossAxisAlignment.start,
             children: [
               Text('Description: ${item.description}'),
               Text('Color: ${item.color}'),
               Text('Type: ${item.type}'),
               Text('Lost Date: ${item.foundDate}'),
               Text('Location ID: ${item.locationId}'),
               Text('User ID: ${item.userId}'),
             ],
           ),
         ),
         actions: [
           TextButton(
             onPressed: () => Navigator.pop(context),
             child: const Text('Close'),
           ),
         ],
       ),
     );
   }
 }

 class FirestoreService {
   final FirebaseFirestore _firestore = FirebaseFirestore.instance;

   Future<List<FoundItem>> fetchLostItems() async {
     try {
       print('Attempting to fetch data from Firestore...');
       final querySnapshot = await _firestore
           .collection('found_items')
           .where('isFound', isEqualTo: false)
           .get();

       print('Received ${querySnapshot.docs.length} documents');

       querySnapshot.docs.forEach((doc) {
         print('Document ID: ${doc.id}');
         print('Document Data: ${doc.data()}');
       });

       return querySnapshot.docs.map((doc) {
         final data = doc.data();
         return FoundItem(
           itemId: doc.id,
           itemName: data['itemName'] ?? '',
           description: data['description'] ?? '',
           color: data['color'] ?? '',
           type: data['type'] ?? 'other',
           isFound: data['isFound'] ?? false,
           foundDate: data['lostDate'] ?? '',
           date: data['date'] ?? '',
           locationId: data['locationId'] ?? '',
           photo: data['photo'] ?? '',
           userId: data['userId'] ?? '',
         );
       }).toList();
     } catch (e) {
       print('Firestore Error: $e');
       throw Exception('Failed to fetch items: $e');
     }
   }
 }