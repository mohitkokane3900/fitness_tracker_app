import '../data/database_helper.dart';

class CalorieRepository {
  final dbHelper = DatabaseHelper();

  Future<int> addMeal({
    required String mealDesc,
    required int calories,
    required double proteinG,
    required double fatG,
    required double carbsG,
    required DateTime dateTime,
  }) async {
    final db = await dbHelper.database;
    return db.insert('calorie_logs', {
      'meal_desc': mealDesc,
      'calories': calories,
      'protein_g': proteinG,
      'fat_g': fatG,
      'carbs_g': carbsG,
      'date_time': dateTime.toIso8601String(),
    });
  }

  Future<List<Map<String, dynamic>>> getAllMeals() async {
    final db = await dbHelper.database;
    final rows = await db.query('calorie_logs', orderBy: 'date_time DESC');
    return rows;
  }
}
