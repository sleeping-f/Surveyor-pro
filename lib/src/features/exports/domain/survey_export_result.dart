class SurveyExportResult {
  const SurveyExportResult({
    required this.filePath,
    required this.exportedAt,
    required this.recordCount,
  });

  final String filePath;
  final DateTime exportedAt;
  final int recordCount;
}
