class ExerciseModel {
  final int? id;
  final int userId;
  final String name;
  final int duration;
  final int caloriesBurned;
  final DateTime date;

  ExerciseModel({
    this.id,
    required this.userId,
    required this.name,
    required this.duration,
    required this.caloriesBurned,
    required this.date,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'user_id': userId,
      'name': name,
      'duration': duration,
      'calories_burned': caloriesBurned,
      'date': date.toIso8601String(),
    };
  }

  factory ExerciseModel.fromMap(Map<String, dynamic> map) {
    return ExerciseModel(
      id: map['id'],
      userId: map['user_id'],
      name: map['name'],
      duration: map['duration'],
      caloriesBurned: map['calories_burned'],
      date: DateTime.parse(map['date']),
    );
  }

  Map<String, dynamic> toJson() => toMap();
  factory ExerciseModel.fromJson(Map<String, dynamic> json) => ExerciseModel.fromMap(json);
}

// Exercise History model
class ExerciseHistory {
  final List<ExerciseModel> exercises;
  final int totalCaloriesBurned;
  final int totalDuration;

  ExerciseHistory({
    required this.exercises,
    required this.totalCaloriesBurned,
    required this.totalDuration,
  });

  factory ExerciseHistory.fromJson(Map<String, dynamic> json) {
    return ExerciseHistory(
      exercises: (json['exercises'] as List)
          .map((e) => ExerciseModel.fromJson(e))
          .toList(),
      totalCaloriesBurned: json['total_calories_burned'],
      totalDuration: json['total_duration'],
    );
  }
}
}
