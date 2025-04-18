import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import '../providers/theme_provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../widgets/menu_drawer.dart';
import '../widgets/bottom_navbar.dart';

class ReportFoundItemForm extends StatefulWidget {
  const ReportFoundItemForm({Key? key}) : super(key: key);

  @override
  _ReportFoundItemFormState createState() => _ReportFoundItemFormState();
}

class _ReportFoundItemFormState extends State<ReportFoundItemForm> {
  bool isMenuOpen = false;
  final TextEditingController _descriptionController = TextEditingController();
  File? _selectedImage;
  final ImagePicker _picker = ImagePicker();
  int _currentNavIndex = 1;

  final FocusNode _descriptionFocusNode = FocusNode();
  bool _isDescriptionFocused = false;
  bool _showError = false;
  String _errorMessage = "";

  @override
  void initState() {
    super.initState();
    _descriptionFocusNode.addListener(() {
      setState(() {
        _isDescriptionFocused = _descriptionFocusNode.hasFocus;
        if (_isDescriptionFocused) _showError = false;
      });
    });
  }

  @override
  void dispose() {
    _descriptionController.dispose();
    _descriptionFocusNode.dispose();
    super.dispose();
  }

  Future<void> _pickImageFromGallery() async {
    try {
      final XFile? pickedFile = await _picker.pickImage(source: ImageSource.gallery);
      if (pickedFile != null) {
        setState(() => _selectedImage = File(pickedFile.path));
      }
    } catch (e) {
      print("Error picking image: $e");
    }
  }

  void _validateAndReport() {
    if (_descriptionController.text.trim().isEmpty) {
      setState(() {
        _showError = true;
        _errorMessage = "Please describe the found item";
      });
    } else {
      print("Report button tapped with: ${_descriptionController.text}");
    }
  }

  void _toggleMenu() => setState(() => isMenuOpen = !isMenuOpen);

