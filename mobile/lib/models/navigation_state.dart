import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:landmark_navigation_app/models/navigation_step.dart';

class NavigationState {
  const NavigationState({
    this.userLocation = const LatLng(45.8150, 15.9819),
    this.selectedDestination,
    this.destinationName,
    this.hasRoute = false,
    this.polylines = const {},
    this.markers = const {},
    this.routeBounds,
    this.travelMode,
    this.steps,
    this.isFetchingRoute = false,
    this.totalDistanceM,
    this.totalDurationS,
  });

  final LatLng userLocation;
  final LatLng? selectedDestination;
  final String? destinationName;
  final bool hasRoute;
  final Set<Polyline> polylines;
  final Set<Marker> markers;
  final LatLngBounds? routeBounds;
  final String? travelMode;
  final List<NavigationStep>? steps;
  final bool isFetchingRoute;
  final int? totalDistanceM;
  final int? totalDurationS;

  NavigationState copyWith({
    LatLng? userLocation,
    LatLng? selectedDestination,
    String? destinationName,
    bool? hasRoute,
    Set<Polyline>? polylines,
    Set<Marker>? markers,
    LatLngBounds? routeBounds,
    String? travelMode,
    List<NavigationStep>? steps,
    bool? isFetchingRoute,
    int? totalDistanceM,
    int? totalDurationS,
  }) {
    return NavigationState(
      userLocation: userLocation ?? this.userLocation,
      selectedDestination: selectedDestination ?? this.selectedDestination,
      destinationName: destinationName ?? this.destinationName,
      hasRoute: hasRoute ?? this.hasRoute,
      polylines: polylines ?? this.polylines,
      markers: markers ?? this.markers,
      routeBounds: routeBounds ?? this.routeBounds,
      travelMode: travelMode ?? this.travelMode,
      steps: steps ?? this.steps,
      isFetchingRoute: isFetchingRoute ?? this.isFetchingRoute,
      totalDistanceM: totalDistanceM ?? this.totalDistanceM,
      totalDurationS: totalDurationS ?? this.totalDurationS,
    );
  }
}
