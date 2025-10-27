import 'package:flutter/material.dart';
import '../repositories/calorie_repository.dart';
import 'package:intl/intl.dart';

// Screen where user can log meals + view meal history
class CalorieTrackerScreen extends StatefulWidget {
  const CalorieTrackerScreen({super.key});
  @override
  State<CalorieTrackerScreen> createState() => _CalorieTrackerScreenState();
}

class _CalorieTrackerScreenState extends State<CalorieTrackerScreen> {
  final repo = CalorieRepository();

  // Controllers for the text fields
  final TextEditingController mealCtl = TextEditingController();
  final TextEditingController calCtl = TextEditingController();
  final TextEditingController proteinCtl = TextEditingController();
  final TextEditingController fatCtl = TextEditingController();
  final TextEditingController carbsCtl = TextEditingController();

  // List of meal rows from the database
  List<Map<String, dynamic>> meals = [];

  @override
  void initState() {
    super.initState();
    _refreshMeals(); // load meals when screen opens
  }

  // Pull meals from DB and show them in the UI
  Future<void> _refreshMeals() async {
    final data = await repo.getAllMeals();
    setState(() {
      meals = data;
    });
  }

  // Add a meal to the DB using the values from the text fields
  Future<void> _addMeal() async {
    final mealName = mealCtl.text.trim();
    final cal = int.tryParse(calCtl.text.trim()) ?? 0;
    final p = double.tryParse(proteinCtl.text.trim()) ?? 0;
    final f = double.tryParse(fatCtl.text.trim()) ?? 0;
    final c = double.tryParse(carbsCtl.text.trim()) ?? 0;

    // basic validation
    if (mealName.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Enter meal info')));
      return;
    }

    // Save in DB
    await repo.addMeal(
      mealDesc: mealName,
      calories: cal,
      proteinG: p,
      fatG: f,
      carbsG: c,
      dateTime: DateTime.now(),
    );

    // Clear inputs after save
    mealCtl.clear();
    calCtl.clear();
    proteinCtl.clear();
    fatCtl.clear();
    carbsCtl.clear();

    // Refresh meal list
    await _refreshMeals();
  }

  @override
  Widget build(BuildContext context) {
    final f = DateFormat('MMM d, h:mm a'); // format for date/time display

    return Scaffold(
      appBar: AppBar(title: const Text('Calorie Tracker')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Meal name / notes input
            TextField(
              controller: mealCtl,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'Meal / Notes',
              ),
            ),
            const SizedBox(height: 12),

            // Calories input
            TextField(
              controller: calCtl,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'Calories',
              ),
            ),
            const SizedBox(height: 12),

            // Macro inputs in a row
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: proteinCtl,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: 'Protein (g)',
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: TextField(
                    controller: fatCtl,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: 'Fat (g)',
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: TextField(
                    controller: carbsCtl,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: 'Carbs (g)',
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            // Add meal button
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                onPressed: _addMeal,
                child: const Text('+ Add Meal Cal'),
              ),
            ),

            const SizedBox(height: 16),

            // List of saved meals
            Expanded(
              child: meals.isEmpty
                  ? const Center(child: Text('No meals yet'))
                  : ListView.builder(
                      itemCount: meals.length,
                      itemBuilder: (context, index) {
                        final row = meals[index];
                        final dt = DateTime.parse(row['date_time'] as String);
                        final timeStr = f.format(dt);
                        final mealName = row['meal_desc'] ?? '';
                        final calAmt = row['calories'] ?? 0;
                        final p = row['protein_g'] ?? 0;
                        final fat = row['fat_g'] ?? 0;
                        final carb = row['carbs_g'] ?? 0;

                        // Card for each meal entry
                        return Card(
                          margin: const EdgeInsets.only(bottom: 12),
                          child: Padding(
                            padding: const EdgeInsets.all(12),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // timestamp
                                Text(
                                  timeStr,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const SizedBox(height: 4),

                                // meal details
                                Text('$mealName'),
                                Text('Calories: $calAmt'),
                                Text('Protein: ${p.toString()} g'),
                                Text('Fat: ${fat.toString()} g'),
                                Text('Carbs: ${carb.toString()} g'),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
