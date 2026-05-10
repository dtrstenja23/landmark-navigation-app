import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart' as gmaps;

class NavigationScreen extends StatefulWidget {
  const NavigationScreen({super.key, required this.destination});

  final gmaps.LatLng destination;

  @override
  State<NavigationScreen> createState() => _NavigationScreenState();
}

class _NavigationScreenState extends State<NavigationScreen> {
  @override
  void initState() {
    super.initState();
    _fetchRoute();
  }

  Future<void> _fetchRoute() async {}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Navigacija')),
      body: Center(
        child: Text(
          'Prikaz rute do odredišta:\nLat: ${widget.destination.latitude}, Lng: ${widget.destination.longitude}',
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 18),
        ),
      ),
    );
  }
}
