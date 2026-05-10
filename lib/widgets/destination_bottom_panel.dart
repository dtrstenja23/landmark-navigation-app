import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class DestinationBottomPanel extends StatelessWidget {
  const DestinationBottomPanel({
    super.key,
    required this.destination,
    required this.destinationName,
    required this.onDirectionsPressed,
    required this.onClose,
  });

  final LatLng destination;
  final String destinationName;
  final VoidCallback onDirectionsPressed;
  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
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
        child: Row(
          children: [
            Expanded(
              child: Text(
                destinationName,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
                overflow: TextOverflow.clip,
              ),
            ),
            const SizedBox(width: 12),
            ElevatedButton.icon(
              onPressed: onDirectionsPressed,
              icon: const Icon(Icons.directions),
              label: const Text('Upute'),
            ),
            const SizedBox(width: 12),
            IconButton(
              onPressed: onClose,
              icon: const Icon(Icons.close),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.grey[300],
                foregroundColor: Colors.black,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
