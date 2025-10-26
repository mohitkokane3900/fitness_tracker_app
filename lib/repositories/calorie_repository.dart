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

  Future<Map<String, double>> getTotalsByRange(Duration range) async {
    final db = await dbHelper.database;

    final now = DateTime.now();
    final cutoff = now.subtract(range);

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

    if (rows.isEmpty) {
      return {'cal': 0, 'protein': 0, 'fat': 0, 'carbs': 0};
    }

    final row = rows.first;
    final cal = (row['total_cal'] as num?)?.toDouble() ?? 0.0;
    final protein = (row['total_protein'] as num?)?.toDouble() ?? 0.0;
    final fat = (row['total_fat'] as num?)?.toDouble() ?? 0.0;
    final carbs = (row['total_carbs'] as num?)?.toDouble() ?? 0.0;

    return {'cal': cal, 'protein': protein, 'fat': fat, 'carbs': carbs};
  }
}
