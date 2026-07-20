import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:landmark_navigation_app/providers/settings_provider.dart';
import 'package:landmark_navigation_app/services/location_service.dart';
import 'package:landmark_navigation_app/widgets/destination_bottom_panel.dart';
import 'package:landmark_navigation_app/widgets/search_box.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:landmark_navigation_app/providers/navigation_provider.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  final _locationService = LocationService();

  GoogleMapController? mapController;

  @override
  void dispose() {
    mapController?.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    ref.read(settingsProvider.notifier).load();
    _loadUserLocation();
  }

  void _onMapCreated(GoogleMapController controller) {
    setState(() => mapController = controller);
  }

  Future<void> _loadUserLocation() async {
    final location = await _locationService.loadUserLocation();
    if (location == null || !mounted) return;
    ref.read(navigationProvider.notifier).setUserLocation(location);
    mapController?.animateCamera(CameraUpdate.newLatLngZoom(location, 20.0));
  }

  @override
  Widget build(BuildContext context) {
    final navigationState = ref.watch(navigationProvider);
    ref.listen(navigationProvider.select((s) => s.routeBounds), (prev, next) {
      if (next != null) {
        mapController?.animateCamera(CameraUpdate.newLatLngBounds(next, 60));
      }
    });

    return Scaffold(
      appBar: AppBar(
        title: const Text('Home'),
        backgroundColor: Theme.of(context).colorScheme.primary,
      ),
      body: Stack(
        children: [
          GoogleMap(
            onMapCreated: _onMapCreated,
            initialCameraPosition: CameraPosition(
              target: navigationState.userLocation,
              zoom: 20.0,
            ),
            myLocationEnabled: true,
            myLocationButtonEnabled: false,
            polylines: navigationState.polylines,
            markers: navigationState.markers,
          ),
          if (mapController != null) SearchBox(mapController: mapController),
          if (navigationState.selectedDestination != null)
            const DestinationBottomPanel(),
        ],
      ),
    );
  }
}
