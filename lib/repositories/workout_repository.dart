import '../data/database_helper.dart';
import '../models/workout_entry.dart';

// All database actions related to workouts live here
class WorkoutRepository {
  final dbHelper = DatabaseHelper();

  // Insert a WorkoutEntry row into workout_sets table
  Future<int> addSetToWorkout(WorkoutEntry entry) async {
    final db = await dbHelper.database;
    return db.insert('workout_sets', entry.toMap());
  }

  // Get all sets for a given workout session (by sessionId)
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

  // Get the most recent set for a specific exercise name
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

  // Delete all sets that belong to a workout session (like discarding it)
  Future<void> discardWorkoutSession(String sessionId) async {
    final db = await dbHelper.database;
    await db.delete(
      'workout_sets',
      where: 'workout_session_id = ?',
      whereArgs: [sessionId],
    );
  }

  // Count how many workouts were done each weekday (Mon/Tue/...etc)
  Future<Map<String, int>> getWorkoutsPerWeekday() async {
    final db = await dbHelper.database;

    // For each workout_session_id, get the first time it happened
    final rows = await db.rawQuery('''
      SELECT workout_session_id, MIN(session_date) as first_date
      FROM workout_sets
      GROUP BY workout_session_id
    ''');

    // Start counts at 0 for all weekdays
    final counts = {
      'Mon': 0,
      'Tue': 0,
      'Wed': 0,
      'Thu': 0,
      'Fri': 0,
      'Sat': 0,
      'Sun': 0,
    };

    // Figure out which weekday each session happened on
    for (final r in rows) {
      final d = DateTime.parse(r['first_date'] as String);
      final weekday = d.weekday; // Monday = 1 ... Sunday = 7

      final label = weekday == 1
          ? 'Mon'
          : weekday == 2
          ? 'Tue'
          : weekday == 3
          ? 'Wed'
          : weekday == 4
          ? 'Thu'
          : weekday == 5
          ? 'Fri'
          : weekday == 6
          ? 'Sat'
          : 'Sun';

      counts[label] = (counts[label] ?? 0) + 1;
    }
    return counts;
  }

  // Get list of all workout sessions (grouped by sessionId and date)
  Future<List<WorkoutSessionMeta>> getAllWorkoutSessions() async {
    final db = await dbHelper.database;
    final rows = await db.rawQuery('''
      SELECT workout_session_id AS sid,
             MIN(session_date) as first_date
      FROM workout_sets
      GROUP BY workout_session_id
      ORDER BY first_date DESC
    ''');

    final sessions = <WorkoutSessionMeta>[];
    for (final r in rows) {
      final sid = r['sid'] as String;
      final d = DateTime.parse(r['first_date'] as String);
      sessions.add(WorkoutSessionMeta(sessionId: sid, firstDate: d));
    }
    return sessions;
  }

  // Filter workout sessions by time range:
  // "this" = last 7 days, "last" = 7-14 days ago, else = 14-21 days ago
  Future<List<WorkoutSessionMeta>> getWorkoutSessionsFiltered(
    String mode,
  ) async {
    final all = await getAllWorkoutSessions();

    final now = DateTime.now();
    final thisWeekStart = now.subtract(const Duration(days: 7));
    final lastWeekStart = now.subtract(const Duration(days: 14));
    final twoWeeksStart = now.subtract(const Duration(days: 21));

    if (mode == 'this') {
      return all.where((s) {
        return s.firstDate.isAfter(thisWeekStart);
      }).toList();
    } else if (mode == 'last') {
      return all.where((s) {
        return s.firstDate.isAfter(lastWeekStart) &&
            s.firstDate.isBefore(thisWeekStart);
      }).toList();
    } else {
      return all.where((s) {
        return s.firstDate.isAfter(twoWeeksStart) &&
            s.firstDate.isBefore(lastWeekStart);
      }).toList();
    }
  }

  // For a given sessionId, group all sets by exercise name
  Future<Map<String, List<WorkoutEntry>>> getEntriesGroupedByExercise(
    String sessionId,
  ) async {
    final sets = await getSetsForSession(sessionId);

    // map["Bench Press"] = [list of sets for Bench Press...]
    final map = <String, List<WorkoutEntry>>{};
    for (final s in sets) {
      map.putIfAbsent(s.exercise, () => []);
      map[s.exercise]!.add(s);
    }
    return map;
  }
}

// Small helper model that represents a workout session summary
class WorkoutSessionMeta {
  final String sessionId; // unique workout session ID
  final DateTime firstDate; // when that workout happened
  WorkoutSessionMeta({required this.sessionId, required this.firstDate});
}
