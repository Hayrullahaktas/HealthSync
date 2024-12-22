
import 'package:flutter/foundation.dart';
import '../../data/repositories/database_repository.dart';
import '../../data/models/user_model.dart';
import '../../data/models/exercise_model.dart';
import '../../data/models/nutrition_model.dart';

class DatabaseProvider extends ChangeNotifier {
  final DatabaseRepository _repository;

  UserModel? _currentUser;
  List<ExerciseModel> _exercises = [];
  List<NutritionModel> _nutritionEntries = [];
  Map<String, double> _dailyNutritionSummary = {};

  DatabaseProvider({required DatabaseRepository repository})
      : _repository = repository;

  // Getters
  UserModel? get currentUser => _currentUser;
  List<ExerciseModel> get exercises => _exercises;
  List<NutritionModel> get nutritionEntries => _nutritionEntries;
  Map<String, double> get dailyNutritionSummary => _dailyNutritionSummary;

  Future<void> loadUser(int userId) async {
    try {
      _currentUser = await _repository.getUser(userId);
      notifyListeners();
    } catch (e) {
      debugPrint('Error loading user: $e');
    }
  }

  Future<void> loadUserExercises(int userId) async {
    try {
      _exercises = await _repository.getUserExercises(userId);
      notifyListeners();
    } catch (e) {
      debugPrint('Error loading exercises: $e');
    }
  }

  Future<void> loadUserNutrition(int userId) async {
    try {
      _nutritionEntries = await _repository.getUserNutrition(userId);
      notifyListeners();
    } catch (e) {
      debugPrint('Error loading nutrition: $e');
    }
  }

  Future<void> loadDailyNutritionSummary(int userId, DateTime date) async {
    try {
      _dailyNutritionSummary =
      await _repository.getDailyNutritionSummary(userId, date);
      notifyListeners();
    } catch (e) {
      debugPrint('Error loading daily nutrition summary: $e');
    }
  }

  Future<void> addExercise(ExerciseModel exercise) async {
    try {
      await _repository.saveExercise(exercise);
      _exercises.add(exercise);
      notifyListeners();
    } catch (e) {
      debugPrint('Error adding exercise: $e');
      rethrow;
    }
  }

  Future<void> addNutrition(NutritionModel nutrition) async {
    try {
      await _repository.saveNutrition(nutrition);
      _nutritionEntries.add(nutrition);
      notifyListeners();
    } catch (e) {
      debugPrint('Error adding nutrition: $e');
      rethrow;
    }
  }
}