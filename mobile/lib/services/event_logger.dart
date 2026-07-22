import 'dart:async';
import 'package:landmark_navigation_app/models/pending_event.dart';
import 'package:landmark_navigation_app/services/event_service.dart';

class EventLogger {
  static const _flushInterval = Duration(seconds: 10);
  static const _batchSize = 5;

  final _eventService = EventService();
  final _queue = <PendingEvent>[];
  Timer? _flushTimer;
  Future<void> _flushChain = Future.value();

  void log({
    int? sessionId,
    int? stepId,
    String? eventType,
    int? reactionTimeMs,
    double? userLat,
    double? userLng,
    Map<String, dynamic>? metadata,
  }) {
    _queue.add(
      PendingEvent(
        sessionId: sessionId,
        stepId: stepId,
        eventType: eventType,
        timestamp: DateTime.now(),
        reactionTimeMs: reactionTimeMs,
        userLat: userLat,
        userLng: userLng,
        metadata: metadata,
      ),
    );

    _flushTimer ??= Timer.periodic(_flushInterval, (_) => flush());
    if (_queue.length >= _batchSize) flush();
  }

  Future<void> flush() {
    final next = _flushChain.then((_) => _flushOnce());
    _flushChain = next;
    return next;
  }

  Future<void> _flushOnce() async {
    if (_queue.isEmpty) return;

    final batch = List<PendingEvent>.from(_queue);
    _queue.clear();

    for (final event in batch) {
      try {
        await _eventService.createEvent(
          sessionId: event.sessionId,
          stepId: event.stepId,
          eventType: event.eventType,
          timestamp: event.timestamp,
          reactionTimeMs: event.reactionTimeMs,
          userLat: event.userLat,
          userLng: event.userLng,
          metadata: event.metadata,
        );
      } catch (_) {
        if (event.attempts < 1) {
          event.attempts++;
          _queue.add(event);
        }
      }
    }
  }

  Future<void> dispose() async {
    _flushTimer?.cancel();
    _flushTimer = null;
    while (_queue.isNotEmpty) {
      await flush();
    }
  }
}
