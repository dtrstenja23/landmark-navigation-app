class Landmark {
  const Landmark({
    required this.id,
    required this.name,
    required this.lat,
    required this.lng,
    this.type,
    this.googlePlaceId,
    this.verified = false,
    this.source,
  });

  factory Landmark.fromJson(Map<String, dynamic> json) {
    return Landmark(
      id: json['id'] as int,
      name: json['name'] as String,
      lat: (json['lat'] as num).toDouble(),
      lng: (json['lng'] as num).toDouble(),
      type: json['type'] as String?,
      googlePlaceId: json['google_place_id'] as String?,
      verified: json['verified'] as bool? ?? false,
      source: json['source'] as String?,
    );
  }

  final int id;
  final String name;
  final double lat;
  final double lng;
  final String? type;
  final String? googlePlaceId;
  final bool verified;
  final String? source;
}
