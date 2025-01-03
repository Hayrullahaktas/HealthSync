enum EventType {
  exerciseStarted,
  exerciseCompleted,
  goalReached,
  dailyReminderDue,
  motivationalMessage,
  inactivityWarning,
  weeklyProgress,
  waterReminder,
  customGoalAchieved
}

class NotificationData {
  final String title;
  final String message;
  final Map<String, dynamic>? data;
  final DateTime time;

  NotificationData({
    required this.title,
    required this.message,
    this.data,
    DateTime? time,
  }) : time = time ?? DateTime.now();
}

class Event {
  final EventType type;
  final Map<String, dynamic> data;
  final DateTime timestamp;

  Event(this.type, this.data) : timestamp = DateTime.now();
}