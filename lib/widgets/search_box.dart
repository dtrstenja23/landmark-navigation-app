import 'package:flutter/material.dart';
import 'package:flutter_google_places_sdk/flutter_google_places_sdk.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart' as gmaps;

class SearchBox extends StatefulWidget {
  const SearchBox({super.key, required this.mapController});

  final gmaps.GoogleMapController? mapController;

  @override
  State<SearchBox> createState() => _SearchBoxState();
}

class _SearchBoxState extends State<SearchBox> {
  late FlutterGooglePlacesSdk flutterGooglePlacesSdk;
  List<AutocompletePrediction> _predictions = [];
  gmaps.LatLng? _destination;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    flutterGooglePlacesSdk = FlutterGooglePlacesSdk(
      dotenv.env['GOOGLE_MAPS_API_KEY']!,
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
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
    final placeDetails = await flutterGooglePlacesSdk.fetchPlace(
      prediction.placeId,
      fields: [PlaceField.Location, PlaceField.Name],
    );

    final lat = placeDetails.place?.latLng?.lat;
    final lng = placeDetails.place?.latLng?.lng;

    if (lat != null && lng != null) {
      setState(() {
        _searchController.text = placeDetails.place?.name ?? '';
        _predictions = [];
        _destination = gmaps.LatLng(lat, lng);
      });

      widget.mapController?.animateCamera(
        gmaps.CameraUpdate.newLatLngZoom(_destination!, 18.0),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(8.0),
          child: TextField(
            decoration: const InputDecoration(
              labelText: 'Traži lokaciju...',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.search),
              filled: true,
              fillColor: Colors.white,
            ),
            onChanged: _onSearchChanged,
            controller: _searchController,
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
