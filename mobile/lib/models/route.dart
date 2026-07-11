import 'package:landmark_navigation_app/models/navigation_step.dart';

class RouteModel {
  const RouteModel({
    required this.id,
    required this.polyline,
    required this.totalDistanceM,
    required this.userId,
    required this.steps,
  });

  factory RouteModel.fromJson(Map<String, dynamic> json) {
    return RouteModel(
      id: json['route']['id'] as int,
      polyline: json['route']['polyline'] as String,
      totalDistanceM: json['route']['total_distance_m'] as int,
      userId: json['user_id'] as int,
      steps:
          (json['steps'] as List<dynamic>)
              .map((e) => NavigationStep.fromJson(e as Map<String, dynamic>))
              .toList(),
    );
  }

  final int id;
  final String polyline;
  final int totalDistanceM;
  final int userId;
  final List<NavigationStep> steps;
}
