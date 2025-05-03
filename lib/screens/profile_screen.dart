import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:foundita/providers/profile_provider.dart';
import 'package:foundita/widgets/image_widget.dart'; // Ensure correct import path

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();

 @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Fetch the user profile only if it hasn't been fetched yet or if you need to refresh it.
    // You might want to add a flag in your ProfileProvider to track if it's been loaded.
    final profileProvider = Provider.of<ProfileProvider>(context, listen: false);
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
      ),
      body: Consumer<ProfileProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (provider.error != null) {
            return Center(child: Text('Error loading profile: ${provider.error}'));
          }
          final user = provider.currentUser;
          if (user == null) {
            return const Center(child: Text('No user data available.'));
          }

          _nameController.text = user.name;
          _phoneController.text = user.phoneNumber;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
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
                                  leading: const Icon(Icons.photo_library),
                                  title: const Text('Pick from Gallery'),
                                  onTap: () {
                                    provider.pickProfileImage(ImageSource.gallery);
                                    Navigator.pop(context);
                                  },
                                ),
                                ListTile(
                                  leading: const Icon(Icons.camera_alt),
                                  title: const Text('Take a Photo'),
                                  onTap: () {
                                    provider.pickProfileImage(ImageSource.camera);
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
                          backgroundImage: provider.profileImageFile != null
                              ? FileImage(provider.profileImageFile!) as ImageProvider<Object>?
                              : provider.profileImageBytes != null
                                  ? MemoryImage(provider.profileImageBytes!)
                                  : null,
                          child: user.profilePictureBlobName != null && user.profilePictureBlobName!.isNotEmpty
                              ? ClipRRect(
                                  borderRadius: BorderRadius.circular(60),
                                  child: ImageFromBackend(blobName: user.profilePictureBlobName!),
                                )
                              : const CircleAvatar(
                                  radius: 60,
                                  child: Icon(Icons.person, size: 60),
                                ),
                        ),
                        const Positioned(
                          bottom: 0,
                          right: 0,
                          child: CircleAvatar(
                            backgroundColor: Colors.blue,
                            radius: 20,
                            child: Icon(Icons.edit, color: Colors.white),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24.0),
                  TextFormField(
                    controller: _nameController,
                    decoration: const InputDecoration(
                      labelText: 'Name',
                      border: OutlineInputBorder(),
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
                    decoration: const InputDecoration(
                      labelText: 'Phone Number',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your phone number';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 24.0),
                  ElevatedButton(
                    onPressed: () => _submitProfile(provider),
                    child: const Text('Update Profile'),
                  ),
                  const SizedBox(height: 16.0),
                  Text('Email: ${user.email}', style: Theme.of(context).textTheme.titleMedium),
                  Text('Auth Method: ${user.authMethod.name}', style: Theme.of(context).textTheme.titleMedium),
                  Text('Banned: ${user.isBanned ? 'Yes' : 'No'}', style: Theme.of(context).textTheme.titleMedium),
                  // You can display other user information here
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}