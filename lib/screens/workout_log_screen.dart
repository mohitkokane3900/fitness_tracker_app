import 'package:flutter/material.dart';

class WorkoutLogScreen extends StatefulWidget {
  const WorkoutLogScreen({super.key});
  @override
  State<WorkoutLogScreen> createState() => _WorkoutLogScreenState();
}

class _WorkoutLogScreenState extends State<WorkoutLogScreen> {
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

  void _addSetForBlock(_ExerciseBlock b) {
    final exName = b.exerciseCtl.text.trim();
    final wt = b.weightCtl.text.trim();
    final rp = b.repsCtl.text.trim();
    final nt = b.notesCtl.text.trim();

    if (exName.isEmpty || wt.isEmpty || rp.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Fill exercise, weight, reps')),
      );
      return;
    }

    setState(() {
      b.loggedSets.add('$wt lb x $rp\n$nt');
      b.weightCtl.clear();
      b.repsCtl.clear();
    });
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
                crossAxisAlignment: CrossAxisAlignment.start,
                children: b.loggedSets.map((s) {
                  return Text(s);
                }).toList(),
              ),
          ],
        ),
      ),
    );
  }

  void _discardWorkout() {
    setState(() {
      blocks.clear();
      blocks.add(_ExerciseBlock());
    });
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Workout discarded')));
  }

  void _saveWorkout() {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Workout saved')));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Workout Log')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
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
  final List<String> loggedSets = [];
}
