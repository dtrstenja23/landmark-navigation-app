import 'package:flutter/material.dart';
import 'package:flutter_google_places_sdk/flutter_google_places_sdk.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart' as gmaps;

class SearchBox extends StatefulWidget {
  const SearchBox({
    super.key,
    required this.mapController,
    required this.onDestinationSelected,
    required this.controller,
  });

  final gmaps.GoogleMapController? mapController;
  final Function(gmaps.LatLng, String) onDestinationSelected;
  final TextEditingController controller;

  @override
  State<SearchBox> createState() => _SearchBoxState();
}

class _SearchBoxState extends State<SearchBox> {
  late FlutterGooglePlacesSdk flutterGooglePlacesSdk;
  List<AutocompletePrediction> _predictions = [];
  gmaps.LatLng? _destination;

  @override
  void initState() {
    super.initState();
    flutterGooglePlacesSdk = FlutterGooglePlacesSdk(
      dotenv.env['GOOGLE_MAPS_API_KEY']!,
    );
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
      setState(() {
        widget.controller.text = placeDetails.place?.name ?? '';
        _predictions = [];
        _destination = gmaps.LatLng(lat, lng);
      });

      widget.mapController?.animateCamera(
        gmaps.CameraUpdate.newLatLngZoom(_destination!, 15.0),
      );
      widget.onDestinationSelected(_destination!, placeDetails.place?.name ?? '');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.fromLTRB(8.0, 16.0, 8.0, 8.0),
          child: TextField(
            decoration: InputDecoration(
              labelText: 'Traži lokaciju...',
              border: OutlineInputBorder(),
              prefixIcon: IconButton(
                icon: const Icon(Icons.search),
                onPressed: _predictions.isNotEmpty
                    ? () => _onPredictionSelected(_predictions.first)
                    : null,
              ),
              suffixIcon: IconButton(
                icon: const Icon(Icons.clear),
                onPressed: () {
                  widget.controller.clear();
                  setState(() => _predictions = []);
                },
              ),
              filled: true,
              fillColor: Colors.white,
            ),
            onChanged: _onSearchChanged,
            controller: widget.controller,
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
