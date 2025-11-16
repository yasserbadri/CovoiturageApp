import 'package:flutter/foundation.dart';
import '../models/user.dart';
import '../services/api_service.dart';

class AuthProvider with ChangeNotifier {
  User? _user;
  String? _token;
  bool _isLoading = false;

  User? get user => _user;
  String? get token => _token;
  bool get isLoading => _isLoading;
  String get userType => _user?.userType ?? 'client';
  bool get isLoggedIn => _user != null && _token != null;

  Future<bool> login(String email, String password) async {
    _isLoading = true;
    notifyListeners();

    try {
      final result = await ApiService.login(email, password);
      if (result != null) {
        _user = result['user'] as User;
        _token = result['token'] as String;
        _isLoading = false;
        notifyListeners();
        return true;
      }
    } catch (e) {
      if (kDebugMode) {
        print('Erreur login: $e');
      }
    }

    _isLoading = false;
    notifyListeners();
    return false;
  }

  Future<bool> register(String name, String email, String password, String userType) async {
    _isLoading = true;
    notifyListeners();

    try {
      final result = await ApiService.register(name, email, password, userType);
      if (result != null) {
        _user = result['user'] as User;
        _token = result['token'] as String;
        _isLoading = false;
        notifyListeners();
        return true;
      }
    } catch (e) {
      if (kDebugMode) {
        print('Erreur register: $e');
      }
    }

    _isLoading = false;
    notifyListeners();
    return false;
  }

  Future<void> logout() async {
    await ApiService.logout();
    _user = null;
    _token = null;
    notifyListeners();
  }

  // CORRECTION : Utiliser getCurrentUser() au lieu de _getToken()
  Future<void> loadCurrentUser() async {
    _isLoading = true;
    notifyListeners();

    try {
      // Essayer de récupérer l'utilisateur depuis l'API
      final user = await ApiService.getCurrentUser();
      if (user != null) {
        _user = user;
        // Le token est géré automatiquement par ApiService via SharedPreferences
        // On peut essayer de le récupérer si nécessaire avec une méthode publique
      } else {
        // Si l'API ne retourne rien, déconnecter l'utilisateur
        await logout();
      }
    } catch (e) {
      print('Erreur chargement utilisateur: $e');
      // En cas d'erreur, déconnecter pour être sûr
      await logout();
    }

    _isLoading = false;
    notifyListeners();
  }

  // Méthode pour initialiser l'authentification au démarrage de l'app
  Future<void> initialize() async {
    try {
      // Vérifier si un token existe et est valide
      final user = await ApiService.getCurrentUser();
      if (user != null) {
        _user = user;
        // Le token est stocké dans SharedPreferences et géré par ApiService
        notifyListeners();
      }
    } catch (e) {
      print('Erreur initialisation auth: $e');
    }
  }
}