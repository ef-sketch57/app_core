import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:timezone/data/latest.dart' as tzdata;
import 'package:timezone/timezone.dart' as tz;

import '../config/app_config.dart';

/// Rappels locaux programmés sur l'appareil (aucun serveur).
class NotificationService {
  NotificationService({this.timeZone = 'Europe/Paris'});

  /// Fuseau des rappels. Les applis de la série ciblent la France et le
  /// Luxembourg, qui partagent le même fuseau.
  final String timeZone;

  final _plugin = FlutterLocalNotificationsPlugin();
  final _taps = StreamController<String>.broadcast();
  bool _ready = false;

  /// Charge utile des notifications touchées par l'utilisateur.
  Stream<String> get taps => _taps.stream;

  bool get supported => AppConfig.mobileServicesAvailable;

  Future<void> init() async {
    if (_ready || !supported) return;
    tzdata.initializeTimeZones();
    tz.setLocalLocation(tz.getLocation(timeZone));
    await _plugin.initialize(
      settings: const InitializationSettings(
        android: AndroidInitializationSettings('@mipmap/ic_launcher'),
        iOS: DarwinInitializationSettings(
          requestAlertPermission: false,
          requestBadgePermission: false,
          requestSoundPermission: false,
        ),
      ),
      onDidReceiveNotificationResponse: (r) {
        if (r.payload != null) _taps.add(r.payload!);
      },
    );
    _ready = true;
  }

  /// Charge utile de la notification qui a lancé l'appli, le cas échéant.
  Future<String?> launchPayload() async {
    if (!supported) return null;
    await init();
    final details = await _plugin.getNotificationAppLaunchDetails();
    if (details?.didNotificationLaunchApp ?? false) {
      return details!.notificationResponse?.payload;
    }
    return null;
  }

  /// Demande l'autorisation d'afficher des notifications (Android 13+, iOS).
  Future<bool> requestPermission() async {
    if (!supported) return false;
    await init();
    if (defaultTargetPlatform == TargetPlatform.android) {
      return await _plugin
              .resolvePlatformSpecificImplementation<
                  AndroidFlutterLocalNotificationsPlugin>()
              ?.requestNotificationsPermission() ??
          false;
    }
    return await _plugin
            .resolvePlatformSpecificImplementation<
                IOSFlutterLocalNotificationsPlugin>()
            ?.requestPermissions(alert: true, badge: true, sound: true) ??
        false;
  }

  /// Programme un rappel unique à la date donnée (heure locale du fuseau).
  Future<void> schedule({
    required int id,
    required DateTime at,
    required String title,
    required String body,
    String? payload,
    String channelId = 'reminders',
    String channelName = 'Rappels',
  }) async {
    if (!supported) return;
    await init();
    final when = tz.TZDateTime(
        tz.local, at.year, at.month, at.day, at.hour, at.minute);
    if (when.isBefore(tz.TZDateTime.now(tz.local))) return;
    await _plugin.zonedSchedule(
      id: id,
      scheduledDate: when,
      title: title,
      body: body,
      payload: payload,
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      notificationDetails: NotificationDetails(
        android: AndroidNotificationDetails(channelId, channelName,
            importance: Importance.high, priority: Priority.high),
        iOS: const DarwinNotificationDetails(),
      ),
    );
  }

  Future<void> cancel(int id) async {
    if (!supported) return;
    await init();
    await _plugin.cancel(id: id);
  }

  Future<void> cancelAll() async {
    if (!supported) return;
    await init();
    await _plugin.cancelAll();
  }
}

final notificationServiceProvider =
    Provider<NotificationService>((ref) => NotificationService());
