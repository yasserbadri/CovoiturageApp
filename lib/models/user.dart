class User {
  final String id;
  final String name;
  final String email;
  final String? phone;
  final String userType;
  final double? rating;
  final int? totalRides;
  final String? vehicleType;
  final String? licensePlate;

  User({
    required this.id,
    required this.name,
    required this.email,
    this.phone,
    required this.userType,
    this.rating,
    this.totalRides,
    this.vehicleType,
    this.licensePlate,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    // Gestion sécurisée du rating qui peut être String ou double
    double? parseRating(dynamic ratingValue) {
      if (ratingValue == null) return null;
      if (ratingValue is double) return ratingValue;
      if (ratingValue is int) return ratingValue.toDouble();
      if (ratingValue is String) {
        return double.tryParse(ratingValue);
      }
      return null;
    }

    // Gestion sécurisée des autres champs
    return User(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      email: json['email']?.toString() ?? '',
      phone: json['phone']?.toString(),
      userType: json['user_type']?.toString() ?? 'client',
      rating: parseRating(json['rating']),
      totalRides: json['total_rides'] is int ? json['total_rides'] : (json['total_rides'] is String ? int.tryParse(json['total_rides']) : null),
      vehicleType: json['vehicle_type']?.toString(),
      licensePlate: json['license_plate']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'phone': phone,
      'user_type': userType,
      'rating': rating,
      'total_rides': totalRides,
      'vehicle_type': vehicleType,
      'license_plate': licensePlate,
    };
  }
}