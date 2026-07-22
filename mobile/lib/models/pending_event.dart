class PendingEvent {
  PendingEvent({
    this.sessionId,
    this.stepId,
    this.eventType,
    this.timestamp,
    this.reactionTimeMs,
    this.userLat,
    this.userLng,
    this.metadata,
  });

  final int? sessionId;
  final int? stepId;
  final String? eventType;
  final DateTime? timestamp;
  final int? reactionTimeMs;
  final double? userLat;
  final double? userLng;
  final Map<String, dynamic>? metadata;
  int attempts = 0;
}
