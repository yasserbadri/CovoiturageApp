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

  Future<void> loadCurrentUser() async {
    _isLoading = true;
    notifyListeners();

    try {
      final user = await ApiService.getCurrentUser();
      if (user != null) {
        _user = user;
        
      } else {
        await logout();
      }
    } catch (e) {
      print('Erreur chargement utilisateur: $e');
      await logout();
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> initialize() async {
    try {
      final user = await ApiService.getCurrentUser();
      if (user != null) {
        _user = user;
        notifyListeners();
      }
    } catch (e) {
      print('Erreur initialisation auth: $e');
    }
  }
}