import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:timezone/data/latest.dart' as tzdata;
import 'package:timezone/timezone.dart' as tz;

import '../config/app_config.dart';

/// Bouton d'action affiché dans une notification.
class NotificationActionSpec {
  const NotificationActionSpec(this.id, this.label);

  /// Identifiant renvoyé dans [NotificationResponse.actionId].
  final String id;
  final String label;
}

/// Groupe de boutons (« catégorie » iOS) déclaré à l'initialisation.
class NotificationCategorySpec {
  const NotificationCategorySpec(this.id, this.actions);

  final String id;
  final List<NotificationActionSpec> actions;
}

/// Rappels locaux programmés sur l'appareil (aucun serveur).
class NotificationService {
  NotificationService({
    this.timeZone = 'Europe/Paris',
    this.categories = const [],
    this.onBackgroundResponse,
  });

  /// Fuseau des rappels. Les applis de la série ciblent la France et le
  /// Luxembourg, qui partagent le même fuseau.
  final String timeZone;

  /// Groupes de boutons d'action utilisables dans [schedule] et [show].
  final List<NotificationCategorySpec> categories;

  /// Appelé dans un isolat d'arrière-plan quand l'utilisateur touche un
  /// bouton d'action, sans ouvrir l'appli. Doit être une fonction de premier
  /// niveau annotée `@pragma('vm:entry-point')`.
  final DidReceiveBackgroundNotificationResponseCallback? onBackgroundResponse;

  final _plugin = FlutterLocalNotificationsPlugin();
  final _taps = StreamController<String>.broadcast();
  final _responses = StreamController<NotificationResponse>.broadcast();
  bool _ready = false;

  /// Charge utile des notifications touchées par l'utilisateur.
  Stream<String> get taps => _taps.stream;

  /// Toutes les réponses reçues appli ouverte (notification ou bouton).
  Stream<NotificationResponse> get responses => _responses.stream;

  bool get supported => AppConfig.mobileServicesAvailable;

  Future<void> init() async {
    if (_ready || !supported) return;
    tzdata.initializeTimeZones();
    tz.setLocalLocation(tz.getLocation(timeZone));
    await _plugin.initialize(
      settings: InitializationSettings(
        android: const AndroidInitializationSettings('@mipmap/ic_launcher'),
        iOS: DarwinInitializationSettings(
          requestAlertPermission: false,
          requestBadgePermission: false,
          requestSoundPermission: false,
          notificationCategories: [
            for (final c in categories)
              DarwinNotificationCategory(c.id, actions: [
                for (final a in c.actions)
                  DarwinNotificationAction.plain(a.id, a.label),
              ]),
          ],
        ),
      ),
      onDidReceiveNotificationResponse: (r) {
        _responses.add(r);
        if (r.actionId == null && r.payload != null) _taps.add(r.payload!);
      },
      onDidReceiveBackgroundNotificationResponse: onBackgroundResponse,
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
    String? categoryId,
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
      notificationDetails: _details(channelId, channelName, categoryId),
    );
  }

  /// Affiche une notification immédiatement (alerte).
  Future<void> show({
    required int id,
    required String title,
    required String body,
    String? payload,
    String channelId = 'alerts',
    String channelName = 'Alertes',
    String? categoryId,
  }) async {
    if (!supported) return;
    await init();
    await _plugin.show(
      id: id,
      title: title,
      body: body,
      payload: payload,
      notificationDetails: _details(channelId, channelName, categoryId),
    );
  }

  /// Identifiants des notifications programmées et pas encore affichées.
  Future<Set<int>> pendingIds() async {
    if (!supported) return {};
    await init();
    final pending = await _plugin.pendingNotificationRequests();
    return {for (final p in pending) p.id};
  }

  NotificationDetails _details(
      String channelId, String channelName, String? categoryId) {
    final category = categoryId == null
        ? null
        : categories.firstWhere((c) => c.id == categoryId);
    return NotificationDetails(
      android: AndroidNotificationDetails(
        channelId,
        channelName,
        importance: Importance.high,
        priority: Priority.high,
        actions: [
          for (final a in category?.actions ?? const <NotificationActionSpec>[])
            AndroidNotificationAction(a.id, a.label),
        ],
      ),
      iOS: DarwinNotificationDetails(categoryIdentifier: categoryId),
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
