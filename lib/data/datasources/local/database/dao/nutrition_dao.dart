
import 'package:sqflite/sqflite.dart';
import '../../../../models/nutrition_model.dart';
import '../app_database.dart';

class NutritionDao {
  static const String tableName = 'nutrition';

  Future<int> insertNutrition(NutritionModel nutrition) async {
    final db = await AppDatabase.database;
    return await db.insert(tableName, nutrition.toMap());
  }

  Future<NutritionModel?> getNutrition(int id) async {
    final db = await AppDatabase.database;
    final List<Map<String, dynamic>> maps = await db.query(
      tableName,
      where: 'id = ?',
      whereArgs: [id],
    );

    if (maps.isEmpty) return null;
    return NutritionModel.fromMap(maps.first);
  }

  Future<List<NutritionModel>> getNutritionForUser(int userId) async {
    final db = await AppDatabase.database;
    final List<Map<String, dynamic>> maps = await db.query(
      tableName,
      where: 'user_id = ?',
      whereArgs: [userId],
    );
    return List.generate(maps.length, (i) => NutritionModel.fromMap(maps[i]));
  }

  Future<List<NutritionModel>> getNutritionByDateRange(
      int userId,
      DateTime startDate,
      DateTime endDate,
      ) async {
    final db = await AppDatabase.database;
    final List<Map<String, dynamic>> maps = await db.query(
      tableName,
      where: 'user_id = ? AND consumed_at BETWEEN ? AND ?',
      whereArgs: [userId, startDate.toIso8601String(), endDate.toIso8601String()],
    );
    return List.generate(maps.length, (i) => NutritionModel.fromMap(maps[i]));
  }

  Future<Map<String, double>> getDailyNutritionSummary(
      int userId,
      DateTime date,
      ) async {
    final db = await AppDatabase.database;
    final startOfDay = DateTime(date.year, date.month, date.day);
    final endOfDay = startOfDay.add(const Duration(days: 1));

    final result = await db.rawQuery('''
      SELECT 
        SUM(calories) as total_calories,
        SUM(protein) as total_protein,
        SUM(carbs) as total_carbs,
        SUM(fat) as total_fat
      FROM $tableName
      WHERE user_id = ? AND consumed_at BETWEEN ? AND ?
    ''', [userId, startOfDay.toIso8601String(), endOfDay.toIso8601String()]);

    return {
      'calories': result.first['total_calories'] as double? ?? 0.0,
      'protein': result.first['total_protein'] as double? ?? 0.0,
      'carbs': result.first['total_carbs'] as double? ?? 0.0,
      'fat': result.first['total_fat'] as double? ?? 0.0,
    };
  }

  Future<int> updateNutrition(NutritionModel nutrition) async {
    final db = await AppDatabase.database;
    return await db.update(
      tableName,
      nutrition.toMap(),
      where: 'id = ?',
      whereArgs: [nutrition.id],
    );
  }

  Future<int> deleteNutrition(int id) async {
    final db = await AppDatabase.database;
    return await db.delete(
      tableName,
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}