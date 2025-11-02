import 'package:flutter/foundation.dart';
import '../models/ride.dart';
import '../services/api_service.dart';

class RideProvider with ChangeNotifier {
  List<Ride> _availableRides = [];
  List<Ride> _userRides = [];
  Ride? _currentRide;
  bool _isLoading = false;

  List<Ride> get availableRides => _availableRides;
  List<Ride> get userRides => _userRides;
  Ride? get currentRide => _currentRide;
  bool get isLoading => _isLoading;

  Future<void> loadAvailableRides() async {
    _isLoading = true;
    notifyListeners();

    try {
      _availableRides = await ApiService.getAvailableRides();
      if (_availableRides.isEmpty) {
        _loadTestRides(); // Charger des données de test si vide
      }
    } catch (e) {
      if (kDebugMode) {
        print('Erreur chargement trajets: $e');
      }
      _loadTestRides(); // Charger des données de test en cas d'erreur
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> loadUserRides() async {
    _isLoading = true;
    notifyListeners();

    try {
      _userRides = await ApiService.getUserRides();
    } catch (e) {
      if (kDebugMode) {
        print('Erreur chargement trajets utilisateur: $e');
      }
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<bool> createRide(Ride ride) async {
    _isLoading = true;
    notifyListeners();

    try {
      final newRide = await ApiService.createRide(ride);
      if (newRide != null) {
        _currentRide = newRide;
        // Recharger les trajets disponibles
        await loadAvailableRides();
        _isLoading = false;
        notifyListeners();
        return true;
      }
    } catch (e) {
      if (kDebugMode) {
        print('Erreur création trajet: $e');
      }
    }

    _isLoading = false;
    notifyListeners();
    return false;
  }

  Future<bool> acceptRide(String rideId) async {
    try {
      final success = await ApiService.acceptRide(rideId);
      if (success) {
        // Retirer le trajet de la liste des disponibles
        _availableRides.removeWhere((ride) => ride.id == rideId);
        // Recharger les trajets de l'utilisateur
        await loadUserRides();
        notifyListeners();
        return true;
      }
    } catch (e) {
      if (kDebugMode) {
        print('Erreur acceptation trajet: $e');
      }
    }
    return false;
  }

  // Charger des données de test
  void _loadTestRides() {
    _availableRides = [
      Ride(
        id: '1',
        driverId: '2',
        startLocation:  LatLng(48.8566, 2.3522),
        endLocation:  LatLng(45.7640, 4.8357),
        startAddress: 'Paris, France',
        endAddress: 'Lyon, France',
        price: 25.50,
        status: 'pending',
        createdAt: DateTime.now(),
        distance: 450.0,
        duration: 240,
        driverName: 'Jean Dupont',
        driverRating: 4.5,
        vehicleType: 'Peugeot 308',
      ),
      Ride(
        id: '2',
        driverId: '3',
        startLocation:  LatLng(43.2965, 5.3698),
        endLocation:  LatLng(43.7102, 7.2620),
        startAddress: 'Marseille, France',
        endAddress: 'Nice, France',
        price: 18.00,
        status: 'pending',
        createdAt: DateTime.now(),
        distance: 200.0,
        duration: 120,
        driverName: 'Marie Martin',
        driverRating: 4.8,
        vehicleType: 'Renault Clio',
      ),
    ];
  }

  void setCurrentRide(Ride? ride) {
    _currentRide = ride;
    notifyListeners();
  }
}