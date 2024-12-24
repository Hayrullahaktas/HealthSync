// lib/presentation/screens/nutrition/nutrition_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/db_provider.dart';
import '../../widgets/common/custom_button.dart';
import '../../widgets/common/custom_text_field.dart';
import '../../../data/models/nutrition_model.dart';

class NutritionScreen extends StatefulWidget {
  final NutritionModel? nutrition; // Düzenleme için varsa mevcut besin

  const NutritionScreen({Key? key, this.nutrition}) : super(key: key);

  @override
  State<NutritionScreen> createState() => _NutritionScreenState();
}

class _NutritionScreenState extends State<NutritionScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _foodNameController;
  late TextEditingController _caloriesController;
  late TextEditingController _proteinController;
  late TextEditingController _carbsController;
  late TextEditingController _fatController;
  DateTime _selectedDateTime = DateTime.now();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _foodNameController = TextEditingController(text: widget.nutrition?.foodName);
    _caloriesController = TextEditingController(
      text: widget.nutrition?.calories.toString(),
    );
    _proteinController = TextEditingController(
      text: widget.nutrition?.protein.toString(),
    );
    _carbsController = TextEditingController(
      text: widget.nutrition?.carbs.toString(),
    );
    _fatController = TextEditingController(
      text: widget.nutrition?.fat.toString(),
    );
    if (widget.nutrition != null) {
      _selectedDateTime = widget.nutrition!.consumedAt;
    }
  }

  @override
  void dispose() {
    _foodNameController.dispose();
    _caloriesController.dispose();
    _proteinController.dispose();
    _carbsController.dispose();
    _fatController.dispose();
    super.dispose();
  }

  Future<void> _selectDateTime(BuildContext context) async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: _selectedDateTime,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );

    if (pickedDate != null) {
      final TimeOfDay? pickedTime = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.fromDateTime(_selectedDateTime),
      );

      if (pickedTime != null) {
        setState(() {
          _selectedDateTime = DateTime(
            pickedDate.year,
            pickedDate.month,
            pickedDate.day,
            pickedTime.hour,
            pickedTime.minute,
          );
        });
      }
    }
  }

  Future<void> _saveNutrition() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final nutrition = NutritionModel(
        id: widget.nutrition?.id,
        userId: 1, // burası auth'dan gelecek şimdilik 1 yaptım
        foodName: _foodNameController.text,
        calories: double.parse(_caloriesController.text),
        protein: double.parse(_proteinController.text),
        carbs: double.parse(_carbsController.text),
        fat: double.parse(_fatController.text),
        consumedAt: _selectedDateTime,
      );

      await Provider.of<DatabaseProvider>(context, listen: false)
          .addNutrition(nutrition);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Nutrition saved successfully')),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error saving nutrition: $e')),
        );
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.nutrition == null ? 'Add Nutrition' : 'Edit Nutrition'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CustomTextField(
                label: 'Food Name',
                controller: _foodNameController,
                validator: (value) {
                  if (value?.isEmpty ?? true) {
                    return 'Please enter food name';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              CustomTextField(
                label: 'Calories',
                controller: _caloriesController,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                validator: (value) {
                  if (value?.isEmpty ?? true) return 'Required';
                  final calories = double.tryParse(value!);
                  if (calories == null || calories < 0) {
                    return 'Invalid calories';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: CustomTextField(
                      label: 'Protein (g)',
                      controller: _proteinController,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      validator: (value) {
                        if (value?.isEmpty ?? true) return 'Required';
                        final protein = double.tryParse(value!);
                        if (protein == null || protein < 0) {
                          return 'Invalid protein';
                        }
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: CustomTextField(
                      label: 'Carbs (g)',
                      controller: _carbsController,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      validator: (value) {
                        if (value?.isEmpty ?? true) return 'Required';
                        final carbs = double.tryParse(value!);
                        if (carbs == null || carbs < 0) {
                          return 'Invalid carbs';
                        }
                        return null;
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              CustomTextField(
                label: 'Fat (g)',
                controller: _fatController,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                validator: (value) {
                  if (value?.isEmpty ?? true) return 'Required';
                  final fat = double.tryParse(value!);
                  if (fat == null || fat < 0) {
                    return 'Invalid fat';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              ListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Time Consumed'),
                subtitle: Text(
                  '${_selectedDateTime.year}-${_selectedDateTime.month.toString().padLeft(2, '0')}-${_selectedDateTime.day.toString().padLeft(2, '0')} '
                      '${_selectedDateTime.hour.toString().padLeft(2, '0')}:${_selectedDateTime.minute.toString().padLeft(2, '0')}',
                ),
                trailing: const Icon(Icons.access_time),
                onTap: () => _selectDateTime(context),
              ),
              const SizedBox(height: 24),
              CustomButton(
                text: widget.nutrition == null ? 'Add Nutrition' : 'Update Nutrition',
                onPressed: _saveNutrition,
                isLoading: _isLoading,
              ),
              if (widget.nutrition != null) ...[
                const SizedBox(height: 16),
                CustomButton(
                  text: 'Delete Nutrition',
                  backgroundColor: Theme.of(context).colorScheme.error,
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: const Text('Delete Nutrition'),
                        content: const Text(
                          'Are you sure you want to delete this nutrition entry? '
                              'This action cannot be undone.',
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: const Text('Cancel'),
                          ),
                          TextButton(
                            onPressed: () {
                              // TODO: Implement delete nutrition
                              Navigator.pop(context);
                              Navigator.pop(context);
                            },
                            child: Text(
                              'Delete',
                              style: TextStyle(
                                color: Theme.of(context).colorScheme.error,
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}