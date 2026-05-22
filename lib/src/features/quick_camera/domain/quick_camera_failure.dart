enum QuickCameraFailureType {
  location,
  camera,
  permission,
  processing,
  unknown,
}

class QuickCameraFailure {
  const QuickCameraFailure({
    required this.type,
    required this.title,
    required this.message,
  });

  final QuickCameraFailureType type;
  final String title;
  final String message;
}

class QuickCameraException implements Exception {
  const QuickCameraException(this.failure);

  final QuickCameraFailure failure;

  @override
  String toString() => failure.message;
}
