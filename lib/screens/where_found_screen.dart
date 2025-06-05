import 'package:flutter/material.dart';
import 'package:foundita/screens/national_id_screen.dart';
import 'package:foundita/screens/map_picker_screen.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import '../providers/theme_provider.dart';

class WhereFoundScreen extends StatefulWidget {
  final Map<String, dynamic> itemData;
  const WhereFoundScreen({Key? key, required this.itemData}) : super(key: key);

  @override
  _WhereFoundScreenState createState() => _WhereFoundScreenState();
}

class _WhereFoundScreenState extends State<WhereFoundScreen> {
  LatLng? _selectedLocation;
  bool _isLoading = true;
  bool _showError = false;
  String _errorMessage = "";

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
  }

  Future<void> _getCurrentLocation() async {
    setState(() => _isLoading = true);

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        setState(() {
          _isLoading = false;
          _showError = true;
          _errorMessage = 'Location permission required to report found items';
        });
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      setState(() {
        _isLoading = false;
        _showError = true;
        _errorMessage =
            'Location permission permanently denied. Enable in app settings';
      });
      return;
    }
    try {
      final position = await Geolocator.getCurrentPosition();
      setState(() {
        _selectedLocation = LatLng(position.latitude, position.longitude);
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _showError = true;
        _errorMessage = 'Failed to get location: $e';
      });
    }
  }

  void _navigateToNextScreen(BuildContext context) {
    if (_selectedLocation == null) {
      setState(() {
        _showError = true;
        _errorMessage = "Please select a location on the map";
      });
      return;
    }

    final updatedData = {
      ...widget.itemData,
      'location': {
        'latitude': _selectedLocation!.latitude,
        'longitude': _selectedLocation!.longitude,
      },
    };

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => NationalIdScreen(itemData: updatedData),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final darkMode = themeProvider.isDarkMode;

    return Scaffold(
      backgroundColor:
          darkMode ? const Color(0xFF1B262C) : const Color(0xFFE6F0FA),
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Where Did You Find It?'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        titleTextStyle: const TextStyle(
          color: Colors.black,
          fontSize: 24,
          fontWeight: FontWeight.bold,
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  // Progress bar
                  ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: Container(
                      height: 8,
                      color: const Color(0xFFF5F7FF),
                      child: Row(
                        children: [
                          Container(
                            width: MediaQuery.of(context).size.width * 0.66,
                            height: 8,
                            color: const Color(0xFF6C63FF),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  if (_showError)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 8.0),
                      child: Text(
                        _errorMessage,
                        style: GoogleFonts.urbanist(
                          color: Colors.red,
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  Expanded(
                    child: Center(
                      child: Container(
                        padding: const EdgeInsets.all(24.0),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(24),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 12,
                              offset: const Offset(0, 6),
                            ),
                          ],
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.location_on,
                              size: 80,
                              color: const Color(0xFF6C63FF),
                            ),
                            const SizedBox(height: 20),
                            Text(
                              'Select Location',
                              style: GoogleFonts.urbanist(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: Colors.black87,
                              ),
                            ),
                            const SizedBox(height: 12),
                            Text(
                              'Choose the location where you found the item',
                              textAlign: TextAlign.center,
                              style: GoogleFonts.urbanist(
                                fontSize: 16,
                                color: Colors.grey[600],
                              ),
                            ),
                            const SizedBox(height: 30),
                            ElevatedButton(
                              onPressed: () async {
                                final result = await Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (context) => MapPickerScreen(),
                                  ),
                                );

                                if (result != null &&
                                    result is Map<String, double>) {
                                  setState(() {
                                    _selectedLocation = LatLng(
                                      result['latitude']!,
                                      result['longitude']!,
                                    );
                                    _showError = false;
                                  });
                                }
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF6C63FF),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 32,
                                  vertical: 16,
                                ),
                              ),
                              child: Text(
                                _selectedLocation == null
                                    ? 'Select Location on Map'
                                    : 'Change Location',
                                style: GoogleFonts.urbanist(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                            if (_selectedLocation != null) ...[
                              const SizedBox(height: 20),
                              Container(
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFF5F7FF),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Column(
                                  children: [
                                    Icon(
                                      Icons.check_circle,
                                      color: Colors.green,
                                      size: 24,
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      'Location Selected',
                                      style: GoogleFonts.urbanist(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.black87,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      'Lat: ${_selectedLocation!.latitude.toStringAsFixed(6)}\nLng: ${_selectedLocation!.longitude.toStringAsFixed(6)}',
                                      textAlign: TextAlign.center,
                                      style: GoogleFonts.urbanist(
                                        fontSize: 14,
                                        color: Colors.grey[600],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () => _navigateToNextScreen(context),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF6C63FF),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: Text(
                        "Continue",
                        style: GoogleFonts.urbanist(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}
