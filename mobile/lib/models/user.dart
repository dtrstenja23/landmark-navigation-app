class User {
  const User({
    required this.id,
    required this.deviceId,
    this.preferredMode,
    this.consentResearch = false,
    this.createdAt,
    this.updatedAt,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] as int,
      deviceId: json['device_id'] as String,
      preferredMode: json['preferred_mode'] as String?,
      consentResearch: json['consent_research'] as bool? ?? false,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'] as String)
          : null,
    );
  }

  final int id;
  final String deviceId;
  final String? preferredMode;
  final bool consentResearch;
  final DateTime? createdAt;
  final DateTime? updatedAt;
}
