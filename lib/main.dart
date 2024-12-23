import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:dio/dio.dart';
import 'presentation/providers/storage_provider.dart';
import 'presentation/providers/db_provider.dart';
import 'presentation/providers/auth_provider.dart';  // Yeni eklendi
import 'presentation/providers/api_provider.dart';   // Yeni eklendi
import 'data/repositories/storage_repository.dart';
import 'data/repositories/database_repository.dart';
import 'data/repositories/api_repository.dart';      // Yeni eklendi
import 'data/datasources/local/storage/secure_storage.dart';
import 'data/datasources/local/storage/shared_prefs.dart';
import 'core/utils/storage_utils.dart';
import 'data/datasources/local/database/dao/user_dao.dart';
import 'data/datasources/local/database/dao/exercise_dao.dart';
import 'data/datasources/local/database/dao/nutrition_dao.dart';
import 'core/network/auth_interceptor.dart';         // Yeni eklendi
import 'presentation/screens/main_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Storage services initialization
  final sharedPrefs = SharedPrefsService();
  await sharedPrefs.init();

  final secureStorage = SecureStorageService();

  final storageRepository = StorageRepository(
    secureStorage: secureStorage,
    sharedPrefs: sharedPrefs,
    storageUtils: StorageUtils(),
  );

  final databaseRepository = DatabaseRepository(
    userDao: UserDao(),
    exerciseDao: ExerciseDao(),
    nutritionDao: NutritionDao(),
  );

  // API initialization
  final dio = Dio()..interceptors.add(
    AuthInterceptor(
      secureStorage,
      Dio(),
    ),
  );

  final apiRepository = ApiRepository(
    dio: dio,
    secureStorage: secureStorage,
    storageRepository: storageRepository,
  );

  runApp(
    MultiProvider(
      providers: [
        // Mevcut providerlar
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
        // Yeni API ve Auth providerları
        ChangeNotifierProvider(
          create: (_) => AuthProvider(
            apiRepository: apiRepository,
            storageRepository: storageRepository,
          ),
        ),
        ChangeNotifierProvider(
          create: (_) => ApiProvider(
            apiRepository: apiRepository,
          ),
        ),
      ],
      child: const MyApp(),
    ),
  );

}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Auth durumunu kontrol et
    final authProvider = context.watch<AuthProvider>();

    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: authProvider.isAuthenticated
          ? const MainScreen()
          : const LoginScreen(), // TODO: LoginScreen oluşturulacak
    );
  }
}