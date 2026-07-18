import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:landmark_navigation_app/providers/active_navigation_provider.dart';
import 'package:landmark_navigation_app/providers/navigation_provider.dart';

class InstructionBanner extends ConsumerWidget {
  const InstructionBanner({super.key});

  static const Map<String, IconData> _maneuverIcons = {
    'TURN_SLIGHT_LEFT': Icons.turn_slight_left,
    'TURN_LEFT': Icons.turn_left,
    'TURN_SHARP_LEFT': Icons.turn_sharp_left,
    'UTURN_LEFT': Icons.u_turn_left,
    'TURN_SLIGHT_RIGHT': Icons.turn_slight_right,
    'TURN_RIGHT': Icons.turn_right,
    'TURN_SHARP_RIGHT': Icons.turn_sharp_right,
    'UTURN_RIGHT': Icons.u_turn_right,
    'ROUNDABOUT_LEFT': Icons.roundabout_left,
    'ROUNDABOUT_RIGHT': Icons.roundabout_right,
    'FORK_LEFT': Icons.fork_left,
    'FORK_RIGHT': Icons.fork_right,
    'RAMP_LEFT': Icons.ramp_left,
    'RAMP_RIGHT': Icons.ramp_right,
    'MERGE': Icons.merge,
    'FERRY': Icons.directions_boat_filled,
    'FERRY_TRAIN': Icons.train,
    'DEPART': Icons.navigation,
    'STRAIGHT': Icons.straight,
    'NAME_CHANGE': Icons.straight,
  };

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final screenSize = MediaQuery.of(context).size;

    final navState = ref.watch(navigationProvider);
    final steps = navState.steps;
    final activeState = ref.watch(activeNavigationProvider);

    if (steps == null || steps.isEmpty) return const SizedBox.shrink();

    final currentStep = steps[activeState.currentStepIndex];
    final isRerouting = navState.isFetchingRoute;

    String displayText;
    if (isRerouting) {
      displayText = 'Preusmjeravam...';
    } else if (activeState.arrived || currentStep.maneuver == 'DEPART') {
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

    return Padding(
      padding: const EdgeInsets.only(top: 12),
      child: Align(
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
                        _maneuverIcons[currentStep.maneuver] ??
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
        ),
      ),
    );
  }
}
