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
    return Ride(
      id: json['id'].toString(),
      driverId: json['driver_id'].toString(),
      passengerId: json['passenger_id']?.toString(),
      startLocation: LatLng(
        json['start_lat']?.toDouble() ?? 0.0,
        json['start_lng']?.toDouble() ?? 0.0,
      ),
      endLocation: LatLng(
        json['end_lat']?.toDouble() ?? 0.0,
        json['end_lng']?.toDouble() ?? 0.0,
      ),
      startAddress: json['start_address'] ?? '',
      endAddress: json['end_address'] ?? '',
      price: json['price']?.toDouble() ?? 0.0,
      status: json['status'] ?? 'pending',
      createdAt: DateTime.parse(json['created_at'] ?? DateTime.now().toIso8601String()),
      startedAt: json['started_at'] != null ? DateTime.parse(json['started_at']) : null,
      completedAt: json['completed_at'] != null ? DateTime.parse(json['completed_at']) : null,
      distance: json['distance']?.toDouble(),
      duration: json['duration'],
      driverName: json['driver_name'],
      driverRating: json['driver_rating']?.toDouble(),
      vehicleType: json['vehicle_type'],
    );
  }
}

class LatLng {
  final double latitude;
  final double longitude;

  LatLng(this.latitude, this.longitude);
}