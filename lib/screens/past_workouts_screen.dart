import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../repositories/workout_repository.dart';
import '../models/workout_entry.dart';

class PastWorkoutsScreen extends StatefulWidget {
  const PastWorkoutsScreen({super.key});
  @override
  State<PastWorkoutsScreen> createState() => _PastWorkoutsScreenState();
}

class _PastWorkoutsScreenState extends State<PastWorkoutsScreen> {
  final repo = WorkoutRepository();

  String mode = 'this';
  List<_SessionDisplay> sessions = [];

  @override
  void initState() {
    super.initState();
    _loadMode('this');
  }

  Future<void> _loadMode(String newMode) async {
    final metas = await repo.getWorkoutSessionsFiltered(newMode);

    final List<_SessionDisplay> built = [];
    for (final m in metas) {
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
            Text(
              hdr,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            Text(
              'Found ${sessions.length} workout(s)',
              style: const TextStyle(fontSize: 14),
            ),
            const SizedBox(height: 16),
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

class _WorkoutSessionCard extends StatelessWidget {
  final _SessionDisplay display;
  const _WorkoutSessionCard({required this.display});

  @override
  Widget build(BuildContext context) {
    final f = DateFormat('EEE MMM d, h:mm a');
    final exNames = display.exercises.keys.toList();

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              f.format(display.date),
              style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
            ),
            const SizedBox(height: 12),
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
          Text(
            exerciseName,
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 8),
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

class _SessionDisplay {
  final String sessionId;
  final DateTime date;
  final Map<String, List<WorkoutEntry>> exercises;
  _SessionDisplay({
    required this.sessionId,
    required this.date,
    required this.exercises,
  });
}
