import 'package:flutter/material.dart';
import '../services/notification_service.dart';
import '../../data/models/notification_models.dart';

class FitnessReceiver {
  final NotificationService _notificationService;

  FitnessReceiver(this._notificationService) {
    _initialize();
  }

  void _initialize() {
    _notificationService.addEventListener(EventType.exerciseStarted, _handleExerciseStarted);
    _notificationService.addEventListener(EventType.exerciseCompleted, _handleExerciseCompleted);
    _notificationService.addEventListener(EventType.goalReached, _handleGoalReached);
    _notificationService.addEventListener(EventType.inactivityWarning, _handleInactivityWarning);
  }

  Future<void> _handleExerciseStarted(Event event) async {
    final exerciseData = event.data['exerciseData'] as Map<String, dynamic>;

    await _notificationService.showNotification(
      title: "Egzersiz Başladı",
      body: "${exerciseData['name']} egzersizine başladınız",
      payload: {
        'eventType': EventType.exerciseStarted.toString(),
        'exerciseName': exerciseData['name'],
      },
    );

    _notificationService.broadcastEvent(Event(
      EventType.exerciseStarted,
      exerciseData,
    ));
  }

  Future<void> _handleExerciseCompleted(Event event) async {
    final exerciseData = event.data['exerciseData'] as Map<String, dynamic>;

    await _notificationService.showNotification(
      title: "Egzersiz Tamamlandı",
      body: "${exerciseData['name']} egzersizini tamamladınız",
      payload: {
        'eventType': EventType.exerciseCompleted.toString(),
        'exerciseName': exerciseData['name'],
      },
    );

    _notificationService.broadcastEvent(Event(
      EventType.exerciseCompleted,
      exerciseData,
    ));
  }

  Future<void> _handleGoalReached(Event event) async {
    final goalData = event.data['goalData'] as Map<String, dynamic>;

    await _notificationService.showNotification(
      title: "Hedefe Ulaştınız",
      body: "${goalData['name']} hedefine ulaştınız!",
      payload: {
        'eventType': EventType.goalReached.toString(),
        'goalName': goalData['name'],
      },
    );

    _notificationService.broadcastEvent(Event(
      EventType.goalReached,
      goalData,
    ));
  }

  Future<void> _handleInactivityWarning(Event event) async {
    final inactivityData = event.data['inactivityData'] as Map<String, dynamic>;

    await _notificationService.showNotification(
      title: "Hareket Zamanı",
      body: "${inactivityData['duration']} süredir hareketsizsiniz",
      payload: {
        'eventType': EventType.inactivityWarning.toString(),
        'duration': inactivityData['duration'],
      },
    );

    _notificationService.broadcastEvent(Event(
      EventType.inactivityWarning,
      inactivityData,
    ));
  }
}