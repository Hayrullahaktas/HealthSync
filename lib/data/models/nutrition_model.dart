class NutritionModel {
  final int? id;
  final int userId;
  final String foodName;
  final double calories;
  final double protein;
  final double carbs;
  final double fat;
  final DateTime consumedAt;

  NutritionModel({
    this.id,
    required this.userId,
    required this.foodName,
    required this.calories,
    required this.protein,
    required this.carbs,
    required this.fat,
    required this.consumedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'user_id': userId,
      'food_name': foodName,
      'calories': calories,
      'protein': protein,
      'carbs': carbs,
      'fat': fat,
      'consumed_at': consumedAt.toIso8601String(),
    };
  }

  factory NutritionModel.fromMap(Map<String, dynamic> map) {
    return NutritionModel(
      id: map['id'],
      userId: map['user_id'],
      foodName: map['food_name'],
      calories: map['calories'],
      protein: map['protein'],
      carbs: map['carbs'],
      fat: map['fat'],
      consumedAt: DateTime.parse(map['consumed_at']),
    );
  }
}

