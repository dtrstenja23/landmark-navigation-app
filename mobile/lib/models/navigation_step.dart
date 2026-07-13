class NavigationStep {
  const NavigationStep({
    required this.id,
    required this.stepIndex,
    required this.instructionText,
    required this.distanceM,
    required this.maneuver,
    required this.startLat,
    required this.startLng,
    required this.endLat,
    required this.endLng,
    required this.isLandmarkBased,
    this.landmarkName,
  });

  factory NavigationStep.fromJson(Map<String, dynamic> json) {
    final landmark = json['landmark'] as Map<String, dynamic>?;
    return NavigationStep(
      id: json['id'] as int,
      stepIndex: json['step_index'] as int,
      instructionText: json['instruction_text'] as String,
      distanceM: json['distance_m'] as int,
      maneuver: json['maneuver'] as String,
      startLat: (json['start_lat'] as num).toDouble(),
      startLng: (json['start_lng'] as num).toDouble(),
      endLat: (json['end_lat'] as num).toDouble(),
      endLng: (json['end_lng'] as num).toDouble(),
      isLandmarkBased: json['is_landmark_based'] as bool,
      landmarkName: landmark?['name'] as String?,
    );
  }

  final int id;
  final int stepIndex;
  final String instructionText;
  final int distanceM;
  final String maneuver;
  final double startLat;
  final double startLng;
  final double endLat;
  final double endLng;
  final bool isLandmarkBased;
  final String? landmarkName;
}
