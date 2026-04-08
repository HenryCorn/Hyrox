import 'package:sqflite/sqflite.dart';
import 'app_database.dart';
import '../models/workout_record.dart';

class WorkoutRepository {
  WorkoutRepository(this._db);
  final AppDatabase _db;

  /// Insert a finished workout. Idempotent — safe to call more than once for
  /// the same workout ID (uses INSERT OR IGNORE).
  Future<void> save(WorkoutRecord record) async {
    final db = await _db.database;
    await db.insert(
      'workout_records',
      record.toRow(),
      conflictAlgorithm: ConflictAlgorithm.ignore,
    );
  }

  /// All workouts for the local user, newest first.
  Future<List<WorkoutRecord>> fetchAll() async {
    final db = await _db.database;
    final userId = await _db.localUserId;
    final rows = await db.query(
      'workout_records',
      where: 'user_id = ?',
      whereArgs: [userId],
      orderBy: 'completed_at DESC',
    );
    return rows.map(WorkoutRecord.fromRow).toList();
  }

  /// Workouts for a single routine, newest first.
  Future<List<WorkoutRecord>> fetchByRoutine(String routineName) async {
    final db = await _db.database;
    final userId = await _db.localUserId;
    final rows = await db.query(
      'workout_records',
      where: 'user_id = ? AND routine_name = ?',
      whereArgs: [userId, routineName],
      orderBy: 'completed_at DESC',
    );
    return rows.map(WorkoutRecord.fromRow).toList();
  }

  /// Delete a single record by id.
  Future<void> delete(String id) async {
    final db = await _db.database;
    await db.delete('workout_records', where: 'id = ?', whereArgs: [id]);
  }
}
