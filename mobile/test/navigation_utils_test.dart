import 'dart:math' as math;
import 'package:flutter_test/flutter_test.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:landmark_navigation_app/models/navigation_step.dart';
import 'package:landmark_navigation_app/utils/navigation_utils.dart';

const _metersPerDegLat = 111320.0;

double _metersPerDegLngAt(double latDeg) {
  return _metersPerDegLat * math.cos(latDeg * math.pi / 180);
}

LatLng _north(LatLng origin, double meters) {
  return LatLng(origin.latitude + meters / _metersPerDegLat, origin.longitude);
}

LatLng _east(LatLng origin, double meters) {
  final metersPerDegLng = _metersPerDegLngAt(origin.latitude);
  return LatLng(origin.latitude, origin.longitude + meters / metersPerDegLng);
}

NavigationStep _step({required LatLng start, required LatLng end}) {
  return NavigationStep(
    id: 1,
    stepIndex: 0,
    instructionText: 'Za 100 m skreni desno',
    distanceM: 100,
    maneuver: 'TURN_RIGHT',
    startLat: start.latitude,
    startLng: start.longitude,
    endLat: end.latitude,
    endLng: end.longitude,
    isLandmarkBased: false,
  );
}

void main() {
  const origin = LatLng(45.8150, 15.9819); //Zagreb center

  group('distanceToPolyline', () {
    test('returns infinity for an empty polyline', () {
      expect(NavigationUtils.distanceToPolyline(origin, []), double.infinity);
    });

    test(
      'returns distance to the single point when polyline has one point',
      () {
        final point = _north(origin, 50);
        expect(
          NavigationUtils.distanceToPolyline(origin, [point]),
          closeTo(50, 0.5),
        );
      },
    );

    test('returns approximately 0 for a point exactly on a segment', () {
      final end = _north(origin, 100);
      final onSegment = _north(origin, 50);
      expect(
        NavigationUtils.distanceToPolyline(onSegment, [origin, end]),
        closeTo(0, 0.5),
      );
    });

    test('returns perpendicular distance for a point off to the side', () {
      final end = _north(origin, 100);
      final sidePoint = _east(origin, 30);
      expect(
        NavigationUtils.distanceToPolyline(sidePoint, [origin, end]),
        closeTo(30, 0.5),
      );
    });

    test(
      'returns distance to nearest endpoint when projection falls outside the segment',
      () {
        final end = _north(origin, 100);
        final beyondEnd = _north(origin, 130);
        expect(
          NavigationUtils.distanceToPolyline(beyondEnd, [origin, end]),
          closeTo(30, 0.5),
        );
      },
    );

    test('picks the closest of multiple segments', () {
      final a = origin;
      final b = _north(origin, 100);
      final c = _north(origin, 200);
      final nearB = _east(b, 5);
      expect(
        NavigationUtils.distanceToPolyline(nearB, [a, b, c]),
        closeTo(5, 0.5),
      );
    });
  });

  group('distanceToNextManeuver', () {
    test('measures distance to the start point of the step', () {
      final step = _step(start: _north(origin, 40), end: _north(origin, 140));
      expect(
        NavigationUtils.distanceToNextManeuver(origin, step),
        closeTo(40, 0.5),
      );
    });
  });

  group('shouldAdvanceStep', () {
    test('true when within WALK threshold (20 m)', () {
      final step = _step(start: _north(origin, 15), end: _north(origin, 115));
      expect(NavigationUtils.shouldAdvanceStep(origin, step, 'WALK'), isTrue);
    });

    test('false when beyond WALK threshold (20 m)', () {
      final step = _step(start: _north(origin, 25), end: _north(origin, 125));
      expect(NavigationUtils.shouldAdvanceStep(origin, step, 'WALK'), isFalse);
    });

    test(
      'true when within DRIVE threshold (30 m) but beyond WALK threshold',
      () {
        final step = _step(start: _north(origin, 25), end: _north(origin, 125));
        expect(
          NavigationUtils.shouldAdvanceStep(origin, step, 'DRIVE'),
          isTrue,
        );
      },
    );
  });

  group('isOffRoute', () {
    test('false when within WALK threshold (35 m)', () {
      final end = _north(origin, 100);
      final near = _east(origin, 20);
      expect(NavigationUtils.isOffRoute(near, [origin, end], 'WALK'), isFalse);
    });

    test('true when beyond WALK threshold (35 m)', () {
      final end = _north(origin, 100);
      final far = _east(origin, 40);
      expect(NavigationUtils.isOffRoute(far, [origin, end], 'WALK'), isTrue);
    });

    test(
      'false when within DRIVE threshold (50 m) but beyond WALK threshold',
      () {
        final end = _north(origin, 100);
        final far = _east(origin, 40);
        expect(
          NavigationUtils.isOffRoute(far, [origin, end], 'DRIVE'),
          isFalse,
        );
      },
    );
  });

  group('distanceToStepEnd', () {
    test('measures distance to the end point of the step', () {
      final step = _step(start: origin, end: _north(origin, 100));
      final near = _north(origin, 90);
      expect(
        NavigationUtils.distanceToStepEnd(near, step),
        closeTo(10, 0.5),
      );
    });
  });

  group('hasReachedStepEnd', () {
    test('true when within WALK threshold (20 m) of the step end', () {
      final step = _step(start: origin, end: _north(origin, 100));
      final near = _north(origin, 85);
      expect(NavigationUtils.hasReachedStepEnd(near, step, 'WALK'), isTrue);
    });

    test('false when beyond WALK threshold (20 m) of the step end', () {
      final step = _step(start: origin, end: _north(origin, 100));
      final far = _north(origin, 70);
      expect(NavigationUtils.hasReachedStepEnd(far, step, 'WALK'), isFalse);
    });
  });
}
