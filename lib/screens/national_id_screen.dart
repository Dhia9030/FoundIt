import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../providers/theme_provider.dart';

class NationalIdScreen extends StatefulWidget {
  final Map<String, dynamic> itemData;
  const NationalIdScreen({Key? key, required this.itemData}) : super(key: key);

  @override
  _NationalIdScreenState createState() => _NationalIdScreenState();
}

class _NationalIdScreenState extends State<NationalIdScreen> {
  final TextEditingController _idController = TextEditingController();
  final ImagePicker _picker = ImagePicker();
  File? _idPhoto;
  bool _showError = false;

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
        title: const Text('Verify Identity'),
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
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Progress bar (step 3 of 3)
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: Container(
                    height: 8,
                    color: const Color(0xFFF5F7FF),
                    child: Row(
                      children: [
                        Container(
                          width: MediaQuery.of(context).size.width * 1.0,
                          height: 8,
                          color: const Color(0xFF6C63FF),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 30),
                Text(
                  "National ID Verification",
                  style: GoogleFonts.urbanist(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  "ID Number",
                  style: GoogleFonts.urbanist(
                    fontSize: 16,
                    color: Colors.black54,
                  ),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: _idController,
                  decoration: InputDecoration(
                    hintText: 'Enter your national ID number',
                    filled: true,
                    fillColor: const Color(0xFFF5F7FF),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 14,
                    ),
                  ),
                  keyboardType: TextInputType.number,
                ),
                if (_showError)
                  Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: Text(
                      "Please enter your ID number",
                      style: GoogleFonts.urbanist(
                        color: Colors.red,
                        fontSize: 14,
                      ),
                    ),
                  ),
                const SizedBox(height: 30),
                Text(
                  "Upload ID Photo",
                  style: GoogleFonts.urbanist(
                    fontSize: 16,
                    color: Colors.black54,
                  ),
                ),
                const SizedBox(height: 12),
                GestureDetector(
                  onTap: _pickIdPhoto,
                  child: Container(
                    height: 150,
                    decoration: BoxDecoration(
                      color: const Color(0xFFF5F7FF),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: _idPhoto == null
                            ? Colors.grey
                            : const Color(0xFF6C63FF),
                        width: 1.5,
                      ),
                    ),
                    child: _idPhoto != null
                        ? ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: Image.file(
                              _idPhoto!,
                              fit: BoxFit.cover,
                            ),
                          )
                        : Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(
                                  Icons.upload_file,
                                  size: 40,
                                  color: Color(0xFF6C63FF),
                                ),
                                const SizedBox(height: 10),
                                Text(
                                  "Tap to upload photo",
                                  style: GoogleFonts.urbanist(
                                    color: const Color(0xFF6C63FF),
                                    fontSize: 16,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ),
                  ),
                ),
                const SizedBox(height: 30),
                Center(
                  child: SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _submitVerification,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF6C63FF),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: Text(
                        "Submit Report",
                        style: GoogleFonts.urbanist(
                          color: Colors.white,
                          fontSize: 18,
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
    );
  }

  Future<void> _pickIdPhoto() async {
    try {
      final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
      if (pickedFile != null) {
        setState(() => _idPhoto = File(pickedFile.path));
      }
    } catch (e) {
      print("Error picking ID photo: $e");
    }
  }

  void _submitVerification() {
    if (_idController.text.isEmpty) {
      setState(() => _showError = true);
      return;
    }

    // Prepare final data
    final reportData = {
      ...widget.itemData,
      'idNumber': _idController.text,
      'idPhoto': _idPhoto?.path,
    };

    print("Final Report Data: $reportData");
    // TODO: Implement submission logic
    Navigator.pushNamedAndRemoveUntil(
        context, '/confirmation', (route) => false);
  }
}
