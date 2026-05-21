enum ImageCaptureFailureType {
  permissionDenied,
  cameraUnavailable,
  fileSystem,
  unknown,
}

class ImageCaptureFailure {
  const ImageCaptureFailure({
    required this.type,
    required this.title,
    required this.message,
  });

  final ImageCaptureFailureType type;
  final String title;
  final String message;
}

class ImageCaptureException implements Exception {
  const ImageCaptureException(this.failure);

  final ImageCaptureFailure failure;

  @override
  String toString() => failure.message;
}
