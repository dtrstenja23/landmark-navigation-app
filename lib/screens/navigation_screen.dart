import 'package:flutter/material.dart';
import 'package:landmark_navigation_app/providers/navigation_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class NavigationScreen extends ConsumerStatefulWidget {
  const NavigationScreen({super.key});

  @override
  ConsumerState<NavigationScreen> createState() => _NavigationScreenState();
}

class _NavigationScreenState extends ConsumerState<NavigationScreen> {
  @override
  void initState() {
    super.initState();
    _fetchRoute();
  }

  Future<void> _fetchRoute() async {}

  @override
  Widget build(BuildContext context) {
    final navigationState = ref.watch(navigationProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Navigacija'),
        backgroundColor: Theme.of(context).colorScheme.primary,
      ),
      body: Center(
        child: Text(
          'Prikaz rute do odredišta:\nLat: ${navigationState.selectedDestination?.latitude}, Lng: ${navigationState.selectedDestination?.longitude}',
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 18),
        ),
      ),
    );
  }
}
