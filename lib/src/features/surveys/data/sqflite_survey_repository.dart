import 'package:sqflite/sqflite.dart';

import '../../../core/location/domain/captured_location.dart';
import '../../../core/storage/app_database.dart';
import '../domain/survey_form_options.dart';
import '../domain/survey_image.dart';
import '../domain/survey_record.dart';
import '../domain/survey_repository.dart';
import '../domain/survey_storage_failure.dart';
import '../domain/survey_summary.dart';

class SqfliteSurveyRepository implements SurveyRepository {
  SqfliteSurveyRepository({
    required AppDatabase database,
  }) : _database = database;

  final AppDatabase _database;

  @override
  Future<int> createSurvey(SurveyRecord record) async {
    final db = await _database.database;

    try {
      return await db.transaction((txn) async {
        final surveyId = await txn.insert('surveys', _surveyRow(record));
        await _insertImages(txn, surveyId, record.images);
        return surveyId;
      });
    } on DatabaseException catch (error) {
      throw SurveyStorageException(_databaseFailure(error));
    }
  }

  @override
  Future<void> updateSurvey(SurveyRecord record) async {
    final id = record.id;
    if (id == null) {
      throw ArgumentError('Survey id is required for updates.');
    }

    final db = await _database.database;
    try {
      await db.transaction((txn) async {
        await txn.update(
          'surveys',
          _surveyRow(record),
          where: 'id = ?',
          whereArgs: [id],
        );
        await txn.delete(
          'survey_images',
          where: 'survey_id = ?',
          whereArgs: [id],
        );
        await _insertImages(txn, id, record.images);
      });
    } on DatabaseException catch (error) {
      throw SurveyStorageException(_databaseFailure(error));
    }
  }

  @override
  Future<void> deleteSurvey(int id) async {
    final db = await _database.database;
    try {
      await db.delete(
        'surveys',
        where: 'id = ?',
        whereArgs: [id],
      );
    } on DatabaseException catch (error) {
      throw SurveyStorageException(_databaseFailure(error));
    }
  }

  @override
  Future<List<SurveyRecord>> fetchAllSurveys() async {
    final db = await _database.database;
    try {
      final surveyRows = await db.query(
        'surveys',
        orderBy: 'created_at DESC',
      );
      if (surveyRows.isEmpty) {
        return const [];
      }

      final ids = surveyRows.map((row) => row['id'] as int).toList();
      final imagesBySurvey = <int, List<SurveyImage>>{};
      if (ids.isNotEmpty) {
        final placeholders = List.filled(ids.length, '?').join(',');
        final imageRows = await db.query(
          'survey_images',
          where: 'survey_id IN ($placeholders)',
          whereArgs: ids,
          orderBy: 'captured_at ASC',
        );

        for (final row in imageRows) {
          final surveyId = row['survey_id'] as int;
          imagesBySurvey.putIfAbsent(surveyId, () => []).add(
                _imageFromRow(row),
              );
        }
      }

      return surveyRows
          .map(
            (row) => _surveyRecordFromRow(
              row,
              imagesBySurvey[row['id'] as int] ?? const [],
            ),
          )
          .toList(growable: false);
    } on DatabaseException catch (error) {
      throw SurveyStorageException(_databaseFailure(error));
    }
  }

  @override
  Future<SurveyRecord?> fetchSurveyById(int id) async {
    final db = await _database.database;
    try {
      final surveyRows = await db.query(
        'surveys',
        where: 'id = ?',
        whereArgs: [id],
        limit: 1,
      );
      if (surveyRows.isEmpty) {
        return null;
      }

      final surveyRow = surveyRows.first;
      final imageRows = await db.query(
        'survey_images',
        where: 'survey_id = ?',
        whereArgs: [id],
        orderBy: 'captured_at ASC',
      );

      return _surveyRecordFromRow(
        surveyRow,
        imageRows.map(_imageFromRow).toList(growable: false),
      );
    } on DatabaseException catch (error) {
      throw SurveyStorageException(_databaseFailure(error));
    }
  }

