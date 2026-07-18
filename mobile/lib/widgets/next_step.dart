import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:landmark_navigation_app/providers/active_navigation_provider.dart';
import 'package:landmark_navigation_app/providers/navigation_provider.dart';

class NextStep extends ConsumerWidget {
  const NextStep({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final screenSize = MediaQuery.of(context).size;

    final steps = ref.watch(navigationProvider).steps;
    final activeState = ref.watch(activeNavigationProvider);

    if (steps == null || steps.isEmpty) return const SizedBox.shrink();

    final nextIndex = activeState.currentStepIndex + 1;
    if (nextIndex >= steps.length) return const SizedBox.shrink();

    final nextStep = steps[nextIndex];

    return Positioned(
      top: screenSize.height * 0.1 + 16,
      left: 0,
      right: 0,
      child: Align(
        alignment: Alignment.topCenter,
        child: SizedBox(
          width: screenSize.width * 0.75,
          child: Card(
            color: Colors.amber.shade50,
            elevation: 3,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: BorderSide(color: Colors.amber.shade800, width: 1.5),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.arrow_right_alt,
                    color: Colors.amber.shade800,
                    size: 22,
                  ),
                  const SizedBox(width: 8),
                  Flexible(
                    child: Text(
                      'Zatim: ${nextStep.instructionText}',
                      style: TextStyle(
                        color: Colors.amber.shade900,
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
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
