class HealthMetricsModel {
  final int? id;
  final int userId;
  final double weight;
  final int steps;
  final int heartRate;
  final DateTime date;

  HealthMetricsModel({
    this.id,
    required this.userId,
    required this.weight,
    required this.steps,
    required this.heartRate,
    required this.date,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'user_id': userId,
      'weight': weight,
      'steps': steps,
      'heart_rate': heartRate,
      'date': date.toIso8601String(),
    };
  }

  factory HealthMetricsModel.fromMap(Map<String, dynamic> map) {
    return HealthMetricsModel(
      id: map['id'],
      userId: map['user_id'],
      weight: map['weight'],
      steps: map['steps'],
      heartRate: map['heart_rate'],
      date: DateTime.parse(map['date']),
    );
  }

  Map<String, dynamic> toJson() => toMap();
  factory HealthMetricsModel.fromJson(Map<String, dynamic> json) => HealthMetricsModel.fromMap(json);
}

class HealthMetricsSummary {
  final List<HealthMetricsModel> metrics;
  final double averageWeight;
  final int totalSteps;
  final double averageHeartRate;

  HealthMetricsSummary({
    required this.metrics,
    required this.averageWeight,
    required this.totalSteps,
    required this.averageHeartRate,
  });

  factory HealthMetricsSummary.fromJson(Map<String, dynamic> json) {
    return HealthMetricsSummary(
      metrics: (json['metrics'] as List)
          .map((e) => HealthMetricsModel.fromJson(e))
          .toList(),
      averageWeight: json['average_weight'],
      totalSteps: json['total_steps'],
      averageHeartRate: json['average_heart_rate'],
    );
  }
}