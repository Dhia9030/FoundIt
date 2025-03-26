import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

import '../models/theme_provider.dart';

class FoundItemForm extends StatefulWidget {
  @override
  _FoundItemFormState createState() => _FoundItemFormState();
}

class _FoundItemFormState extends State<FoundItemForm> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _itemNameController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();
  DateTime? _foundDate;
  String? _selectedCategory;
  List<String> _categories = ['Electronics', 'Documents', 'Jewelry', 'Clothing', 'Other'];
  List<String> _selectedImages = [];

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final darkMode = themeProvider.isDarkMode;

    return Scaffold(
      backgroundColor: darkMode ? const Color(0xFF1B262C) : const Color(0xFFD1ECFF),
      appBar: AppBar(
        title: Text('Report Found Item', style: TextStyle(
          fontFamily: 'Montserrat',
          fontWeight: FontWeight.bold,
          color: Colors.white,
        )),
        backgroundColor: darkMode ? Color(0xFF0F4C75) : Color(0xFF415FCC),
        elevation: 8,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(20)),
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildFormField(
                label: 'Item Name',
                controller: _itemNameController,
                icon: 'assets/icons/tag.svg',
                darkMode: darkMode,
              ),
              SizedBox(height: 20),
              _buildCategoryDropdown(darkMode),
              SizedBox(height: 20),
              _buildFormField(
                label: 'Location Found',
                controller: _locationController,
                icon: 'assets/icons/location.svg',
                darkMode: darkMode,
              ),
              SizedBox(height: 20),
              _buildDatePicker(darkMode),
              SizedBox(height: 20),
              _buildDescriptionField(darkMode),
              SizedBox(height: 20),
              _buildImageUploadSection(darkMode),
              SizedBox(height: 30),
              _buildSubmitButton(darkMode),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFormField({
    required String label,
    required TextEditingController controller,
    required String icon,
    required bool darkMode,
  }) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: darkMode ? Colors.black54 : Color(0x3F535353),
            blurRadius: 4,
            offset: Offset(2, 4),
          ),
        ],
      ),
      child: TextFormField(
        controller: controller,
        style: TextStyle(
          fontFamily: 'Montserrat',
          color: darkMode ? Colors.white : Colors.black,
        ),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(
            fontFamily: 'Montserrat',
            color: darkMode ? Colors.white70 : Colors.black54,
          ),
          prefixIcon: Padding(
            padding: const EdgeInsets.all(12.0),
            child: SvgPicture.asset(
              icon,
              width: 24,
              height: 24,
              color: darkMode ? Colors.white : Color(0xFF415FCC),
            ),
          ),
          filled: true,
          fillColor: darkMode ? Color(0xFF0F4C75) : Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
            borderSide: BorderSide(
              color: Color(0xFF7996FF),
              width: 2,
            ),
          ),
        ),
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'Please enter $label';
          }
          return null;
        },
      ),
    );
  }

  Widget _buildCategoryDropdown(bool darkMode) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: darkMode ? Colors.black54 : Color(0x3F535353),
            blurRadius: 4,
            offset: Offset(2, 4),
          ),
        ],
      ),
      child: DropdownButtonFormField<String>(
        value: _selectedCategory,
        decoration: InputDecoration(
          labelText: 'Category',
          labelStyle: TextStyle(
            fontFamily: 'Montserrat',
            color: darkMode ? Colors.white70 : Colors.black54,
          ),
          prefixIcon: Padding(
            padding: const EdgeInsets.all(12.0),
            child: SvgPicture.asset(
              'assets/icons/category.svg',
              width: 24,
              height: 24,
              color: darkMode ? Colors.white : Color(0xFF415FCC),
            ),
          ),
          filled: true,
          fillColor: darkMode ? Color(0xFF0F4C75) : Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
            borderSide: BorderSide.none,
          ),
        ),
        items: _categories.map((String category) {
          return DropdownMenuItem<String>(
            value: category,
            child: Text(
              category,
              style: TextStyle(
                fontFamily: 'Montserrat',
                color: darkMode ? Colors.white : Colors.black,
              ),
            ),
          );
        }).toList(),
        onChanged: (String? newValue) {
          setState(() {
            _selectedCategory = newValue;
          });
        },
        validator: (value) => value == null ? 'Please select a category' : null,
      ),
    );
  }

  Widget _buildDatePicker(bool darkMode) {
    return GestureDetector(
      onTap: () async {
        final DateTime? picked = await showDatePicker(
          context: context,
          initialDate: DateTime.now(),
          firstDate: DateTime(2000),
          lastDate: DateTime.now(),
          builder: (context, child) {
            return Theme(
              data: Theme.of(context).copyWith(
                colorScheme: ColorScheme.light(
                  primary: Color(0xFF415FCC),
                  onPrimary: Colors.white,
                  onSurface: darkMode ? Colors.white : Colors.black,
                ),
                dialogBackgroundColor: darkMode ? Color(0xFF1B262C) : Colors.white,
              ),
              child: child!,
            );
          },
        );
        if (picked != null) {
          setState(() {
            _foundDate = picked;
          });
        }
      },
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(15),
          color: darkMode ? Color(0xFF0F4C75) : Colors.white,
          boxShadow: [
            BoxShadow(
              color: darkMode ? Colors.black54 : Color(0x3F535353),
              blurRadius: 4,
              offset: Offset(2, 4),
            ),
          ],
        ),
        padding: EdgeInsets.all(16),
        child: Row(
          children: [
            SvgPicture.asset(
              'assets/icons/calendar.svg',
              width: 24,
              height: 24,
              color: darkMode ? Colors.white : Color(0xFF415FCC),
            ),
            SizedBox(width: 16),
            Text(
              _foundDate == null
                  ? 'Select Found Date'
                  : 'Date: ${DateFormat('MMM dd, yyyy').format(_foundDate!)}',
              style: TextStyle(
                fontFamily: 'Montserrat',
                color: darkMode ? Colors.white70 : Colors.black54,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDescriptionField(bool darkMode) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: darkMode ? Colors.black54 : Color(0x3F535353),
            blurRadius: 4,
            offset: Offset(2, 4),
          ),
        ],
      ),
      child: TextFormField(
        controller: _descriptionController,
        maxLines: 4,
        style: TextStyle(
          fontFamily: 'Montserrat',
          color: darkMode ? Colors.white : Colors.black,
        ),
        decoration: InputDecoration(
          labelText: 'Description',
          labelStyle: TextStyle(
            fontFamily: 'Montserrat',
            color: darkMode ? Colors.white70 : Colors.black54,
          ),
          prefixIcon: Padding(
            padding: const EdgeInsets.all(12.0),
            child: SvgPicture.asset(
              'assets/icons/description.svg',
              width: 24,
              height: 24,
              color: darkMode ? Colors.white : Color(0xFF415FCC),
            ),
          ),
          filled: true,
          fillColor: darkMode ? Color(0xFF0F4C75) : Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
            borderSide: BorderSide(
              color: Color(0xFF7996FF),
              width: 2,
            ),
          ),
        ),
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'Please enter a description';
          }
          return null;
        },
      ),
    );
  }

  Widget _buildImageUploadSection(bool darkMode) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Upload Photos (max 3)',
          style: TextStyle(
            fontFamily: 'Montserrat',
            fontWeight: FontWeight.bold,
            color: darkMode ? Colors.white : Color(0xFF415FCC),
            fontSize: 16,
          ),
        ),
        SizedBox(height: 10),
        Container(
          height: 100,
          child: ListView(
            scrollDirection: Axis.horizontal,
            children: [
              _buildImageUploadBox(darkMode),
              ..._selectedImages.map((image) => _buildImagePreview(image, darkMode)).toList(),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildImageUploadBox(bool darkMode) {
    return GestureDetector(
      onTap: () {
        // Implement image picker functionality
        if (_selectedImages.length < 3) {
          // Add dummy image for demonstration
          setState(() {
            _selectedImages.add('dummy_path');
          });
        }
      },
      child: Container(
        width: 100,
        height: 100,
        margin: EdgeInsets.only(right: 10),
        decoration: BoxDecoration(
          color: darkMode ? Color(0xFF0F4C75) : Colors.white,
          borderRadius: BorderRadius.circular(15),
          boxShadow: [
            BoxShadow(
              color: darkMode ? Colors.black54 : Color(0x3F535353),
              blurRadius: 4,
              offset: Offset(2, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SvgPicture.asset(
              'assets/icons/camera.svg',
              width: 32,
              height: 32,
              color: darkMode ? Colors.white : Color(0xFF415FCC),
            ),
            SizedBox(height: 5),
            Text(
              'Add Photo',
              style: TextStyle(
                fontFamily: 'Montserrat',
                fontSize: 12,
                color: darkMode ? Colors.white70 : Colors.black54,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImagePreview(String imagePath, bool darkMode) {
    return Container(
      width: 100,
      height: 100,
      margin: EdgeInsets.only(right: 10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(15),
        image: DecorationImage(
          image: AssetImage('assets/images/dummy_item.jpg'), // Replace with actual image
          fit: BoxFit.cover,
        ),
      ),
    );
  }

  Widget _buildSubmitButton(bool darkMode) {
    return Center(
      child: ElevatedButton(
        onPressed: () {
          if (_formKey.currentState!.validate()) {
            // Handle form submission
            _submitForm();
          }
        },
        style: ElevatedButton.styleFrom(
          padding: EdgeInsets.symmetric(horizontal: 40, vertical: 15),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(25),
          ),
          backgroundColor: Color(0xFF415FCC),
          shadowColor: Color(0x4C655B7F),
          elevation: 8,
        ),
        child: Text(
          'Submit Report',
          style: TextStyle(
            fontFamily: 'Montserrat',
            fontWeight: FontWeight.bold,
            fontSize: 18,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  void _submitForm() {
    // Handle form submission logic here
    // You can access all form fields through the controllers and state variables
    final formData = {
      'itemName': _itemNameController.text,
      'category': _selectedCategory,
      'location': _locationController.text,
      'foundDate': _foundDate,
      'description': _descriptionController.text,
      'images': _selectedImages,
    };

    print(formData); // Replace with actual submission logic

    // Show success message
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Report submitted successfully!', style: TextStyle(fontFamily: 'Montserrat')),
        backgroundColor: Colors.green,
      ),
    );

    Navigator.pop(context);
  }

  @override
  void dispose() {
    _itemNameController.dispose();
    _descriptionController.dispose();
    _locationController.dispose();
    super.dispose();
  }
}