  void _handleNavTap(int index) {
    if (index == _currentNavIndex) return;

    setState(() {
      _currentNavIndex = index;
      if (isMenuOpen) _toggleMenu();
    });

    switch (index) {
      case 0:
        Navigator.pushReplacementNamed(context, '/search');
        break;
      case 1:
        Navigator.pushReplacementNamed(context, '/home');
        break;
      case 2:
        Navigator.pushReplacementNamed(context, '/notifications');
        break;
      case 3:
        Navigator.pushReplacementNamed(context, '/profile');
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final darkMode = themeProvider.isDarkMode;
    final backgroundColor = darkMode ? const Color(0xFF1B262C) : const Color(0xFFD1ECFF);

    return Scaffold(
      backgroundColor: backgroundColor,
      body: Stack(
        children: [
          Positioned(
            top: -100,
            right: -100,
            child: Image.asset(
              darkMode ? 'assets/images/blob-1.png' : 'assets/images/blob2-1.png',
              width: 300,
              height: 300,
            ),
          ),
          Positioned(
            bottom: -100,
            left: -100,
            child: Image.asset(
              darkMode ? 'assets/images/blob-3.png' : 'assets/images/blob2-3.png',
              width: 300,
              height: 300,
            ),
          ),

          SafeArea(
            child: Padding(
              padding: const EdgeInsets.only(top: 70, bottom: 0),
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Container(
                    decoration: BoxDecoration(
                      color: const Color(0xFFCDDDFF),
                      borderRadius: BorderRadius.circular(30),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 10,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              GestureDetector(
                                onTap: () => Navigator.pop(context),
                                child: const Icon(Icons.arrow_back, size: 34, color: Colors.black),
                              ),
                              const SizedBox(width: 40),
                              Expanded(
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(10),
                                  child: Container(
                                    height: 8,
                                    color: Colors.white,
                                    child: Row(
                                      children: [
                                        Container(
                                          width: MediaQuery.of(context).size.width * 0.3,
                                          height: 8,
                                          color: const Color(0xFF3694FF),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 50)
                            ],
                          ),

                          const SizedBox(height: 20),

                          Text(
                            "Report Found Item",
                            style: GoogleFonts.urbanist(
                              fontSize: 32,
                              fontWeight: FontWeight.bold,
                              color: const Color(0xFF1B262C),
                            ),
                          ),

                          const SizedBox(height: 20),

                          GestureDetector(
                            onTap: () => FocusScope.of(context).requestFocus(_descriptionFocusNode),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 300),
                              height: 200,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                  color: _showError
                                      ? Colors.red
                                      : _isDescriptionFocused
                                      ? const Color(0xFF3694FF)
                                      : Colors.transparent,
                                  width: _isDescriptionFocused || _showError ? 2.5 : 0.0,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: _isDescriptionFocused
                                        ? const Color(0xFF3694FF).withOpacity(0.4)
                                        : Colors.black.withOpacity(0.05),
                                    blurRadius: _isDescriptionFocused ? 12 : 5,
                                    spreadRadius: _isDescriptionFocused ? 2 : 0,
                                    offset: const Offset(0, 3),
                                  ),
                                ],
                              ),
                              child: TextField(
                                controller: _descriptionController,
                                focusNode: _descriptionFocusNode,
                                maxLines: 10,
                                onChanged: (text) {
                                  if (_showError && text.trim().isNotEmpty) {
                                    setState(() => _showError = false);
                                  }
                                },
                                decoration: InputDecoration(
                                  hintText: 'Describe the found item...',
                                  hintStyle: GoogleFonts.urbanist(
                                    color: Colors.grey,
                                    fontSize: 16,
                                  ),
                                  border: InputBorder.none,
                                  contentPadding: const EdgeInsets.all(20),
                                ),
                              ),
                            ),
                          ),

                          if (_showError)
                            Padding(
                              padding: const EdgeInsets.only(top: 8.0, left: 8.0),
                              child: Text(
                                _errorMessage,
                                style: GoogleFonts.urbanist(
                                  color: Colors.red,
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),

                          SizedBox(height: _showError ? 8.0 : 20.0),

                          Text(
                            "Additional Information",
                            style: GoogleFonts.urbanist(
                              fontSize: 16,
                              color: const Color(0xFF1B262C),
                            ),
                          ),

                          const SizedBox(height: 10),

                          GestureDetector(
                            onTap: _pickImageFromGallery,
                            child: Container(
                              height: 150,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(20),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.05),
                                    blurRadius: 5,
                                    offset: const Offset(0, 3),
                                  ),
                                ],
                              ),
                              child: _selectedImage != null
                                  ? ClipRRect(
                                borderRadius: BorderRadius.circular(20),
                                child: Image.file(
                                  _selectedImage!,
                                  fit: BoxFit.cover,
                                ),
                              )
                                  : Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.image_outlined,
                                      color: Colors.grey.shade400,
                                      size: 40,
                                    ),
                                    const SizedBox(height: 10),
                                    Text(
                                      "Upload photo of found item",
                                      style: GoogleFonts.urbanist(
                                        color: Colors.grey,
                                        fontSize: 20,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),

                          const SizedBox(height: 20),

                          SizedBox(
                            width: double.infinity,
                            height: 60,
                            child: ElevatedButton(
                              onPressed: _validateAndReport,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF3694FF),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(30),
                                ),
                                elevation: 5,
                              ),
                              child: Text(
                                "Report",
                                style: GoogleFonts.urbanist(
                                  color: Colors.white,
                                  fontSize: 40,
                                  fontWeight: FontWeight.w600,
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
          ),

          if (isMenuOpen)
            GestureDetector(
              onTap: _toggleMenu,
              behavior: HitTestBehavior.opaque,
              child: Container(color: Colors.black.withOpacity(0.5)),
            ),

          MenuDrawer(
            isMenuOpen: isMenuOpen,
            onMenuToggle: _toggleMenu,
          ),
        ],
      ),
      bottomNavigationBar: CustomBottomNavBar(
        currentIndex: _currentNavIndex,
        onTap: _handleNavTap,
      ),
    );
  }
}