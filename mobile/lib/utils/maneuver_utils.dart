import 'package:flutter/material.dart';
import 'package:landmark_navigation_app/models/navigation_step.dart';

class ManeuverUtils {
  static const Map<String, String> texts = {
    'MANEUVER_UNSPECIFIED': 'nastavi ravno',
    'TURN_SLIGHT_LEFT': 'skreni blago lijevo',
    'TURN_SHARP_LEFT': 'skreni oštro lijevo',
    'UTURN_LEFT': 'okreni se polukružno ulijevo',
    'TURN_LEFT': 'skreni lijevo',
    'TURN_SLIGHT_RIGHT': 'skreni blago desno',
    'TURN_SHARP_RIGHT': 'skreni oštro desno',
    'UTURN_RIGHT': 'okreni se polukružno udesno',
    'TURN_RIGHT': 'skreni desno',
    'STRAIGHT': 'nastavi ravno',
    'RAMP_LEFT': 'uđi na rampu lijevo',
    'RAMP_RIGHT': 'uđi na rampu desno',
    'MERGE': 'uključi se u promet',
    'FORK_LEFT': 'drži se lijevo na račvanju',
    'FORK_RIGHT': 'drži se desno na račvanju',
    'ROUNDABOUT_LEFT': 'na kružnom toku izađi lijevo',
    'ROUNDABOUT_RIGHT': 'na kružnom toku izađi desno',
    'NAME_CHANGE': 'nastavi ravno',
    'DEPART': 'kreni',
  };

  static const Map<String, IconData> icons = {
    'TURN_SLIGHT_LEFT': Icons.turn_slight_left,
    'TURN_LEFT': Icons.turn_left,
    'TURN_SHARP_LEFT': Icons.turn_sharp_left,
    'UTURN_LEFT': Icons.u_turn_left,
    'TURN_SLIGHT_RIGHT': Icons.turn_slight_right,
    'TURN_RIGHT': Icons.turn_right,
    'TURN_SHARP_RIGHT': Icons.turn_sharp_right,
    'UTURN_RIGHT': Icons.u_turn_right,
    'ROUNDABOUT_LEFT': Icons.roundabout_left,
    'ROUNDABOUT_RIGHT': Icons.roundabout_right,
    'FORK_LEFT': Icons.fork_left,
    'FORK_RIGHT': Icons.fork_right,
    'RAMP_LEFT': Icons.ramp_left,
    'RAMP_RIGHT': Icons.ramp_right,
    'MERGE': Icons.merge,
    'FERRY': Icons.directions_boat_filled,
    'FERRY_TRAIN': Icons.train,
    'DEPART': Icons.navigation,
    'STRAIGHT': Icons.straight,
    'NAME_CHANGE': Icons.straight,
  };

  static String getText(String maneuver) => texts[maneuver] ?? 'nastavi ravno';

  static IconData getIcon(String maneuver) =>
      icons[maneuver] ?? Icons.arrow_right_alt;

  static bool isStraight(String maneuver) =>
      maneuver == 'STRAIGHT' ||
      maneuver == 'NAME_CHANGE' ||
      maneuver == 'MANEUVER_UNSPECIFIED';

  static String formatDistance(double meters) {
    if (meters >= 1000) {
      final km = (meters / 1000).toStringAsFixed(1);
      final formatted =
          km.endsWith('.0')
              ? km.substring(0, km.length - 2)
              : km.replaceAll('.', ',');
      return '$formatted km';
    }
    return '${meters.round()} m';
  }

  static String formatLiveBanner(NavigationStep step, double distanceMeters) {
    if (step.maneuver == 'DEPART') {
      return step.instructionText;
    }

    final dist = formatDistance(distanceMeters);

    if (isStraight(step.maneuver)) {
      return 'Nastavi ravno sljedećih $dist';
    }

    final base = getText(step.maneuver);
    final hasLandmark =
        step.isLandmarkBased &&
        step.landmarkName != null &&
        step.landmarkName!.isNotEmpty;

    if (step.maneuver.startsWith('ROUNDABOUT')) {
      final exitDirection =
          step.maneuver == 'ROUNDABOUT_LEFT' ? 'izađi lijevo' : 'izađi desno';
      if (hasLandmark) {
        final isRotor = RegExp(
          r'rotor|kru[žz]ni',
          caseSensitive: false,
        ).hasMatch(step.landmarkName!);
        if (isRotor) {
          return 'Za $dist na rotoru "${step.landmarkName}" $exitDirection';
        }
        return 'Za $dist na kružnom toku $exitDirection kod "${step.landmarkName}"';
      }
      return 'Za $dist na kružnom toku $exitDirection';
    }

    if (hasLandmark) {
      return 'Za $dist $base kod "${step.landmarkName}"';
    }
    return 'Za $dist $base';
  }
}
