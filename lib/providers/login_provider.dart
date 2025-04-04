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

  Future<void> loginWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      _currentAccountHolder = await _loginService.loginWithEmailAndPassword(
        email: email,
        password: password,
      );
    } catch (e) {
      _error = e.toString();
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loginWithGoogle() async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      _currentAccountHolder = await _loginService.loginWithGoogle();
    } catch (e) {
      _error = e.toString();
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loginWithFacebook() async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      _currentAccountHolder = await _loginService.loginWithFacebook();
    } catch (e) {
      _error = e.toString();
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> logout() async {
    try {
      _isLoading = true;
      notifyListeners();

      await _loginService.logout();
      _currentAccountHolder = null;
    } catch (e) {
      _error = e.toString();
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchCurrentAccountHolder() async {
    try {
      _isLoading = true;
      notifyListeners();

      final auth.FirebaseAuth _firebaseAuth = auth.FirebaseAuth.instance;
      final FirebaseFirestore _firestore = FirebaseFirestore.instance;

      final user = _firebaseAuth.currentUser;
      if (user != null) {
        String userId = user.uid;

        DocumentSnapshot userDoc =
            await _firestore.collection('users').doc(userId).get();
        DocumentSnapshot adminDoc =
            await _firestore.collection('administrators').doc(userId).get();

        if (userDoc.exists) {
          _currentAccountHolder = User.fromJson(userDoc.data() as Map<String, dynamic>);
        } else if (adminDoc.exists) {
          _currentAccountHolder = Administrator.fromJson(adminDoc.data() as Map<String, dynamic>);
        }
      }
    } catch (e) {
      _error = e.toString();
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}