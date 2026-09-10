import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:landmark_navigation_app/utils/navigation_utils.dart';

class LocationService {
  Future<LatLng?> loadUserLocation() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) return null;

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) return null;
    }
    if (permission == LocationPermission.deniedForever) return null;

    final position = await Geolocator.getCurrentPosition();
    return LatLng(position.latitude, position.longitude);
  }

  Stream<LatLng> positionStream() {
    return Geolocator.getPositionStream(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.best,
        distanceFilter: 5,
      ),
    ).map((position) => LatLng(position.latitude, position.longitude));
  }

  Stream<LatLng> simulatedPositionStream(
    List<LatLng> polylinePoints, {
    double speedKmh = 50.0,
    int tickIntervalMs = 250,
  }) async* {
    if (polylinePoints.isEmpty) return;
    if (polylinePoints.length == 1) {
      yield polylinePoints.first;
      return;
    }

    final speedMs = speedKmh * 1000 / 3600;
    final stepDistMeters = speedMs * (tickIntervalMs / 1000);

    final interpolatedPath = <LatLng>[polylinePoints.first];

    for (var i = 0; i < polylinePoints.length - 1; i++) {
      final p1 = polylinePoints[i];
      final p2 = polylinePoints[i + 1];
      final dist = NavigationUtils.distanceBetween(p1, p2);

      if (dist <= stepDistMeters) {
        interpolatedPath.add(p2);
      } else {
        final count = (dist / stepDistMeters).ceil();
        for (var j = 1; j <= count; j++) {
          final fraction = j / count;
          final lat = p1.latitude + (p2.latitude - p1.latitude) * fraction;
          final lng = p1.longitude + (p2.longitude - p1.longitude) * fraction;
          interpolatedPath.add(LatLng(lat, lng));
        }
      }
    }

    for (final point in interpolatedPath) {
      yield point;
      await Future.delayed(Duration(milliseconds: tickIntervalMs));
    }
  }
}
