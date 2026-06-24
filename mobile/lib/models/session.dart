class Session {
  const Session({
    required this.id,
    this.userId,
    this.routeId,
    this.startedAt,
    this.endedAt,
    this.mode,
  });

  factory Session.fromJson(Map<String, dynamic> json) {
    return Session(
      id: json['id'] as int,
      userId: json['user_id'] as int?,
      routeId: json['route_id'] as int?,
      startedAt: json['started_at'] != null
          ? DateTime.parse(json['started_at'] as String)
          : null,
      endedAt: json['ended_at'] != null
          ? DateTime.parse(json['ended_at'] as String)
          : null,
      mode: json['mode'] as String?,
    );
  }

  final int id;
  final int? userId;
  final int? routeId;
  final DateTime? startedAt;
  final DateTime? endedAt;
  final String? mode;
}
