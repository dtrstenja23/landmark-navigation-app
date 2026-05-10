import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:landmark_navigation_app/services/directions_service.dart';
import 'package:landmark_navigation_app/services/location_service.dart';
import 'package:landmark_navigation_app/widgets/destination_bottom_panel.dart';
import 'package:landmark_navigation_app/widgets/search_box.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _locationService = LocationService();
  final _directionsService = DirectionsService();

  GoogleMapController? mapController;
  LatLng _center = const LatLng(45.8150, 15.9819);
  LatLng _userLocation = const LatLng(45.8150, 15.9819);
  LatLng? _selectedDestination;
  String? _selectedDestinationName;
  Set<Polyline> _polylines = {};

  @override
  void dispose() {
    mapController?.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _loadUserLocation();
  }

  void _onMapCreated(GoogleMapController controller) {
    setState(() => mapController = controller);
  }

  Future<void> _loadUserLocation() async {
    final location = await _locationService.loadUserLocation();
    if (location == null || !mounted) return;
    setState(() {
      _center = location;
      _userLocation = location;
    });
    mapController?.animateCamera(CameraUpdate.newLatLngZoom(location, 20.0));
  }

  Future<void> _fetchRoute() async {
    if (_selectedDestination == null) return;
    final result = await _directionsService.fetchRoute(_userLocation, _selectedDestination!);
    if (result == null || !mounted) return;
    setState(() {
      _polylines = {
        Polyline(
          polylineId: const PolylineId('route'),
          points: result.points,
          color: Colors.blue,
          width: 5,
        ),
      };
    });
    await mapController?.animateCamera(CameraUpdate.newLatLngBounds(result.bounds, 60));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Home'),
        backgroundColor: Theme.of(context).colorScheme.primary,
      ),
      body: Stack(
        children: [
          GoogleMap(
            onMapCreated: _onMapCreated,
            initialCameraPosition: CameraPosition(target: _center, zoom: 20.0),
            myLocationEnabled: true,
            myLocationButtonEnabled: false,
            polylines: _polylines,
          ),
          if (mapController != null)
            SearchBox(
              mapController: mapController,
              onDestinationSelected: (latLng, name) {
                setState(() {
                  _center = latLng;
                  _selectedDestination = latLng;
                  _selectedDestinationName = name;
                  _polylines = {};
                });
              },
            ),
          if (_selectedDestination != null)
            DestinationBottomPanel(
              destination: _selectedDestination!,
              destinationName: _selectedDestinationName!,
              onDirectionsPressed: _fetchRoute,
            ),
        ],
      ),
    );
  }
}
