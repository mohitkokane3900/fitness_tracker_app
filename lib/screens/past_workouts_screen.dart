import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../repositories/workout_repository.dart';
import '../models/workout_entry.dart';

// Screen that shows past workouts (grouped by week)
class PastWorkoutsScreen extends StatefulWidget {
  const PastWorkoutsScreen({super.key});
  @override
  State<PastWorkoutsScreen> createState() => _PastWorkoutsScreenState();
}

class _PastWorkoutsScreenState extends State<PastWorkoutsScreen> {
  final repo = WorkoutRepository();

  // which "time window" we're showing
  String mode = 'this';

  // list of workout sessions to show in UI
  List<_SessionDisplay> sessions = [];

  @override
  void initState() {
    super.initState();
    _loadMode('this'); // default view = This Week
  }

  // Load workout sessions for a range then build display objects
  Future<void> _loadMode(String newMode) async {
    final metas = await repo.getWorkoutSessionsFiltered(newMode);

    final List<_SessionDisplay> built = [];
    for (final m in metas) {
      // Group each session's sets by exercise
      final grouped = await repo.getEntriesGroupedByExercise(m.sessionId);
      built.add(
        _SessionDisplay(
          sessionId: m.sessionId,
          date: m.firstDate,
          exercises: grouped,
        ),
      );
    }

    setState(() {
      mode = newMode;
      sessions = built;
    });
  }

  @override
  Widget build(BuildContext context) {
    // Header text based on mode
    final hdr = mode == 'this'
        ? 'This Week'
        : mode == 'last'
        ? 'Last Week'
        : '2 Weeks Ago';

    return Scaffold(
      appBar: AppBar(title: const Text('Past Workouts')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Buttons to switch time range
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  onPressed: () {
                    _loadMode('this');
                  },
                  child: const Text('This Week'),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: () {
                    _loadMode('last');
                  },
                  child: const Text('Last Week'),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: () {
                    _loadMode('2w');
                  },
                  child: const Text('2 Weeks Ago'),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Section header text
            Text(
              hdr,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),

            const SizedBox(height: 8),

            // How many workouts found
            Text(
              'Found ${sessions.length} workout(s)',
              style: const TextStyle(fontSize: 14),
            ),

            const SizedBox(height: 16),

            // Main list of workout session cards
            Expanded(
              child: sessions.isEmpty
                  ? const Center(child: Text('No workouts found'))
                  : ListView.builder(
                      itemCount: sessions.length,
                      itemBuilder: (context, i) {
                        final s = sessions[i];
                        return _WorkoutSessionCard(display: s);
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

// Card that shows one workout session (one day)
class _WorkoutSessionCard extends StatelessWidget {
  final _SessionDisplay display;
  const _WorkoutSessionCard({required this.display});

  @override
  Widget build(BuildContext context) {
    final f = DateFormat('EEE MMM d, h:mm a'); // ex: Mon Oct 7, 5:30 PM
    final exNames = display.exercises.keys.toList();

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16), // ✅ FIXED
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Date/time of workout
            Text(
              f.format(display.date),
              style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
            ),
            const SizedBox(height: 12),

            // For each exercise in that workout, show sets
            Column(
              children: exNames.map((exName) {
                final sets = display.exercises[exName] ?? [];
                return _ExerciseGroup(exerciseName: exName, sets: sets);
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }
}

// Box that shows the sets for a single exercise in a session
class _ExerciseGroup extends StatelessWidget {
  final String exerciseName;
  final List<WorkoutEntry> sets;

  const _ExerciseGroup({required this.exerciseName, required this.sets});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.orange),
        borderRadius: BorderRadius.circular(8),
      ),
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Exercise name
          Text(
            exerciseName,
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 8),

          // List each set: "100 lb x 10"
          Column(
            children: sets.map((w) {
              final notesLine = w.notes == null || w.notes!.isEmpty
                  ? ''
                  : '\n${w.notes}';
              return Align(
                alignment: Alignment.centerLeft,
                child: Text('${w.weight} lb x ${w.reps}$notesLine'),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}

// Internal model used for displaying past sessions on screen
class _SessionDisplay {
  final String sessionId;
  final DateTime date;
  final Map<String, List<WorkoutEntry>> exercises; // grouped by exercise name
  _SessionDisplay({
    required this.sessionId,
    required this.date,
    required this.exercises,
  });
}
