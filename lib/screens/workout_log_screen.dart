import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../repositories/workout_repository.dart';
import '../models/workout_entry.dart';

class WorkoutLogScreen extends StatefulWidget {
  const WorkoutLogScreen({super.key});
  @override
  State<WorkoutLogScreen> createState() => _WorkoutLogScreenState();
}

class _WorkoutLogScreenState extends State<WorkoutLogScreen> {
  final repo = WorkoutRepository();
  final String sessionId = DateTime.now().millisecondsSinceEpoch.toString();
  final List<_ExerciseBlock> blocks = [];

  @override
  void initState() {
    super.initState();
    _addNewBlock();
  }

  void _addNewBlock() {
    setState(() {
      blocks.add(_ExerciseBlock());
    });
  }

  Future<void> _discardWorkout() async {
    await repo.discardWorkoutSession(sessionId);
    setState(() {
      blocks.clear();
      blocks.add(_ExerciseBlock());
    });
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Workout discarded')));
  }

  Future<void> _saveWorkout() async {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Workout saved')));
  }

  Future<void> _addSetForBlock(_ExerciseBlock b) async {
    final exName = b.exerciseCtl.text.trim();
    final wt = double.tryParse(b.weightCtl.text.trim());
    final rp = int.tryParse(b.repsCtl.text.trim());
    final nt = b.notesCtl.text.trim();

    if (exName.isEmpty || wt == null || rp == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Fill exercise, weight, reps')),
      );
      return;
    }

    try {
      final entry = WorkoutEntry(
        workoutSessionId: sessionId,
        exercise: exName,
        notes: nt.isEmpty ? null : nt,
        weight: wt,
        reps: rp,
        sessionDate: DateTime.now(),
      );

      await repo.addSetToWorkout(entry);

      final latest = await repo.getLatestSetForExercise(exName);
      final updatedSets = await repo.getSetsForSession(sessionId);
      final onlyThisExercise = updatedSets
          .where((s) => s.exercise == exName)
          .toList();

      setState(() {
        b.previousForExercise = latest;
        b.loggedSets = onlyThisExercise;
        b.weightCtl.clear();
        b.repsCtl.clear();
      });

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Added set for $exName')));
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error saving set: $e')));
    }
  }

  Widget _buildBlockCard(_ExerciseBlock b) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: b.exerciseCtl,
              decoration: const InputDecoration(
                labelText: 'Exercise Name (e.g. Chest Press)',
                border: OutlineInputBorder(),
              ),
              onChanged: (_) async {
                final name = b.exerciseCtl.text.trim();
                if (name.isEmpty) return;
                final latest = await repo.getLatestSetForExercise(name);
                setState(() {
                  b.previousForExercise = latest;
                });
              },
            ),
            const SizedBox(height: 12),
            TextField(
              controller: b.notesCtl,
              decoration: const InputDecoration(
                labelText: 'Add notes here...',
                border: OutlineInputBorder(),
              ),
              maxLines: 2,
            ),
            const SizedBox(height: 12),
            if (b.previousForExercise != null)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.orange),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  'Previous: ${b.previousForExercise!.weight} lb x ${b.previousForExercise!.reps} reps',
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
              ),
            if (b.previousForExercise != null) const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: b.weightCtl,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Weight',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextField(
                    controller: b.repsCtl,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Reps',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                ElevatedButton(
                  onPressed: () {
                    _addSetForBlock(b);
                  },
                  child: const Text('+'),
                ),
              ],
            ),
            const SizedBox(height: 16),
            const Text(
              'Sets logged for this exercise',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            if (b.loggedSets.isEmpty)
              const Text('No sets yet')
            else
              Column(
                children: b.loggedSets.map((w) {
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
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final dateLabel = DateFormat('EEE MMM d, h:mm a').format(DateTime.now());

    return Scaffold(
      appBar: AppBar(title: const Text('Workout Log')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(dateLabel, style: const TextStyle(fontSize: 16)),
            const SizedBox(height: 16),
            Column(children: blocks.map(_buildBlockCard).toList()),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blueGrey,
                ),
                onPressed: _addNewBlock,
                child: const Text('+ Add Exercise'),
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                onPressed: _saveWorkout,
                child: const Text('Save Workout'),
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                onPressed: _discardWorkout,
                child: const Text('Discard Workout'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ExerciseBlock {
  final TextEditingController exerciseCtl = TextEditingController();
  final TextEditingController notesCtl = TextEditingController();
  final TextEditingController weightCtl = TextEditingController();
  final TextEditingController repsCtl = TextEditingController();
  WorkoutEntry? previousForExercise;
  List<WorkoutEntry> loggedSets = [];
}
