// models/rating.dart
class Rating {
  final String id;
  final String rideId;
  final String fromUserId;
  final String toUserId;
  final String? fromUserName;
  final String? toUserName;
  final int rating; // 1-5
  final String? comment;
  final DateTime createdAt;

  Rating({
    required this.id,
    required this.rideId,
    required this.fromUserId,
    required this.toUserId,
    this.fromUserName,
    this.toUserName,
    required this.rating,
    this.comment,
    required this.createdAt,
  });

  factory Rating.fromJson(Map<String, dynamic> json) {
    return Rating(
      id: json['id']?.toString() ?? '',
      rideId: json['ride_id']?.toString() ?? '',
      fromUserId: json['from_user_id']?.toString() ?? '',
      toUserId: json['to_user_id']?.toString() ?? '',
      fromUserName: json['from_user_name']?.toString(),
      toUserName: json['to_user_name']?.toString(),
      rating: json['rating'] is int ? json['rating'] : int.tryParse(json['rating']?.toString() ?? '0') ?? 0,
      comment: json['comment']?.toString(),
      createdAt: DateTime.parse(json['created_at'] ?? DateTime.now().toIso8601String()),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'ride_id': rideId,
      'from_user_id': fromUserId,
      'to_user_id': toUserId,
      'rating': rating,
      'comment': comment,
      'created_at': createdAt.toIso8601String(),
    };
  }
}