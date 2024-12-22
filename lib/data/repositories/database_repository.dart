
import '../datasources/local/database/dao/user_dao.dart';
import '../datasources/local/database/dao/exercise_dao.dart';
import '../datasources/local/database/dao/nutrition_dao.dart';
import '../models/user_model.dart';
import '../models/exercise_model.dart';
import '../models/nutrition_model.dart';

class DatabaseRepository {
  final UserDao _userDao;
  final ExerciseDao _exerciseDao;
  final NutritionDao _nutritionDao;

  DatabaseRepository({
    required UserDao userDao,
    required ExerciseDao exerciseDao,
    required NutritionDao nutritionDao,
  })  : _userDao = userDao,
        _exerciseDao = exerciseDao,
        _nutritionDao = nutritionDao;

  // User operations
  Future<int> saveUser(UserModel user) => _userDao.insertUser(user);
  Future<UserModel?> getUser(int id) => _userDao.getUser(id);
  Future<List<UserModel>> getAllUsers() => _userDao.getAllUsers();
  Future<int> updateUser(UserModel user) => _userDao.updateUser(user);
  Future<int> deleteUser(int id) => _userDao.deleteUser(id);

  // Exercise operations
  Future<int> saveExercise(ExerciseModel exercise) =>
      _exerciseDao.insertExercise(exercise);

  Future<List<ExerciseModel>> getUserExercises(int userId) =>
      _exerciseDao.getExercisesForUser(userId);

  Future<List<ExerciseModel>> getExercisesByDateRange(
      int userId,
      DateTime startDate,
      DateTime endDate,
      ) => _exerciseDao.getExercisesByDateRange(userId, startDate, endDate);

  // Nutrition operations
  Future<int> saveNutrition(NutritionModel nutrition) =>
      _nutritionDao.insertNutrition(nutrition);

  Future<List<NutritionModel>> getUserNutrition(int userId) =>
      _nutritionDao.getNutritionForUser(userId);

  Future<Map<String, double>> getDailyNutritionSummary(
      int userId,
      DateTime date,
      ) => _nutritionDao.getDailyNutritionSummary(userId, date);

  Future<List<NutritionModel>> getNutritionByDateRange(
      int userId,
      DateTime startDate,
      DateTime endDate,
      ) => _nutritionDao.getNutritionByDateRange(userId, startDate, endDate);
}