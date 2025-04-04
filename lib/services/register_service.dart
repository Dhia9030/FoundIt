import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:foundita/models/account_holder.dart';
import 'package:foundita/models/user.dart' as foundita_user;

class RegisterService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Register a new user with email and password
  Future<User?> registerWithEmailAndPassword({
    required String name,
    required String email,
    required String password,
    required String phoneNumber,
  }) async {
    try {
      // 1. Create user in Firebase Authentication
      final UserCredential credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // 2. Create user document in Firestore
      final foundita_user.User user = foundita_user.User(
        userId: credential.user?.uid,
        name: name,
        email: email,
        authMethod: AuthMethod.email,
        password: password, // Note: In production, you shouldn't store raw passwords
        phoneNumber: phoneNumber,
      );

      await _firestore
          .collection('users')
          .doc(credential.user?.uid)
          .set(user.toJson());

      return credential.user;
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    } on FirebaseException catch (e) {
      throw _handleFirestoreException(e);
    } catch (e) {
      throw Exception('Registration failed: ${e.toString()}');
    }
  }

  // Register with social providers (Google, Facebook)
  Future<User?> registerWithSocialProvider({
    required AuthMethod method,
    required String name,
    required String email,
    required String phoneNumber,
  }) async {
    try {
      // This is a placeholder - you'll need to implement actual social auth
      // For example, using google_sign_in or facebook_auth packages
      throw UnimplementedError('Social registration not implemented yet');
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    } on FirebaseException catch (e) {
      throw _handleFirestoreException(e);
    } catch (e) {
      throw Exception('Social registration failed: ${e.toString()}');
    }
  }

  // Helper method to handle auth exceptions
  String _handleAuthException(FirebaseAuthException e) {
    switch (e.code) {
      case 'email-already-in-use':
        return 'The email address is already in use by another account.';
      case 'invalid-email':
        return 'The email address is not valid.';
      case 'operation-not-allowed':
        return 'Email/password accounts are not enabled.';
      case 'weak-password':
        return 'The password is too weak.';
      default:
        return 'An undefined authentication error occurred.';
    }
  }

  // Helper method to handle Firestore exceptions
  String _handleFirestoreException(FirebaseException e) {
    return 'Database error: ${e.message}';
  }

  // Get current user data
  Future<foundita_user.User?> getCurrentUser() async {
    try {
      final User? firebaseUser = _auth.currentUser;
      if (firebaseUser == null) return null;

      final DocumentSnapshot doc =
          await _firestore.collection('users').doc(firebaseUser.uid).get();

      if (doc.exists) {
        return foundita_user.User.fromJson(doc.data() as Map<String, dynamic>);
      }
      return null;
    } catch (e) {
      throw Exception('Failed to get user data: ${e.toString()}');
    }
  }
}