import 'package:firebase_auth/firebase_auth.dart' as auth;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:foundita/models/account_holder.dart';
import 'package:foundita/models/user.dart';
import 'package:foundita/models/administrator.dart';
import 'package:google_sign_in/google_sign_in.dart';

class LoginService {
  final auth.FirebaseAuth _firebaseAuth = auth.FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  final FacebookAuth _facebookAuth = FacebookAuth.instance;

  Future<AccountHolder?> loginWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    try {
      auth.UserCredential userCredential =
          await _firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      String userId = userCredential.user!.uid;

      DocumentSnapshot userDoc =
          await _firestore.collection('users').doc(userId).get();
      DocumentSnapshot adminDoc =
          await _firestore.collection('admins').doc(userId).get();

      if (userDoc.exists) {
        final userData = userDoc.data() as Map<String, dynamic>;
        if (userData['isBanned'] == true) {
          await _firebaseAuth.signOut();
          throw Exception('Your account has been suspended. Please contact support.');
        }
        return User.fromJson(userData);
      } else if (adminDoc.exists) {
        // No ban check for administrators
        return Administrator.fromJson(adminDoc.data() as Map<String, dynamic>);
      } else {
        throw Exception('User not found in collections');
      }
    } catch (e) {
      print('Login error: $e');
      rethrow;
    }
  }

  Future<AccountHolder?> loginWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        // User cancelled the sign-in
        return null;
      }
      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      final auth.OAuthCredential credential = auth.GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final auth.UserCredential userCredential =
          await _firebaseAuth.signInWithCredential(credential);
      final auth.User? firebaseUser = userCredential.user;

      if (firebaseUser != null) {
        return await _handleFirebaseUser(firebaseUser);
      }
      return null;
    } catch (e) {
      print('Google login error: $e');
      rethrow;
    }
  }

  // Helper function to handle fetching user/admin data after Firebase sign-in
  Future<AccountHolder?> _handleFirebaseUser(auth.User firebaseUser) async {
    String userId = firebaseUser.uid;
    DocumentSnapshot userDoc =
        await _firestore.collection('users').doc(userId).get();
    DocumentSnapshot adminDoc =
        await _firestore.collection('admins').doc(userId).get();

    if (userDoc.exists) {
      final userData = userDoc.data() as Map<String, dynamic>;
      if (userData['isBanned'] == true) {
        await _firebaseAuth.signOut();
        throw Exception('Your account has been suspended. Please contact support.');
      }
      return User.fromJson(userData);
    } else if (adminDoc.exists) {
      return Administrator.fromJson(adminDoc.data() as Map<String, dynamic>);
    } else {
      // If the user doesn't exist in either collection, you might want to:
      // 1. Create a new user document in 'users' collection
      // 2. Redirect them to a profile setup screen
      throw Exception('User not found in collections');
    }
  }

  Future<AccountHolder?> loginWithFacebook() async {
    try {
      final LoginResult result = await _facebookAuth.login();

      if (result.status == LoginStatus.success) {
        final auth.FacebookAuthProvider facebookProvider =
            auth.FacebookAuthProvider();
        final auth.AuthCredential credential =
            auth.FacebookAuthProvider.credential(result.accessToken!.tokenString);

        final auth.UserCredential userCredential =
            await _firebaseAuth.signInWithCredential(credential);
        final auth.User? firebaseUser = userCredential.user;

        if (firebaseUser != null) {
          return await _handleFirebaseUser(firebaseUser);
        }
        return null;
      } else {
        print('Facebook login failed: ${result.status}');
        if (result.message != null) {
          print('Facebook login error message: ${result.message}');
        }
        // Handle the error appropriately
        throw Exception('Facebook login failed.');
      }
    } catch (e) {
      print('Facebook login error: $e');
      rethrow;
    }
  }

  Future<void> logout() async {
    await _firebaseAuth.signOut();
  }
}