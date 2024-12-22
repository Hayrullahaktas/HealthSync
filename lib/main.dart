// lib/main.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'presentation/providers/storage_provider.dart';
import 'presentation/providers/db_provider.dart';
import 'data/repositories/storage_repository.dart';
import 'data/repositories/database_repository.dart';
import 'data/datasources/local/storage/secure_storage.dart';
import 'data/datasources/local/storage/shared_prefs.dart';
import 'core/utils/storage_utils.dart';
import 'data/datasources/local/database/dao/user_dao.dart';
import 'data/datasources/local/database/dao/exercise_dao.dart';
import 'data/datasources/local/database/dao/nutrition_dao.dart';
import 'presentation/screens/main_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Storage services initialization
  final sharedPrefs = SharedPrefsService();
  await sharedPrefs.init();

  final storageRepository = StorageRepository(
    secureStorage: SecureStorageService(),
    sharedPrefs: sharedPrefs,
    storageUtils: StorageUtils(),
  );

  final databaseRepository = DatabaseRepository(
    userDao: UserDao(),
    exerciseDao: ExerciseDao(),
    nutritionDao: NutritionDao(),
  );

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => StorageProvider(
            storageRepository: storageRepository,
          ),
        ),
        ChangeNotifierProvider(
          create: (_) => DatabaseProvider(
            repository: databaseRepository,
          ),
        ),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'HealthSync',
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
      ),
      home: const MainScreen(),
    );
  }
}