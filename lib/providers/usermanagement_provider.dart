import 'package:flutter/foundation.dart';
import 'package:foundita/models/user.dart';
import 'package:foundita/services/usermanagement_service.dart';

class UserManagementProvider with ChangeNotifier {
  final UserManagementService _userManagementService;
  List<User> _users = [];
  bool _isLoading = false;
  String? _error;
  
  UserManagementProvider({required UserManagementService userManagementService})
      : _userManagementService = userManagementService {
    loadUsers();
  }
  
  List<User> get users => _users;
  bool get isLoading => _isLoading;
  String? get error => _error;
  
  Future<void> banUser(String userId) async {
    try {
      _isLoading = true;
      notifyListeners();
      
      await _userManagementService.banUser(userId);
      final index = _users.indexWhere((user) => user.userId == userId);
      if (index != -1) {
        _users[index] = User(
          userId: _users[index].userId,
          name: _users[index].name,
          email: _users[index].email,
          authMethod: _users[index].authMethod,
          password: _users[index].password,
          phoneNumber: _users[index].phoneNumber,
          notificationIds: _users[index].notificationIds,
          isBanned: true,
          postIds: _users[index].postIds,
          chatIds: _users[index].chatIds,
        );
      }
    } catch (e) {
      _error = e.toString();
      print('Erreur de bannissement: $_error');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
  
  Future<void> unbanUser(String userId) async {
    try {
      _isLoading = true;
      notifyListeners();
      
      await _userManagementService.unbanUser(userId);
      final index = _users.indexWhere((user) => user.userId == userId);
      if (index != -1) {
        _users[index] = User(
          userId: _users[index].userId,
          name: _users[index].name,
          email: _users[index].email,
          authMethod: _users[index].authMethod,
          password: _users[index].password,
          phoneNumber: _users[index].phoneNumber,
          notificationIds: _users[index].notificationIds,
          isBanned: false,
          postIds: _users[index].postIds,
          chatIds: _users[index].chatIds,
        );
      }
    } catch (e) {
      _error = e.toString();
      print('Erreur de réactivation: $_error');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
  
  Future<void> loadUsers() async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();
      
      _users = await _userManagementService.getAllUsers();
      print('Utilisateurs chargés: ${_users.length}');
    } catch (e) {
      _error = e.toString();
      print('Erreur de chargement: $_error');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
  
  Future<User?> getUserById(String userId) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();
      
      final user = await _userManagementService.getUserById(userId);
      return user;
    } catch (e) {
      _error = e.toString();
      print('Erreur lors de la récupération d\'un utilisateur: $_error');
      return null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
  
  Future<List<User>> searchUsers(String query) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();
      
      final results = await _userManagementService.searchUsers(query);
      return results;
    } catch (e) {
      _error = e.toString();
      print('Erreur de recherche: $_error');
      return [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}