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

  // Méthode temporaire - à implémenter plus tard dans ApiService
  Future<void> loadCurrentUser() async {
    try {
      // Pour l'instant, on simule un utilisateur
      _user = User(
        id: '1',
        name: 'Utilisateur Test',
        email: 'test@example.com',
        userType: 'client',
        rating: 4.5,
        totalRides: 10,
      );
      notifyListeners();
    } catch (e) {
      if (kDebugMode) {
        print('Erreur chargement utilisateur: $e');
      }
    }
  }
}