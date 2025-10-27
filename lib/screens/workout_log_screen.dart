import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../repositories/workout_repository.dart';
import '../models/workout_entry.dart';

// Screen where user logs today's workout sets
class WorkoutLogScreen extends StatefulWidget {
  const WorkoutLogScreen({super.key});
  @override
  State<WorkoutLogScreen> createState() => _WorkoutLogScreenState();
}

class _WorkoutLogScreenState extends State<WorkoutLogScreen> {
  final repo = WorkoutRepository();

  // Unique id for this workout session (timestamp in ms)
  final String sessionId = DateTime.now().millisecondsSinceEpoch.toString();

  // List of exercise "blocks" (each block is one exercise with its sets)
  final List<_ExerciseBlock> blocks = [];

  @override
  void initState() {
    super.initState();
    _addNewBlock(); // start with 1 empty block
  }

  // Add a new empty exercise block to the workout
  void _addNewBlock() {
    setState(() {
      blocks.add(_ExerciseBlock());
    });
  }

  // Delete all sets in this session from the DB and reset UI
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

  // Right now this just shows a snackbar.
  // Data is already being saved set-by-set when you press "+"
  Future<void> _saveWorkout() async {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Workout saved')));
  }

  // Called when user taps "+" to save one set for that exercise block
  Future<void> _addSetForBlock(_ExerciseBlock b) async {
    final exName = b.exerciseCtl.text.trim();
    final wt = double.tryParse(b.weightCtl.text.trim());
    final rp = int.tryParse(b.repsCtl.text.trim());
    final nt = b.notesCtl.text.trim();

    // basic validation
    if (exName.isEmpty || wt == null || rp == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Fill exercise, weight, reps')),
      );
      return;
    }

    try {
      // Build the WorkoutEntry model using text field values
      final entry = WorkoutEntry(
        workoutSessionId: sessionId,
        exercise: exName,
        notes: nt.isEmpty ? null : nt,
        weight: wt,
        reps: rp,
        sessionDate: DateTime.now(),
      );

      // Insert into DB
      await repo.addSetToWorkout(entry);

      // Get the latest set for this exercise (for "Previous" box)
      final latest = await repo.getLatestSetForExercise(exName);

      // Get all sets for only this session so far
      final updatedSets = await repo.getSetsForSession(sessionId);

      // Filter to only the sets for this specific exercise block
      final onlyThisExercise = updatedSets
          .where((s) => s.exercise == exName)
          .toList();

      // Update the UI for that block
      setState(() {
        b.previousForExercise = latest;
        b.loggedSets = onlyThisExercise;
        b.weightCtl.clear();
        b.repsCtl.clear();
      });

      // Notify user
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Added set for $exName')));
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error saving set: $e')));
    }
  }

  // Builds the card UI for one exercise block
  Widget _buildBlockCard(_ExerciseBlock b) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16), // ✅ FIXED
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Exercise name field
            TextField(
              controller: b.exerciseCtl,
              decoration: const InputDecoration(
                labelText: 'Exercise Name (e.g. Chest Press)',
                border: OutlineInputBorder(),
              ),
              // When the exercise name changes, try to load "Previous" data
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

            // Notes field (optional)
            TextField(
              controller: b.notesCtl,
              decoration: const InputDecoration(
                labelText: 'Add notes here...',
                border: OutlineInputBorder(),
              ),
              maxLines: 2,
            ),
            const SizedBox(height: 12),

            // Box that shows "Previous" best/latest set for this exercise
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

            // Row for Weight/Reps input + "+" button to save the set
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

            // List of sets logged for THIS exercise in THIS workout
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
    // Show current date/time at top
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

            // Render all exercise blocks
            Column(children: blocks.map(_buildBlockCard).toList()),

            const SizedBox(height: 12),

            // Button: add another exercise block
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

            // Button: save workout (right now mostly UI feedback)
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

            // Button: discard workout (clears data for this session)
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

// Holds state for one exercise block in the workout log form
class _ExerciseBlock {
  final TextEditingController exerciseCtl = TextEditingController();
  final TextEditingController notesCtl = TextEditingController();
  final TextEditingController weightCtl = TextEditingController();
  final TextEditingController repsCtl = TextEditingController();

  WorkoutEntry? previousForExercise; // last logged set for this exercise
  List<WorkoutEntry> loggedSets = []; // sets user logged this session
}