  @override
  Future<List<SurveySummary>> fetchSurveySummaries({String? query}) async {
    final db = await _database.database;
    final trimmedQuery = query?.trim() ?? '';

    final whereClause = trimmedQuery.isEmpty
        ? ''
        : 'WHERE project_name LIKE ? OR road_name LIKE ? '
            'OR chainage LIKE ? OR distress_type LIKE ?';
    final queryArg = '%$trimmedQuery%';
    final whereArgs = trimmedQuery.isEmpty
        ? const <Object?>[]
        : [queryArg, queryArg, queryArg, queryArg];

    try {
      final rows = await db.rawQuery('''
        SELECT
          s.*,
          (
            SELECT path
            FROM survey_images si
            WHERE si.survey_id = s.id
            ORDER BY si.captured_at ASC
            LIMIT 1
          ) AS thumbnail_path,
          (
            SELECT COUNT(*)
            FROM survey_images si
            WHERE si.survey_id = s.id
          ) AS image_count
        FROM surveys s
        $whereClause
        ORDER BY s.created_at DESC
      ''', whereArgs);

      return rows
          .map((row) => SurveySummary(
                id: row['id'] as int,
                projectName: row['project_name'] as String,
                roadName: row['road_name'] as String,
                chainage: row['chainage'] as String,
                roadSide: _roadSideFromStorage(row['road_side'] as String),
                distressType: row['distress_type'] as String,
                severity: _severityFromStorage(row['severity'] as String),
                createdAt: DateTime.parse(row['created_at'] as String),
                thumbnailPath: row['thumbnail_path'] as String?,
                imageCount: (row['image_count'] as int?) ?? 0,
              ))
          .toList(growable: false);
    } on DatabaseException catch (error) {
      throw SurveyStorageException(_databaseFailure(error));
    }
  }

  Future<void> _insertImages(
    DatabaseExecutor executor,
    int surveyId,
    List<SurveyImage> images,
  ) async {
    if (images.isEmpty) {
      return;
    }

    final batch = executor.batch();
    for (final image in images) {
      batch.insert(
        'survey_images',
        {
          'survey_id': surveyId,
          'image_id': image.id,
          'path': image.path,
          'captured_at': image.capturedAt.toIso8601String(),
        },
      );
    }
    await batch.commit(noResult: true);
  }

  Map<String, Object?> _surveyRow(SurveyRecord record) {
    final location = record.location;

    return {
      'project_name': record.projectName,
      'road_name': record.roadName,
      'chainage': record.chainage,
      'road_side': record.roadSide.name,
      'distress_type': record.distressType,
      'severity': record.severity.name,
      'notes': record.notes,
      'latitude': location?.latitude,
      'longitude': location?.longitude,
      'accuracy_meters': location?.accuracyMeters,
      'location_captured_at': location?.timestamp.toIso8601String(),
      'created_at': record.createdAt.toIso8601String(),
    };
  }

  SurveyImage _imageFromRow(Map<String, Object?> row) {
    return SurveyImage(
      id: row['image_id'] as String,
      path: row['path'] as String,
      capturedAt: DateTime.parse(row['captured_at'] as String),
    );
  }

  SurveyRecord _surveyRecordFromRow(
    Map<String, Object?> row,
    List<SurveyImage> images,
  ) {
    return SurveyRecord(
      id: row['id'] as int,
      projectName: row['project_name'] as String,
      roadName: row['road_name'] as String,
      chainage: row['chainage'] as String,
      roadSide: _roadSideFromStorage(row['road_side'] as String),
      distressType: row['distress_type'] as String,
      severity: _severityFromStorage(row['severity'] as String),
      notes: row['notes'] as String,
      createdAt: DateTime.parse(row['created_at'] as String),
      location: _locationFromRow(row),
      images: images,
    );
  }

  CapturedLocation? _locationFromRow(Map<String, Object?> row) {
    final latitude = (row['latitude'] as num?)?.toDouble();
    final longitude = (row['longitude'] as num?)?.toDouble();
    final accuracy = (row['accuracy_meters'] as num?)?.toDouble();
    final capturedAt =
        (row['location_captured_at'] as String?) ??
            (row['created_at'] as String?);

    if (latitude == null || longitude == null || accuracy == null) {
      return null;
    }

    return CapturedLocation(
      latitude: latitude,
      longitude: longitude,
      accuracyMeters: accuracy,
      timestamp: capturedAt == null ? DateTime.now() : DateTime.parse(capturedAt),
    );
  }

  RoadSide _roadSideFromStorage(String value) {
    return RoadSide.values.byName(value);
  }

  SurveySeverity _severityFromStorage(String value) {
    return SurveySeverity.values.byName(value);
  }

  SurveyStorageFailure _databaseFailure(DatabaseException error) {
    return SurveyStorageFailure(
      type: SurveyStorageFailureType.database,
      title: 'Storage unavailable',
      message: error.toString(),
    );
  }
}
