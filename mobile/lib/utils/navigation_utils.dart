import 'dart:math' as math;
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:landmark_navigation_app/models/navigation_step.dart';

class NavigationUtils {
  static const double _earthRadiusM = 6371000;
  static const double _metersPerDegLat = _earthRadiusM * math.pi / 180;

  static const double _advanceThresholdWalkM = 20;
  static const double _advanceThresholdDriveM = 30;
  static const double _offRouteThresholdWalkM = 35;
  static const double _offRouteThresholdDriveM = 50;

  static double distanceToPolyline(LatLng position, List<LatLng> polyline) {
    if (polyline.isEmpty) return double.infinity;
    if (polyline.length == 1) {
      return _distanceToSegment(position, polyline.first, polyline.first);
    }

    var minDistance = double.infinity;
    for (var i = 0; i < polyline.length - 1; i++) {
      final distance = _distanceToSegment(
        position,
        polyline[i],
        polyline[i + 1],
      );
      if (distance < minDistance) minDistance = distance;
    }
    return minDistance;
  }

  static double _distanceToSegment(LatLng point, LatLng start, LatLng end) {
    final metersPerDegLng = _metersPerDegLng(start.latitude);

    double toX(LatLng p) => (p.longitude - start.longitude) * metersPerDegLng;
    double toY(LatLng p) => (p.latitude - start.latitude) * _metersPerDegLat;

    final px = toX(point);
    final py = toY(point);
    final ex = toX(end);
    final ey = toY(end);

    final segLengthSq = ex * ex + ey * ey;
    if (segLengthSq == 0) {
      return math.sqrt(px * px + py * py);
    }

    final t = ((px * ex + py * ey) / segLengthSq).clamp(0.0, 1.0);
    final dx = px - t * ex;
    final dy = py - t * ey;
    return math.sqrt(dx * dx + dy * dy);
  }

  static double _metersPerDegLng(double latDeg) {
    return _metersPerDegLat * math.cos(latDeg * math.pi / 180);
  }

  static double distanceToNextManeuver(LatLng position, NavigationStep step) {
    final maneuverPoint = LatLng(step.startLat, step.startLng);
    return _distanceToSegment(position, maneuverPoint, maneuverPoint);
  }

  static bool shouldAdvanceStep(
    LatLng position,
    NavigationStep step,
    String travelMode,
  ) {
    final threshold =
        travelMode == 'DRIVE'
            ? _advanceThresholdDriveM
            : _advanceThresholdWalkM;
    return distanceToNextManeuver(position, step) <= threshold;
  }

  static bool isOffRoute(
    LatLng position,
    List<LatLng> polyline,
    String travelMode,
  ) {
    final threshold =
        travelMode == 'DRIVE'
            ? _offRouteThresholdDriveM
            : _offRouteThresholdWalkM;
    return distanceToPolyline(position, polyline) > threshold;
  }
}
