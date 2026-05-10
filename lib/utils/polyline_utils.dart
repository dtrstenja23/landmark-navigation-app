import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:google_polyline_algorithm/google_polyline_algorithm.dart';

class PolylineUtils {
  static List<LatLng> decode(String encoded) {
    return decodePolyline(encoded)
        .map((point) => LatLng(point[0].toDouble(), point[1].toDouble()))
        .toList();
  }
}
