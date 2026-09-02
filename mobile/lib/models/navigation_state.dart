import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:landmark_navigation_app/models/navigation_step.dart';

class NavigationState {
  const NavigationState({
    this.userLocation = const LatLng(45.8150, 15.9819),
    this.originName,
    this.isCustomOrigin = false,
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
    this.routeId,
    this.userId,
  });

  final LatLng userLocation;
  final String? originName;
  final bool isCustomOrigin;
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
  final int? routeId;
  final int? userId;

  NavigationState copyWith({
    LatLng? userLocation,
    String? originName,
    bool clearOriginName = false,
    bool? isCustomOrigin,
    LatLng? selectedDestination,
    String? destinationName,
    bool clearDestination = false,
    bool? hasRoute,
    Set<Polyline>? polylines,
    Set<Marker>? markers,
    LatLngBounds? routeBounds,
    String? travelMode,
    List<NavigationStep>? steps,
    bool? isFetchingRoute,
    int? totalDistanceM,
    int? totalDurationS,
    int? routeId,
    int? userId,
  }) {
    return NavigationState(
      userLocation: userLocation ?? this.userLocation,
      originName: clearOriginName ? null : (originName ?? this.originName),
      isCustomOrigin: isCustomOrigin ?? this.isCustomOrigin,
      selectedDestination:
          clearDestination
              ? null
              : (selectedDestination ?? this.selectedDestination),
      destinationName:
          clearDestination ? null : (destinationName ?? this.destinationName),
      hasRoute: hasRoute ?? this.hasRoute,
      polylines: polylines ?? this.polylines,
      markers: markers ?? this.markers,
      routeBounds: routeBounds ?? this.routeBounds,
      travelMode: travelMode ?? this.travelMode,
      steps: steps ?? this.steps,
      isFetchingRoute: isFetchingRoute ?? this.isFetchingRoute,
      totalDistanceM: totalDistanceM ?? this.totalDistanceM,
      totalDurationS: totalDurationS ?? this.totalDurationS,
      routeId: routeId ?? this.routeId,
      userId: userId ?? this.userId,
    );
  }
}
