import '../../../core/location/domain/captured_location.dart';

class QuickCameraResult {
  const QuickCameraResult({
    required this.filePath,
    required this.capturedAt,
    required this.location,
    this.chainage,
  });

  final String filePath;
  final DateTime capturedAt;
  final CapturedLocation location;
  final String? chainage;
}
