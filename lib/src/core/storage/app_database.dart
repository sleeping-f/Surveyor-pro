import 'package:path/path.dart' as p;
import 'package:sqflite/sqflite.dart';

class AppDatabase {
  AppDatabase._();

  static final AppDatabase instance = AppDatabase._();
  static const _databaseName = 'surveyor_pro.db';
  static const _databaseVersion = 1;

  Database? _database;

  Future<Database> get database async {
    final database = _database;
    if (database != null) {
      return database;
    }

    final db = await _openDatabase();
    _database = db;
    return db;
  }

  Future<void> close() async {
    final database = _database;
    if (database != null) {
      await database.close();
      _database = null;
    }
  }

  Future<Database> _openDatabase() async {
    final databasesPath = await getDatabasesPath();
    final path = p.join(databasesPath, _databaseName);

    return openDatabase(
      path,
      version: _databaseVersion,
      onConfigure: (db) async {
        await db.execute('PRAGMA foreign_keys = ON');
      },
      onCreate: (db, version) async {
        await _createSchema(db);
      },
    );
  }

  Future<void> _createSchema(Database db) async {
    await db.execute('''
      CREATE TABLE surveys (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        project_name TEXT NOT NULL,
        road_name TEXT NOT NULL,
        chainage TEXT NOT NULL,
        road_side TEXT NOT NULL,
        distress_type TEXT NOT NULL,
        severity TEXT NOT NULL,
        notes TEXT NOT NULL,
        latitude REAL,
        longitude REAL,
        accuracy_meters REAL,
        location_captured_at TEXT,
        created_at TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE survey_images (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        survey_id INTEGER NOT NULL,
        image_id TEXT NOT NULL,
        path TEXT NOT NULL,
        captured_at TEXT NOT NULL,
        FOREIGN KEY (survey_id) REFERENCES surveys(id) ON DELETE CASCADE
      )
    ''');

    await db.execute(
      'CREATE INDEX idx_surveys_created_at ON surveys(created_at)',
    );
    await db.execute(
      'CREATE INDEX idx_surveys_project_name ON surveys(project_name)',
    );
    await db.execute(
      'CREATE INDEX idx_surveys_road_name ON surveys(road_name)',
    );
    await db.execute(
      'CREATE INDEX idx_survey_images_survey_id ON survey_images(survey_id)',
    );
  }
}
