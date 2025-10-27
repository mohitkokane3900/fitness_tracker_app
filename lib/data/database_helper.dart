import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

// Handles opening/creating the local SQLite database for the app
class DatabaseHelper {
  // Singleton pattern so we only ever have one DatabaseHelper
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  factory DatabaseHelper() => _instance;
  DatabaseHelper._internal();

  // Database name/version
  static const _dbName = 'fitness_tracker.db';
  static const _dbVersion = 2;

  // Cached db instance (so we don't reopen it every time)
  Database? _db;

  // Get database. If it's not opened yet, open it (or create it).
  Future<Database> get database async {
    if (_db != null) return _db!;
    final dir = await getApplicationDocumentsDirectory();
    final path = join(dir.path, _dbName);
    _db = await openDatabase(
      path,
      version: _dbVersion,
      onCreate: _onCreate, // called first time db is created
      onUpgrade: _onUpgrade, // called when version number goes up
    );
    return _db!;
  }

  // Runs when the DB is first created. Creates our tables.
  Future<void> _onCreate(Database db, int version) async {
    // Table for workout sets that were logged
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

    // Table for food / calories / macros log
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

  // Runs when db version changes. We can modify tables here.
  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      // Make sure new columns exist (protein_g, fat_g, carbs_g)
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

  // Helper to only add a column if it doesn't already exist
  Future<void> _ensureColumn(
    Database db,
    String table,
    String column,
    String alterSql,
  ) async {
    // PRAGMA table_info returns info about columns in a table
    final info = await db.rawQuery('PRAGMA table_info($table)');
    final exists = info.any((row) => row['name'] == column);
    if (!exists) {
      await db.execute(alterSql);
    }
  }
}
