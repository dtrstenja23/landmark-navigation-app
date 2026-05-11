import 'package:flutter/material.dart';
import 'package:flutter_google_places_sdk/flutter_google_places_sdk.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:landmark_navigation_app/providers/navigation_provider.dart';

class SearchPredictionsList extends ConsumerWidget {
  const SearchPredictionsList({
    super.key,
    required this.predictions,
  });

  final List<AutocompletePrediction> predictions;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      constraints: const BoxConstraints(maxHeight: 300),
      margin: const EdgeInsets.symmetric(horizontal: 12.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [
          BoxShadow(color: Colors.black26, blurRadius: 8, offset: Offset(0, 2)),
        ],
      ),
      child: ListView.separated(
        shrinkWrap: true,
        itemCount: predictions.length,
        separatorBuilder: (_, __) => const Divider(height: 1),
        itemBuilder: (context, index) {
          final prediction = predictions[index];
          return ListTile(
            leading: const Icon(Icons.location_on_outlined, color: Colors.grey),
            title: Text(prediction.primaryText),
            subtitle: Text(
              prediction.secondaryText,
              style: const TextStyle(fontSize: 12),
            ),
            onTap: () => ref.read(navigationProvider.notifier).selectPrediction(prediction),
          );
        },
      ),
    );
  }
}
