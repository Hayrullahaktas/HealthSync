import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:dio/dio.dart';
import 'package:timezone/data/latest.dart' as tz;

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
import '../../core/services/notification_service.dart';
import 'data/datasources/local/storage/secure_storage.dart';
import 'data/datasources/local/storage/shared_prefs.dart';
import 'core/utils/storage_utils.dart';

// Database
import 'data/datasources/local/database/dao/user_dao.dart';
import 'data/datasources/local/database/dao/exercise_dao.dart';
import 'data/datasources/local/database/dao/nutrition_dao.dart';

// Network
import 'core/network/auth_interceptor.dart';

// Receivers
import 'core/receivers/fitness_receiver.dart';

// Screens
import 'presentation/screens/main_screen.dart';
import 'presentation/screens/auth/login_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize timezone for notifications
  tz.initializeTimeZones();

  // Services initialization
  final sharedPrefs = SharedPrefsService();
  await sharedPrefs.init();

  final secureStorage = SecureStorageService();
  final jwtService = JwtService();
  final oAuthService = OAuthService();

  // Initialize notification service
  final notificationService = NotificationService();
  await notificationService.initialize();

  // Initialize fitness receiver
  final fitnessReceiver = FitnessReceiver(notificationService);

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
  final dio = Dio(BaseOptions(
    baseUrl: 'http://10.0.2.2:3000',
    connectTimeout: const Duration(seconds: 5),
    receiveTimeout: const Duration(seconds: 3),
    headers: {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    },
  ))..interceptors.add(AuthInterceptor(secureStorage, Dio()));

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
        Provider(create: (_) => notificationService),
        Provider(create: (_) => fitnessReceiver),
        Provider(create: (_) => dio),

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
    return Consumer<StorageProvider>(
      builder: (context, storageProvider, _) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'HealthSync',
          theme: ThemeData.light(useMaterial3: true),
          darkTheme: ThemeData.dark(useMaterial3: true),
          themeMode: storageProvider.isDarkMode ? ThemeMode.dark : ThemeMode.light,
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
      },
    );
  }
}