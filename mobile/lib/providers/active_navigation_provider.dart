import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:landmark_navigation_app/models/active_navigation_state.dart';
import 'package:landmark_navigation_app/providers/navigation_provider.dart';
import 'package:landmark_navigation_app/providers/settings_provider.dart';
import 'package:landmark_navigation_app/services/event_logger.dart';
import 'package:landmark_navigation_app/services/location_service.dart';
import 'package:landmark_navigation_app/services/session_service.dart';
import 'package:landmark_navigation_app/utils/navigation_utils.dart';

class ActiveNavigationNotifier extends Notifier<ActiveNavigationState> {
  static const _stepLookahead = 3;

  final _locationService = LocationService();
  final _sessionService = SessionService();
  final _eventLogger = EventLogger();
  StreamSubscription<LatLng>? _positionSubscription;
  int _offRouteStreak = 0;
  bool _stopped = false;
  bool _sessionEnded = false;

  @override
  ActiveNavigationState build() {
    ref.onDispose(() {
      _positionSubscription?.cancel();
      _endSession();
      _eventLogger.dispose();
    });
    return const ActiveNavigationState();
  }

  void start() {
    _stopped = false;
    _sessionEnded = false;
    _startSession();
    _positionSubscription = _locationService.positionStream().listen(
      _onPosition,
      onError: (_) => stop(),
    );
  }

  void stop() {
    _stopped = true;
    _positionSubscription?.cancel();
    _positionSubscription = null;
    _endSession();
    _eventLogger.dispose();
  }

  Future<void> _startSession() async {
    final navState = ref.read(navigationProvider);
    final userId = navState.userId;
    final routeId = navState.routeId;
    if (userId == null || routeId == null) return;
    try {
      final session = await _sessionService.createSession(
        userId: userId,
        routeId: routeId,
        mode: ref.read(settingsProvider).mode,
      );
      state = state.copyWith(sessionId: session.id);
    } catch (_) {}
  }

  void _endSession() {
    final sessionId = state.sessionId;
    if (_sessionEnded || sessionId == null) return;
    _sessionEnded = true;
    _finishSession(sessionId);
  }

  Future<void> _finishSession(int sessionId) async {
    try {
      await _sessionService.updateSession(sessionId, endedAt: DateTime.now());
    } catch (_) {}
  }

  void _onPosition(LatLng position) {
    final navState = ref.read(navigationProvider);
    final steps = navState.steps;
    if (steps == null || steps.isEmpty) return;

    final travelMode = navState.travelMode ?? 'WALK';
    final polylinePoints =
        navState.polylines.isEmpty
            ? <LatLng>[]
            : navState.polylines.first.points;

    final isOffRoute = NavigationUtils.isOffRoute(
      position,
      polylinePoints,
      travelMode,
    );
    _offRouteStreak = isOffRoute ? _offRouteStreak + 1 : 0;

    if (_offRouteStreak >= 3 && !navState.isFetchingRoute) {
      state = state.copyWith(offRoute: true);
      _eventLogger.log(
        sessionId: state.sessionId,
        stepId: steps[state.currentStepIndex].id,
        eventType: 'missed_turn',
        userLat: position.latitude,
        userLng: position.longitude,
      );
      _reroute(position);
      return;
    }

    var stepIndex = state.currentStepIndex;
    var shownAt = state.stepShownAt;

    final lookaheadEnd =
        stepIndex + _stepLookahead < steps.length - 1
            ? stepIndex + _stepLookahead
            : steps.length - 1;
    for (var i = stepIndex; i < lookaheadEnd; i++) {
      final step = steps[i];
      final reached =
          step.maneuver == 'DEPART'
              ? NavigationUtils.hasReachedStepEnd(position, step, travelMode)
              : NavigationUtils.shouldAdvanceStep(position, step, travelMode);
      if (reached) stepIndex = i + 1;
    }
    if (stepIndex != state.currentStepIndex) {
      final now = DateTime.now();
      final newShownAt = Map<int, DateTime>.from(shownAt);
      newShownAt[stepIndex] = now;
      shownAt = newShownAt;

      for (var i = state.currentStepIndex; i < stepIndex; i++) {
        final completedStep = steps[i];
        if (completedStep.maneuver == 'DEPART') continue;
        final shownAtStep = state.stepShownAt[i];
        _eventLogger.log(
          sessionId: state.sessionId,
          stepId: completedStep.id,
          eventType: completedStep.isLandmarkBased
              ? 'landmark_shown'
              : 'fallback_used',
          reactionTimeMs: shownAtStep != null
              ? _positiveMillis(now.difference(shownAtStep))
              : null,
          metadata: {
            'completed': true,
            'travel_mode': travelMode,
            'mode': ref.read(settingsProvider).mode,
          },
        );
      }
    }

    final isLastStep = stepIndex == steps.length - 1;
    final newCurrentStep = steps[stepIndex];
    final newTargetsEnd = isLastStep || newCurrentStep.maneuver == 'DEPART';
    final distanceToManeuver =
        newTargetsEnd
            ? NavigationUtils.distanceToStepEnd(position, newCurrentStep)
            : NavigationUtils.distanceToNextManeuver(position, newCurrentStep);
    final arrived =
        isLastStep &&
        NavigationUtils.hasReachedStepEnd(position, newCurrentStep, travelMode);

    state = state.copyWith(
      currentPosition: position,
      currentStepIndex: stepIndex,
      distanceToManeuver: distanceToManeuver,
      offRoute: _offRouteStreak >= 3,
      arrived: arrived,
      stepShownAt: shownAt,
    );

    if (arrived) _endSession();
  }

  Future<void> _reroute(LatLng position) async {
    final notifier = ref.read(navigationProvider.notifier);
    notifier.setUserLocation(position);
    final success = await notifier.fetchRoute();

    if (success && !_stopped) {
      final newNavState = ref.read(navigationProvider);
      final steps = newNavState.steps ?? [];
      final startIndex =
          steps.length > 1 && steps.first.maneuver == 'DEPART' ? 1 : 0;
      _offRouteStreak = 0;
      state = state.copyWith(
        currentStepIndex: startIndex,
        stepShownAt: {},
        offRoute: false,
      );
      _eventLogger.log(
        sessionId: state.sessionId,
        eventType: 'reroute_triggered',
        metadata: {'new_route_id': newNavState.routeId},
      );
    }
  }
}

final activeNavigationProvider =
    NotifierProvider<ActiveNavigationNotifier, ActiveNavigationState>(
      ActiveNavigationNotifier.new,
    );

int _positiveMillis(Duration duration) {
  final ms = duration.inMilliseconds;
  return ms < 0 ? 0 : ms;
}
