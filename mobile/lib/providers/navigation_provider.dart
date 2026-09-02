import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_google_places_sdk/flutter_google_places_sdk.dart'
    hide LatLng, LatLngBounds;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:landmark_navigation_app/models/navigation_state.dart';
import 'package:landmark_navigation_app/providers/settings_provider.dart';
import 'package:landmark_navigation_app/services/device_identity_service.dart';
import 'package:landmark_navigation_app/services/route_generation_service.dart';
import 'package:landmark_navigation_app/utils/polyline_utils.dart';

class NavigationNotifier extends Notifier<NavigationState> {
  final _routeGenerationService = RouteGenerationService();
  final _deviceIdentityService = DeviceIdentityService();
  late final FlutterGooglePlacesSdk _placesClient;

  @override
  NavigationState build() {
    _placesClient = FlutterGooglePlacesSdk(dotenv.env['GOOGLE_MAPS_API_KEY']!);
    return const NavigationState();
  }

  Future<void> selectPrediction(AutocompletePrediction prediction) async {
    final placeDetails = await _placesClient.fetchPlace(
      prediction.placeId,
      fields: [PlaceField.Location, PlaceField.Name],
    );
    final lat = placeDetails.place?.latLng?.lat;
    final lng = placeDetails.place?.latLng?.lng;
    if (lat != null && lng != null) {
      selectDestination(LatLng(lat, lng), placeDetails.place?.name ?? '');
    }
  }

  void setUserLocation(LatLng location) {
    if (!state.isCustomOrigin) {
      state = state.copyWith(userLocation: location);
    }
  }

  void setTravelMode(String travelMode) {
    state = state.copyWith(
      travelMode: travelMode,
      hasRoute: false,
      polylines: {},
    );
  }

  void selectCustomOrigin(LatLng latLng, String name) {
    final markers = Set<Marker>.from(state.markers);
    markers.removeWhere((m) => m.markerId.value == 'origin');
    markers.add(
      Marker(
        markerId: const MarkerId('origin'),
        position: latLng,
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
        anchor: const Offset(0.5, 1.0),
        infoWindow: InfoWindow(title: name),
      ),
    );

    state = state.copyWith(
      userLocation: latLng,
      originName: name,
      isCustomOrigin: true,
      hasRoute: false,
      polylines: {},
      markers: markers,
    );
  }

  void resetToGpsOrigin(LatLng gpsLocation) {
    final markers = Set<Marker>.from(state.markers);
    markers.removeWhere((m) => m.markerId.value == 'origin');

    state = state.copyWith(
      userLocation: gpsLocation,
      clearOriginName: true,
      isCustomOrigin: false,
      hasRoute: false,
      polylines: {},
      markers: markers,
    );
  }

  void selectDestination(LatLng latLng, String name) {
    final markers = Set<Marker>.from(state.markers);
    markers.removeWhere((m) => m.markerId.value == 'destination');
    markers.add(
      Marker(
        markerId: const MarkerId('destination'),
        position: latLng,
        anchor: const Offset(0.5, 1.0),
        infoWindow: InfoWindow(title: name),
      ),
    );

    state = state.copyWith(
      selectedDestination: latLng,
      destinationName: name,
      hasRoute: false,
      polylines: {},
      markers: markers,
    );
  }

  void clearDestination() {
    final markers = Set<Marker>.from(state.markers);
    markers.removeWhere((m) => m.markerId.value == 'destination');

    state = NavigationState(
      userLocation: state.userLocation,
      originName: state.originName,
      isCustomOrigin: state.isCustomOrigin,
      markers: markers,
    );
  }

  Future<bool> fetchRoute() async {
    if (state.selectedDestination == null) return false;

    state = state.copyWith(isFetchingRoute: true);
    try {
      final deviceId = await _deviceIdentityService.getDeviceId();
      final route = await _routeGenerationService.generateRoute(
        deviceId: deviceId,
        origin: state.userLocation,
        destination: state.selectedDestination!,
        travelMode: state.travelMode ?? 'WALK',
        mode: ref.read(settingsProvider).mode,
      );

      final points = PolylineUtils.decode(route.polyline);

      state = state.copyWith(
        hasRoute: true,
        polylines: {
          Polyline(
            polylineId: const PolylineId('route'),
            points: points,
            color: Colors.blue,
            width: 5,
          ),
        },
        routeBounds: _boundsFromPoints(points),
        steps: route.steps,
        totalDistanceM: route.totalDistanceM,
        totalDurationS: route.totalDurationS,
        routeId: route.id,
        userId: route.userId,
      );
      return true;
    } catch (_) {
      return false;
    } finally {
      state = state.copyWith(isFetchingRoute: false);
    }
  }
}

LatLngBounds _boundsFromPoints(List<LatLng> points) {
  var minLat = points.first.latitude;
  var maxLat = points.first.latitude;
  var minLng = points.first.longitude;
  var maxLng = points.first.longitude;

  for (final point in points) {
    if (point.latitude < minLat) minLat = point.latitude;
    if (point.latitude > maxLat) maxLat = point.latitude;
    if (point.longitude < minLng) minLng = point.longitude;
    if (point.longitude > maxLng) maxLng = point.longitude;
  }

  return LatLngBounds(
    southwest: LatLng(minLat, minLng),
    northeast: LatLng(maxLat, maxLng),
  );
}

final navigationProvider =
    NotifierProvider<NavigationNotifier, NavigationState>(
      NavigationNotifier.new,
    );
