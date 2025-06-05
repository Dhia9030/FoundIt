import 'package:flutter/foundation.dart';
import 'package:foundita/services/register_service.dart';


import 'package:foundita/models/account_holder.dart';
import 'package:foundita/models/user.dart';
import 'package:firebase_auth/firebase_auth.dart' as auth;
import 'package:cloud_firestore/cloud_firestore.dart';

class RegisterProvider with ChangeNotifier {
  final RegisterService _regService;
  AccountHolder? _currentAccountHolder;
  bool _isLoading = false;
  String? _error;

  RegisterProvider({required RegisterService regService}) : _regService = regService;
  AccountHolder? get currentAccountHolder => _currentAccountHolder;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> registerWithEmailAndPassword({
    required String email,
    required String password,
    required String name,
    required String phoneNumber,
  }) async {
    try {
      _setLoading(true);

      // 1. Create Firebase auth user
      final auth.FirebaseAuth _firebaseAuth = auth.FirebaseAuth.instance;
      final FirebaseFirestore _firestore = FirebaseFirestore.instance;

      final auth.UserCredential userCredential =
      await _firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // 2. Update user display name
      await userCredential.user!.updateDisplayName(name);

      // 3. Create user document in Firestore
      final newUser = User(
        authMethod: AuthMethod.email,
        chatIds: List.empty(),
        notificationIds: List.empty(),
        postIds: List.empty(),
        password: password,
        name: name,
        email: email,
        phoneNumber: phoneNumber,
        isBanned: false,
        userId: userCredential.user!.uid,
      );

      await _firestore.collection('users')
          .doc(userCredential.user!.uid)
          .set(newUser.toJson());

      // 4. Send email verification
      await userCredential.user!.sendEmailVerification();

      // 5. Set current account holder
      _currentAccountHolder = newUser;

    } on auth.FirebaseAuthException catch (e) {
      _handleError(_parseAuthError(e.code));
    } on FirebaseException catch (e) {
      _handleError('Database error: ${e.message}');
    } catch (e) {
      _handleError('An unexpected error occurred');
    } finally {
      _setLoading(false);
    }
  }

  String _parseAuthError(String code) {
    switch (code) {
      case 'email-already-in-use':
        return 'This email is already in use';
      case 'invalid-email':
        return 'Invalid email address';
      case 'operation-not-allowed':
        return 'Email/password accounts are not enabled';
      case 'weak-password':
        return 'Password is too weak';
      default:
        return 'Registration failed';
    }
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _handleError(String error) {
    _error = error;
    notifyListeners();
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}

// class RegisterProvider with ChangeNotifier {
//   final RegisterService _regService;
//   foundita_user.User? _currentUser;
//   bool _isLoading = false;
//   String? _error;
//
//   RegisterProvider({required RegisterService regService}) : _regService = regService;
//
//   foundita_user.User? get currentUser => _currentUser;
//   bool get isLoading => _isLoading;
//   String? get error => _error;
//
//   Future<void> registerWithEmailAndPassword({
//     required String name,
//     required String email,
//     required String password,
//     required String phoneNumber,
//   }) async {
//     try {
//       _isLoading = true;
//       _error = null;
//       notifyListeners();
//
//       await _regService.registerWithEmailAndPassword(
//         name: name,
//         email: email,
//         password: password,
//         phoneNumber: phoneNumber,
//       );
//
//       await fetchCurrentUser();
//     } catch (e) {
//       _error = e.toString();
//       rethrow;
//     } finally {
//       _isLoading = false;
//       notifyListeners();
//     }
//   }
//
//   Future<void> fetchCurrentUser() async {
//     try {
//       _isLoading = true;
//       notifyListeners();
//
//       _currentUser = await _regService.getCurrentUser();
//     } catch (e) {
//       _error = e.toString();
//       rethrow;
//     } finally {
//       _isLoading = false;
//       notifyListeners();
//     }
//   }
//
//
// }