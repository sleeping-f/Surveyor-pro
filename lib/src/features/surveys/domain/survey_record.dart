import '../../../core/location/domain/captured_location.dart';
import 'survey_form_options.dart';
import 'survey_image.dart';

class SurveyRecord {
  const SurveyRecord({
    this.id,
    required this.projectName,
    required this.roadName,
    required this.chainage,
    required this.roadSide,
    required this.distressType,
    required this.severity,
    required this.notes,
    required this.createdAt,
    this.location,
    this.images = const [],
  });

  final int? id;
  final String projectName;
  final String roadName;
  final String chainage;
  final RoadSide roadSide;
  final String distressType;
  final SurveySeverity severity;
  final String notes;
  final DateTime createdAt;
  final CapturedLocation? location;
  final List<SurveyImage> images;

  SurveyRecord copyWith({
    int? id,
    String? projectName,
    String? roadName,
    String? chainage,
    RoadSide? roadSide,
    String? distressType,
    SurveySeverity? severity,
    String? notes,
    DateTime? createdAt,
    CapturedLocation? location,
    List<SurveyImage>? images,
  }) {
    return SurveyRecord(
      id: id ?? this.id,
      projectName: projectName ?? this.projectName,
      roadName: roadName ?? this.roadName,
      chainage: chainage ?? this.chainage,
      roadSide: roadSide ?? this.roadSide,
      distressType: distressType ?? this.distressType,
      severity: severity ?? this.severity,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
      location: location ?? this.location,
      images: images ?? this.images,
    );
  }
}
