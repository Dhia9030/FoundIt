import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:foundita/models/user.dart' as custom_user;
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter/foundation.dart' hide Category;
import 'package:http_parser/http_parser.dart';
import 'package:path/path.dart' as path;

class ProfileService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final String _uploadImageUrl = dotenv.env['BACKEND_UPLOAD_URL']!;
  final String _uploadapiKey = dotenv.env['UPLOAD_API_KEY']!;

  Future<custom_user.User?> getCurrentUserProfile() async {
    final userId = _auth.currentUser?.uid;
    if (userId == null) {
      return null;
    }
    final userDoc = await _firestore.collection('users').doc(userId).get();
    if (userDoc.exists && userDoc.data() != null) {
      return custom_user.User.fromJson(userDoc.data() as Map<String, dynamic>);
    }
    return null;
  }

  /// Uploads image bytes to the Python backend and returns the blob name
  Future<String?> _uploadImageBytes(Uint8List imageBytes, {String? filename}) async {
    try {
      final uri = Uri.parse(_uploadImageUrl);
      final request = http.MultipartRequest('POST', uri);
      request.headers['X-API-Key'] = _uploadapiKey;
      request.files.add(
        http.MultipartFile.fromBytes(
          'file',
          imageBytes,
          filename: filename ?? 'profile_${DateTime.now().millisecondsSinceEpoch}.png',
          contentType: MediaType('image', 'png'), // Adjust if needed
        ),
      );

      final response = await request.send();
      final responseBody = await response.stream.bytesToString();
      final jsonResponse = jsonDecode(responseBody);

      if (response.statusCode == 200 && jsonResponse['status'] == 'success') {
        return jsonResponse['blob_name'];
      } else {
        print('Error uploading image bytes to backend: ${response.statusCode} - $responseBody');
        return null;
      }
    } catch (e) {
      print('Error uploading image bytes: $e');
      return null;
    }
  }

  /// Uploads a File to the Python backend and returns the blob name
  Future<String?> _uploadImageFile(File imageFile) async {
    try {
      final uri = Uri.parse(_uploadImageUrl);
      final request = http.MultipartRequest('POST', uri);
      request.headers['X-API-Key'] = _uploadapiKey;
      request.files.add(
        await http.MultipartFile.fromPath(
          'file',
          imageFile.path,
          filename: path.basename(imageFile.path),
        ),
      );

      final response = await request.send();
      final responseBody = await response.stream.bytesToString();
      final jsonResponse = jsonDecode(responseBody);

      if (response.statusCode == 200 && jsonResponse['status'] == 'success') {
        return jsonResponse['blob_name'];
      } else {
        print('Error uploading image file to backend: ${response.statusCode} - $responseBody');
        return null;
      }
    } catch (e) {
      print('Error uploading image file: $e');
      return null;
    }
  }

  Future<void> updateProfile({required String name, required String phoneNumber, File? profileImage, Uint8List? profileImageBytes}) async {
    final userId = _auth.currentUser?.uid;
    if (userId == null) {
      throw Exception('User not logged in');
    }

    Map<String, dynamic> updateData = {
      'name': name,
      'phoneNumber': phoneNumber,
    };

    if (profileImageBytes != null) {
      final blobName = await _uploadImageBytes(profileImageBytes);
      if (blobName != null) {
        updateData['profilePictureBlobName'] = blobName;
      }
    } else if (profileImage != null) {
      final blobName = await _uploadImageFile(profileImage);
      if (blobName != null) {
        updateData['profilePictureBlobName'] = blobName;
      }
    }

    await _firestore.collection('users').doc(userId).update(updateData);
  }
}