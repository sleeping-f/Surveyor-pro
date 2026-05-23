import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

import '../../../core/storage/app_database.dart';

class HomeMetrics {
  const HomeMetrics({
    required this.localRecords,
    required this.draftImages,
    required this.storedImages,
    required this.pendingExports,
  });

  const HomeMetrics.empty()
      : localRecords = 0,
        draftImages = 0,
        storedImages = 0,
        pendingExports = 0;

  final int localRecords;
  final int draftImages;
  final int storedImages;
  final int pendingExports;
}

enum HomeMetricsStatus {
  loading,
  ready,
  failure,
}

class HomeMetricsState {
  const HomeMetricsState({
    required this.status,
    required this.metrics,
    this.message,
  });

  const HomeMetricsState.loading()
      : status = HomeMetricsStatus.loading,
        metrics = const HomeMetrics.empty(),
        message = null;

  const HomeMetricsState.failure(String message)
      : status = HomeMetricsStatus.failure,
        metrics = const HomeMetrics.empty(),
        message = message;

  final HomeMetricsStatus status;
  final HomeMetrics metrics;
  final String? message;

  bool get isLoading => status == HomeMetricsStatus.loading;
}

class HomeMetricsController extends ChangeNotifier {
  HomeMetricsController({AppDatabase? database})
      : _database = database ?? AppDatabase.instance;

  final AppDatabase _database;

  HomeMetricsState _state = const HomeMetricsState.loading();
  bool _isDisposed = false;

  HomeMetricsState get state => _state;

  Future<void> load() async {
    try {
      final db = await _database.database;
      final localRecords = await _countRows(db, 'surveys');
      final storedImages = await _countRows(db, 'survey_images');
      final draftImages = await _countDraftImages(db);
      final pendingExports = await _countPendingExports();

      _setState(
        HomeMetricsState(
          status: HomeMetricsStatus.ready,
          metrics: HomeMetrics(
            localRecords: localRecords,
            draftImages: draftImages,
            storedImages: storedImages,
            pendingExports: pendingExports,
          ),
        ),
      );
    } catch (error) {
      _setState(
        HomeMetricsState.failure(
          'Storage counts could not be loaded.',
        ),
      );
    }
  }

  Future<int> _countRows(Database db, String table) async {
    final rows = await db.rawQuery('SELECT COUNT(*) AS count FROM $table');
    return Sqflite.firstIntValue(rows) ?? 0;
  }

  Future<int> _countDraftImages(Database db) async {
    final rows = await db.rawQuery(
      'SELECT path FROM survey_images',
    );
    final storedPaths = rows
        .map((row) => row['path'] as String)
        .where((value) => value.isNotEmpty)
        .toSet();

    final directory = await getApplicationDocumentsDirectory();
    final imageDirectory = Directory(
      p.join(directory.path, 'survey_images'),
    );

    if (!await imageDirectory.exists()) {
      return 0;
    }

    final files = imageDirectory
        .listSync(followLinks: false)
        .whereType<File>()
        .where((file) => p.extension(file.path).toLowerCase() == '.jpg');

    return files.where((file) => !storedPaths.contains(file.path)).length;
  }

  Future<int> _countPendingExports() async {
    Directory? directory;
    if (Platform.isAndroid) {
      directory = await getExternalStorageDirectory();
    }
    directory ??= await getApplicationDocumentsDirectory();

    final exportDirectory = Directory(p.join(directory.path, 'exports'));
    if (!await exportDirectory.exists()) {
      return 0;
    }

    return exportDirectory
        .listSync(followLinks: false)
        .whereType<File>()
        .where((file) => p.extension(file.path).toLowerCase() == '.csv')
        .length;
  }

  void _setState(HomeMetricsState value) {
    if (_isDisposed) {
      return;
    }

    _state = value;
    notifyListeners();
  }

  @override
  void dispose() {
    _isDisposed = true;
    super.dispose();
  }
}
