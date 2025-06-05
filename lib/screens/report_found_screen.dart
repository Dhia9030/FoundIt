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
            content:
                Text('Location permission is required to report a found item.'),
          ),
        );
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
              'Location permission is permanently denied. Please enable it in app settings.'),
        ),
      );
      return;
    }

    try {
      _currentPosition = await Geolocator.getCurrentPosition();
      setState(() {
        _selectedLocation =
            LatLng(_currentPosition!.latitude, _currentPosition!.longitude);
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
            content: Text(
                'Please select the location of the found item on the map.'),
          ),
        );
        return;
      }
      if (_isSubmitting) return;
      setState(() {
        _isSubmitting = true;
      });
      final foundItemProvider =
          Provider.of<FoundItemProvider>(context, listen: false);

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
              content:
                  Text('Failed to report item. Please check the information.'),
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
      appBar: AppBar(
        title: Text('Report Found Item'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                TextFormField(
                  controller: _itemNameController,
                  decoration: InputDecoration(labelText: 'Item Name'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter the item name';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 12),
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
                  decoration: InputDecoration(labelText: 'Type'),
                  validator: (value) =>
                      value == null ? 'Please select item type' : null,
                ),
                SizedBox(height: 12),
                TextFormField(
                  controller: _descriptionController,
                  decoration: InputDecoration(labelText: 'Description'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter the item description';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 12),
                TextFormField(
                  controller: _colorController,
                  decoration: InputDecoration(labelText: 'Color'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter the item color';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 12),

                // 📅 Date Pickers
                TextFormField(
                  readOnly: true,
                  decoration: InputDecoration(
                    labelText: 'Date Found',
                    suffixIcon: Icon(Icons.calendar_today),
                  ),
                  controller: TextEditingController(
                    text:
                        '${_foundDate.day}/${_foundDate.month}/${_foundDate.year}',
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
                SizedBox(height: 12),
                TextFormField(
                  readOnly: true,
                  decoration: InputDecoration(
                    labelText: 'Report Date',
                    suffixIcon: Icon(Icons.calendar_today),
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
                SizedBox(height: 12),

                ElevatedButton(
                  onPressed: _pickImage,
                  child: Text('Pick Image'),
                ),
                if (_imageFile != null)
                  Container(
                    height: 150,
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Stack(
                      children: [
                        Center(
                          child: Image.network(
                            // ✅ This is web-compatible
                            _imageFile!.path,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) =>
                                Icon(Icons.image, size: 50),
                          ),
                        ),
                        Positioned(
                          top: 0,
                          right: 0,
                          child: IconButton(
                            icon: Icon(Icons.close, color: Colors.red),
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
                SizedBox(height: 20),
                ElevatedButton(
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
                  child: Text(_selectedLocation == null
                      ? 'Select Location on Map'
                      : 'Change Location'),
                ),
                if (_selectedLocation != null) ...[
                  SizedBox(height: 12),
                  Text(
                    'Selected Location: ${_selectedLocation!.latitude.toStringAsFixed(6)}, ${_selectedLocation!.longitude.toStringAsFixed(6)}',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ],
                SizedBox(height: 20),
                ElevatedButton(
                  onPressed: _isSubmitting
                      ? null
                      : () => _handleReport(context, userId),
                  child: _isSubmitting
                      ? CircularProgressIndicator()
                      : Text('Report Found Item'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
