import 'dart:io' as io;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/foundation.dart' hide Category;
import 'package:flutter/material.dart';
import 'package:foundita/providers/found_item_provider.dart';
import 'package:foundita/providers/location_provider.dart';
import 'package:foundita/screens/map_picker_screen.dart';
import 'package:foundita/services/found_item_service.dart';
import 'package:image_picker/image_picker.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';
import 'package:geolocator/geolocator.dart';
import 'package:foundita/models/item.dart';
import 'package:foundita/models/found_item.dart';
import 'package:foundita/models/location.dart';

class ReportFoundItemScreen extends StatefulWidget {
  @override
  _ReportFoundItemScreenState createState() => _ReportFoundItemScreenState();
}

class _ReportFoundItemScreenState extends State<ReportFoundItemScreen> {
  final _formKey = GlobalKey<FormState>();
  final _itemNameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _colorController = TextEditingController();
  DateTime _date = DateTime.now();
  DateTime _foundDate = DateTime.now();
  Category _type = Category.other;
  XFile? _imageFile;
  Position? _currentPosition;
  bool _isSubmitting = false;
  LatLng? _selectedLocation;

  Future<void> _getCurrentLocation() async {
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Location permission is required to report a found item.'),
          ),
        );
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Location permission is permanently denied. Please enable it in app settings.'),
        ),
      );
      return;
    }

    try {
      _currentPosition = await Geolocator.getCurrentPosition();
      setState(() {
        _selectedLocation = LatLng(_currentPosition!.latitude, _currentPosition!.longitude);
      });
    } catch (e) {
      print("Error getting location: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to get your location: $e'),
        ),
      );
    }
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _imageFile = pickedFile;
      });
    }
  }

  Future<void> _handleReport(BuildContext context, String userId) async {
    if (_formKey.currentState!.validate()) {
      if (_selectedLocation == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Please select the location of the found item on the map.'),
          ),
        );
        return;
      }
      if (_isSubmitting) return;
      setState(() {
        _isSubmitting = true;
      });
      final foundItemProvider = Provider.of<FoundItemProvider>(context, listen: false);

      try {
        final success = await foundItemProvider.reportFoundItem(
          userId: userId,
          itemName: _itemNameController.text,
          type: _type,
          description: _descriptionController.text,
          color: _colorController.text,
          date: _date,
          imageFile: _imageFile,
          latitude: _selectedLocation!.latitude,
          longitude: _selectedLocation!.longitude,
          foundDate: _foundDate,
        );

        if (success) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Item reported successfully!'),
            ),
          );
          Navigator.of(context).pop();
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Failed to report item. Please check the information.'),
            ),
          );
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error reporting item: $e'),
          ),
        );
      } finally {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _itemNameController.dispose();
    _descriptionController.dispose();
    _colorController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
  }

  @override
  Widget build(BuildContext context) {
    final String userId = FirebaseAuth.instance.currentUser!.uid;
    return Scaffold(
      backgroundColor: const Color(0xFFE6F0FA), // Light blue pastel background
      appBar: AppBar(
        title: const Text('Report Found Item'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        titleTextStyle: const TextStyle(
          color: Colors.black,
          fontSize: 24,
          fontWeight: FontWeight.bold,
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Center(
          child: Container(
            padding: const EdgeInsets.all(16.0),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 10,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: Form(
              key: _formKey,
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: <Widget>[
                    TextFormField(
                      controller: _itemNameController,
                      decoration: InputDecoration(
                        labelText: 'Item Name',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                        filled: true,
                        fillColor: const Color(0xFFF5F7FF),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter the item name';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<Category>(
                      value: _type,
                      onChanged: (Category? newValue) {
                        if (newValue != null) {
                          setState(() {
                            _type = newValue;
                          });
                        }
                      },
                      items: Category.values.map((Category category) {
                        return DropdownMenuItem<Category>(
                          value: category,
                          child: Text(category.name),
                        );
                      }).toList(),
                      decoration: InputDecoration(
                        labelText: 'Type',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                        filled: true,
                        fillColor: const Color(0xFFF5F7FF),
                      ),
                      validator: (value) => value == null ? 'Please select item type' : null,
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _descriptionController,
                      decoration: InputDecoration(
                        labelText: 'Description',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                        filled: true,
                        fillColor: const Color(0xFFF5F7FF),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter the item description';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _colorController,
                      decoration: InputDecoration(
                        labelText: 'Color',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                        filled: true,
                        fillColor: const Color(0xFFF5F7FF),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter the item color';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      readOnly: true,
                      decoration: InputDecoration(
                        labelText: 'Date Found',
                        suffixIcon: const Icon(Icons.calendar_today),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                        filled: true,
                        fillColor: const Color(0xFFF5F7FF),
                      ),
                      controller: TextEditingController(
                        text: '${_foundDate.day}/${_foundDate.month}/${_foundDate.year}',
                      ),
                      onTap: () async {
                        final DateTime? picked = await showDatePicker(
                          context: context,
                          initialDate: _foundDate,
                          firstDate: DateTime(2000),
                          lastDate: DateTime(2100),
                        );
                        if (picked != null) {
                          setState(() {
                            _foundDate = picked;
                          });
                        }
                      },
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      readOnly: true,
                      decoration: InputDecoration(
                        labelText: 'Report Date',
                        suffixIcon: const Icon(Icons.calendar_today),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                        filled: true,
                        fillColor: const Color(0xFFF5F7FF),
                      ),
                      controller: TextEditingController(
                        text: '${_date.day}/${_date.month}/${_date.year}',
                      ),
                      onTap: () async {
                        final DateTime? picked = await showDatePicker(
                          context: context,
                          initialDate: _date,
                          firstDate: DateTime(2000),
                          lastDate: DateTime(2100),
                        );
                        if (picked != null) {
                          setState(() {
                            _date = picked;
                          });
                        }
                      },
                    ),
                    const SizedBox(height: 12),
                    Center(
                      child: SizedBox(
                        width: 200, // Fixed width for the button
                        child: ElevatedButton(
                          onPressed: _pickImage,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF6C63FF),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 12),
                          ),
                          child: const Text(
                            'Pick Image',
                            style: TextStyle(color: Colors.white, fontSize: 16),
                          ),
                        ),
                      ),
                    ),
                    if (_imageFile != null)
                      Container(
                        height: 150,
                        margin: const EdgeInsets.only(top: 12),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Stack(
                          children: [
                            Center(
                              child: Image.network(
                                _imageFile!.path,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) =>
                                    const Icon(Icons.image, size: 50),
                              ),
                            ),
                            Positioned(
                              top: 0,
                              right: 0,
                              child: IconButton(
                                icon: const Icon(Icons.close, color: Colors.red),
                                onPressed: () {
                                  setState(() {
                                    _imageFile = null;
                                  });
                                },
                              ),
                            ),
                          ],
                        ),
                      ),
                    const SizedBox(height: 20),
                    Center(
                      child: SizedBox(
                        width: 200, // Fixed width for the button
                        child: ElevatedButton(
                          onPressed: () async {
                            final result = await Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (context) => MapPickerScreen(),
                              ),
                            );
                            if (result != null && result is Map<String, double>) {
                              setState(() {
                                _selectedLocation = LatLng(
                                  result['latitude']!,
                                  result['longitude']!,
                                );
                              });
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF6C63FF),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 12),
                          ),
                          child: Text(
                            _selectedLocation == null
                                ? 'Select Location on Map'
                                : 'Change Location',
                            style: const TextStyle(color: Colors.white, fontSize: 16),
                          ),
                        ),
                      ),
                    ),
                    if (_selectedLocation != null) ...[
                      const SizedBox(height: 12),
                      Text(
                        'Selected Location: ${_selectedLocation!.latitude.toStringAsFixed(6)}, ${_selectedLocation!.longitude.toStringAsFixed(6)}',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                        textAlign: TextAlign.center,
                      ),
                    ],
                    const SizedBox(height: 20),
                    Center(
                      child: SizedBox(
                        width: 200, // Fixed width for the button
                        child: ElevatedButton(
                          onPressed: _isSubmitting
                              ? null
                              : () => _handleReport(context, userId),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF6C63FF),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 12),
                          ),
                          child: _isSubmitting
                              ? const CircularProgressIndicator(color: Colors.white)
                              : const Text(
                                  'Report Found Item',
                                  style: TextStyle(color: Colors.white, fontSize: 16),
                                ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}