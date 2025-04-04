// // screens/map_screen.dart
// import 'package:flutter/material.dart';
// import 'package:google_maps_flutter/google_maps_flutter.dart';
// import '../models/lost_item.dart';
//
// class MapScreen extends StatefulWidget {
//   final List<LostItem> items;
//
//   const MapScreen({super.key, required this.items});
//
//   @override
//   State<MapScreen> createState() => _MapScreenState();
// }
//
// class _MapScreenState extends State<MapScreen> {
//   late GoogleMapController _mapController;
//   final CameraPosition _initialPosition = const CameraPosition(
//     target: LatLng(25.7617, -80.1918), // Miami coordinates
//     zoom: 12,
//   );
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Found Items Map'),
//       ),
//       body: GoogleMap(
//         initialCameraPosition: _initialPosition,
//         markers: _createMarkers(),
//         onMapCreated: (controller) => _mapController = controller,
//       ),
//     );
//   }
//
//   Set<Marker> _createMarkers() {
//     return widget.items.map((item) => Marker(
//       markerId: MarkerId(item.title),
//       position: item.location, // Using LatLng from the item
//       infoWindow: InfoWindow(
//         title: item.title,
//         snippet: item.description,
//       ),
//       onTap: () => _showItemDetails(item),
//     )).toSet();
//   }
//
//   void _showItemDetails(LostItem item) {
//     showDialog(
//       context: context,
//       builder: (context) => AlertDialog(
//         title: Text(item.title),
//         content: SingleChildScrollView(
//           child: Column(
//             children: [
//               if (item.imageUrl != null)
//                 Image.network(item.imageUrl!),
//               Text(item.description),
//               Text('Coordinates: ${item.location.latitude.toStringAsFixed(4)}, '
//                   '${item.location.longitude.toStringAsFixed(4)}'),
//             ],
//           ),
//         ),
//         actions: [
//           TextButton(
//             onPressed: () => Navigator.pop(context),
//             child: const Text('Close'),
//           ),
//         ],
//       ),
//     );
//   }
// }