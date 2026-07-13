import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:landmark_navigation_app/providers/navigation_provider.dart';

class TravelModeSelector extends ConsumerWidget {
  const TravelModeSelector({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final travelMode = ref.watch(navigationProvider).travelMode ?? 'WALK';

    return ToggleButtons(
      isSelected: [travelMode == 'WALK', travelMode == 'DRIVE'],
      onPressed: (index) {
        final selected = index == 0 ? 'WALK' : 'DRIVE';
        ref.read(navigationProvider.notifier).setTravelMode(selected);
      },
      borderRadius: BorderRadius.circular(10),
      selectedColor: Colors.white,
      fillColor: Theme.of(context).colorScheme.primary,
      constraints: const BoxConstraints(minHeight: 40, minWidth: 96),
      children: const [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [Icon(Icons.directions_walk, size: 18), SizedBox(width: 6), Text('Pješice')],
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [Icon(Icons.directions_car, size: 18), SizedBox(width: 6), Text('Vožnja')],
        ),
      ],
    );
  }
}
