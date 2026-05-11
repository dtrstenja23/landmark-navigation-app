import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:landmark_navigation_app/services/directions_service.dart';

class NavigationState {
  const NavigationState({
    this.userLocation = const LatLng(45.8150, 15.9819),
    this.selectedDestination,
    this.destinationName,
    this.hasRoute = false,
    this.polylines = const {},
    this.markers = const {},
    this.routeBounds,
  });

  final LatLng userLocation;
  final LatLng? selectedDestination;
  final String? destinationName;
  final bool hasRoute;
  final Set<Polyline> polylines;
  final Set<Marker> markers;
  final LatLngBounds? routeBounds;
}

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
