import 'package:flutter/material.dart';

enum RoadSide {
  left('Left', Icons.keyboard_arrow_left),
  center('Center', Icons.vertical_align_center),
  right('Right', Icons.keyboard_arrow_right);

  const RoadSide(this.label, this.icon);

  final String label;
  final IconData icon;
}

enum SurveySeverity {
  low('Low', Icons.trending_down),
  medium('Medium', Icons.drag_handle),
  high('High', Icons.priority_high);

  const SurveySeverity(this.label, this.icon);

  final String label;
  final IconData icon;
}

abstract final class SurveyFormOptions {
  static const List<String> distressTypes = [
    'Pothole',
    'Alligator cracking',
    'Longitudinal cracking',
    'Transverse cracking',
    'Rutting',
    'Raveling',
    'Edge failure',
    'Surface deformation',
  ];
}
