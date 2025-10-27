// Represents a single workout set (exercise, weight, reps, etc.)
class WorkoutEntry {
  int? id; // null before it's inserted into DB
  String workoutSessionId; // unique id for the workout session/day
  String exercise; // exercise name (ex: Bench Press)
  String? notes; // optional notes user typed
  double weight; // weight used for this set
  int reps; // reps done for this set
  DateTime sessionDate; // when the set was logged

  WorkoutEntry({
    this.id,
    required this.workoutSessionId,
    required this.exercise,
    required this.notes,
    required this.weight,
    required this.reps,
    required this.sessionDate,
  });

  // Convert this object to a Map for inserting into SQLite
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'workout_session_id': workoutSessionId,
      'exercise': exercise,
      'notes': notes,
      'weight': weight,
      'reps': reps,
      'session_date': sessionDate.toIso8601String(),
    };
  }

  // Create a WorkoutEntry object from a DB row (Map)
  factory WorkoutEntry.fromMap(Map<String, dynamic> m) {
    return WorkoutEntry(
      id: m['id'] as int?,
      workoutSessionId: m['workout_session_id'] as String,
      exercise: m['exercise'] as String,
      notes: m['notes'] as String?,
      weight: (m['weight'] as num).toDouble(),
      reps: (m['reps'] as num).toInt(),
      sessionDate: DateTime.parse(m['session_date'] as String),
    );
  }
}
