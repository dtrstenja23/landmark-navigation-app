import 'package:google_maps_flutter/google_maps_flutter.dart';

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
