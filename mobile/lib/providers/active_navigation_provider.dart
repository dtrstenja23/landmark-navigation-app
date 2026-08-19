import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:landmark_navigation_app/models/active_navigation_state.dart';
import 'package:landmark_navigation_app/providers/navigation_provider.dart';
import 'package:landmark_navigation_app/providers/settings_provider.dart';
import 'package:landmark_navigation_app/services/event_logger.dart';
import 'package:landmark_navigation_app/services/location_service.dart';
import 'package:landmark_navigation_app/services/session_service.dart';
import 'package:landmark_navigation_app/services/tts_service.dart';
import 'package:landmark_navigation_app/utils/navigation_utils.dart';
import 'package:landmark_navigation_app/models/navigation_step.dart';

class ActiveNavigationNotifier extends Notifier<ActiveNavigationState> {
  static const _driveMilestones = [1000, 500, 200, 50];
  static const _walkMilestones = [300, 100, 25];

  final _locationService = LocationService();
  final _sessionService = SessionService();
  final _eventLogger = EventLogger();
  StreamSubscription<LatLng>? _positionSubscription;
  int _offRouteStreak = 0;
  bool _stopped = false;
  bool _sessionEnded = false;
  final _ttsService = TtsService();
  final Set<int> _triggeredMilestones = {};

  @override
  ActiveNavigationState build() {
    ref.onDispose(() {
      _positionSubscription?.cancel();
      _endSession();
      _eventLogger.dispose();
    });
    return const ActiveNavigationState();
  }

  void start({bool simulate = false, double speedKmh = 50.0}) {
    _stopped = false;
    _sessionEnded = false;
    _startSession();

    final navState = ref.read(navigationProvider);
    final steps = navState.steps;
    if (steps != null && steps.isNotEmpty) {
      final travelMode = navState.travelMode ?? 'WALK';
      _resetMilestones(steps[state.currentStepIndex], travelMode);
      _ttsService.speak(steps[state.currentStepIndex].instructionText);
    }

    final Stream<LatLng> stream;
    if (simulate && navState.polylines.isNotEmpty) {
      final points = navState.polylines.first.points;
      final speed = navState.travelMode == 'DRIVE' ? speedKmh : 15.0;
      stream = _locationService.simulatedPositionStream(
        points,
        speedKmh: speed,
      );
    } else {
      stream = _locationService.positionStream();
    }

    _positionSubscription = stream.listen(_onPosition, onError: (_) => stop());
  }

  void _resetMilestones(NavigationStep step, String travelMode) {
    _triggeredMilestones.clear();
    final milestones =
        travelMode == 'DRIVE' ? _driveMilestones : _walkMilestones;
    final initialDist = step.distanceM.toDouble();
    for (final m in milestones) {
      if (m >= initialDist - 50) {
        _triggeredMilestones.add(m);
      }
    }
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

    if (stepIndex < steps.length - 1) {
      final currentStep = steps[stepIndex];
      final reached = NavigationUtils.hasReachedStepEnd(
        position,
        currentStep,
        travelMode,
      );
      if (reached) {
        stepIndex++;
      }
    }
    if (stepIndex != state.currentStepIndex) {
      final now = DateTime.now();
      final newShownAt = Map<int, DateTime>.from(shownAt);
      newShownAt[stepIndex] = now;
      shownAt = newShownAt;

      _resetMilestones(steps[stepIndex], travelMode);
      _ttsService.speak(steps[stepIndex].instructionText);

      for (var i = state.currentStepIndex; i < stepIndex; i++) {
        final completedStep = steps[i];
        if (completedStep.maneuver == 'DEPART') continue;
        final shownAtStep = state.stepShownAt[i];
        _eventLogger.log(
          sessionId: state.sessionId,
          stepId: completedStep.id,
          eventType:
              completedStep.isLandmarkBased
                  ? 'landmark_shown'
                  : 'fallback_used',
          reactionTimeMs:
              shownAtStep != null
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
    final distanceToManeuver = NavigationUtils.distanceToStepEnd(
      position,
      newCurrentStep,
    );
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

    if (arrived) {
      _ttsService.speak('Stigli ste na odredište');
      _endSession();
    } else {
      final milestones =
          travelMode == 'DRIVE' ? _driveMilestones : _walkMilestones;
      for (final m in milestones) {
        if (distanceToManeuver <= m && !_triggeredMilestones.contains(m)) {
          _triggeredMilestones.add(m);
          final prompt = NavigationUtils.buildMilestonePrompt(
            newCurrentStep,
            m,
            ref.read(settingsProvider).mode,
          );
          if (prompt != null) {
            _ttsService.speak(prompt);
          }
          break;
        }
      }
    }
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
      final travelMode = newNavState.travelMode ?? 'WALK';
      _offRouteStreak = 0;
      _triggeredMilestones.clear();
      state = state.copyWith(
        currentStepIndex: startIndex,
        stepShownAt: {},
        offRoute: false,
      );
      if (steps.isNotEmpty) {
        _resetMilestones(steps[startIndex], travelMode);
        _ttsService.speak(steps[startIndex].instructionText);
      }
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
