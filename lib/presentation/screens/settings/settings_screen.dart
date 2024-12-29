
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/db_provider.dart';
import '../../providers/storage_provider.dart';
import '../../widgets/common/custom_button.dart';
import '../../widgets/common/custom_text_field.dart';
import '../../providers/auth_provider.dart';
class SettingsScreen extends StatefulWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  // Controller'ları direkt oluşturalım
  final _nameController = TextEditingController();
  final _heightController = TextEditingController();
  final _weightController = TextEditingController();
  final _ageController = TextEditingController();
  final _dailyGoalController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final storageProvider = Provider.of<StorageProvider>(context, listen: false);
    await storageProvider.loadUserProfile();

    // Verileri controller'lara yükle
    _nameController.text = storageProvider.userName ?? '';
    _heightController.text = storageProvider.userHeight?.toString() ?? '';
    _weightController.text = storageProvider.userWeight?.toString() ?? '';
    _ageController.text = storageProvider.userAge?.toString() ?? '';
    _dailyGoalController.text = storageProvider.dailyGoal.toString();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _heightController.dispose();
    _weightController.dispose();
    _ageController.dispose();
    _dailyGoalController.dispose();
    super.dispose();
  }



  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;

    final storageProvider = Provider.of<StorageProvider>(context, listen: false);

    try {
      await storageProvider.saveUserProfile(
        name: _nameController.text,
        height: double.parse(_heightController.text),
        weight: double.parse(_weightController.text),
        age: int.parse(_ageController.text),
      );

      await storageProvider.updateDailyGoal(
        int.parse(_dailyGoalController.text),
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Settings saved successfully')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error saving settings: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: Consumer<StorageProvider>(
        builder: (context, storageProvider, child) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Profile Settings',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 16),
                  CustomTextField(
                    label: 'Name',
                    controller: _nameController,
                    validator: (value) {
                      if (value?.isEmpty ?? true) {
                        return 'Please enter your name';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: CustomTextField(
                          label: 'Height (cm)',
                          controller: _heightController,
                          keyboardType: TextInputType.number,
                          validator: (value) {
                            if (value?.isEmpty ?? true) {
                              return 'Required';
                            }
                            final height = double.tryParse(value!);
                            if (height == null || height <= 0) {
                              return 'Invalid height';
                            }
                            return null;
                          },
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: CustomTextField(
                          label: 'Weight (kg)',
                          controller: _weightController,
                          keyboardType: TextInputType.number,
                          validator: (value) {
                            if (value?.isEmpty ?? true) {
                              return 'Required';
                            }
                            final weight = double.tryParse(value!);
                            if (weight == null || weight <= 0) {
                              return 'Invalid weight';
                            }
                            return null;
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  CustomTextField(
                    label: 'Age',
                    controller: _ageController,
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value?.isEmpty ?? true) {
                        return 'Please enter your age';
                      }
                      final age = int.tryParse(value!);
                      if (age == null || age <= 0) {
                        return 'Invalid age';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'App Settings',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 16),
                  CustomTextField(
                    label: 'Daily Step Goal',
                    controller: _dailyGoalController,
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value?.isEmpty ?? true) {
                        return 'Please enter your daily goal';
                      }
                      final steps = int.tryParse(value!);
                      if (steps == null || steps <= 0) {
                        return 'Invalid step count';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  SwitchListTile(
                    title: const Text('Dark Mode'),
                    value: storageProvider.isDarkMode,
                    onChanged: (_) => storageProvider.toggleThemeMode(),
                  ),
                  const SizedBox(height: 24),
                  CustomButton(
                    text: 'Save Settings',
                    onPressed: _saveProfile,
                  ),
                  const SizedBox(height: 16),
                  const Divider(),
                  const SizedBox(height: 16),
                  Text(
                    'Account',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 16),
                  CustomButton(
                    text: 'Logout',
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: const Text('Logout'),
                          content: const Text(
                            'Are you sure you want to logout?',
                          ),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(context),
                              child: const Text('Cancel'),
                            ),
                            TextButton(
                              onPressed: () async {
                                Navigator.pop(context); // Dialog'u kapat
                                await context.read<AuthProvider>().logout();
                                if (mounted) {
                                  // Login sayfasına yönlendir ve geri dönüşü engelle
                                  Navigator.pushNamedAndRemoveUntil(
                                    context,
                                    '/login',
                                        (route) => false,
                                  );
                                }
                              },
                              child: Text(
                                'Logout',
                                style: TextStyle(
                                  color: Theme.of(context).colorScheme.error,
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                    backgroundColor: Theme.of(context).colorScheme.error,
                  ),
                  const SizedBox(height: 16),
                  const Divider(),
                  const SizedBox(height: 16),
                  Text(
                    'Data Management',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 16),
                  CustomButton(
                    text: 'Export Data',
                    onPressed: () {
                      // TODO: Implement data export
                    },
                    backgroundColor: Theme.of(context).colorScheme.secondary,
                  ),
                  CustomButton(
                    text: 'Clear All Data',
                    onPressed: () {
                      // Önce onay dialogu göster
                      showDialog(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: const Text('Clear All Data'),
                          content: const Text(
                            'Are you sure you want to clear all data? This action cannot be undone.',
                          ),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(context),
                              child: const Text('Cancel'),
                            ),
                            TextButton(
                              onPressed: () async {
                                try {
                                  final authProvider = Provider.of<AuthProvider>(context, listen: false);
                                  final userId = authProvider.userId;

                                  if (userId != null) {
                                    // Önce dialog'u kapat
                                    Navigator.pop(context);

                                    // Verileri sil
                                    await Provider.of<DatabaseProvider>(context, listen: false)
                                        .clearUserData(int.parse(userId));

                                    // Başarılı mesajını göster
                                    if (mounted) {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        const SnackBar(content: Text('All data cleared successfully')),
                                      );
                                    }

                                    // Verileri yeniden yükle
                                    await _loadUserData();
                                  }
                                } catch (e) {
                                  if (mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(content: Text('Error clearing data: $e')),
                                    );
                                  }
                                }
                              },
                              child: Text(
                                'Clear All',
                                style: TextStyle(
                                  color: Theme.of(context).colorScheme.error,
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                    backgroundColor: Theme.of(context).colorScheme.error,
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
