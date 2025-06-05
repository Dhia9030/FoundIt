import 'dart:io';
import 'package:flutter/material.dart';
import 'package:foundita/screens/where_found_screen.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import '../providers/theme_provider.dart';
import '../providers/lost_item_provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../widgets/menu_drawer.dart';
import '../widgets/bottom_navbar.dart';
import 'package:provider/provider.dart';
import '../providers/theme_provider.dart';

class DescribeItemScreen extends StatefulWidget {
  final Function(int)? onNavItemSelected;
  const DescribeItemScreen({Key? key, this.onNavItemSelected})
      : super(key: key);

  @override
  _DescribeItemScreenState createState() => _DescribeItemScreenState();
}

class _DescribeItemScreenState extends State<DescribeItemScreen> {
  bool isMenuOpen = false;
  final TextEditingController _descriptionController = TextEditingController();
  File? _selectedImage;
  final ImagePicker _picker = ImagePicker();
  int _currentNavIndex = 1; // Default to Home tab

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
      final XFile? pickedFile =
          await _picker.pickImage(source: ImageSource.gallery);
      if (pickedFile != null) {
        setState(() => _selectedImage = File(pickedFile.path));
      }
    } catch (e) {
      print("Error picking image: $e");
    }
  }

  void _validateAndPost() {
    if (_descriptionController.text.trim().isEmpty) {
      setState(() {
        _showError = true;
        _errorMessage = "Please describe your item";
      });
    } else {
      print("Post button tapped with: ${_descriptionController.text}");
      // From DescribeItemScreen
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => WhereFoundScreen(itemData: {
            'description': _descriptionController.text,
            'image': _selectedImage?.path,
          }),
        ),
      );
    }
  }

  void _toggleMenu() {
    setState(() => isMenuOpen = !isMenuOpen);
  }

  void _handleNavTap(int index) {
    if (index != 1) {
      Navigator.pop(context);
      widget.onNavItemSelected?.call(index);
    }

    /*
    setState(() {
      _currentNavIndex = index;
      if (isMenuOpen) _toggleMenu();
    });
    // Handle navigation based on the selected tab
    switch (index) {
      case 0: // Search
        Navigator.pushNamed(context, '/search');
        break;
      case 1: // Home
        Navigator.pushNamed(context, '/home');
        break;
      case 2: // Notifications
        Navigator.pushNamed(context, '/notifications');
        break;
      case 3: // Profile
        Navigator.pushNamed(context, '/profile');
        break;
    }*/
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final darkMode = themeProvider.isDarkMode;
    return Scaffold(
      backgroundColor: darkMode
          ? const Color(0xFF1B262C)
          : const Color(0xFFE6F0FA), // Light blue pastel background
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Describe Your Item'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        titleTextStyle: const TextStyle(
          color: Colors.black,
          fontSize: 24,
          fontWeight: FontWeight.bold,
        ),
      ),
      body: Stack(
        children: [
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.only(
                  top: 0, bottom: 60), // Adjusted for navbar
              child: SingleChildScrollView(
                child: Padding(
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
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
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
                                    width:
                                        MediaQuery.of(context).size.width * 0.3,
                                    height: 8,
                                    color: const Color(0xFF6C63FF),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 20),
                          // Description text field
                          GestureDetector(
                            onTap: () => FocusScope.of(context)
                                .requestFocus(_descriptionFocusNode),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 300),
                              height: 200,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: _showError
                                      ? Colors.red
                                      : _isDescriptionFocused
                                          ? const Color(0xFF6C63FF)
                                          : Colors.transparent,
                                  width: _isDescriptionFocused || _showError
                                      ? 2.5
                                      : 0.0,
                                ),
                                color: const Color(0xFFF5F7FF),
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
                                  hintText: 'describe here',
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
                              padding:
                                  const EdgeInsets.only(top: 8.0, left: 8.0),
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
                            "optional",
                            style: GoogleFonts.urbanist(
                              fontSize: 16,
                              color: Colors.black87,
                            ),
                          ),
                          const SizedBox(height: 10),
                          GestureDetector(
                            onTap: _pickImageFromGallery,
                            child: Container(
                              height: 150,
                              decoration: BoxDecoration(
                                color: const Color(0xFFF5F7FF),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: _selectedImage != null
                                  ? ClipRRect(
                                      borderRadius: BorderRadius.circular(12),
                                      child: Image.file(
                                        _selectedImage!,
                                        fit: BoxFit.cover,
                                      ),
                                    )
                                  : Center(
                                      child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Icon(
                                            Icons.image_outlined,
                                            color: Colors.grey.shade400,
                                            size: 40,
                                          ),
                                          const SizedBox(height: 10),
                                          Text(
                                            "Select file",
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
                          Center(
                            child: SizedBox(
                              width: 200,
                              child: ElevatedButton(
                                onPressed: _validateAndPost,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF6C63FF),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 12),
                                ),
                                child: Text(
                                  "Post",
                                  style: GoogleFonts.urbanist(
                                    color: Colors.white,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                  ),
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
      /*bottomNavigationBar: CustomBottomNavBar(
        currentIndex: 1,
        onTap: _handleNavTap,
      ),*/
    );
  }
}
