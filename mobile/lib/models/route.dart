class RouteModel {
  const RouteModel({
    required this.id,
    this.userId,
    required this.originLat,
    required this.originLng,
    required this.destLat,
    required this.destLng,
    this.polyline,
    this.totalDistanceM,
    this.createdAt,
  });

  factory RouteModel.fromJson(Map<String, dynamic> json) {
    return RouteModel(
      id: json['id'] as int,
      userId: json['user_id'] as int?,
      originLat: (json['origin_lat'] as num).toDouble(),
      originLng: (json['origin_lng'] as num).toDouble(),
      destLat: (json['dest_lat'] as num).toDouble(),
      destLng: (json['dest_lng'] as num).toDouble(),
      polyline: json['polyline'] as String?,
      totalDistanceM: json['total_distance_m'] as int?,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : null,
    );
  }

  final int id;
  final int? userId;
  final double originLat;
  final double originLng;
  final double destLat;
  final double destLng;
  final String? polyline;
  final int? totalDistanceM;
  final DateTime? createdAt;
}
