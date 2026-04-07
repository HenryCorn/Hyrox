import 'package:sqflite/sqflite.dart';
import 'database_schema.dart';

class AppDatabase {
  AppDatabase._();
  static final AppDatabase instance = AppDatabase._();

  Database? _db;
  String? _cachedUserId;

  Future<Database> get database async {
    _db ??= await _open();
    return _db!;
  }

  Future<Database> _open() async {
    final path = '${await getDatabasesPath()}/hyrox.db';
    return openDatabase(
      path,
      version: kDbVersion,
      onCreate: (db, _) async {
        await db.execute(kCreateUserProfile);
        await db.execute(kCreateFriendships);
        await db.execute(kCreateWorkoutRecords);
        await db.execute(kCreateWorkoutIndex);
        await _bootstrapUser(db);
      },
      onUpgrade: (db, oldVersion, newVersion) async {
        // Future migrations go here as switch cases.
      },
    );
  }

  Future<void> _bootstrapUser(Database db) async {
    final id = _generateId();
    await db.insert('user_profile', {
      'id': id,
      'display_name': 'You',
      'created_at': DateTime.now().millisecondsSinceEpoch,
    });
  }

  /// Returns the local user ID, creating a profile row if the DB is brand-new.
  Future<String> get localUserId async {
    if (_cachedUserId != null) return _cachedUserId!;
    final db = await database;
    final rows = await db.query('user_profile', columns: ['id'], limit: 1);
    if (rows.isEmpty) {
      await _bootstrapUser(db);
      return localUserId;
    }
    _cachedUserId = rows.first['id'] as String;
    return _cachedUserId!;
  }

  /// Lightweight collision-resistant ID — no external package needed.
  static String _generateId() {
    final now = DateTime.now().millisecondsSinceEpoch;
    final rand = now ^ (now >> 16);
    return '${now.toRadixString(16)}-${rand.toRadixString(16)}';
  }
}
