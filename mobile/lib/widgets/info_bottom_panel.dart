import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:landmark_navigation_app/providers/active_navigation_provider.dart';
import 'package:landmark_navigation_app/providers/navigation_provider.dart';
import 'package:landmark_navigation_app/utils/navigation_utils.dart';
import 'package:landmark_navigation_app/widgets/info_column.dart';

class InfoBottomPanel extends ConsumerWidget {
  const InfoBottomPanel({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final navState = ref.watch(navigationProvider);
    final activeState = ref.watch(activeNavigationProvider);
    final steps = navState.steps;
    final position = activeState.currentPosition;

    if (steps == null || steps.isEmpty || position == null) {
      return const SizedBox.shrink();
    }

    final currentStep = steps[activeState.currentStepIndex];
    final remainingSteps = steps.sublist(activeState.currentStepIndex + 1);
    var remainingStepsDistanceM = 0;
    for (var step in remainingSteps) {
      remainingStepsDistanceM += step.distanceM;
    }
    final remainingDistanceM =
        NavigationUtils.distanceToStepEnd(position, currentStep) +
        remainingStepsDistanceM;

    final totalDistanceM = navState.totalDistanceM;
    final totalDurationS = navState.totalDurationS;

    int? remainingTimeS;
    if (totalDistanceM != null &&
        totalDurationS != null &&
        totalDistanceM > 0) {
      remainingTimeS =
          (totalDurationS * remainingDistanceM / totalDistanceM).round();
    }

    final distanceText =
        remainingDistanceM >= 1000
            ? '${(remainingDistanceM / 1000).toStringAsFixed(1)} km'
            : '${remainingDistanceM.round()} m';

    String? timeText;
    String? etaText;
    if (remainingTimeS != null) {
      final minutes = (remainingTimeS / 60).round();
      timeText =
          minutes < 60
              ? '$minutes min'
              : '${minutes ~/ 60} h ${minutes % 60} min';
      final eta = DateTime.now().add(Duration(seconds: remainingTimeS));
      final hour = eta.hour.toString().padLeft(2, '0');
      final minute = eta.minute.toString().padLeft(2, '0');
      etaText = '$hour:$minute';
    }

    return Positioned(
      left: 0,
      right: 0,
      bottom: 0,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
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
        child: SafeArea(
          top: false,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              InfoColumn(label: 'Udaljenost', value: distanceText),
              if (timeText != null)
                InfoColumn(label: 'Vrijeme', value: timeText),
              if (etaText != null) InfoColumn(label: 'Dolazak', value: etaText),
            ],
          ),
        ),
      ),
    );
  }
}
