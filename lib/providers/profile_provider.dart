import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:foundita/models/user.dart';
import 'package:foundita/services/profile_service.dart';

class ProfileProvider with ChangeNotifier {
  final ProfileService _profileService;
  User? _currentUser;
  bool _isLoading = false;
  String? _error;
  File? _profileImageFile;
  Uint8List? _profileImageBytes; // New variable to hold image bytes

  ProfileProvider({required ProfileService profileService}) : _profileService = profileService;

  User? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  String? get error => _error;
  File? get profileImageFile => _profileImageFile;
  Uint8List? get profileImageBytes => _profileImageBytes; // Getter for image bytes

  Future<void> fetchCurrentUserProfile() async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      _currentUser = await _profileService.getCurrentUserProfile();
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> pickProfileImage(ImageSource source) async {
    final ImagePicker picker = ImagePicker();
    final XFile? pickedFile = await picker.pickImage(source: source);
    if (pickedFile != null) {
      if (kIsWeb) {
        _profileImageBytes = await pickedFile.readAsBytes();
        _profileImageFile = null; // Clear the File object for web
      } else {
        _profileImageFile = File(pickedFile.path);
        _profileImageBytes = null; // Clear the bytes for mobile
      }
      // Add this Future.delayed to ensure the UI has a chance to rebuild
      Future.delayed(Duration.zero, () {
        notifyListeners();
      });
    }
  }

  Future<void> updateProfile({required String name, required String phoneNumber}) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      File? fileToUpload = kIsWeb ? null : _profileImageFile;
      Uint8List? bytesToUpload = kIsWeb ? _profileImageBytes : null;

      if (fileToUpload != null || bytesToUpload != null) {
        if (kIsWeb && bytesToUpload != null) {
          await _profileService.updateProfile(name: name, phoneNumber: phoneNumber, profileImageBytes: bytesToUpload);
        } else if (!kIsWeb && fileToUpload != null) {
          await _profileService.updateProfile(name: name, phoneNumber: phoneNumber, profileImage: fileToUpload);
        } else {
          await _profileService.updateProfile(name: name, phoneNumber: phoneNumber); // No image to update
        }
      } else {
        await _profileService.updateProfile(name: name, phoneNumber: phoneNumber); // No image to update
      }
      await fetchCurrentUserProfile(); // Refresh user data
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void clearProfileImage() {
    _profileImageFile = null;
    _profileImageBytes = null;
    notifyListeners();
  }
}