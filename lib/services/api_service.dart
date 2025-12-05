import 'dart:convert';
import 'package:covoituragesite/models/rating.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user.dart';
import '../models/ride.dart';

class ApiService {
  static const String baseUrl = 'http://localhost:3000/api';

  // Méthode : Gestion centralisée des réponses
  static dynamic _handleResponse(http.Response response) {
    print(' Status: ${response.statusCode}');
    print(' Response: ${response.body}');

    if (response.statusCode >= 200 && response.statusCode < 300) {
      if (response.body.isEmpty) return true; // Pour les réponses sans contenu
      return jsonDecode(response.body);
    } else {
      print(' Erreur HTTP: ${response.statusCode}');
      return null;
    }
  }

  // CORRECTION: Une seule définition de _getToken
  static Future<String?> _getToken() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString('auth_token');
    } catch (e) {
      print(' Erreur récupération token: $e');
      return null;
    }
  }

  static Future<void> _saveToken(String token) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('auth_token', token);
    } catch (e) {
      print(' Erreur sauvegarde token: $e');
    }
  }

  static Future<void> _removeToken() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('auth_token');
    } catch (e) {
      print(' Erreur suppression token: $e');
    }
  }

  // Headers communs
  static Future<Map<String, String>> _getHeaders() async {
    final token = await _getToken();
    final headers = {'Content-Type': 'application/json'};
    if (token != null) {
      headers['Authorization'] = 'Bearer $token';
    }
    return headers;
  }

  // Authentification
  static Future<Map<String, dynamic>?> login(String email, String password) async {
    try {
      print(' Tentative de connexion: $email');
      
      final response = await http.post(
        Uri.parse('$baseUrl/auth/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': email.trim(),
          'password': password,
        }),
      );

      final data = _handleResponse(response);
      if (data != null) {
        await _saveToken(data['token']);
        print(' Connexion réussie!');
        return {
          'user': User.fromJson(data['user']),
          'token': data['token'],
        };
      }
      return null;
    } catch (e) {
      print(' Erreur de connexion: $e');
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
      print(' Tentative d\'inscription: $email en tant que $userType');

      final Map<String, dynamic> body = {
        'name': name,
        'email': email,
        'password': password,
        'user_type': userType,
      };

      if (phone != null && phone.isNotEmpty) {
        body['phone'] = phone;
      }

      if (userType == 'chauffeur') {
        if (vehicleType != null && vehicleType.isNotEmpty) {
          body['vehicle_type'] = vehicleType;
        }
        if (licensePlate != null && licensePlate.isNotEmpty) {
          body['license_plate'] = licensePlate;
        }
      }

      print(' Body envoyé: $body');

      final response = await http.post(
        Uri.parse('$baseUrl/auth/register'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(body),
      );

      print(' Status: ${response.statusCode}');
      print(' Response: ${response.body}');

      if (response.statusCode == 201 || response.statusCode == 200) {
        final data = jsonDecode(response.body);
        await _saveToken(data['token']);
        print(' Inscription réussie pour $userType');
        return {
          'user': User.fromJson(data['user']),
          'token': data['token'],
        };
      } else {
        print(' Erreur HTTP: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      print(' Erreur d\'inscription: $e');
      return null;
    }
  }

  static Future<void> logout() async {
    await _removeToken();
    print(' Déconnexion réussie');
  }

  // Récupérer les trajets disponibles
  static Future<List<Ride>> getAvailableRides() async {
    try {
      print(' Récupération des trajets disponibles...');
      
      final response = await http.get(
        Uri.parse('$baseUrl/rides/available'),
        headers: await _getHeaders(),
      );

      final data = _handleResponse(response);
      if (data != null && data['rides'] != null) {
        final rides = (data['rides'] as List).map((ride) => Ride.fromJson(ride)).toList();
        print(' ${rides.length} trajets récupérés');
        return rides;
      }
      return [];
    } catch (e) {
      print(' Erreur récupération trajets: $e');
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
      print(' Backend non accessible: $e');
      return false;
    }
  }

  // Méthode pour créer un trajet
  static Future<Ride?> createRide(Ride ride) async {
    try {
      print(' Création d\'un trajet...');
      
      final response = await http.post(
        Uri.parse('$baseUrl/rides'),
        headers: await _getHeaders(),
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

      final data = _handleResponse(response);
      if (data != null && data['ride'] != null) {
        print(' Trajet créé avec succès');
        return Ride.fromJson(data['ride']);
      }
      return null;
    } catch (e) {
      print(' Erreur création trajet: $e');
      return null;
    }
  }

  // Méthode pour accepter un trajet
  static Future<bool> acceptRide(String rideId) async {
    try {
      print(' Acceptation du trajet $rideId...');
      
      final response = await http.post(
        Uri.parse('$baseUrl/rides/$rideId/accept'),
        headers: await _getHeaders(),
      );

      final data = _handleResponse(response);
      if (data != null) {
        print(' Trajet accepté avec succès');
        return true;
      }
      return false;
    } catch (e) {
      print(' Erreur acceptation trajet: $e');
      return false;
    }
  }

  // Méthode pour récupérer les trajets de l'utilisateur
  static Future<List<Ride>> getUserRides() async {
    try {
      print(' Récupération des trajets utilisateur...');
      
      final response = await http.get(
        Uri.parse('$baseUrl/rides/my-rides'),
        headers: await _getHeaders(),
      );

      final data = _handleResponse(response);
      if (data != null && data['rides'] != null) {
        final rides = (data['rides'] as List).map((ride) => Ride.fromJson(ride)).toList();
        print(' ${rides.length} trajets utilisateur récupérés');
        return rides;
      }
      return [];
    } catch (e) {
      print(' Erreur récupération trajets utilisateur: $e');
      return [];
    }
  }

  // Mettre à jour le statut d'un trajet
  static Future<bool> updateRideStatus(String rideId, String status) async {
    try {
      print(' Mise à jour du statut du trajet $rideId: $status');
      
      final response = await http.patch(
        Uri.parse('$baseUrl/rides/$rideId/status'),
        headers: await _getHeaders(),
        body: jsonEncode({'status': status}),
      );

      final data = _handleResponse(response);
      if (data != null) {
        print(' Statut mis à jour: $status');
        return true;
      }
      return false;
    } catch (e) {
      print(' Erreur mise à jour statut: $e');
      return false;
    }
  }

  // Récupérer l'utilisateur courant
  static Future<User?> getCurrentUser() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/auth/me'),
        headers: await _getHeaders(),
      );

      final data = _handleResponse(response);
      if (data != null && data['user'] != null) {
        return User.fromJson(data['user']);
      }
      return null;
    } catch (e) {
      print(' Erreur récupération utilisateur: $e');
      return null;
    }
  }

  static Future<bool> createRating(String rideId, int rating, String? comment) async {
    try {
      print(' Création d\'une notation pour le trajet $rideId...');
      
      final response = await http.post(
        Uri.parse('$baseUrl/ratings'),
        headers: await _getHeaders(),
        body: jsonEncode({
          'ride_id': rideId,
          'rating': rating,
          'comment': comment,
        }),
      );

      final data = _handleResponse(response);
      if (data != null) {
        print(' Notation créée avec succès');
        return true;
      }
      return false;
    } catch (e) {
      print(' Erreur création notation: $e');
      return false;
    }
  }

  static Future<List<Rating>> getUserRatings() async {
    try {
      print(' Récupération des notations utilisateur...');
      
      final response = await http.get(
        Uri.parse('$baseUrl/ratings/my-ratings'),
        headers: await _getHeaders(),
      );

      final data = _handleResponse(response);
      if (data != null && data['ratings'] != null) {
        final ratings = (data['ratings'] as List).map((rating) => Rating.fromJson(rating)).toList();
        print(' ${ratings.length} notations récupérées');
        return ratings;
      }
      return [];
    } catch (e) {
      print(' Erreur récupération notations: $e');
      return [];
    }
  }

  static Future<bool> updateProfile({
    required String name,
    required String email,
    required String phone,
    String? vehicleType,
    String? licensePlate,
  }) async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/auth/profile'),
        headers: await _getHeaders(),
        body: jsonEncode({
          'name': name,
          'email': email,
          'phone': phone,
          'vehicle_type': vehicleType,
          'license_plate': licensePlate,
        }),
      );

      final data = _handleResponse(response);
      return data != null;
    } catch (e) {
      print(' Erreur mise à jour profil: $e');
      return false;
    }
  }

  static Future<bool> uploadProfileImage(String imagePath) async {
    try {
      var request = http.MultipartRequest('POST', Uri.parse('$baseUrl/auth/upload-profile-image'));
      request.headers['Authorization'] = 'Bearer ${await _getToken()}';
      
      request.files.add(await http.MultipartFile.fromPath('image', imagePath));
      
      var response = await request.send();
      return response.statusCode == 200;
    } catch (e) {
      print(' Erreur upload image: $e');
      return false;
    }
  }
}