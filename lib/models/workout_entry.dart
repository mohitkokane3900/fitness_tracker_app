class WorkoutEntry {
  int? id;
  String workoutSessionId;
  String exercise;
  String? notes;
  double weight;
  int reps;
  DateTime sessionDate;

  WorkoutEntry({
    this.id,
    required this.workoutSessionId,
    required this.exercise,
    required this.notes,
    required this.weight,
    required this.reps,
    required this.sessionDate,
  });

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
