import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:landmark_navigation_app/widgets/search_box.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  GoogleMapController? mapController;
  bool _locationLoaded = false;
  LatLng _center = const LatLng(45.8150, 15.9819); // Zagreb
  LatLng? _selectedDestination;
  String? _selectedDestinationName;

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
    setState(() {
      mapController = controller;
    });
    if (_locationLoaded) {
      controller.animateCamera(CameraUpdate.newLatLngZoom(_center, 20.0));
    }
  }

  Future<void> _loadUserLocation() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return;
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return;
      }
    }
    if (permission == LocationPermission.deniedForever) {
      return;
    }

    Position position = await Geolocator.getCurrentPosition();
    final userLatLng = LatLng(position.latitude, position.longitude);
    mapController?.animateCamera(CameraUpdate.newLatLng(userLatLng));
    setState(() {
      _locationLoaded = true;
      _center = userLatLng;
    });
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
          ),
          if (mapController != null)
            SearchBox(
              mapController: mapController,
              onDestinationSelected: (latLng, name) {
                setState(() {
                  _center = latLng;
                  _selectedDestination = latLng;
                  _selectedDestinationName = name;
                });
              },
            ),
        ],
      ),
    );
  }
}
