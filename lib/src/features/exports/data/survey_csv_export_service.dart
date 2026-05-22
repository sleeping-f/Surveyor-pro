import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import '../../../core/utils/app_formatters.dart';
import '../../surveys/domain/survey_record.dart';
import '../domain/survey_export_failure.dart';
import '../domain/survey_export_result.dart';

class SurveyCsvExportService {
  Future<SurveyExportResult> exportSurveys(
    List<SurveyRecord> surveys,
  ) async {
    final exportedAt = DateTime.now();
    final fileName = 'surveys_${AppFormatters.fileTimestamp(exportedAt)}.csv';

    try {
      Directory? directory;
      if (Platform.isAndroid) {
        directory = await getExternalStorageDirectory();
      }
      directory ??= await getApplicationDocumentsDirectory();
      final exportDirectory = Directory(p.join(directory.path, 'exports'));
      if (!await exportDirectory.exists()) {
        await exportDirectory.create(recursive: true);
      }

      final filePath = p.join(exportDirectory.path, fileName);
      final csvContent = _buildCsv(surveys);
      final file = File(filePath);
      await file.writeAsString(csvContent, flush: true);

      return SurveyExportResult(
        filePath: filePath,
        exportedAt: exportedAt,
        recordCount: surveys.length,
      );
    } on FileSystemException catch (error) {
      throw SurveyExportException(
        SurveyExportFailure(
          type: SurveyExportFailureType.fileSystem,
          title: 'Export failed',
          message: error.message,
        ),
      );
    } catch (_) {
      throw const SurveyExportException(
        SurveyExportFailure(
          type: SurveyExportFailureType.unknown,
          title: 'Export failed',
          message: 'The CSV file could not be created.',
        ),
      );
    }
  }

  String _buildCsv(List<SurveyRecord> surveys) {
    final buffer = StringBuffer();
    buffer.writeln(
      [
        'id',
        'project_name',
        'road_name',
        'chainage',
        'road_side',
        'distress_type',
        'severity',
        'notes',
        'created_at',
        'latitude',
        'longitude',
        'accuracy_meters',
        'location_captured_at',
        'image_paths',
        'image_count',
      ].join(','),
    );

    for (final survey in surveys) {
      final location = survey.location;
      final imagePaths = survey.images.map((image) => image.path).join('|');

      buffer.writeln(
        [
          survey.id?.toString() ?? '',
          survey.projectName,
          survey.roadName,
          survey.chainage,
          survey.roadSide.name,
          survey.distressType,
          survey.severity.name,
          survey.notes,
          survey.createdAt.toIso8601String(),
          location?.latitude.toStringAsFixed(7) ?? '',
          location?.longitude.toStringAsFixed(7) ?? '',
          location?.accuracyMeters.toStringAsFixed(1) ?? '',
          location?.timestamp.toIso8601String() ?? '',
          imagePaths,
          survey.images.length.toString(),
        ].map(_csvEscape).join(','),
      );
    }

    return buffer.toString();
  }

  String _csvEscape(String value) {
    final needsQuotes =
        value.contains(',') ||
            value.contains('"') ||
            value.contains('\n') ||
            value.contains('\r');
    if (!needsQuotes) {
      return value;
    }
    final escaped = value.replaceAll('"', '""');
    return '"$escaped"';
  }
}
