// providers/rating_provider.dart
import 'package:flutter/foundation.dart';
import '../models/rating.dart';
import '../services/api_service.dart';

class RatingProvider with ChangeNotifier {
  List<Rating> _userRatings = [];
  bool _isLoading = false;

  List<Rating> get userRatings => _userRatings;
  bool get isLoading => _isLoading;

  Future<void> loadUserRatings() async {
    _isLoading = true;
    notifyListeners();

    try {
      _userRatings = await ApiService.getUserRatings();
    } catch (e) {
      print('Erreur chargement notations: $e');
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<bool> createRating(String rideId, int rating, String? comment) async {
    try {
      final success = await ApiService.createRating(rideId, rating, comment);
      if (success) {
        // Recharger les notations après création
        await loadUserRatings();
        return true;
      }
      return false;
    } catch (e) {
      print('Erreur création notation: $e');
      return false;
    }
  }

  // Calculer la note moyenne
  double get averageRating {
    if (_userRatings.isEmpty) return 0.0;
    final total = _userRatings.fold(0, (sum, rating) => sum + rating.rating);
    return total / _userRatings.length;
  }

  // Obtenir les notations récentes
  List<Rating> get recentRatings {
    return _userRatings.take(5).toList();
  }
}