import 'dart:io';

import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

abstract class AdhanNotificationService {
  // Future<void> checkAndRequestPermissions();
  Future<void> initializeNotification();
  Future<void> scheduleNotification({
    required int id,
    required String title,
    required String body,
    required DateTime dateTime,
    String? payload,
  });
  Future<void> cancelNotification(int id);
  Future<List<PendingNotificationRequest>> getPendingNotifications();
  Future<List<ActiveNotification>> getActiveNotifications();
  Future<void> cancelAllNotifications();
  Future<void> sendNotification({required String title, required String body});
}

class AdhanNotificationServiceImpl implements AdhanNotificationService {
  final FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin;

  AdhanNotificationServiceImpl()
      : _flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin() {
    tz.initializeTimeZones();
  }

  // Future<void> _checkNotificationPermission() async {
  //   if (Platform.isAndroid || Platform.isIOS) {
  //     var status = await Permission.notification.status;
  //     if (!status.isGranted) {
  //       await Permission.notification.request();
  //     }
  //   }
  // }

  @override
  Future<void> initializeNotification() async {
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings("@mipmap/launcher_icon");

    final DarwinInitializationSettings initializationSettingsDarwin =
        DarwinInitializationSettings(
      onDidReceiveLocalNotification: _onDidReceiveLocalNotification,
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
      defaultPresentAlert: true,
      defaultPresentBadge: true,
      defaultPresentSound: true,
    );

    const LinuxInitializationSettings initializationSettingsLinux =
        LinuxInitializationSettings(
      defaultActionName: 'Open notification',
    );

    final InitializationSettings initializationSettings =
        InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsDarwin,
      macOS: initializationSettingsDarwin,
      linux: initializationSettingsLinux,
    );

    await _flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: _onDidReceiveNotificationResponse,
      onDidReceiveBackgroundNotificationResponse: _notificationTapBackground,
    );

    if (Platform.isAndroid) {
      final androidVersion = int.tryParse(Platform.operatingSystemVersion
              .replaceAll(RegExp(r'[^0-9.]'), '')
              .split('.')
              .first) ??
          0;

      if (androidVersion >= 13) {
        final status = await Permission.notification.status;
        if (!status.isGranted) {
          await Permission.notification.request();
        }
      }
    } else if (Platform.isIOS) {
      await _flutterLocalNotificationsPlugin
          .resolvePlatformSpecificImplementation<
              IOSFlutterLocalNotificationsPlugin>()
          ?.requestPermissions(
            alert: true,
            badge: true,
            sound: true,
          );
    }
  }

  // @override
  // Future<void> checkAndRequestPermissions() async {
  //   await _checkNotificationPermission();
  // }

  @override
  Future<void> scheduleNotification({
    required int id,
    required String title,
    required String body,
    required DateTime dateTime,
    String? payload,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final selectedSound = prefs.getString('selectedSoundName') ?? 'azan_1';

    final scheduledDate = await _nextInstance(dateTime);
    await _flutterLocalNotificationsPlugin.zonedSchedule(
      id,
      title,
      body,
      scheduledDate,
      _getNotificationDetails(sound: selectedSound, channel: selectedSound),
      androidScheduleMode: AndroidScheduleMode.exact,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      payload: payload,
    );
  }

  Future<tz.TZDateTime> _nextInstance(DateTime dateTime) async {
    final String timeZoneName = await FlutterTimezone.getLocalTimezone();
    final tz.TZDateTime scheduledDateTime = tz.TZDateTime.from(
      dateTime,
      tz.getLocation(timeZoneName),
    );

    final tzNow = tz.TZDateTime.now(tz.getLocation(timeZoneName));

    if (scheduledDateTime.isBefore(tzNow)) {
      return scheduledDateTime.add(const Duration(days: 1));
    }
    return scheduledDateTime;
  }

  @override
  Future<void> cancelAllNotifications() async {
    await _flutterLocalNotificationsPlugin.cancelAll();
  }

  @override
  Future<void> cancelNotification(int id) async {
    await _flutterLocalNotificationsPlugin.cancel(id);
  }

  @override
  Future<List<ActiveNotification>> getActiveNotifications() async {
    return _flutterLocalNotificationsPlugin.getActiveNotifications();
  }

  @override
  Future<List<PendingNotificationRequest>> getPendingNotifications() async {
    return _flutterLocalNotificationsPlugin.pendingNotificationRequests();
  }

  void _onDidReceiveLocalNotification(
    int id,
    String? title,
    String? body,
    String? payload,
  ) async {
    // Implement your own local notification handler here
  }

  void _onDidReceiveNotificationResponse(
    NotificationResponse notificationResponse,
  ) async {
    // final String? payload = notificationResponse.payload;
    // Implement your own notification response handler here
  }

  @pragma('vm:entry-point')
  static void _notificationTapBackground(
    NotificationResponse notificationResponse,
  ) {
    // Implement your own background notification handler here
  }

  NotificationDetails _getNotificationDetails({
    String? channel,
    String? sound,
  }) {
    final iosSound = '$sound.aiff';
    final androidSound = sound;
    return NotificationDetails(
      android: AndroidNotificationDetails(
        channel ?? 'channelId',
        channel ?? 'channelName',
        importance: Importance.max,
        priority: Priority.max,
        sound: RawResourceAndroidNotificationSound(androidSound),
        playSound: true,
        enableVibration: true,
        largeIcon: const DrawableResourceAndroidBitmap('dark_icon'),
        colorized: true,
      ),
      iOS: DarwinNotificationDetails(
        presentAlert: true,
        presentSound: true,
        presentBadge: true,
        sound: iosSound,
      ),
    );
  }

  @override
  Future<void> sendNotification({
    required String title,
    required String body,
  }) async {
    await _flutterLocalNotificationsPlugin.show(
      0,
      title,
      body,
      _getNotificationDetails(channel: 'default_channel', sound: 'azan_1'),
      payload: 'Default_Sound',
    );
  }
}
