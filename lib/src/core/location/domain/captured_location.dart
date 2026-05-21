enum GpsAccuracyLevel {
  excellent('Excellent'),
  good('Good'),
  fair('Fair'),
  poor('Poor');

  const GpsAccuracyLevel(this.label);

  final String label;
}

class CapturedLocation {
  const CapturedLocation({
    required this.latitude,
    required this.longitude,
    required this.accuracyMeters,
    required this.timestamp,
  });

  final double latitude;
  final double longitude;
  final double accuracyMeters;
  final DateTime timestamp;

  GpsAccuracyLevel get accuracyLevel {
    if (accuracyMeters <= 5) {
      return GpsAccuracyLevel.excellent;
    }
    if (accuracyMeters <= 10) {
      return GpsAccuracyLevel.good;
    }
    if (accuracyMeters <= 25) {
      return GpsAccuracyLevel.fair;
    }
    return GpsAccuracyLevel.poor;
  }
}
