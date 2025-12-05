import 'package:flutter/foundation.dart';
import '../services/api_service.dart';
import '../models/ride.dart';

class NotificationProvider with ChangeNotifier {
  List<Ride> _userRides = []; 
  bool _hasNewNotification = false;

  List<Ride> get userRides => _userRides;
  bool get hasNewNotification => _hasNewNotification;

  Future<void> checkForAcceptedRides() async {
    try {
      final allRides = await ApiService.getUserRides();
      
      final newAcceptedRides = allRides.where((ride) => 
          ride.status == 'accepted' && 
          !_userRides.any((r) => r.id == ride.id && r.status == 'accepted')
      ).toList();

      if (newAcceptedRides.isNotEmpty) {
        _hasNewNotification = true;
      }

      _userRides = allRides;
      notifyListeners();
      
    } catch (e) {
      print('Erreur vérification trajets: $e');
    }
  }

  List<Ride> get acceptedRides => _userRides.where((ride) => ride.status == 'accepted').toList();
  List<Ride> get inProgressRides => _userRides.where((ride) => ride.status == 'in_progress').toList();
  List<Ride> get completedRides => _userRides.where((ride) => ride.status == 'completed').toList();
  List<Ride> get cancelledRides => _userRides.where((ride) => ride.status == 'cancelled').toList();

  void clearNotifications() {
    _hasNewNotification = false;
    notifyListeners();
  }

  void markRideAsSeen(String rideId) {
    _hasNewNotification = false;
    notifyListeners();
  }

  Future<void> loadUserRides() async {
    try {
      _userRides = await ApiService.getUserRides();
      notifyListeners();
    } catch (e) {
      print('Erreur chargement trajets utilisateur: $e');
    }
  }
}