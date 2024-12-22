import 'package:sqflite/sqflite.dart';
import '../../../../models/user_model.dart';
import '../app_database.dart';

class UserDao {
  static const String tableName = 'users';

  Future<int> insertUser(UserModel user) async {
    final db = await AppDatabase.database;
    return await db.insert(tableName, user.toMap());
  }

  Future<UserModel?> getUser(int id) async {
    final db = await AppDatabase.database;
    final List<Map<String, dynamic>> maps = await db.query(
      tableName,
      where: 'id = ?',
      whereArgs: [id],
    );

    if (maps.isEmpty) return null;
    return UserModel.fromMap(maps.first);
  }

  Future<List<UserModel>> getAllUsers() async {
    final db = await AppDatabase.database;
    final List<Map<String, dynamic>> maps = await db.query(tableName);
    return List.generate(maps.length, (i) => UserModel.fromMap(maps[i]));
  }

  Future<int> updateUser(UserModel user) async {
    final db = await AppDatabase.database;
    return await db.update(
      tableName,
      user.toMap(),
      where: 'id = ?',
      whereArgs: [user.id],
    );
  }

  Future<int> deleteUser(int id) async {
    final db = await AppDatabase.database;
    return await db.delete(
      tableName,
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}
