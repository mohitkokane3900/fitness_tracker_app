import '../data/database_helper.dart';

// All database actions related to calories/macros live here
class CalorieRepository {
  final dbHelper = DatabaseHelper();

  // Add a meal (one row) to calorie_logs table
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

  // Get every meal in reverse time order (newest first)
  Future<List<Map<String, dynamic>>> getAllMeals() async {
    final db = await dbHelper.database;
    final rows = await db.query('calorie_logs', orderBy: 'date_time DESC');
    return rows;
  }

  // Get total cals/macros for a time range (like last 7 days)
  Future<Map<String, double>> getTotalsByRange(Duration range) async {
    final db = await dbHelper.database;

    final now = DateTime.now();
    final cutoff = now.subtract(range);

    // SUM(...) gives us total calories, protein, fat, carbs after cutoff
    final rows = await db.rawQuery(
      '''
      SELECT
        SUM(calories) as total_cal,
        SUM(protein_g) as total_protein,
        SUM(fat_g) as total_fat,
        SUM(carbs_g) as total_carbs
      FROM calorie_logs
      WHERE date_time >= ?
    ''',
      [cutoff.toIso8601String()],
    );

    // If there's no data, just return zeros
    if (rows.isEmpty) {
      return {'cal': 0, 'protein': 0, 'fat': 0, 'carbs': 0};
    }

    // Pull values from the query result
    final row = rows.first;
    final cal = (row['total_cal'] as num?)?.toDouble() ?? 0.0;
    final protein = (row['total_protein'] as num?)?.toDouble() ?? 0.0;
    final fat = (row['total_fat'] as num?)?.toDouble() ?? 0.0;
    final carbs = (row['total_carbs'] as num?)?.toDouble() ?? 0.0;

    return {'cal': cal, 'protein': protein, 'fat': fat, 'carbs': carbs};
  }
}
