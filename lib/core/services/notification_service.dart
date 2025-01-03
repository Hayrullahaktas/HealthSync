import 'package:flutter/material.dart';
import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:rxdart/subjects.dart';
import '../../data/models/notification_models.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final _eventController = BehaviorSubject<Event>();
  final Map<EventType, List<Function(Event)>> _eventListeners = {};

  Stream<Event> get eventStream => _eventController.stream;

  Future<void> initialize() async {
    await AwesomeNotifications().initialize(
      null, // null for default icon
      [
        NotificationChannel(
          channelKey: 'health_sync_channel',
          channelName: 'HealthSync Notifications',
          channelDescription: 'Health and fitness notifications',
          defaultColor: const Color.fromARGB(255, 157, 80, 221),
          ledColor: Colors.white,
          importance: NotificationImportance.High,
          playSound: true,
          enableVibration: true,
        ),
      ],
    );

    await requestPermission();

    AwesomeNotifications().setListeners(
      onActionReceivedMethod: (ReceivedAction receivedAction) async {
        _handleNotificationAction(receivedAction);
      },
    );
  }

  Future<void> requestPermission() async {
    await AwesomeNotifications().isNotificationAllowed().then((isAllowed) async {
      if (!isAllowed) {
        await AwesomeNotifications().requestPermissionToSendNotifications();
      }
    });
  }

  Future<void> showNotification({
    required String title,
    required String body,
    Map<String, String>? payload,
  }) async {
    await AwesomeNotifications().createNotification(
      content: NotificationContent(
        id: DateTime.now().millisecondsSinceEpoch.remainder(100000),
        channelKey: 'health_sync_channel',
        title: title,
        body: body,
        payload: payload ?? {},
        notificationLayout: NotificationLayout.Default,
      ),
    );
  }

  Future<void> scheduleNotification({
    required String title,
    required String body,
    required DateTime scheduledDate,
    Map<String, String>? payload,
  }) async {
    await AwesomeNotifications().createNotification(
      content: NotificationContent(
        id: DateTime.now().millisecondsSinceEpoch.remainder(100000),
        channelKey: 'health_sync_channel',
        title: title,
        body: body,
        payload: payload ?? {},
        notificationLayout: NotificationLayout.Default,
      ),
      schedule: NotificationCalendar.fromDate(date: scheduledDate),
    );
  }

  void broadcastEvent(Event event) {
    _eventController.add(event);
    _notifyListeners(event);
  }

  void addEventListener(EventType type, Function(Event) listener) {
    _eventListeners[type] ??= [];
    _eventListeners[type]!.add(listener);
  }

  void removeEventListener(EventType type, Function(Event) listener) {
    _eventListeners[type]?.remove(listener);
  }

  void _notifyListeners(Event event) {
    _eventListeners[event.type]?.forEach((listener) => listener(event));
  }

  void _handleNotificationAction(ReceivedAction receivedAction) {
    if (receivedAction.payload != null) {
      final eventType = _getEventTypeFromPayload(receivedAction.payload!);
      if (eventType != null) {
        broadcastEvent(Event(eventType, Map<String, dynamic>.from(receivedAction.payload!)));
      }
    }
  }

  EventType? _getEventTypeFromPayload(Map<String, String?> payload) {
    final typeStr = payload['eventType'];
    if (typeStr != null) {
      return EventType.values.firstWhere(
            (e) => e.toString() == typeStr,
        orElse: () => EventType.exerciseStarted,
      );
    }
    return null;
  }

  void dispose() {
    _eventController.close();
    _eventListeners.clear();
    AwesomeNotifications().dispose();
  }
}