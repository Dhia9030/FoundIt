import 'dart:io';
import 'package:flutter/material.dart';
import 'package:foundita/widgets/menu_drawer.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:foundita/providers/profile_provider.dart';
import 'package:foundita/widgets/image_widget.dart';
import 'package:foundita/widgets/bottom_navbar.dart';
import 'package:provider/provider.dart';
import '../providers/theme_provider.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  int _currentNavIndex = 1;
  bool isMenuOpen = false;
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final profileProvider =
        Provider.of<ProfileProvider>(context, listen: false);
    if (profileProvider.currentUser == null && !profileProvider.isLoading) {
      profileProvider.fetchCurrentUserProfile();
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _submitProfile(ProfileProvider provider) async {
    if (_formKey.currentState!.validate()) {
      await provider.updateProfile(
        name: _nameController.text,
        phoneNumber: _phoneController.text,
      );
      if (provider.error == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Profile updated successfully!')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error updating profile: ${provider.error}')),
        );
      }
    }
  }
  void _toggleMenu() {
    setState(() => isMenuOpen = !isMenuOpen);
  }

  void _handleNavTap(int index) {
    if (index == _currentNavIndex) return;

    setState(() {
      _currentNavIndex = index;
      if (isMenuOpen) _toggleMenu();
    });

    // Handle navigation based on the selected tab
    switch (index) {
      case 0: // Search
        Navigator.pushReplacementNamed(context, '/search');
        break;
      case 1: // Home
        Navigator.pushReplacementNamed(context, '/home');
        break;
      case 2: // Notifications
        Navigator.pushReplacementNamed(context, '/notifications');
        break;
      case 3: // Profile
        Navigator.pushReplacementNamed(context, '/profile');
        break;
    }
  }

  // Add this method inside your _ProfileScreenState class, after the build method
