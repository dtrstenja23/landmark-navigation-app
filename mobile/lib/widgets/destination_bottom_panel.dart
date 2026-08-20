import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:landmark_navigation_app/providers/navigation_provider.dart';
import 'package:landmark_navigation_app/screens/navigation_screen.dart';
import 'package:landmark_navigation_app/utils/maneuver_utils.dart';
import 'package:landmark_navigation_app/widgets/travel_mode_selector.dart';

class DestinationBottomPanel extends ConsumerWidget {
  const DestinationBottomPanel({super.key});

  String _formatDuration(int seconds) {
    final min = (seconds / 60).round();
    if (min < 1) return '< 1 min';
    if (min >= 60) {
      final hours = min ~/ 60;
      final remainingMin = min % 60;
      return '$hours h $remainingMin min';
    }
    return '$min min';
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final navigationState = ref.watch(navigationProvider);

    return Positioned(
      left: 0,
      right: 0,
      bottom: 0,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          boxShadow: [
            BoxShadow(
              color: Colors.black26,
              blurRadius: 10,
              offset: Offset(0, -2),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                if (navigationState.hasRoute &&
                    navigationState.totalDistanceM != null) ...[
                  Text(
                    _formatDuration(navigationState.totalDurationS ?? 0),
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.green.shade800,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Text(
                    '(${ManeuverUtils.formatDistance(navigationState.totalDistanceM!.toDouble())})',
                    style: const TextStyle(
                      fontSize: 16,
                      color: Colors.grey,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const Spacer(),
                ] else ...[
                  Expanded(
                    child: Text(
                      navigationState.destinationName ?? '',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 8),
                ],
                IconButton(
                  onPressed:
                      () =>
                          ref
                              .read(navigationProvider.notifier)
                              .clearDestination(),
                  icon: const Icon(Icons.close, size: 20),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.grey[200],
                    foregroundColor: Colors.black87,
                    padding: const EdgeInsets.all(6),
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            const TravelModeSelector(),
            const SizedBox(height: 14),
            Row(
              children: [
                if (!navigationState.hasRoute)
                  Expanded(
                    child: ElevatedButton.icon(
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
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      icon:
                          navigationState.isFetchingRoute
                              ? const SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                              : const Icon(Icons.directions),
                      label: const Text(
                        'Prikaži upute',
                        style: TextStyle(fontSize: 16),
                      ),
                    ),
                  ),
                if (navigationState.hasRoute) ...[
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const NavigationScreen(),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      icon: const Icon(Icons.navigation),
                      label: const Text(
                        'Početak',
                        style: TextStyle(fontSize: 16),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder:
                                (context) =>
                                    const NavigationScreen(isSimulated: true),
                          ),
                        );
                      },
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        foregroundColor: Colors.blue.shade800,
                        side: BorderSide(
                          color: Colors.blue.shade700,
                          width: 1.5,
                        ),
                      ),
                      icon: const Icon(
                        Icons.play_circle_outline,
                        color: Colors.blue,
                      ),
                      label: const Text(
                        'Simuliraj',
                        style: TextStyle(fontSize: 16),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }
}
