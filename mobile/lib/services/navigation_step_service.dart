import 'package:landmark_navigation_app/models/navigation_step.dart';
import 'package:landmark_navigation_app/services/api_client.dart';

class NavigationStepService {
  final ApiClient _client = ApiClient();

  Future<NavigationStep> createNavigationStep({
    int? routeId,
    required int stepIndex,
    required String instructionText,
    int? distanceM,
    int? landmarkId,
    bool? isLandmarkBased,
  }) async {
    final body = await _client.postJson('/navigation-steps', {
      if (routeId != null) 'route_id': routeId,
      'step_index': stepIndex,
      'instruction_text': instructionText,
      if (distanceM != null) 'distance_m': distanceM,
      if (landmarkId != null) 'landmark_id': landmarkId,
      if (isLandmarkBased != null) 'is_landmark_based': isLandmarkBased,
    });
    return NavigationStep.fromJson(body['data'] as Map<String, dynamic>);
  }

  Future<List<NavigationStep>> getNavigationSteps() async {
    final body = await _client.getJson('/navigation-steps');
    return (body['data'] as List<dynamic>)
        .map((e) => NavigationStep.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<NavigationStep> getNavigationStep(int id) async {
    final body = await _client.getJson('/navigation-steps/$id');
    return NavigationStep.fromJson(body['data'] as Map<String, dynamic>);
  }

  Future<NavigationStep> updateNavigationStep(
    int id, {
    int? routeId,
    int? stepIndex,
    String? instructionText,
    int? distanceM,
    int? landmarkId,
    bool? isLandmarkBased,
  }) async {
    final body = await _client.patchJson('/navigation-steps/$id', {
      if (routeId != null) 'route_id': routeId,
      if (stepIndex != null) 'step_index': stepIndex,
      if (instructionText != null) 'instruction_text': instructionText,
      if (distanceM != null) 'distance_m': distanceM,
      if (landmarkId != null) 'landmark_id': landmarkId,
      if (isLandmarkBased != null) 'is_landmark_based': isLandmarkBased,
    });
    return NavigationStep.fromJson(body['data'] as Map<String, dynamic>);
  }

  Future<void> deleteNavigationStep(int id) async {
    await _client.deleteJson('/navigation-steps/$id');
  }
}
