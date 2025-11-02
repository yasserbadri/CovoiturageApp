class Ride {
  final String id;
  final String driverId;
  final String? passengerId;
  final LatLng startLocation;
  final LatLng endLocation;
  final String startAddress;
  final String endAddress;
  final double price;
  final String status;
  final DateTime createdAt;
  final DateTime? startedAt;
  final DateTime? completedAt;
  final double? distance;
  final int? duration;
  final String? driverName;
  final double? driverRating;
  final String? vehicleType;

  Ride({
    required this.id,
    required this.driverId,
    this.passengerId,
    required this.startLocation,
    required this.endLocation,
    required this.startAddress,
    required this.endAddress,
    required this.price,
    required this.status,
    required this.createdAt,
    this.startedAt,
    this.completedAt,
    this.distance,
    this.duration,
    this.driverName,
    this.driverRating,
    this.vehicleType,
  });

  factory Ride.fromJson(Map<String, dynamic> json) {
  double? safeParseDouble(dynamic value) {
    if (value == null) return null;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) return double.tryParse(value);
    return null;
  }

  int? safeParseInt(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    if (value is String) return int.tryParse(value);
    return null;
  }

  DateTime? safeParseDateTime(dynamic value) {
    if (value == null) return null;
    if (value is DateTime) return value;
    if (value is String) return DateTime.tryParse(value);
    return null;
  }

  return Ride(
    id: json['id']?.toString() ?? '',
    driverId: json['driver_id']?.toString() ?? '',
    passengerId: json['passenger_id']?.toString(),
    startLocation: LatLng(
      safeParseDouble(json['start_lat']) ?? 0.0,
      safeParseDouble(json['start_lng']) ?? 0.0,
    ),
    endLocation: LatLng(
      safeParseDouble(json['end_lat']) ?? 0.0,
      safeParseDouble(json['end_lng']) ?? 0.0,
    ),
    startAddress: json['start_address']?.toString() ?? '',
    endAddress: json['end_address']?.toString() ?? '',
    price: safeParseDouble(json['price']) ?? 0.0,
    status: json['status']?.toString() ?? 'pending',
    createdAt: safeParseDateTime(json['created_at']) ?? DateTime.now(),
    startedAt: safeParseDateTime(json['started_at']),
    completedAt: safeParseDateTime(json['completed_at']),
    distance: safeParseDouble(json['distance']),
    duration: safeParseInt(json['duration']),
    driverName: json['driver_name']?.toString(),
    driverRating: safeParseDouble(json['driver_rating']),
    vehicleType: json['vehicle_type']?.toString(),
  );
}
}

class LatLng {
  final double latitude;
  final double longitude;

  LatLng(this.latitude, this.longitude);
}