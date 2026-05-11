import 'package:flutter/material.dart';
import 'package:flutter_google_places_sdk/flutter_google_places_sdk.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart' as gmaps;
import 'package:landmark_navigation_app/providers/navigation_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

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

  Future<void> _onPredictionSelected(AutocompletePrediction prediction) async {
    FocusManager.instance.primaryFocus?.unfocus();
    final placeDetails = await flutterGooglePlacesSdk.fetchPlace(
      prediction.placeId,
      fields: [PlaceField.Location, PlaceField.Name],
    );

    final lat = placeDetails.place?.latLng?.lat;
    final lng = placeDetails.place?.latLng?.lng;

    if (lat != null && lng != null) {
      final destination = gmaps.LatLng(lat, lng);
      final name = placeDetails.place?.name ?? '';
      setState(() {
        _predictions = [];
      });

      widget.mapController?.animateCamera(
        gmaps.CameraUpdate.newLatLngZoom(destination, 15.0),
      );
      ref
          .read(navigationProvider.notifier)
          .selectDestination(destination, name);
    }
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
      }
    });

    return Column(
      children: [
        Container(
          padding: const EdgeInsets.fromLTRB(8.0, 16.0, 8.0, 8.0),
          child: TextField(
            focusNode: _focusNode,
            decoration: InputDecoration(
              labelText: 'Traži lokaciju...',
              border: OutlineInputBorder(),
              prefixIcon: IconButton(
                icon: const Icon(Icons.search),
                onPressed:
                    _predictions.isNotEmpty
                        ? () => _onPredictionSelected(_predictions.first)
                        : null,
              ),
              suffixIcon:
                  _focusNode.hasFocus || _controller.text.isNotEmpty
                      ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _controller.clear();
                          setState(() => _predictions = []);
                        },
                      )
                      : null,
              filled: true,
              fillColor: Colors.white,
            ),
            onChanged: _onSearchChanged,
            controller: _controller,
          ),
        ),
        if (_predictions.isNotEmpty)
          Container(
            constraints: const BoxConstraints(maxHeight: 300),
            margin: const EdgeInsets.symmetric(horizontal: 8.0),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey),
              borderRadius: BorderRadius.circular(8.0),
              color: Colors.white,
            ),
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: _predictions.length,
              itemBuilder: (context, index) {
                final prediction = _predictions[index];
                return ListTile(
                  title: Text(prediction.primaryText),
                  subtitle: Text(prediction.secondaryText),
                  onTap: () => _onPredictionSelected(prediction),
                );
              },
            ),
          ),
      ],
    );
  }
}
