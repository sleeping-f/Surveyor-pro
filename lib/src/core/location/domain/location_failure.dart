enum LocationFailureType {
  serviceDisabled,
  permissionDenied,
  permissionDeniedForever,
  timeout,
  unavailable,
  unknown,
}

class LocationFailure {
  const LocationFailure({
    required this.type,
    required this.title,
    required this.message,
  });

  final LocationFailureType type;
  final String title;
  final String message;

  bool get canRetry {
    return true;
  }

  bool get canOpenAppSettings {
    return type == LocationFailureType.permissionDeniedForever;
  }

  bool get canOpenLocationSettings {
    return type == LocationFailureType.serviceDisabled;
  }
}

class LocationCaptureException implements Exception {
  const LocationCaptureException(this.failure);

  final LocationFailure failure;

  @override
  String toString() => failure.message;
}
