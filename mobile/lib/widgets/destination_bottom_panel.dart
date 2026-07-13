import 'package:flutter/material.dart';
import 'package:landmark_navigation_app/screens/navigation_screen.dart';
import 'package:landmark_navigation_app/providers/navigation_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:landmark_navigation_app/widgets/travel_mode_selector.dart';

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
          mainAxisSize: MainAxisSize.min,
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
                const SizedBox(width: 8),
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
            const SizedBox(height: 12),
            const TravelModeSelector(),
            const SizedBox(height: 12),
            Row(
              children: [
                if (!navigationState.hasRoute)
                  ElevatedButton.icon(
                    onPressed:
                        navigationState.isFetchingRoute
                            ? null
                            : () async {
                              final success =
                                  await ref
                                      .read(navigationProvider.notifier)
                                      .fetchRoute();
                              if (!success && context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: const Row(
                                      children: [
                                        Icon(
                                          Icons.error_outline,
                                          color: Colors.white,
                                        ),
                                        SizedBox(width: 8),
                                        Text('Ruta nije pronađena.'),
                                      ],
                                    ),
                                    backgroundColor: Colors.red[700],
                                    behavior: SnackBarBehavior.floating,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    margin: const EdgeInsets.all(12),
                                  ),
                                );
                              }
                            },
                    icon:
                        navigationState.isFetchingRoute
                            ? const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                            : const Icon(Icons.directions),
                    label: const Text('Upute'),
                  ),
                const SizedBox(width: 8),
                if (navigationState.hasRoute)
                  ElevatedButton.icon(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => NavigationScreen(),
                        ),
                      );
                    },
                    icon: const Icon(Icons.navigation),
                    label: const Text('Početak'),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
