import 'package:flutter/foundation.dart';
import 'package:foundita/models/user.dart' as foundita_user;
import 'package:foundita/services/register_service.dart';

class RegisterProvider with ChangeNotifier {
  final RegisterService _regService;
  foundita_user.User? _currentUser;
  bool _isLoading = false;
  String? _error;

  RegisterProvider({required RegisterService regService}) : _regService = regService;

  foundita_user.User? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> registerWithEmailAndPassword({
    required String name,
    required String email,
    required String password,
    required String phoneNumber,
  }) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      await _regService.registerWithEmailAndPassword(
        name: name,
        email: email,
        password: password,
        phoneNumber: phoneNumber,
      );

      await fetchCurrentUser();
    } catch (e) {
      _error = e.toString();
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchCurrentUser() async {
    try {
      _isLoading = true;
      notifyListeners();

      _currentUser = await _regService.getCurrentUser();
    } catch (e) {
      _error = e.toString();
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  
}