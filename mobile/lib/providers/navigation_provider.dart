import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_google_places_sdk/flutter_google_places_sdk.dart' hide LatLng;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:landmark_navigation_app/services/directions_service.dart';
import 'package:landmark_navigation_app/models/navigation_state.dart';

class NavigationNotifier extends Notifier<NavigationState> {
  final _directionsService = DirectionsService();
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
