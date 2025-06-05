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
  }) async
  {
    try {
      _setLoading(true);
      _currentAccountHolder = await _loginService.loginWithEmailAndPassword(
        email: email,
        password: password,
      );
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
      _currentAccountHolder = await _loginService.loginWithGoogle();
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
      _currentAccountHolder = await _loginService.loginWithFacebook();
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
      _currentAccountHolder = null;
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
          final userData = userDoc.data() as Map<String, dynamic>;
          if (userData['isBanned'] == true) {
            await _firebaseAuth.signOut();
            throw Exception('Votre compte a été suspendu. Contactez le support.');
          }
          _currentAccountHolder = User.fromJson(userData);
        } else if (adminDoc.exists) {
          // Pas de vérification de ban pour les administrateurs
          _currentAccountHolder = Administrator.fromJson(adminDoc.data() as Map<String, dynamic>);
        }
      }
    } catch (e) {
      _handleError(e);
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
    _error = e.toString();
    notifyListeners();
  }
}