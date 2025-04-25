import 'package:firebase_auth/firebase_auth.dart' as auth;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:foundita/models/account_holder.dart';
import 'package:foundita/models/user.dart';
import 'package:foundita/models/administrator.dart';

class LoginService {
  final auth.FirebaseAuth _firebaseAuth = auth.FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

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
          await _firestore.collection('administrators').doc(userId).get();

      if (userDoc.exists) {
        final userData = userDoc.data() as Map<String, dynamic>;
        if (userData['isBanned'] == true) {
          await _firebaseAuth.signOut();
          throw Exception('Votre compte a été suspendu. Contactez le support.');
        }
        return User.fromJson(userData);
      } else if (adminDoc.exists) {
        // Pas de vérification de ban pour les administrateurs
        return Administrator.fromJson(adminDoc.data() as Map<String, dynamic>);
      } else {
        throw Exception('Utilisateur non trouvé dans les collections');
      }
    } catch (e) {
      print('Erreur de connexion: $e');
      rethrow;
    }
  }

  Future<AccountHolder?> loginWithGoogle() async {
    try {
      auth.User? firebaseUser = _firebaseAuth.currentUser;

      if (firebaseUser != null) {
        String userId = firebaseUser.uid;

        DocumentSnapshot userDoc =
            await _firestore.collection('users').doc(userId).get();
        DocumentSnapshot adminDoc =
            await _firestore.collection('administrators').doc(userId).get();

        if (userDoc.exists) {
          final userData = userDoc.data() as Map<String, dynamic>;
          if (userData['isBanned'] == true) {
            await _firebaseAuth.signOut();
            throw Exception('Votre compte a été suspendu. Contactez le support.');
          }
          return User.fromJson(userData);
        } else if (adminDoc.exists) {
          // Pas de vérification de ban pour les administrateurs
          return Administrator.fromJson(adminDoc.data() as Map<String, dynamic>);
        } else {
          throw Exception('Utilisateur non trouvé dans les collections');
        }
      }
      return null;
    } catch (e) {
      print('Erreur de connexion Google: $e');
      rethrow;
    }
  }

  Future<AccountHolder?> loginWithFacebook() async {
    try {
      auth.User? firebaseUser = _firebaseAuth.currentUser;

      if (firebaseUser != null) {
        String userId = firebaseUser.uid;

        DocumentSnapshot userDoc =
            await _firestore.collection('users').doc(userId).get();
        DocumentSnapshot adminDoc =
            await _firestore.collection('administrators').doc(userId).get();

        if (userDoc.exists) {
          final userData = userDoc.data() as Map<String, dynamic>;
          if (userData['isBanned'] == true) {
            await _firebaseAuth.signOut();
            throw Exception('Votre compte a été suspendu. Contactez le support.');
          }
          return User.fromJson(userData);
        } else if (adminDoc.exists) {
          // Pas de vérification de ban pour les administrateurs
          return Administrator.fromJson(adminDoc.data() as Map<String, dynamic>);
        } else {
          throw Exception('Utilisateur non trouvé dans les collections');
        }
      }
      return null;
    } catch (e) {
      print('Erreur de connexion Facebook: $e');
      rethrow;
    }
  }

  Future<void> logout() async {
    await _firebaseAuth.signOut();
  }
}