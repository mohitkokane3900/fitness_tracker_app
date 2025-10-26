import 'package:flutter/material.dart';

class WorkoutProgramsScreen extends StatelessWidget {
  const WorkoutProgramsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final programs = [
      _ProgramData(
        title: 'Full Body Plan',
        exercises: [
          _ExerciseData(name: 'Bench Press', sets: 1),
          _ExerciseData(name: 'Seated Row', sets: 1),
          _ExerciseData(name: 'Shoulder Press', sets: 1),
          _ExerciseData(name: 'Bicep Curl', sets: 1),
          _ExerciseData(name: 'Tricep Extension', sets: 1),
          _ExerciseData(name: 'Leg Press', sets: 1),
          _ExerciseData(name: 'Leg Extension', sets: 1),
          _ExerciseData(name: 'Leg Curl', sets: 1),
          _ExerciseData(name: 'Calf Raise', sets: 1),
        ],
      ),
      _ProgramData(
        title: 'Upper Plan (Push Focus)',
        exercises: [
          _ExerciseData(name: 'Pec Fly', sets: 2),
          _ExerciseData(name: 'Dumbbell Front Raise', sets: 2),
          _ExerciseData(name: 'Tricep Pushdown Straightbar', sets: 2),
          _ExerciseData(name: 'Cable Lateral Raise', sets: 2),
          _ExerciseData(name: 'Seated Row', sets: 1),
          _ExerciseData(name: 'Lat Pulldown', sets: 1),
          _ExerciseData(name: 'Cable Bicep Curl', sets: 1),
        ],
      ),
      _ProgramData(
        title: 'Upper Plan (Pull Focus)',
        exercises: [
          _ExerciseData(name: 'Seated Row', sets: 2),
          _ExerciseData(name: 'Lat Pulldown', sets: 2),
          _ExerciseData(name: 'Cable Bicep Curl', sets: 2),
          _ExerciseData(name: 'Pec Fly', sets: 2),
          _ExerciseData(name: 'Cable Lateral Raise', sets: 2),
          _ExerciseData(name: 'Dumbbell Front Raise', sets: 1),
          _ExerciseData(name: 'Tricep Pushdown Straightbar', sets: 1),
        ],
      ),
      _ProgramData(
        title: 'Lower Plan',
        exercises: [
          _ExerciseData(name: 'Leg Press', sets: 1),
          _ExerciseData(name: 'Hip Thrust', sets: 1),
          _ExerciseData(name: 'Leg Extension', sets: 1),
          _ExerciseData(name: 'Leg Curl', sets: 1),
          _ExerciseData(name: 'Calf Raise', sets: 1),
        ],
      ),
    ];

    return Scaffold(
      appBar: AppBar(title: const Text('Workout Programs')),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: programs.length,
        itemBuilder: (context, index) {
          final p = programs[index];
          return _ProgramCard(program: p);
        },
      ),
    );
  }
}

class _ProgramCard extends StatelessWidget {
  final _ProgramData program;
  const _ProgramCard({required this.program});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              program.title,
              style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
            ),
            const SizedBox(height: 12),
            Column(
              children: program.exercises.map((ex) {
                return _ProgramExerciseRow(data: ex);
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }
}

class _ProgramExerciseRow extends StatelessWidget {
  final _ExerciseData data;
  const _ProgramExerciseRow({required this.data});

  @override
  Widget build(BuildContext context) {
    final setsStr = data.sets == 1 ? '1 set' : '${data.sets} sets';
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.orange),
        borderRadius: BorderRadius.circular(8),
      ),
      padding: const EdgeInsets.all(12),
      child: Text(
        '${data.name}\n$setsStr • 4-8 reps',
        style: const TextStyle(fontSize: 14),
      ),
    );
  }
}

class _ProgramData {
  final String title;
  final List<_ExerciseData> exercises;
  _ProgramData({required this.title, required this.exercises});
}

class _ExerciseData {
  final String name;
  final int sets;
  _ExerciseData({required this.name, required this.sets});
}
