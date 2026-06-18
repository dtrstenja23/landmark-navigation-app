import 'package:flutter/material.dart';
import 'package:flutter_google_places_sdk/flutter_google_places_sdk.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart' as gmaps;
import 'package:landmark_navigation_app/providers/navigation_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'search_predictions_list.dart';

class SearchBox extends ConsumerStatefulWidget {
  const SearchBox({super.key, required this.mapController});

  final gmaps.GoogleMapController? mapController;

  @override
  ConsumerState<SearchBox> createState() => _SearchBoxState();
}

class _SearchBoxState extends ConsumerState<SearchBox> {
  late FlutterGooglePlacesSdk flutterGooglePlacesSdk;
  final _focusNode = FocusNode();
  final _controller = TextEditingController();
  List<AutocompletePrediction> _predictions = [];

  @override
  void initState() {
    super.initState();
    flutterGooglePlacesSdk = FlutterGooglePlacesSdk(
      dotenv.env['GOOGLE_MAPS_API_KEY']!,
    );
    _focusNode.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _focusNode.dispose();
    _controller.dispose();
    super.dispose();
  }

  Future<void> _onSearchChanged(String query) async {
    if (query.isEmpty) {
      setState(() {
        _predictions = [];
      });
      return;
    }

    final results = await flutterGooglePlacesSdk.findAutocompletePredictions(
      query,
    );

    setState(() {
      _predictions = results.predictions;
    });
  }

  @override
  Widget build(BuildContext context) {
    ref.listen(navigationProvider.select((s) => s.selectedDestination), (
      prev,
      next,
    ) {
      if (next == null) {
        _controller.clear();
        setState(() => _predictions = []);
      } else {
        final name = ref.read(navigationProvider).destinationName ?? '';
        _controller.text = name;
        FocusManager.instance.primaryFocus?.unfocus();
        setState(() => _predictions = []);
        widget.mapController?.animateCamera(
          gmaps.CameraUpdate.newLatLngZoom(next, 15.0),
        );
      }
    });

    return Column(
      children: [
        Container(
          margin: const EdgeInsets.fromLTRB(12.0, 16.0, 12.0, 8.0),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: const [
              BoxShadow(
                color: Colors.black26,
                blurRadius: 8,
                offset: Offset(0, 2),
              ),
            ],
          ),
          child: TextField(
            focusNode: _focusNode,
            controller: _controller,
            decoration: InputDecoration(
              hintText: 'Traži lokaciju...',
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(vertical: 14),
              prefixIcon: const Icon(Icons.search, color: Colors.grey),
              suffixIcon:
                  _focusNode.hasFocus || _controller.text.isNotEmpty
                      ? IconButton(
                        icon: const Icon(Icons.clear, color: Colors.grey),
                        onPressed: () {
                          _controller.clear();
                          setState(() => _predictions = []);
                          ref
                              .read(navigationProvider.notifier)
                              .clearDestination();
                        },
                      )
                      : null,
            ),
            onChanged: _onSearchChanged,
          ),
        ),
        if (_predictions.isNotEmpty)
          SearchPredictionsList(predictions: _predictions),
      ],
    );
  }
}
