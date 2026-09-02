import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_google_places_sdk/flutter_google_places_sdk.dart'
    hide LatLng;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart' as gmaps;
import 'package:landmark_navigation_app/providers/navigation_provider.dart';
import 'package:landmark_navigation_app/services/location_service.dart';
import 'dual_search_card.dart';
import 'search_predictions_list.dart';
import 'single_search_field.dart';

enum SearchTarget { origin, destination }

class SearchBox extends ConsumerStatefulWidget {
  const SearchBox({super.key, required this.mapController});

  final gmaps.GoogleMapController? mapController;

  @override
  ConsumerState<SearchBox> createState() => _SearchBoxState();
}

class _SearchBoxState extends ConsumerState<SearchBox> {
  late final FlutterGooglePlacesSdk _placesSdk;

  final _originController = TextEditingController();
  final _destinationController = TextEditingController();
  final _originFocus = FocusNode();
  final _destinationFocus = FocusNode();

  SearchTarget _activeTarget = SearchTarget.destination;
  List<AutocompletePrediction> _predictions = [];

  @override
  void initState() {
    super.initState();
    _placesSdk = FlutterGooglePlacesSdk(dotenv.env['GOOGLE_MAPS_API_KEY']!);

    _originFocus.addListener(() {
      if (_originFocus.hasFocus) {
        _originController.clear();
        setState(() {
          _activeTarget = SearchTarget.origin;
          _predictions = [];
        });
      }
    });

    _destinationFocus.addListener(() {
      if (_destinationFocus.hasFocus) {
        _destinationController.clear();
        setState(() {
          _activeTarget = SearchTarget.destination;
          _predictions = [];
        });
      }
    });
  }

  @override
  void dispose() {
    _originController.dispose();
    _destinationController.dispose();
    _originFocus.dispose();
    _destinationFocus.dispose();
    super.dispose();
  }

  Future<void> _onSearchChanged(String query) async {
    if (query.trim().isEmpty) {
      setState(() => _predictions = []);
      return;
    }

    try {
      final res = await _placesSdk.findAutocompletePredictions(query);
      if (mounted) {
        setState(() => _predictions = res.predictions);
      }
    } catch (_) {
      if (mounted) setState(() => _predictions = []);
    }
  }

  Future<void> _handlePredictionSelected(
    AutocompletePrediction prediction,
  ) async {
    final details = await _placesSdk.fetchPlace(
      prediction.placeId,
      fields: [PlaceField.Location, PlaceField.Name],
    );
    final lat = details.place?.latLng?.lat;
    final lng = details.place?.latLng?.lng;

    if (lat == null || lng == null || !mounted) return;

    final targetPoint = gmaps.LatLng(lat, lng);
    final name = prediction.primaryText;
    final navNotifier = ref.read(navigationProvider.notifier);

    if (_activeTarget == SearchTarget.origin) {
      _originController.text = name;
      _originFocus.unfocus();
      setState(() => _predictions = []);
      navNotifier.selectCustomOrigin(targetPoint, name);
      widget.mapController?.animateCamera(
        gmaps.CameraUpdate.newLatLngZoom(targetPoint, 15.0),
      );
      await navNotifier.fetchRoute();
    } else {
      _destinationController.text = name;
      _destinationFocus.unfocus();
      setState(() => _predictions = []);
      navNotifier.selectDestination(targetPoint, name);
      widget.mapController?.animateCamera(
        gmaps.CameraUpdate.newLatLngZoom(targetPoint, 15.0),
      );
      await navNotifier.fetchRoute();
    }
  }

  Future<void> _revertToGpsOrigin() async {
    final loc = await LocationService().loadUserLocation();
    if (loc != null && mounted) {
      final navNotifier = ref.read(navigationProvider.notifier);
      navNotifier.resetToGpsOrigin(loc);
      _originController.clear();
      _originFocus.unfocus();
      setState(() => _predictions = []);
      await navNotifier.fetchRoute();
    }
  }

  void _swapOriginAndDestination() {
    final navState = ref.read(navigationProvider);
    if (navState.selectedDestination == null) return;

    final oldOriginLoc = navState.userLocation;
    final oldOriginName = navState.originName ?? 'Moja lokacija';
    final oldDestLoc = navState.selectedDestination!;
    final oldDestName = navState.destinationName ?? '';

    final navNotifier = ref.read(navigationProvider.notifier);
    navNotifier.selectCustomOrigin(oldDestLoc, oldDestName);
    navNotifier.selectDestination(oldOriginLoc, oldOriginName);

    _originController.text = oldDestName;
    _destinationController.text = oldOriginName;
    setState(() => _predictions = []);

    navNotifier.fetchRoute();
  }

  @override
  Widget build(BuildContext context) {
    ref.listen(navigationProvider.select((s) => s.selectedDestination), (previous, next) {
      if (next == null) {
        _destinationController.clear();
        _originController.clear();
        setState(() => _predictions = []);
      }
    });

    final navState = ref.watch(navigationProvider);
    final isRouteActive = navState.selectedDestination != null;

    if (isRouteActive) {
      if (!_originFocus.hasFocus) {
        _originController.text = navState.originName ?? 'Vaša lokacija';
      }
      if (!_destinationFocus.hasFocus) {
        _destinationController.text = navState.destinationName ?? '';
      }
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          margin: const EdgeInsets.fromLTRB(12.0, 16.0, 12.0, 8.0),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: const [
              BoxShadow(
                color: Colors.black26,
                blurRadius: 8,
                offset: Offset(0, 2),
              ),
            ],
          ),
          child:
              !isRouteActive
                  ? SingleSearchField(
                    focusNode: _destinationFocus,
                    controller: _destinationController,
                    onTap: () => _destinationController.clear(),
                    onChanged: _onSearchChanged,
                  )
                  : DualSearchCard(
                    originController: _originController,
                    destinationController: _destinationController,
                    originFocus: _originFocus,
                    destinationFocus: _destinationFocus,
                    isCustomOrigin: navState.isCustomOrigin,
                    onSearchChanged: _onSearchChanged,
                    onTapOrigin: () {
                      _originController.clear();
                      setState(() {
                        _activeTarget = SearchTarget.origin;
                        _predictions = [];
                      });
                    },
                    onTapDestination: () {
                      _destinationController.clear();
                      setState(() {
                        _activeTarget = SearchTarget.destination;
                        _predictions = [];
                      });
                    },
                    onRevertGps: _revertToGpsOrigin,
                    onSwap: _swapOriginAndDestination,
                  ),
        ),
        if (_predictions.isNotEmpty)
          SearchPredictionsList(
            predictions: _predictions,
            onPredictionTap: _handlePredictionSelected,
          ),
      ],
    );
  }
}
