class ActiveNavigationState {
  const ActiveNavigationState({
    this.currentStepIndex = 0,
    this.distanceToManeuver = 0,
    this.offRoute = false,
    this.arrived = false,
    this.stepShownAt = const {},
  });
  final int currentStepIndex;
  final double distanceToManeuver;
  final bool offRoute;
  final bool arrived;
  final Map<int, DateTime> stepShownAt;

  ActiveNavigationState copyWith({
    int? currentStepIndex,
    double? distanceToManeuver,
    bool? offRoute,
    bool? arrived,
    Map<int, DateTime>? stepShownAt,
  }) {
    return ActiveNavigationState(
      currentStepIndex: currentStepIndex ?? this.currentStepIndex,
      distanceToManeuver: distanceToManeuver ?? this.distanceToManeuver,
      offRoute: offRoute ?? this.offRoute,
      arrived: arrived ?? this.arrived,
      stepShownAt: stepShownAt ?? this.stepShownAt,
    );
  }
}
