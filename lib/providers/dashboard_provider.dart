import 'package:flutter/foundation.dart';
import 'package:foundita/services/dashboard_service.dart';

class DashboardProvider with ChangeNotifier {
  final AdminDashboardService _adminDashboardService;
  Map<String, Map<String, int>>? _monthlyStats;
  bool _isLoading = false;
  String? _error;

  DashboardProvider({required AdminDashboardService adminDashboardService})
      : _adminDashboardService = adminDashboardService;

  Map<String, Map<String, int>>? get monthlyStats => _monthlyStats;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> loadInitialStats() async {
    await refreshStats();
  }

  Future<void> refreshStats() async {
    _isLoading = true;
    _error = null; // Réinitialiser l'erreur avant de commencer
    notifyListeners();

    try {
      _monthlyStats = await _adminDashboardService.getMonthlyItemsCount();
      
      // Vérifier si les stats sont vides et définir un message d'erreur approprié
      if (_monthlyStats == null || _monthlyStats!.isEmpty) {
        _error = 'Aucune statistique disponible';
      } else {
        _error = null;
      }
    } catch (e) {
      _error = 'Échec du chargement des statistiques: ${e.toString()}';
      _monthlyStats = {};  // Initialiser à une map vide plutôt que null
      if (kDebugMode) {
        print('Error loading dashboard stats: $e');
      }
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}