import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:landmark_navigation_app/services/directions_service.dart';
import 'package:landmark_navigation_app/models/navigation_state.dart';

class NavigationNotifier extends Notifier<NavigationState> {
  final _directionsService = DirectionsService();

  @override
  NavigationState build() => const NavigationState();

  void setUserLocation(LatLng location) {
    state = NavigationState(
      userLocation: location,
      selectedDestination: state.selectedDestination,
      destinationName: state.destinationName,
      hasRoute: state.hasRoute,
      polylines: state.polylines,
      markers: state.markers,
      routeBounds: state.routeBounds,
    );
  }

  void selectDestination(LatLng latLng, String name) {
    state = NavigationState(
      userLocation: state.userLocation,
      selectedDestination: latLng,
      destinationName: name,
      hasRoute: false,
      polylines: {},
      markers: {
        Marker(
          markerId: const MarkerId('destination'),
          position: latLng,
          infoWindow: InfoWindow(title: name),
        ),
      },
    );
  }

  void clearDestination() {
    state = NavigationState(userLocation: state.userLocation);
  }

  Future<bool> fetchRoute() async {
    if (state.selectedDestination == null) return false;
    final result = await _directionsService.fetchRoute(
      state.userLocation,
      state.selectedDestination!,
    );
    if (result == null) return false;
    state = NavigationState(
      userLocation: state.userLocation,
      selectedDestination: state.selectedDestination,
      destinationName: state.destinationName,
      hasRoute: true,
      polylines: {
        Polyline(
          polylineId: const PolylineId('route'),
          points: result.points,
          color: Colors.blue,
          width: 5,
        ),
      },
      markers: state.markers,
      routeBounds: result.bounds,
    );
    return true;
  }
}

final navigationProvider =
    NotifierProvider<NavigationNotifier, NavigationState>(
      NavigationNotifier.new,
    );
