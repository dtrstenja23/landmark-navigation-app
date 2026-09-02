import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:landmark_navigation_app/providers/active_navigation_provider.dart';
import 'package:landmark_navigation_app/providers/navigation_provider.dart';
import 'package:landmark_navigation_app/utils/maneuver_utils.dart';

class InstructionBanner extends ConsumerWidget {
  const InstructionBanner({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final screenSize = MediaQuery.of(context).size;

    final navState = ref.watch(navigationProvider);
    final steps = navState.steps;
    final activeState = ref.watch(activeNavigationProvider);

    if (steps == null || steps.isEmpty) return const SizedBox.shrink();

    final currentStep = steps[activeState.currentStepIndex];
    final isRerouting = navState.isFetchingRoute;
    final isLastStep = activeState.currentStepIndex == steps.length - 1;

    String displayText;
    if (isRerouting) {
      displayText = 'Preusmjeravam...';
    } else if (activeState.arrived) {
      displayText = 'Stigli ste na odredište';
    } else if (isLastStep && currentStep.maneuver != 'ARRIVE') {
      final dist = ManeuverUtils.formatDistance(activeState.distanceToManeuver);
      displayText = 'Za $dist stižete na odredište';
    } else {
      displayText = ManeuverUtils.formatLiveBanner(
        currentStep,
        activeState.distanceToManeuver,
      );
    }

    final IconData stepIcon;
    if (activeState.arrived) {
      stepIcon = Icons.check_circle;
    } else if (currentStep.maneuver == 'ARRIVE' || isLastStep) {
      stepIcon = Icons.sports_score;
    } else {
      stepIcon = ManeuverUtils.getIcon(currentStep.maneuver);
    }

    return SizedBox(
      width: screenSize.width * 0.95,
      child: Card(
        color: Colors.amber.shade800,
        elevation: 6,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          child: Row(
            children: [
              isRerouting
                  ? const SizedBox(
                    width: 28,
                    height: 28,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 3,
                    ),
                  )
                  : Icon(
                    stepIcon,
                    color: Colors.white,
                    size: 36,
                  ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  displayText,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              IconButton(
                onPressed: () {
                  ref.read(activeNavigationProvider.notifier).stop();
                  Navigator.pop(context);
                },
                icon: const Icon(Icons.cancel, color: Colors.white),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
