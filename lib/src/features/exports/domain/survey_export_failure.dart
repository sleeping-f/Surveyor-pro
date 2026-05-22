enum SurveyExportFailureType {
  storage,
  fileSystem,
  unknown,
}

class SurveyExportFailure {
  const SurveyExportFailure({
    required this.type,
    required this.title,
    required this.message,
  });

  final SurveyExportFailureType type;
  final String title;
  final String message;
}

class SurveyExportException implements Exception {
  const SurveyExportException(this.failure);

  final SurveyExportFailure failure;

  @override
  String toString() => failure.message;
}
