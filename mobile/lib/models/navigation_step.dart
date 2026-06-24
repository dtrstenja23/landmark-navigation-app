class NavigationStep {
  const NavigationStep({
    required this.id,
    this.routeId,
    required this.stepIndex,
    required this.instructionText,
    this.distanceM,
    this.landmarkId,
    this.isLandmarkBased = false,
  });

  factory NavigationStep.fromJson(Map<String, dynamic> json) {
    return NavigationStep(
      id: json['id'] as int,
      routeId: json['route_id'] as int?,
      stepIndex: json['step_index'] as int,
      instructionText: json['instruction_text'] as String,
      distanceM: json['distance_m'] as int?,
      landmarkId: json['landmark_id'] as int?,
      isLandmarkBased: json['is_landmark_based'] as bool? ?? false,
    );
  }

  final int id;
  final int? routeId;
  final int stepIndex;
  final String instructionText;
  final int? distanceM;
  final int? landmarkId;
  final bool isLandmarkBased;
}
