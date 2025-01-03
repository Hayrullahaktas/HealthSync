
import 'package:sqflite/sqflite.dart';
import '../../../../models/exercise_model.dart';
import '../app_database.dart';

class ExerciseDao {
  static const String tableName = 'exercises';

  Future<int> insertExercise(ExerciseModel exercise) async {
    final db = await AppDatabase.database;
    return await db.insert(tableName, exercise.toMap());
  }

  Future<ExerciseModel?> getExercise(int id) async {
    final db = await AppDatabase.database;
    final List<Map<String, dynamic>> maps = await db.query(
      tableName,
      where: 'id = ?',
      whereArgs: [id],
    );

    if (maps.isEmpty) return null;
    return ExerciseModel.fromMap(maps.first);
  }

  Future<List<ExerciseModel>> getExercisesForUser(int userId) async {
    final db = await AppDatabase.database;
    final List<Map<String, dynamic>> maps = await db.query(
      tableName,
      where: 'user_id = ?',
      whereArgs: [userId],
    );
    return List.generate(maps.length, (i) => ExerciseModel.fromMap(maps[i]));
  }

  Future<List<ExerciseModel>> getExercisesByDateRange(
      int userId,
      DateTime startDate,
      DateTime endDate,
      ) async {
    final db = await AppDatabase.database;
    final List<Map<String, dynamic>> maps = await db.query(
      tableName,
      where: 'user_id = ? AND date BETWEEN ? AND ?',
      whereArgs: [userId, startDate.toIso8601String(), endDate.toIso8601String()],
    );
    return List.generate(maps.length, (i) => ExerciseModel.fromMap(maps[i]));
  }

  Future<int> updateExercise(ExerciseModel exercise) async {
    final db = await AppDatabase.database;
    return await db.update(
      tableName,
      exercise.toMap(),
      where: 'id = ?',
      whereArgs: [exercise.id],
    );
  }

  Future<int> deleteExercise(int id) async {
    final db = await AppDatabase.database;
    return await db.delete(
      tableName,
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<int> deleteAllForUser(int userId) async {
    final db = await AppDatabase.database;
    return await db.delete(
      tableName,
      where: 'user_id = ?',
      whereArgs: [userId],
    );
  }
}
