import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:landmark_navigation_app/providers/active_navigation_provider.dart';
import 'package:landmark_navigation_app/providers/navigation_provider.dart';

class InstructionBanner extends ConsumerWidget {
  const InstructionBanner({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final screenSize = MediaQuery.of(context).size;

    final steps = ref.watch(navigationProvider).steps;
    final activeState = ref.watch(activeNavigationProvider);

    if (steps == null || steps.isEmpty) return const SizedBox.shrink();

    final currentStep = steps[activeState.currentStepIndex];

    String displayText;
    if (activeState.arrived) {
      displayText = currentStep.instructionText;
    } else {
      var maneuverPhrase = currentStep.instructionText;
      final prefixEnd = maneuverPhrase.indexOf(' m ');
      if (maneuverPhrase.startsWith('Za ') && prefixEnd != -1) {
        maneuverPhrase = maneuverPhrase.substring(prefixEnd + 3);
      }
      final landmarkStart = maneuverPhrase.indexOf(' kod "');
      if (landmarkStart != -1) {
        maneuverPhrase = maneuverPhrase.substring(0, landmarkStart);
      }
      if (maneuverPhrase.isNotEmpty) {
        maneuverPhrase =
            maneuverPhrase[0].toLowerCase() + maneuverPhrase.substring(1);
      }

      final landmarkText =
          currentStep.landmarkName != null
              ? 'kod "${currentStep.landmarkName}" '
              : '';
      displayText =
          'Za ${activeState.distanceToManeuver.round()} m $landmarkText$maneuverPhrase';
    }

    return Align(
      alignment: Alignment.topCenter,
      child: SizedBox(
        width: screenSize.width * 0.95,
        height: screenSize.height * 0.1,
        child: Card(
          color: Colors.amber.shade800,
          elevation: 6,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                const Icon(
                  Icons.arrow_right_alt,
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
                    maxLines: 2,
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
      ),
    );
  }
}
