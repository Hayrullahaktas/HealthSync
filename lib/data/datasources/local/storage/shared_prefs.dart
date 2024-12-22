
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../core/constants/storage_constants.dart';

class SharedPrefsService {
  late SharedPreferences _prefs;

  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  Future<void> saveUserProfile({
    required String name,
    required double height,
    required double weight,
    required int age,
  }) async {
    await _prefs.setString(StorageConstants.keyUserName, name);
    await _prefs.setDouble(StorageConstants.keyUserHeight, height);
    await _prefs.setDouble(StorageConstants.keyUserWeight, weight);
    await _prefs.setInt(StorageConstants.keyUserAge, age);
  }

  Future<void> saveDailyGoal(int steps) async {
    await _prefs.setInt(StorageConstants.keyDailyGoal, steps);
  }

  Future<void> saveThemeMode(bool isDarkMode) async {
    await _prefs.setBool(StorageConstants.keyThemeMode, isDarkMode);
  }

  String? getUserName() => _prefs.getString(StorageConstants.keyUserName);
  double? getUserHeight() => _prefs.getDouble(StorageConstants.keyUserHeight);
  double? getUserWeight() => _prefs.getDouble(StorageConstants.keyUserWeight);
  int? getUserAge() => _prefs.getInt(StorageConstants.keyUserAge);
  int getDailyGoal() => _prefs.getInt(StorageConstants.keyDailyGoal) ?? 10000;
  bool isDarkMode() => _prefs.getBool(StorageConstants.keyThemeMode) ?? false;
}