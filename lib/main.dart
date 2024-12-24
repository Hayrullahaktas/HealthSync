import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:dio/dio.dart';

// Providers
import 'presentation/providers/storage_provider.dart';
import 'presentation/providers/db_provider.dart';
import 'presentation/providers/auth_provider.dart';
import 'presentation/providers/api_provider.dart';

// Repositories
import 'data/repositories/storage_repository.dart';
import 'data/repositories/database_repository.dart';
import 'data/repositories/api_repository.dart';

// Services
import 'core/services/jwt_service.dart';
import 'core/services/oauth_service.dart';
import 'data/datasources/local/storage/secure_storage.dart';
import 'data/datasources/local/storage/shared_prefs.dart';
import 'core/utils/storage_utils.dart';

// Database
import 'data/datasources/local/database/dao/user_dao.dart';
import 'data/datasources/local/database/dao/exercise_dao.dart';
import 'data/datasources/local/database/dao/nutrition_dao.dart';

// Network
import 'core/network/auth_interceptor.dart';

// Screens
import 'presentation/screens/main_screen.dart';
import 'presentation/screens/auth/login_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Services initialization
  final sharedPrefs = SharedPrefsService();
  await sharedPrefs.init();

  final secureStorage = SecureStorageService();
  final jwtService = JwtService();
  final oAuthService = OAuthService();

  // Repository initialization
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
    AuthInterceptor(secureStorage, Dio()),
  );

  final apiRepository = ApiRepository(
    dio: dio,
    secureStorage: secureStorage,
    storageRepository: storageRepository,
  );

  runApp(
    MultiProvider(
      providers: [
        // Storage & Database Providers
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

        // Service Providers
        Provider(create: (_) => jwtService),
        Provider(create: (_) => oAuthService),
        Provider(create: (_) => secureStorage),

        // API & Auth Providers
        Provider(create: (_) => apiRepository),
        ChangeNotifierProvider(
          create: (_) => AuthProvider(
            apiRepository: apiRepository,
            storageRepository: storageRepository,
            oAuthService: oAuthService,
            jwtService: jwtService,
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
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'HealthSync',
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
      ),
      home: Consumer<AuthProvider>(
        builder: (context, authProvider, _) {
          if (authProvider.isLoading) {
            return const Scaffold(
              body: Center(
                child: CircularProgressIndicator(),
              ),
            );
          }

          return authProvider.isAuthenticated
              ? const MainScreen()
              : const LoginScreen();
        },
      ),
    );
  }
}