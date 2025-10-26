import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  factory DatabaseHelper() => _instance;
  DatabaseHelper._internal();

  static const _dbName = 'fitness_tracker.db';
  static const _dbVersion = 2;
  Database? _db;

  Future<Database> get database async {
    if (_db != null) return _db!;
    final dir = await getApplicationDocumentsDirectory();
    final path = join(dir.path, _dbName);
    _db = await openDatabase(
      path,
      version: _dbVersion,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
    return _db!;
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE workout_sets(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        workout_session_id TEXT,
        exercise TEXT,
        notes TEXT,
        weight REAL,
        reps INTEGER,
        session_date TEXT
      )
    ''');

    await db.execute('''
      CREATE TABLE calorie_logs(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        meal_desc TEXT,
        calories INTEGER,
        protein_g REAL,
        fat_g REAL,
        carbs_g REAL,
        date_time TEXT
      )
    ''');
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      await _ensureColumn(
        db,
        'calorie_logs',
        'protein_g',
        "ALTER TABLE calorie_logs ADD COLUMN protein_g REAL DEFAULT 0",
      );
      await _ensureColumn(
        db,
        'calorie_logs',
        'fat_g',
        "ALTER TABLE calorie_logs ADD COLUMN fat_g REAL DEFAULT 0",
      );
      await _ensureColumn(
        db,
        'calorie_logs',
        'carbs_g',
        "ALTER TABLE calorie_logs ADD COLUMN carbs_g REAL DEFAULT 0",
      );
    }
  }

  Future<void> _ensureColumn(
    Database db,
    String table,
    String column,
    String alterSql,
  ) async {
    final info = await db.rawQuery('PRAGMA table_info($table)');
    final exists = info.any((row) => row['name'] == column);
    if (!exists) {
      await db.execute(alterSql);
    }
  }
}