Widget _buildInfoRow(String label, String value, IconData icon, Color valueColor, Color labelColor) {
  return Row(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Icon(icon, size: 20, color: valueColor),
      const SizedBox(width: 12),
      Expanded(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: labelColor,
                letterSpacing: 0.5,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              value,
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w500,
                color: valueColor,
              ),
            ),
          ],
        ),
      ),
    ],
  );
}

  @override
  Widget build(BuildContext context) {
        final themeProvider = Provider.of<ThemeProvider>(context);
    final darkMode = themeProvider.isDarkMode;
    final textColor = darkMode ? Colors.black87 : Colors.black87;
final labelColor = darkMode ? Colors.white54 : Colors.black54;
    return Scaffold(
      backgroundColor: darkMode ? const Color(0xFF1B262C) : const Color(0xFFE6F0FA), // Light blue pastel background
      appBar: AppBar(
        title: Text('Profile',
        style: TextStyle(
          color: darkMode ? Colors.white : Colors.black,
          fontSize: 24,
          fontWeight: FontWeight.bold,
        ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        titleTextStyle: const TextStyle(
          color: Colors.black,
          fontSize: 24,
          fontWeight: FontWeight.bold,
        ),
      ),
      body: Consumer<ProfileProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (provider.error != null) {
            return Center(
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
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.error, color: Colors.red),
                    const SizedBox(width: 8),
                    Text('Error loading profile: ${provider.error}'),
                  ],
                ),
              ),
            );
          }
          final user = provider.currentUser;
          if (user == null) {
            return const Center(child: Text('No user data available.'));
          }

          _nameController.text = user.name;
          _phoneController.text = user.phoneNumber;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Center(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  if (provider.error != null) ...[
                    Container(
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
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.error, color: Colors.red),
                          const SizedBox(width: 8),
                          Text('Error: ${provider.error}'),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16.0),
                  ],
                  Container(
                    padding: const EdgeInsets.all(16.0),
                    decoration: BoxDecoration(
                      color: darkMode? const Color(0xFF0e1214):const Color(0xFFEBFFFE),
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
                      children: [
                        GestureDetector(
                          onTap: () {
                            showModalBottomSheet(
                              context: context,
                              builder: (BuildContext context) {
                                return SafeArea(
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: <Widget>[
                                      ListTile(
                                        leading:
                                            const Icon(Icons.photo_library),
                                        title: const Text('Pick from Gallery'),
                                        onTap: () async {
                                          await provider.pickProfileImage(
                                              ImageSource.gallery);
                                          Navigator.pop(context);
                                        },
                                      ),
                                      ListTile(
                                        leading: const Icon(Icons.camera_alt),
                                        title: const Text('Take a Photo'),
                                        onTap: () async {
                                          await provider.pickProfileImage(
                                              ImageSource.camera);
                                          Navigator.pop(context);
                                        },
                                      ),
                                    ],
                                  ),
                                );
                              },
                            );
                          },
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              CircleAvatar(
                                radius: 60,
                                backgroundImage: provider.profileImageFile !=
                                        null
                                    ? FileImage(provider.profileImageFile!)
                                        as ImageProvider<Object>?
                                    : provider.profileImageBytes != null
                                        ? MemoryImage(
                                            provider.profileImageBytes!)
                                        : user.profilePictureBlobName != null &&
                                                user.profilePictureBlobName!
                                                    .isNotEmpty
                                            ? null
                                            : null,
                                child: provider.profileImageFile == null &&
                                        provider.profileImageBytes == null &&
                                        user.profilePictureBlobName != null &&
                                        user.profilePictureBlobName!.isNotEmpty
                                    ? ClipRRect(
                                        borderRadius: BorderRadius.circular(60),
                                        child: ImageFromBackend(
                                            blobName:
                                                user.profilePictureBlobName!),
                                      )
                                    : provider.profileImageFile == null &&
                                            provider.profileImageBytes == null
                                        ? const CircleAvatar(
                                            radius: 60,
                                            child: Icon(Icons.person, size: 60),
                                          )
                                        : null,
                              ),
                              const Positioned(
                                bottom: 0,
                                right: 0,
                                child: CircleAvatar(
                                  backgroundColor: Color(0xFF6C63FF),
                                  radius: 20,
                                  child: Icon(Icons.edit, color: Colors.white),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 24.0),
                        Form(
                          key: _formKey,
                          child: Column(
                            children: [
                              TextFormField(
                                controller: _nameController,
                                decoration: InputDecoration(
                                  labelText: 'Name',
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: BorderSide.none,
                                  ),
                                  filled: true,
                                  fillColor: darkMode? const Color(0xFF19252B):const Color(0xFFE6F0FA),
                                ),
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Please enter your name';
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(height: 16.0),
                              TextFormField(
                                controller: _phoneController,
                                decoration: InputDecoration(
                                  labelText: 'Phone Number',
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: BorderSide.none,
                                  ),
                                  filled: true,
                                  fillColor: darkMode? const Color(0xFF19252B):const Color(0xFFE6F0FA),
                                ),
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Please enter your phone number';
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(height: 16.0),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  _buildInfoRow('Email', user.email, Icons.email_outlined, textColor, labelColor),
                                  const SizedBox(height: 12.0),
                                  _buildInfoRow('Auth Method', user.authMethod.name, Icons.security_outlined, textColor, labelColor),
                                  const SizedBox(height: 12.0),
                                  _buildInfoRow('Status', user.isBanned ? 'Banned' : 'Active', 
                                      user.isBanned ? Icons.block : Icons.verified_user,
                                      user.isBanned ? Colors.redAccent : (darkMode ? Colors.lightGreenAccent : Colors.green),
                                      labelColor),
                                ],
                              ),
                              const SizedBox(height: 24.0),
                              Center(
                                child: SizedBox(
                                  width: 240, // Slightly wider button
                                  child: ElevatedButton(
                                    onPressed: () => _submitProfile(provider),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: const Color(0xFF6C63FF),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 16),
                                    ),
                                    child: const Text(
                                      'Update Profile',
                                      style: TextStyle(
                                          color: Colors.white, fontSize: 16),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
          
          
        },
      ),
      /*bottomNavigationBar: CustomBottomNavBar(
        currentIndex: _currentNavIndex,
        onTap: _handleNavTap,
      ),*/
    );
  }
}
