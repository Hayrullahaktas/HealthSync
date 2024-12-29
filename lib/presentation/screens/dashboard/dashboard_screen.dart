
import 'package:flutter/material.dart';
import 'package:health_sync/presentation/screens/auth/login_screen.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/storage_provider.dart';
import '../../providers/db_provider.dart';
import '../../widgets/common/metric_card.dart';
import '../exercise/exercise_screen.dart';
import '../nutrition/nutrition_screen.dart';
import '../settings/settings_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({Key? key}) : super(key: key);

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  @override
  void initState() {
    super.initState();
    _loadData();
  }
  Future<void> _loadData() async {
    final dbProvider = Provider.of<DatabaseProvider>(context, listen: false);
    final storageProvider = Provider.of<StorageProvider>(context, listen: false);
    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    try {
      // AuthProvider'dan userId'yi al
      final userId = authProvider.userId;
      if (userId == null) {
        // Kullanıcı giriş yapmamışsa login sayfasına yönlendir
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const LoginScreen()),
        );        return;
      }

      // String olan userId'yi int'e çevir
      final userIdInt = int.parse(userId);

      // Verileri yükle
      await dbProvider.loadUser(userIdInt);
      await dbProvider.loadUserExercises(userIdInt);
      await dbProvider.loadDailyNutritionSummary(userIdInt, DateTime.now());
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Veriler yüklenirken bir hata oluştu')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard'),

        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const SettingsScreen(),
                ),
              );
            },
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _loadData,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Consumer<StorageProvider>(
                builder: (context, storageProvider, child) {
                  return Text(
                    'Hello, ${storageProvider.userName ?? 'User'}!',
                    style: Theme.of(context).textTheme.headlineSmall,
                  );
                },
              ),
              const SizedBox(height: 24),
              Consumer<DatabaseProvider>(
                builder: (context, dbProvider, child) {
                  final nutritionSummary = dbProvider.dailyNutritionSummary;

                  return GridView.count(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisCount: 2,
                    mainAxisSpacing: 16,
                    crossAxisSpacing: 16,
                    childAspectRatio: 1.5,
                    children: [
                      MetricCard(
                        title: 'Calories',
                        value: '${nutritionSummary['calories']?.toInt() ?? 0}',
                        subtitle: 'kcal consumed today',
                        icon: Icons.local_fire_department,
                      ),
                      MetricCard(
                        title: 'Exercise',
                        value: '${dbProvider.exercises.length}',
                        subtitle: 'workouts today',
                        icon: Icons.fitness_center,
                      ),
                      MetricCard(
                        title: 'Protein',
                        value: '${nutritionSummary['protein']?.toInt() ?? 0}g',
                        icon: Icons.egg_outlined,
                      ),
                      MetricCard(
                        title: 'Water',
                        value: '0',
                        subtitle: 'glasses today',
                        icon: Icons.water_drop,
                      ),
                    ],
                  );
                },
              ),
              const SizedBox(height: 24),
              Text(
                'Recent Activities',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 16),
              Consumer<DatabaseProvider>(
                builder: (context, dbProvider, child) {
                  final exercises = dbProvider.exercises;

                  if (exercises.isEmpty) {
                    return const Center(
                      child: Text('No recent activities'),
                    );
                  }

                  return ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: exercises.length,
                    itemBuilder: (context, index) {
                      final exercise = exercises[index];
                      return Card(
                        margin: const EdgeInsets.only(bottom: 8),
                        child: ListTile(
                          leading: const Icon(Icons.fitness_center),
                          title: Text(exercise.name),
                          subtitle: Text(
                            'Duration: ${exercise.duration} mins • ${exercise.caloriesBurned} kcal',
                          ),
                          trailing: Text(
                            exercise.date.toString().substring(0, 10),
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ],
          ),
        ),
      ),

      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          showModalBottomSheet(
            context: context,
            builder: (context) => SafeArea(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ListTile(
                    leading: const Icon(Icons.fitness_center),
                    title: const Text('Add Exercise'),
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const ExerciseScreen(),
                        ),
                      );
                    },
                  ),


                  ListTile(
                    leading: const Icon(Icons.restaurant_menu),
                    title: const Text('Add Nutrition'),
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const NutritionScreen(),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          );
        },
        label: const Text('Add'),
        icon: const Icon(Icons.add),
      ),
    );
  }
}
