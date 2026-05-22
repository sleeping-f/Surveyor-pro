import 'survey_form_options.dart';

class SurveySummary {
  const SurveySummary({
    required this.id,
    required this.projectName,
    required this.roadName,
    required this.chainage,
    required this.roadSide,
    required this.distressType,
    required this.severity,
    required this.createdAt,
    required this.thumbnailPath,
    required this.imageCount,
  });

  final int id;
  final String projectName;
  final String roadName;
  final String chainage;
  final RoadSide roadSide;
  final String distressType;
  final SurveySeverity severity;
  final DateTime createdAt;
  final String? thumbnailPath;
  final int imageCount;
}
