
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../providers/auth_provider.dart';
import '../../providers/db_provider.dart';
import '../../../data/models/exercise_model.dart';
import '../../../data/models/nutrition_model.dart';
import '../auth/login_screen.dart';

class StatisticsScreen extends StatefulWidget {
  const StatisticsScreen({Key? key}) : super(key: key);

  @override
  State<StatisticsScreen> createState() => _StatisticsScreenState();
}

class _StatisticsScreenState extends State<StatisticsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  DateTime _selectedDate = DateTime.now();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadData();
  }
  Future<void> _loadData() async {
    final dbProvider = Provider.of<DatabaseProvider>(context, listen: false);
    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    try {
      // AuthProvider'dan userId'yi al
      final userId = authProvider.userId;
      if (userId == null) {
        // Kullanıcı giriş yapmamışsa login sayfasına yönlendir
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const LoginScreen()),
        );
        return;
      }

      // String olan userId'yi int'e çevir
      final userIdInt = int.parse(userId);

      // Verileri yükle
      await dbProvider.loadUserExercises(userIdInt);
      await dbProvider.loadUserNutrition(userIdInt);
    } catch (e) {
      print('Error loading data: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Veriler yüklenirken bir hata oluştu')),
      );
    }
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Statistics'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Overview'),
            Tab(text: 'Exercise'),
            Tab(text: 'Nutrition'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildOverviewTab(),
          _buildExerciseTab(),
          _buildNutritionTab(),
        ],
      ),
    );
  }

  Widget _buildOverviewTab() {
    return Consumer<DatabaseProvider>(
      builder: (context, dbProvider, child) {
        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Weekly Summary',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: 16),
                      SizedBox(
                        height: 200,
                        child: LineChart(
                          LineChartData(
                            gridData: FlGridData(show: false),
                            titlesData: FlTitlesData(
                              rightTitles: AxisTitles(
                                sideTitles: SideTitles(showTitles: false),
                              ),
                              topTitles: AxisTitles(
                                sideTitles: SideTitles(showTitles: false),
                              ),
                            ),
                            borderData: FlBorderData(
                              show: true,
                              border: Border.all(color: const Color(0xff37434d)),
                            ),
                            lineBarsData: [
                              // Calories burned line
                              LineChartBarData(
                                spots: _getWeeklyExerciseData(dbProvider.exercises),
                                isCurved: true,
                                color: Colors.green,
                                dotData: FlDotData(show: false),
                              ),
                              // Calories consumed line
                              LineChartBarData(
                                spots: _getWeeklyNutritionData(
                                    dbProvider.nutritionEntries),
                                isCurved: true,
                                color: Colors.blue,
                                dotData: FlDotData(show: false),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          _buildLegendItem('Calories Burned', Colors.green),
                          const SizedBox(width: 16),
                          _buildLegendItem('Calories Consumed', Colors.blue),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Activity Goals',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: 16),
                      LinearProgressIndicator(
                        value: 0.7, // Calculate based on actual data
                        backgroundColor: Colors.grey[300],
                        valueColor: AlwaysStoppedAnimation<Color>(
                          Theme.of(context).colorScheme.primary,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '70% of daily goal completed',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildExerciseTab() {
    return Consumer<DatabaseProvider>(
      builder: (context, dbProvider, child) {
        final exercises = dbProvider.exercises;
        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Exercise Distribution',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: 16),
                      SizedBox(
                        height: 200,
                        child: PieChart(
                          PieChartData(
                            sections: _getExerciseDistribution(exercises),
                            sectionsSpace: 0,
                            centerSpaceRadius: 40,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Exercise History',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: 16),
                      ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: exercises.length,
                        itemBuilder: (context, index) {
                          final exercise = exercises[index];
                          return ListTile(
                            title: Text(exercise.name),
                            subtitle: Text(
                              '${exercise.duration} mins • ${exercise.caloriesBurned} kcal',
                            ),
                            trailing: Text(
                              exercise.date.toString().substring(0, 10),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildNutritionTab() {
    return Consumer<DatabaseProvider>(
      builder: (context, dbProvider, child) {
        final nutritionEntries = dbProvider.nutritionEntries;
        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Macro Distribution',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: 16),
                      SizedBox(
                        height: 200,
                        child: PieChart(
                          PieChartData(
                            sections: _getMacroDistribution(nutritionEntries),
                            sectionsSpace: 0,
                            centerSpaceRadius: 40,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Nutrition History',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: 16),
                      ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: nutritionEntries.length,
                        itemBuilder: (context, index) {
                          final nutrition = nutritionEntries[index];
                          return ListTile(
                            title: Text(nutrition.foodName),
                            subtitle: Text(
                              '${nutrition.calories} kcal • '
                                  'P: ${nutrition.protein}g • '
                                  'C: ${nutrition.carbs}g • '
                                  'F: ${nutrition.fat}g',
                            ),
                            trailing: Text(
                              nutrition.consumedAt.toString().substring(0, 10),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildLegendItem(String label, Color color) {
    return Row(
      children: [
        Container(
          width: 16,
          height: 16,
          color: color,
        ),
        const SizedBox(width: 4),
        Text(label),
      ],
    );
  }

  List<FlSpot> _getWeeklyExerciseData(List<ExerciseModel> exercises) {
    // Implementation for exercise data points
    return List.generate(7, (i) {
      final date = DateTime.now().subtract(Duration(days: 6 - i));
      final dayExercises = exercises.where((e) =>
      e.date.year == date.year &&
          e.date.month == date.month &&
          e.date.day == date.day);
      final calories =
      dayExercises.fold(0, (sum, e) => sum + e.caloriesBurned).toDouble();
      return FlSpot(i.toDouble(), calories);
    });
  }

  List<FlSpot> _getWeeklyNutritionData(List<NutritionModel> nutritionEntries) {
    // Implementation for nutrition data points
    return List.generate(7, (i) {
      final date = DateTime.now().subtract(Duration(days: 6 - i));
      final dayNutrition = nutritionEntries.where((n) =>
      n.consumedAt.year == date.year &&
          n.consumedAt.month == date.month &&
          n.consumedAt.day == date.day);
      final calories =
      dayNutrition.fold(0.0, (sum, n) => sum + n.calories);
      return FlSpot(i.toDouble(), calories);
    });
  }

  List<PieChartSectionData> _getExerciseDistribution(
      List<ExerciseModel> exercises) {
    // Group exercises by type and calculate total duration
    final Map<String, int> exerciseMap = {};
    for (var exercise in exercises) {
      exerciseMap[exercise.name] =
          (exerciseMap[exercise.name] ?? 0) + exercise.duration;
    }

    // Convert to pie chart sections
    return exerciseMap.entries.map((entry) {
      final double percentage =
          entry.value / exercises.fold(0, (sum, e) => sum + e.duration);
      return PieChartSectionData(
        color: Colors.primaries[exerciseMap.keys.toList().indexOf(entry.key) %
            Colors.primaries.length],
        value: percentage * 100,
        title: '${(percentage * 100).toStringAsFixed(1)}%',
        radius: 50,
        titleStyle: const TextStyle(color: Colors.white, fontSize: 12),
      );
    }).toList();
  }

  List<PieChartSectionData> _getMacroDistribution(
      List<NutritionModel> nutritionEntries) {
    // Calculate total macros
    double totalProtein = 0;
    double totalCarbs = 0;
    double totalFat = 0;

    for (var nutrition in nutritionEntries) {
      totalProtein += nutrition.protein;
      totalCarbs += nutrition.carbs;
      totalFat += nutrition.fat;
    }

    final total = totalProtein + totalCarbs + totalFat;
    if (total == 0) return [];

    return [
      PieChartSectionData(
        color: Colors.red,
        value: totalProtein,
        title: 'Protein\n${(totalProtein / total * 100).toStringAsFixed(1)}%',
        radius: 50,
        titleStyle: const TextStyle(color: Colors.white, fontSize: 12),
      ),
      PieChartSectionData(
        color: Colors.blue,
        value: totalCarbs,
        title: 'Carbs\n${(totalCarbs / total * 100).toStringAsFixed(1)}%',
        radius: 50,
        titleStyle: const TextStyle(color: Colors.white, fontSize: 12),
      ),
      PieChartSectionData(
        color: Colors.yellow,
        value: totalFat,
        title: 'Fat\n${(totalFat / total * 100).toStringAsFixed(1)}%',
        radius: 50,
        titleStyle: const TextStyle(color: Colors.white, fontSize: 12),
      ),
    ];
  }
}
