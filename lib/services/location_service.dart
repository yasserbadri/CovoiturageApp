import 'package:http/http.dart' as http;
import 'dart:convert';
import '../models/ride.dart';

class LocationService {
  // Utiliser l'API OpenRouteService pour calculer l'itinéraire
  static Future<Map<String, dynamic>?> calculateRoute(
      String startAddress, String endAddress) async {
    try {
      // Géocodage des adresses (simplifié - en production, utiliser un service de géocodage)
      final startCoords = await _geocodeAddress(startAddress);
      final endCoords = await _geocodeAddress(endAddress);

      if (startCoords == null || endCoords == null) {
        return null;
      }

      // Calcul de la distance et durée avec une API de routage
      final response = await http.get(
        Uri.parse(
          'https://router.project-osrm.org/route/v1/driving/'
          '${startCoords['lng']},${startCoords['lat']};'
          '${endCoords['lng']},${endCoords['lat']}?overview=false',
        ),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['code'] == 'Ok' && data['routes'].isNotEmpty) {
          final route = data['routes'][0];
          final distance = route['distance'] / 1000; // Convertir en km
          final duration = (route['duration'] / 60).round(); // Convertir en minutes

          return {
            'distance': distance,
            'duration': duration,
            'startLat': startCoords['lat'],
            'startLng': startCoords['lng'],
            'endLat': endCoords['lat'],
            'endLng': endCoords['lng'],
            'success': true,
          };
        }
      }
    } catch (e) {
      print('Erreur calcul itinéraire: $e');
    }

    return null;
  }

  // Géocodage simplifié (en production, utiliser Google Maps Geocoding ou autre)
  static Future<Map<String, double>?> _geocodeAddress(String address) async {
    // Pour la démo, on utilise des coordonnées fixes selon l'adresse
    final addressLower = address.toLowerCase();
    
    if (addressLower.contains('tunis') || addressLower.contains('ghazela')) {
      return {'lat': 36.8065, 'lng': 10.1815}; // Tunis
    } else if (addressLower.contains('ariana')) {
      return {'lat': 36.8625, 'lng': 10.1956}; // Ariana
    } else if (addressLower.contains('sidi bou said') || addressLower.contains('sidi bousaid')) {
      return {'lat': 36.8720, 'lng': 10.3410}; // Sidi Bou Said
    } else if (addressLower.contains('lac')) {
      return {'lat': 36.8381, 'lng': 10.2407}; // Lac
    } else if (addressLower.contains('marsa')) {
      return {'lat': 36.8762, 'lng': 10.3243}; // Marsa
    } else if (addressLower.contains('carthage')) {
      return {'lat': 36.8540, 'lng': 10.3300}; // Carthage
    }
    
    // Coordonnées par défaut (Tunis centre)
    return {'lat': 36.8065, 'lng': 10.1815};
  }

  // Calcul du prix basé sur la distance
  static double calculatePrice(double distance, int duration) {
    const double basePrice = 2.0;
    const double pricePerKm = 0.5;
    const double pricePerMinute = 0.1;
    
    return basePrice + (distance * pricePerKm) + (duration * pricePerMinute);
  }
}