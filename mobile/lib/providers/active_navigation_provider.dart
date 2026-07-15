import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:landmark_navigation_app/models/active_navigation_state.dart';
import 'package:landmark_navigation_app/providers/navigation_provider.dart';
import 'package:landmark_navigation_app/services/location_service.dart';
import 'package:landmark_navigation_app/utils/navigation_utils.dart';

class ActiveNavigationNotifier extends Notifier<ActiveNavigationState> {
  final _locationService = LocationService();
  StreamSubscription<LatLng>? _positionSubscription;
  int _offRouteStreak = 0;

  @override
  ActiveNavigationState build() {
    ref.onDispose(() => _positionSubscription?.cancel());
    return const ActiveNavigationState();
  }

  void start() {
    _positionSubscription = _locationService.positionStream().listen(
      _onPosition,
      onError: (_) => stop(),
    );
  }

  void stop() {
    _positionSubscription?.cancel();
    _positionSubscription = null;
  }

  void _onPosition(LatLng position) {
    final navState = ref.read(navigationProvider);
    final steps = navState.steps;
    if (steps == null || steps.isEmpty) return;

    final travelMode = navState.travelMode ?? 'WALK';
    final currentStep = steps[state.currentStepIndex];
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

    var stepIndex = state.currentStepIndex;
    var shownAt = state.stepShownAt;
    final isLastStep = stepIndex == steps.length - 1;
    final reachedStep = NavigationUtils.shouldAdvanceStep(
      position,
      currentStep,
      travelMode,
    );
    if (reachedStep && !isLastStep) {
      stepIndex++;
      final newShownAt = Map<int, DateTime>.from(shownAt);
      newShownAt[stepIndex] = DateTime.now();
      shownAt = newShownAt;
    }

    state = state.copyWith(
      currentStepIndex: stepIndex,
      distanceToManeuver: NavigationUtils.distanceToNextManeuver(
        position,
        steps[stepIndex],
      ),
      offRoute: _offRouteStreak >= 3,
      arrived: isLastStep && reachedStep,
      stepShownAt: shownAt,
    );
  }
}

final activeNavigationProvider =
    NotifierProvider<ActiveNavigationNotifier, ActiveNavigationState>(
      ActiveNavigationNotifier.new,
    );
