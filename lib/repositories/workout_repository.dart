import '../data/database_helper.dart';
import '../models/workout_entry.dart';

class WorkoutRepository {
  final dbHelper = DatabaseHelper();

  Future<int> addSetToWorkout(WorkoutEntry entry) async {
    final db = await dbHelper.database;
    return db.insert('workout_sets', entry.toMap());
  }

  Future<List<WorkoutEntry>> getSetsForSession(String sessionId) async {
    final db = await dbHelper.database;
    final rows = await db.query(
      'workout_sets',
      where: 'workout_session_id = ?',
      whereArgs: [sessionId],
      orderBy: 'id ASC',
    );
    return rows.map((e) => WorkoutEntry.fromMap(e)).toList();
  }

  Future<WorkoutEntry?> getLatestSetForExercise(String exerciseName) async {
    final db = await dbHelper.database;
    final rows = await db.query(
      'workout_sets',
      where: 'exercise = ?',
      whereArgs: [exerciseName],
      orderBy: 'id DESC',
      limit: 1,
    );
    if (rows.isEmpty) return null;
    return WorkoutEntry.fromMap(rows.first);
  }

  Future<void> discardWorkoutSession(String sessionId) async {
    final db = await dbHelper.database;
    await db.delete(
      'workout_sets',
      where: 'workout_session_id = ?',
      whereArgs: [sessionId],
    );
  }
}
