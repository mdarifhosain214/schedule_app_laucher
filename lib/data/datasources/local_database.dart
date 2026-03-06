import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../../core/constants/app_constants.dart';

/// SQLite database helper for managing schedules and history.
class LocalDatabase {
  static Database? _database;

  Future<Database> get database async {
    _database ??= await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, AppConstants.dbName);

    return openDatabase(
      path,
      version: AppConstants.dbVersion,
      onCreate: _onCreate,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE ${AppConstants.schedulesTable} (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        app_name TEXT NOT NULL,
        package_name TEXT NOT NULL,
        app_icon BLOB,
        label TEXT,
        scheduled_date_time TEXT NOT NULL,
        is_active INTEGER NOT NULL DEFAULT 1,
        created_at TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE ${AppConstants.historyTable} (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        schedule_id INTEGER NOT NULL,
        app_name TEXT NOT NULL,
        package_name TEXT NOT NULL,
        executed_at TEXT NOT NULL,
        was_successful INTEGER NOT NULL DEFAULT 1
      )
    ''');

    // Index for faster conflict queries
    await db.execute('''
      CREATE INDEX idx_scheduled_time 
      ON ${AppConstants.schedulesTable} (scheduled_date_time)
    ''');
  }

  Future<void> close() async {
    final db = _database;
    if (db != null) {
      await db.close();
      _database = null;
    }
  }
}
