enum SurveyStorageFailureType {
  database,
  unknown,
}

class SurveyStorageFailure {
  const SurveyStorageFailure({
    required this.type,
    required this.title,
    required this.message,
  });

  final SurveyStorageFailureType type;
  final String title;
  final String message;
}

class SurveyStorageException implements Exception {
  const SurveyStorageException(this.failure);

  final SurveyStorageFailure failure;

  @override
  String toString() => failure.message;
}
