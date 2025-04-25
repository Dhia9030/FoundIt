import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:foundita/providers/lost_item_provider.dart';
import 'package:foundita/models/item.dart';
import 'package:image_picker/image_picker.dart';
import 'package:foundita/screens/map_picker_screen.dart';
import 'package:intl/intl.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:latlong2/latlong.dart' as latlong;

class ReportLostItemScreen extends StatefulWidget {
  const ReportLostItemScreen({Key? key}) : super(key: key);

  @override
  _ReportLostItemScreenState createState() => _ReportLostItemScreenState();
}

class _ReportLostItemScreenState extends State<ReportLostItemScreen> {
  final _formKey = GlobalKey<FormState>();
  final _itemNameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _colorController = TextEditingController();

  Category _selectedCategory = Category.other;
  DateTime _lostDate = DateTime.now();
  XFile? _imageFile;
  bool _isLoading = false;

  // Location data
  double? _latitude;
  double? _longitude;
  String _locationText = 'No location selected';

  @override
  void dispose() {
    _itemNameController.dispose();
    _descriptionController.dispose();
    _colorController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);

    if (image != null) {
      setState(() {
        _imageFile = image;
      });
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _lostDate,
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    );

    if (picked != null && picked != _lostDate) {
      setState(() {
        _lostDate = picked;
      });
    }
  }

  Future<void> _selectLocation() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => MapPickerScreen()),
    );

    if (result != null) {
      setState(() {
        _latitude = result['latitude'];
        _longitude = result['longitude'];
        _locationText =
            'Location selected: ${_latitude!.toStringAsFixed(6)}, ${_longitude!.toStringAsFixed(6)}';
      });
    }
  }

  Future<void> _submitForm() async {
    if (_formKey.currentState!.validate()) {
      if (_latitude == null || _longitude == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Please select a location')),
        );
        return;
      }

      setState(() {
        _isLoading = true;
      });

      try {
        // Get the current user's ID (replace with your auth implementation)
        String userId = FirebaseAuth.instance.currentUser!.uid;

        await Provider.of<LostItemProvider>(context, listen: false)
            .reportLostItem(
          userId: userId,
          itemName: _itemNameController.text,
          type: _selectedCategory,
          description: _descriptionController.text,
          color: _colorController.text,
          date: DateTime.now(),
          imageFile: _imageFile,
          latitude: _latitude!,
          longitude: _longitude!,
          lostDate: _lostDate,
        );

        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Lost item reported successfully')),
        );

        // Navigate back
        Navigator.of(context).pop();
      } catch (e) {
        // Show error message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error reporting lost item: ${e.toString()}')),
        );
      } finally {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Report Lost Item'),
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    TextFormField(
                      controller: _itemNameController,
                      decoration: InputDecoration(
                        labelText: 'Item Name',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter the item name';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 16),
                    DropdownButtonFormField<Category>(
                      value: _selectedCategory,
                      decoration: InputDecoration(
                        labelText: 'Category',
                        border: OutlineInputBorder(),
                      ),
                      items: Category.values.map((category) {
                        return DropdownMenuItem(
                          value: category,
                          child: Text(category.name),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          _selectedCategory = value!;
                        });
                      },
                    ),
                    SizedBox(height: 16),
                    TextFormField(
                      controller: _descriptionController,
                      decoration: InputDecoration(
                        labelText: 'Description',
                        border: OutlineInputBorder(),
                      ),
                      maxLines: 3,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter a description';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 16),
                    TextFormField(
                      controller: _colorController,
                      decoration: InputDecoration(
                        labelText: 'Color',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter the color';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 16),
                    InkWell(
                      onTap: () => _selectDate(context),
                      child: InputDecorator(
                        decoration: InputDecoration(
                          labelText: 'Lost Date',
                          border: OutlineInputBorder(),
                        ),
                        child: Text(
                          DateFormat('MMM dd, yyyy').format(_lostDate),
                        ),
                      ),
                    ),
                    SizedBox(height: 16),
                    ElevatedButton.icon(
                      onPressed: _selectLocation,
                      icon: Icon(Icons.location_on),
                      label: Text('Select Location'),
                      style: ElevatedButton.styleFrom(
                        padding: EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      _locationText,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: _latitude == null ? Colors.red : Colors.green,
                      ),
                    ),
                    SizedBox(height: 16),
                    ElevatedButton.icon(
                      onPressed: _pickImage,
                      icon: Icon(Icons.photo),
                      label: Text('Add Photo'),
                      style: ElevatedButton.styleFrom(
                        padding: EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                    SizedBox(height: 8),
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
                    SizedBox(height: 24),
                    ElevatedButton(
                      onPressed: _submitForm,
                      child: Text('Report Lost Item'),
                      style: ElevatedButton.styleFrom(
                        padding: EdgeInsets.symmetric(vertical: 16),
                        textStyle: TextStyle(fontSize: 18),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
