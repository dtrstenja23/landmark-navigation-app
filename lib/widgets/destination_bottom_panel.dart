import 'package:flutter/material.dart';
import 'package:landmark_navigation_app/screens/navigation_screen.dart';
import 'package:landmark_navigation_app/providers/navigation_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class DestinationBottomPanel extends ConsumerWidget {
  const DestinationBottomPanel({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final navigationState = ref.watch(navigationProvider);

    return Positioned(
      left: 0,
      right: 0,
      bottom: 0,
      child: Container(
        height: 150,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
          boxShadow: [
            BoxShadow(
              color: Colors.black26,
              blurRadius: 8,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    navigationState.destinationName ?? '',
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                IconButton(
                  onPressed:
                      () =>
                          ref
                              .read(navigationProvider.notifier)
                              .clearDestination(),
                  icon: const Icon(Icons.close),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.grey[300],
                    foregroundColor: Colors.black,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            if (!navigationState.hasRoute)
              ElevatedButton.icon(
                onPressed: () async {
                  final success =
                      await ref.read(navigationProvider.notifier).fetchRoute();
                  if (!success && context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Ruta nije pronađena.')),
                    );
                  }
                },
                icon: const Icon(Icons.directions),
                label: const Text('Upute'),
              ),
            if (navigationState.hasRoute)
              ElevatedButton.icon(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder:
                          (context) => NavigationScreen(
                            destination: navigationState.selectedDestination!,
                          ),
                    ),
                  );
                },
                icon: const Icon(Icons.navigation),
                label: const Text('Početak'),
              ),
          ],
        ),
      ),
    );
  }
}
