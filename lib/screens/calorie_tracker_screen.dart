import 'package:flutter/material.dart';

class CalorieTrackerScreen extends StatefulWidget {
  const CalorieTrackerScreen({super.key});
  @override
  State<CalorieTrackerScreen> createState() => _CalorieTrackerScreenState();
}

class _CalorieTrackerScreenState extends State<CalorieTrackerScreen> {
  final TextEditingController mealCtl = TextEditingController();
  final TextEditingController calCtl = TextEditingController();
  final TextEditingController proteinCtl = TextEditingController();
  final TextEditingController fatCtl = TextEditingController();
  final TextEditingController carbsCtl = TextEditingController();

  final List<Map<String, dynamic>> meals = [];

  void _addMeal() {
    final mealName = mealCtl.text.trim();
    final cal = calCtl.text.trim();
    final p = proteinCtl.text.trim();
    final f = fatCtl.text.trim();
    final c = carbsCtl.text.trim();

    if (mealName.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Enter meal info')));
      return;
    }

    setState(() {
      meals.insert(0, {
        'meal_desc': mealName,
        'calories': cal,
        'protein_g': p,
        'fat_g': f,
        'carbs_g': c,
        'time': DateTime.now().toString(),
      });
    });

    mealCtl.clear();
    calCtl.clear();
    proteinCtl.clear();
    fatCtl.clear();
    carbsCtl.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Calorie Tracker')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: mealCtl,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'Meal / Notes',
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: calCtl,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'Calories',
              ),
            ),
            const SizedBox(height: 12),
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
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                onPressed: _addMeal,
                child: const Text('+ Add Meal Cal'),
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: meals.isEmpty
                  ? const Center(child: Text('No meals yet'))
                  : ListView.builder(
                      itemCount: meals.length,
                      itemBuilder: (context, index) {
                        final row = meals[index];
                        return Card(
                          margin: const EdgeInsets.only(bottom: 12),
                          child: Padding(
                            padding: const EdgeInsets.all(12),
                            child: Text(
                              '${row['meal_desc']}\nCalories: ${row['calories']}\nProtein: ${row['protein_g']} g\nFat: ${row['fat_g']} g\nCarbs: ${row['carbs_g']} g\n${row['time']}',
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
