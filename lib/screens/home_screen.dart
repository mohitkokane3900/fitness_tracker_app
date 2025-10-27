import 'package:flutter/material.dart';
import 'workout_log_screen.dart';
import 'calorie_tracker_screen.dart';
import 'summary_screen.dart';
import 'nutrition_summary_screen.dart';
import 'past_workouts_screen.dart';
import 'workout_programs_screen.dart';

// Main menu screen with all the navigation buttons
class HomeScreen extends StatelessWidget {
  final bool dark; // whether dark mode is currently on
  final ValueChanged<bool> onThemeChanged; // callback to toggle theme

  const HomeScreen({
    super.key,
    required this.dark,
    required this.onThemeChanged,
  });

  @override
  Widget build(BuildContext context) {
    final bg = Theme.of(context).colorScheme.surface; // background color
    return Scaffold(
      appBar: AppBar(title: const Text('Fitness Tracker')),
      body: Container(
        width: double.infinity,
        color: bg,
        padding: const EdgeInsets.all(24),
        child: SingleChildScrollView(
          child: Column(
            children: [
              const Text(
                'Welcome to Fitness Tracker App',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 24),

              // Dark mode toggle
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('Dark Mode'),
                  Switch(value: dark, onChanged: onThemeChanged),
                ],
              ),

              const SizedBox(height: 24),

              // Button: Workout Log
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const WorkoutLogScreen(),
                      ),
                    );
                  },
                  child: const Text('Workout Log'),
                ),
              ),
              const SizedBox(height: 12),

              // Button: Calorie Tracker
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const CalorieTrackerScreen(),
                      ),
                    );
                  },
                  child: const Text('Calorie Tracker'),
                ),
              ),
              const SizedBox(height: 12),

              // Button: Workout Summary / bar chart
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const SummaryScreen()),
                    );
                  },
                  child: const Text('Workout Summary'),
                ),
              ),
              const SizedBox(height: 12),

              // Button: Nutrition Summary / donut chart
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const NutritionSummaryScreen(),
                      ),
                    );
                  },
                  child: const Text('Nutrition Summary'),
                ),
              ),
              const SizedBox(height: 12),

              // Button: Past Workouts
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const PastWorkoutsScreen(),
                      ),
                    );
                  },
                  child: const Text('Past Workouts'),
                ),
              ),
              const SizedBox(height: 12),

              // Button: Workout Programs
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const WorkoutProgramsScreen(),
                      ),
                    );
                  },
                  child: const Text('Workout Programs'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
