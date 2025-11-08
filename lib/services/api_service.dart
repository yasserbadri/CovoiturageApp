import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user.dart';
import '../models/ride.dart';

class ApiService {
  static const String baseUrl = 'http://localhost:3000/api';

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

  static Future<Map<String, dynamic>?> register(
  String name,
  String email,
  String password,
  String userType, {
  String? phone,
  String? vehicleType,
  String? licensePlate,
}) async {
  try {
    print('🔄 Tentative d\'inscription: $email en tant que $userType');

    // Préparer le corps JSON dynamiquement selon le rôle
    final Map<String, dynamic> body = {
      'name': name,
      'email': email,
      'password': password,
      'user_type': userType,
    };

    if (phone != null && phone.isNotEmpty) body['phone'] = phone;
    if (userType == 'chauffeur') {
      if (vehicleType != null && vehicleType.isNotEmpty) {
        body['vehicle_type'] = vehicleType;
      }
      if (licensePlate != null && licensePlate.isNotEmpty) {
        body['license_plate'] = licensePlate;
      }
    }

    final response = await http.post(
      Uri.parse('$baseUrl/auth/register'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(body),
    );

    print('📡 Status: ${response.statusCode}');
    print('📦 Response: ${response.body}');

    if (response.statusCode == 201 || response.statusCode == 200) {
      final data = jsonDecode(response.body);
      await _saveToken(data['token']);
      print('✅ Inscription réussie pour $userType');
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

  // Méthodes temporaires pour le développement
static Future<User?> getCurrentUser() async {
  // Simulation - à remplacer par un vrai appel API plus tard
  await Future.delayed(const Duration(seconds: 1));
  return User(
    id: '1',
    name: 'Utilisateur Test',
    email: 'test@example.com',
    userType: 'client',
    rating: 4.5,
    totalRides: 10,
  );
}

// Méthode pour créer un trajet
static Future<Ride?> createRide(Ride ride) async {
  final token = await _getToken();
  try {
    print('🔄 Création d\'un trajet...');
    
    final response = await http.post(
      Uri.parse('$baseUrl/rides'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({
        'start_lat': ride.startLocation.latitude,
        'start_lng': ride.startLocation.longitude,
        'end_lat': ride.endLocation.latitude,
        'end_lng': ride.endLocation.longitude,
        'start_address': ride.startAddress,
        'end_address': ride.endAddress,
        'price': ride.price,
        'distance': ride.distance,
        'duration': ride.duration,
      }),
    );

    print('📡 Status création: ${response.statusCode}');
    print('📦 Response création: ${response.body}');

    if (response.statusCode == 201) {
      final data = jsonDecode(response.body);
      print('✅ Trajet créé avec succès');
      return Ride.fromJson(data['ride']);
    }
    return null;
  } catch (e) {
    print('❌ Erreur création trajet: $e');
    return null;
  }
}

// Méthode pour accepter un trajet
static Future<bool> acceptRide(String rideId) async {
  final token = await _getToken();
  try {
    print('🔄 Acceptation du trajet $rideId...');
    
    final response = await http.post(
      Uri.parse('$baseUrl/rides/$rideId/accept'),
      headers: {'Authorization': 'Bearer $token'},
    );

    print('📡 Status acceptation: ${response.statusCode}');

    if (response.statusCode == 200) {
      print('✅ Trajet accepté avec succès');
      return true;
    }
    return false;
  } catch (e) {
    print('❌ Erreur acceptation trajet: $e');
    return false;
  }
}

// Méthode pour récupérer les trajets de l'utilisateur
static Future<List<Ride>> getUserRides() async {
  final token = await _getToken();
  try {
    print('🔄 Récupération des trajets utilisateur...');
    
    final response = await http.get(
      Uri.parse('$baseUrl/rides/my-rides'),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final rides = (data['rides'] as List).map((ride) => Ride.fromJson(ride)).toList();
      
      print('✅ ${rides.length} trajets utilisateur récupérés');
      return rides;
    }
    return [];
  } catch (e) {
    print('❌ Erreur récupération trajets utilisateur: $e');
    return [];
  }
}
}