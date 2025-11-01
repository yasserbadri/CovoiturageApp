class Rating {
  final String id;
  final String rideId;
  final String fromUserId;
  final String toUserId;
  final int rating; // 1-5
  final String? comment;
  final DateTime createdAt;

  Rating({
    required this.id,
    required this.rideId,
    required this.fromUserId,
    required this.toUserId,
    required this.rating,
    this.comment,
    required this.createdAt,
  });

  factory Rating.fromJson(Map<String, dynamic> json) {
    return Rating(
      id: json['id'] ?? '',
      rideId: json['ride_id'] ?? '',
      fromUserId: json['from_user_id'] ?? '',
      toUserId: json['to_user_id'] ?? '',
      rating: json['rating'] ?? 0,
      comment: json['comment'],
      createdAt: DateTime.parse(json['created_at']),
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