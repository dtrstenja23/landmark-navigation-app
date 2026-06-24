class Event {
  const Event({
    required this.id,
    this.sessionId,
    this.stepId,
    this.eventType,
    this.timestamp,
    this.reactionTimeMs,
    this.userLat,
    this.userLng,
    this.metadata,
  });

  factory Event.fromJson(Map<String, dynamic> json) {
    return Event(
      id: json['id'] as int,
      sessionId: json['session_id'] as int?,
      stepId: json['step_id'] as int?,
      eventType: json['event_type'] as String?,
      timestamp: json['timestamp'] != null
          ? DateTime.parse(json['timestamp'] as String)
          : null,
      reactionTimeMs: json['reaction_time_ms'] as int?,
      userLat: json['user_lat'] != null
          ? (json['user_lat'] as num).toDouble()
          : null,
      userLng: json['user_lng'] != null
          ? (json['user_lng'] as num).toDouble()
          : null,
      metadata: json['metadata'] as Map<String, dynamic>?,
    );
  }

  final int id;
  final int? sessionId;
  final int? stepId;
  final String? eventType;
  final DateTime? timestamp;
  final int? reactionTimeMs;
  final double? userLat;
  final double? userLng;
  final Map<String, dynamic>? metadata;
}
