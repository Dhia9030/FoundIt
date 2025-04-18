import "package:flutter/material.dart";
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Complete OSM Example')),
      body: FlutterMap(
        options: MapOptions(
          initialCenter: LatLng(51.509364, -0.128928),
          initialZoom: 13,
          onTap: (tapPosition, point) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Tapped at: ${point.latitude}, ${point.longitude}')),
            );
          },
        ),
        children: [
          TileLayer(
            urlTemplate: 'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
            subdomains: ['a', 'b', 'c'],
            userAgentPackageName: 'com.example.app',
          ),
          MarkerLayer(
            markers: [
              Marker(
                width: 80.0,
                height: 80.0,
                point: LatLng(51.509364, -0.128928),
                child: Icon(Icons.location_pin, color: Colors.red, size: 40),
              ),
            ],
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.my_location),
        onPressed: () {
          // Add location functionality here
        },
      ),
    );
  }
}
