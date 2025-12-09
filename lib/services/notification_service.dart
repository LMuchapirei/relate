import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;
import 'package:relate/features/relationship/models/relationship_model.dart';
import 'package:relate/features/interactions/models/interaction_model.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();

  factory NotificationService() {
    return _instance;
  }

  NotificationService._internal();

  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  Future<void> init() async {
    tz.initializeTimeZones();
    final String timeZoneName = await FlutterTimezone.getLocalTimezone();
    tz.setLocalLocation(tz.getLocation(timeZoneName));

    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    final DarwinInitializationSettings initializationSettingsDarwin =
        DarwinInitializationSettings(
      requestSoundPermission: false,
      requestBadgePermission: false,
      requestAlertPermission: false,
    );

    final InitializationSettings initializationSettings =
        InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsDarwin,
    );

    await flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
    );
  }

  Future<void> requestPermissions() async {
    await flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
            IOSFlutterLocalNotificationsPlugin>()
        ?.requestPermissions(
          alert: true,
          badge: true,
          sound: true,
        );
  }

  Future<void> scheduleNotification(
      int id, String title, String body, DateTime scheduledDate) async {
    await flutterLocalNotificationsPlugin.zonedSchedule(
      id,
      title,
      body,
      tz.TZDateTime.from(scheduledDate, tz.local),
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'interaction_channel',
          'Interaction Reminders',
          channelDescription: 'Reminders for scheduled interactions',
          importance: Importance.max,
          priority: Priority.high,
        ),
        iOS: DarwinNotificationDetails(),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
    );
  }

  Future<void> cancelNotification(int id) async {
    await flutterLocalNotificationsPlugin.cancel(id);
  }

  // Drift Detection Logic
  // This is a simplified check that can be run on app start or periodically
  Future<void> checkForDrift(
      List<Relationship> relationships, List<Interaction> interactions) async {
    for (var relationship in relationships) {
      if (relationship.frequency == null || relationship.frequency == 'Never') {
        continue;
      }

      final relatedInteractions = interactions
          .where(
              (i) => i.relationshipId == relationship.id && i.completed == true)
          .toList();

      if (relatedInteractions.isEmpty) continue; // Or handle never contacted

      // Sort by date desc
      relatedInteractions.sort((a, b) =>
          b.selectedDate?.compareTo(a.selectedDate ?? DateTime(0)) ?? 0);

      final lastInteractionDate = relatedInteractions.first.selectedDate;

      if (lastInteractionDate != null) {
        final daysSince = DateTime.now().difference(lastInteractionDate).inDays;
        final frequencyDays = _getFrequencyDays(relationship.frequency!);

        // If days since last interaction is greater than frequency + buffer (e.g. 50%)
        if (daysSince > frequencyDays * 1.5) {
          // Trigger a local notification immediately (or schedule for a reasonable time)
          // Use a hash of relationship ID for unique notification ID, ensuring we don't spam
          final notificationId = relationship.id.hashCode;

          // Simple check to avoid spamming every time (real imp would check if already shown)
          await showDriftNotification(
            notificationId,
            "Drift Alert: ${relationship.firstName} ${relationship.lastName}",
            "You haven't contacted ${relationship.firstName} ${relationship.lastName} in $daysSince days.",
          );
        }
      }
    }
  }

  Future<void> showDriftNotification(int id, String title, String body) async {
    const AndroidNotificationDetails androidNotificationDetails =
        AndroidNotificationDetails('drift_channel', 'Drift Alerts',
            channelDescription: 'Alerts when you lose touch',
            importance: Importance.max,
            priority: Priority.high,
            ticker: 'ticker');
    const NotificationDetails notificationDetails =
        NotificationDetails(android: androidNotificationDetails);

    await flutterLocalNotificationsPlugin.show(
        id, title, body, notificationDetails);
  }

  int _getFrequencyDays(String frequency) {
    switch (frequency) {
      case 'Daily':
        return 1;
      case 'Weekly':
        return 7;
      case 'Fortnightly':
        return 14;
      case 'Monthly':
        return 30;
      case 'Every 3 Months':
        return 90;
      case 'Every 6 Months':
        return 180;
      case 'Yearly':
        return 365;
      default:
        return 30;
    }
  }
}
