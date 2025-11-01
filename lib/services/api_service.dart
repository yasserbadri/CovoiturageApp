import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user.dart';
import '../models/ride.dart';

class ApiService {
  // IMPORTANT: Utilisez la bonne URL selon votre plateforme
  //static const String baseUrl = 'http://10.0.2.2:3000/api'; // Android Emulator
  // static const String baseUrl = 'http://127.0.0.1:3000/api'; // iOS Simulator
   static const String baseUrl = 'http://localhost:3000/api'; // Web

  static Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('auth_token');
  }

  static Future<void> _saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('auth_token', token);
  }

  static Future<void> _removeToken() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('auth_token');
  }

  // Authentification
  static Future<Map<String, dynamic>?> login(String email, String password) async {
    try {
      print('🔄 Tentative de connexion: $email');
      
      final response = await http.post(
        Uri.parse('$baseUrl/auth/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': email,
          'password': password,
        }),
      );

      print('📡 Status: ${response.statusCode}');
      print('📦 Response: ${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        await _saveToken(data['token']);
        
        print('✅ Connexion réussie! Token sauvegardé');
        return {
          'user': User.fromJson(data['user']),
          'token': data['token'],
        };
      } else {
        print('❌ Erreur HTTP: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      print('❌ Erreur de connexion: $e');
      return null;
    }
  }

  static Future<Map<String, dynamic>?> register(String name, String email, String password, String userType) async {
    try {
      print('🔄 Tentative d\'inscription: $email');
      
      final response = await http.post(
        Uri.parse('$baseUrl/auth/register'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'name': name,
          'email': email,
          'password': password,
          'user_type': userType,
        }),
      );

      print('📡 Status: ${response.statusCode}');
      print('📦 Response: ${response.body}');

      if (response.statusCode == 201) {
        final data = jsonDecode(response.body);
        await _saveToken(data['token']);
        
        print('✅ Inscription réussie!');
        return {
          'user': User.fromJson(data['user']),
          'token': data['token'],
        };
      } else {
        print('❌ Erreur HTTP: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      print('❌ Erreur d\'inscription: $e');
      return null;
    }
  }

  static Future<void> logout() async {
    await _removeToken();
    print('✅ Déconnexion réussie');
  }

  // Récupérer les trajets disponibles
  static Future<List<Ride>> getAvailableRides() async {
    final token = await _getToken();
    try {
      print('🔄 Récupération des trajets disponibles...');
      
      final response = await http.get(
        Uri.parse('$baseUrl/rides/available'),
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final rides = (data['rides'] as List).map((ride) => Ride.fromJson(ride)).toList();
        
        print('✅ ${rides.length} trajets récupérés');
        return rides;
      }
      return [];
    } catch (e) {
      print('❌ Erreur récupération trajets: $e');
      return [];
    }
  }

  // Vérifier la connexion
  static Future<bool> checkConnection() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/health'),
        headers: {'Content-Type': 'application/json'},
      );
      return response.statusCode == 200;
    } catch (e) {
      print('❌ Backend non accessible: $e');
      return false;
    }
  }
}