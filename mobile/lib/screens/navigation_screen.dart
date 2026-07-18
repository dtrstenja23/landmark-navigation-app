import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:landmark_navigation_app/providers/active_navigation_provider.dart';
import 'package:landmark_navigation_app/providers/navigation_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:landmark_navigation_app/widgets/info_bottom_panel.dart';
import 'package:landmark_navigation_app/widgets/instruction_banner.dart';
import 'package:landmark_navigation_app/widgets/next_step.dart';

class NavigationScreen extends ConsumerStatefulWidget {
  const NavigationScreen({super.key});

  @override
  ConsumerState<NavigationScreen> createState() => _NavigationScreenState();
}

class _NavigationScreenState extends ConsumerState<NavigationScreen> {
  GoogleMapController? mapController;
  late final ActiveNavigationNotifier _activeNavigationNotifier;

  void _onMapCreated(GoogleMapController controller) {
    setState(() => mapController = controller);
  }

  void _recenter() {
    final position = ref.read(activeNavigationProvider).currentPosition;
    if (position != null) {
      mapController?.animateCamera(CameraUpdate.newLatLng(position));
    }
  }

  @override
  void initState() {
    super.initState();
    _activeNavigationNotifier = ref.read(activeNavigationProvider.notifier);
    _activeNavigationNotifier.start();
  }

  @override
  void dispose() {
    _activeNavigationNotifier.stop();
    mapController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final navigationState = ref.watch(navigationProvider);

    ref.listen(activeNavigationProvider, (previous, next) {
      if (next.currentPosition != null) {
        mapController?.animateCamera(
          CameraUpdate.newLatLng(next.currentPosition!),
        );
      }
    });

    ref.listen(activeNavigationProvider, (previous, next) {
      if (next.arrived && previous?.arrived != true) {
        _activeNavigationNotifier.stop();
        Future.delayed(const Duration(seconds: 2), () {
          if (context.mounted) Navigator.pop(context);
        });
      }
    });

    return Scaffold(
      appBar: AppBar(
        title: const Text('Navigacija'),
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
            zoomControlsEnabled: false,
            polylines: navigationState.polylines,
            markers: navigationState.markers,
          ),
          InstructionBanner(),
          NextStep(),
          InfoBottomPanel(),
          Positioned(
            right: 16,
            bottom: 100,
            child: FloatingActionButton(
              heroTag: 'recenter',
              onPressed: _recenter,
              backgroundColor: Colors.white,
              child: const Icon(Icons.my_location, color: Colors.black87),
            ),
          ),
        ],
      ),
    );
  }
}
