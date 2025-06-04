import 'package:flutter/foundation.dart';
import 'package:foundita/models/account_holder.dart';
import 'package:foundita/models/user.dart';
import 'package:foundita/models/administrator.dart';
import 'package:foundita/services/login_service.dart';
import 'package:firebase_auth/firebase_auth.dart' as auth;
import 'package:cloud_firestore/cloud_firestore.dart';

class LoginProvider with ChangeNotifier {
  final LoginService _loginService;
  AccountHolder? _currentAccountHolder;
  bool _isLoading = false;
  String? _error;

  LoginProvider({required LoginService loginService}) : _loginService = loginService;

  AccountHolder? get currentAccountHolder => _currentAccountHolder;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // Helper method to update _currentAccountHolder and notify listeners
  void _setAccountHolder(AccountHolder? holder) {
    _currentAccountHolder = holder;
    notifyListeners();
  }

  Future<void> loginWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    try {
      _setLoading(true);
      final accountHolder = await _loginService.loginWithEmailAndPassword(
        email: email,
        password: password,
      );
      _setAccountHolder(accountHolder); // Set the account holder
    } catch (e) {
      _handleError(e);
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  Future<void> loginWithGoogle() async {
    try {
      _setLoading(true);
      final accountHolder = await _loginService.loginWithGoogle();
      _setAccountHolder(accountHolder); // Set the account holder
    } catch (e) {
      _handleError(e);
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  Future<void> loginWithFacebook() async {
    try {
      _setLoading(true);
      final accountHolder = await _loginService.loginWithFacebook();
      _setAccountHolder(accountHolder); // Set the account holder
    } catch (e) {
      _handleError(e);
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  Future<void> logout() async {
    try {
      _setLoading(true);
      await _loginService.logout();
      _setAccountHolder(null); // Clear account holder on logout
    } catch (e) {
      _handleError(e);
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  Future<void> fetchCurrentAccountHolder() async {
    try {
      _setLoading(true);

      final firebaseUser = auth.FirebaseAuth.instance.currentUser;
      if (firebaseUser != null) {
        String userId = firebaseUser.uid;
        if (kDebugMode) {
          print('Fetching account holder for user ID: $userId');
        }

        DocumentSnapshot userDoc =
            await FirebaseFirestore.instance.collection('users').doc(userId).get();
        DocumentSnapshot adminDoc =
            await FirebaseFirestore.instance.collection('administrators').doc(userId).get();

        if (userDoc.exists) {
          final userData = userDoc.data() as Map<String, dynamic>;
          if (userData['isBanned'] == true) {
            await auth.FirebaseAuth.instance.signOut();
            throw Exception('User is banned.');
          }
          _setAccountHolder(User.fromJson(userData)); // Set as User
        } else if (adminDoc.exists) {
          _setAccountHolder(Administrator.fromJson(adminDoc.data() as Map<String, dynamic>)); // Set as Administrator
        } else {
          _setAccountHolder(null); // No account holder found
          await auth.FirebaseAuth.instance.signOut(); // Log out if not found
          throw Exception('User data not found in users or administrators collection.');
        }
      } else {
        _setAccountHolder(null); // No logged-in Firebase user
      }
    } catch (e) {
      _handleError(e);
      _setAccountHolder(null); // Ensure null on error
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _handleError(dynamic e) {
    if (kDebugMode) {
      print('LoginProvider error: $e');
    }
    _error = e.toString();
    notifyListeners();
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}