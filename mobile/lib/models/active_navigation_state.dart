import 'package:google_maps_flutter/google_maps_flutter.dart';

class ActiveNavigationState {
  const ActiveNavigationState({
    this.currentPosition,
    this.currentStepIndex = 0,
    this.distanceToManeuver = 0,
    this.offRoute = false,
    this.arrived = false,
    this.stepShownAt = const {},
  });
  final LatLng? currentPosition;
  final int currentStepIndex;
  final double distanceToManeuver;
  final bool offRoute;
  final bool arrived;
  final Map<int, DateTime> stepShownAt;

  ActiveNavigationState copyWith({
    LatLng? currentPosition,
    int? currentStepIndex,
    double? distanceToManeuver,
    bool? offRoute,
    bool? arrived,
    Map<int, DateTime>? stepShownAt,
  }) {
    return ActiveNavigationState(
      currentPosition: currentPosition ?? this.currentPosition,
      currentStepIndex: currentStepIndex ?? this.currentStepIndex,
      distanceToManeuver: distanceToManeuver ?? this.distanceToManeuver,
      offRoute: offRoute ?? this.offRoute,
      arrived: arrived ?? this.arrived,
      stepShownAt: stepShownAt ?? this.stepShownAt,
    );
  }
}
