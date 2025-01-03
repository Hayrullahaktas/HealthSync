import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:provider/provider.dart';
import '../../core/services/notification_service.dart';  // Import yolu düzeltildi
import '../../data/models/notification_models.dart';  // Import yolu düzeltildi
import 'dashboard/dashboard_screen.dart';
import 'statistics/statistics_screen.dart';
import 'settings/settings_screen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({Key? key}) : super(key: key);

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;

  final List<Widget> _screens = [
    const DashboardScreen(),
    const StatisticsScreen(),
    const SettingsScreen(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  Future<void> testNotifications(BuildContext context) async {
    final notificationService = Provider.of<NotificationService>(context, listen: false);

    try {
      // Test bildirimi gönder
      await notificationService.showNotification(
        title: "Egzersiz Başladı",
        body: "Koşu egzersiziniz başladı!",
        payload: {
          'eventType': EventType.exerciseStarted.toString(),
          'exerciseName': 'Koşu',
          'duration': '30',
        },
      );

      // 5 saniye sonrası için zamanlanmış bildirim
      await notificationService.scheduleNotification(
        title: "Hareketsizlik Uyarısı",
        body: "1 saattir hareketsizsiniz. Biraz hareket etmeye ne dersiniz?",
        scheduledDate: DateTime.now().add(const Duration(seconds: 5)),
        payload: {
          'eventType': EventType.inactivityWarning.toString(),
          'duration': '1 saat',
        },
      );

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Test bildirimleri gönderildi')),
      );
    } catch (e) {
      print('Bildirim hatası: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Bildirim gönderilirken hata oluştu')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _selectedIndex,
        children: _screens,
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: _onItemTapped,
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.dashboard_outlined),
            selectedIcon: Icon(Icons.dashboard),
            label: 'Dashboard',
          ),
          NavigationDestination(
            icon: Icon(Icons.insert_chart_outlined),
            selectedIcon: Icon(Icons.insert_chart),
            label: 'Statistics',
          ),
          NavigationDestination(
            icon: Icon(Icons.settings_outlined),
            selectedIcon: Icon(Icons.settings),
            label: 'Settings',
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => testNotifications(context),
        label: const Text('Test Notifications'),
        icon: const Icon(Icons.notifications_active),
      ),
    );
  }
}