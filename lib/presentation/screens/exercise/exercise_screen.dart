
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/db_provider.dart';
import '../../widgets/common/custom_button.dart';
import '../../widgets/common/custom_text_field.dart';
import '../../../data/models/exercise_model.dart';

class ExerciseScreen extends StatefulWidget {
  final ExerciseModel? exercise; // Düzenleme için varsa mevcut egzersiz

  const ExerciseScreen({Key? key, this.exercise}) : super(key: key);

  @override
  State<ExerciseScreen> createState() => _ExerciseScreenState();
}

class _ExerciseScreenState extends State<ExerciseScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _durationController;
  late TextEditingController _caloriesController;
  DateTime _selectedDate = DateTime.now();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.exercise?.name);
    _durationController = TextEditingController(
      text: widget.exercise?.duration.toString(),
    );
    _caloriesController = TextEditingController(
      text: widget.exercise?.caloriesBurned.toString(),
    );
    if (widget.exercise != null) {
      _selectedDate = widget.exercise!.date;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _durationController.dispose();
    _caloriesController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  Future<void> _saveExercise() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      // AuthProvider'dan userId'yi al
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final userId = authProvider.userId;

      if (userId == null) {
        throw Exception('User not authenticated');
      }

      final exercise = ExerciseModel(
        id: widget.exercise?.id,
        userId: int.parse(userId), // Burada string olan userId'yi int'e çeviriyoruz
        name: _nameController.text,
        duration: int.parse(_durationController.text),
        caloriesBurned: int.parse(_caloriesController.text),
        date: _selectedDate,
      );

      await Provider.of<DatabaseProvider>(context, listen: false)
          .addExercise(exercise);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Exercise saved successfully')),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error saving exercise: $e')),
        );
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _deleteExercise() async {
    setState(() => _isLoading = true);

    try {
      if (widget.exercise?.id != null) {
        await Provider.of<DatabaseProvider>(context, listen: false)
            .deleteExercise(widget.exercise!.id!);

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Exercise deleted successfully')),
          );
          Navigator.pop(context);
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error deleting exercise: $e')),
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
        title: Text(widget.exercise == null ? 'Add Exercise' : 'Edit Exercise'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CustomTextField(
                label: 'Exercise Name',
                controller: _nameController,
                validator: (value) {
                  if (value?.isEmpty ?? true) {
                    return 'Please enter exercise name';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: CustomTextField(
                      label: 'Duration (minutes)',
                      controller: _durationController,
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value?.isEmpty ?? true) {
                          return 'Required';
                        }
                        final duration = int.tryParse(value!);
                        if (duration == null || duration <= 0) {
                          return 'Invalid duration';
                        }
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: CustomTextField(
                      label: 'Calories Burned',
                      controller: _caloriesController,
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value?.isEmpty ?? true) {
                          return 'Required';
                        }
                        final calories = int.tryParse(value!);
                        if (calories == null || calories <= 0) {
                          return 'Invalid calories';
                        }
                        return null;
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              ListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Date'),
                subtitle: Text(
                  '${_selectedDate.year}-${_selectedDate.month.toString().padLeft(2, '0')}-${_selectedDate.day.toString().padLeft(2, '0')}',
                ),
                trailing: const Icon(Icons.calendar_today),
                onTap: () => _selectDate(context),
              ),
              const SizedBox(height: 24),
              CustomButton(
                text: widget.exercise == null ? 'Add Exercise' : 'Update Exercise',
                onPressed: _saveExercise,
                isLoading: _isLoading,
              ),
              if (widget.exercise != null) ...[
                const SizedBox(height: 16),
                CustomButton(
                  text: 'Delete Exercise',
                  backgroundColor: Theme.of(context).colorScheme.error,
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: const Text('Delete Exercise'),
                        content: const Text(
                          'Are you sure you want to delete this exercise? '
                              'This action cannot be undone.',
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: const Text('Cancel'),
                          ),
                          TextButton(
                            onPressed: () {
                              Navigator.pop(context); 
                              _deleteExercise(); // Silme işlemini gerçekleştir
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
