import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

// Top-level background handler — must not be inside a class
@pragma('vm:entry-point')
void _onBackgroundNotification(NotificationResponse response) async {
  final prefs = await SharedPreferences.getInstance();
  if (response.payload != null) {
    await prefs.setString('_notif_pending_route', response.payload!);
  }
}

class LocalNotificationService {
  LocalNotificationService._();
  static final LocalNotificationService instance = LocalNotificationService._();

  final _plugin = FlutterLocalNotificationsPlugin();

  /// Fires when a notification is tapped — value is the route payload, e.g. '/dashboard'.
  final pendingRoute = ValueNotifier<String?>(null);

  static const _checkinId   = 1001;
  static const _cravingBase = 2000;

  // ── Init ────────────────────────────────────────────────────────────────────

  Future<void> init() async {
    tz.initializeTimeZones();

    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    await _plugin.initialize(
      const InitializationSettings(android: androidSettings, iOS: iosSettings),
      onDidReceiveNotificationResponse: _onForegroundTap,
      onDidReceiveBackgroundNotificationResponse: _onBackgroundNotification,
    );

    // Handle payload stored by background handler or app-launch-via-notification
    final prefs = await SharedPreferences.getInstance();
    final pending = prefs.getString('_notif_pending_route');
    if (pending != null) {
      await prefs.remove('_notif_pending_route');
      pendingRoute.value = pending;
    }

    final launchDetails = await _plugin.getNotificationAppLaunchDetails();
    if (launchDetails?.didNotificationLaunchApp == true) {
      final p = launchDetails!.notificationResponse?.payload;
      if (p != null) pendingRoute.value = p;
    }
  }

  void _onForegroundTap(NotificationResponse response) {
    if (response.payload != null) {
      pendingRoute.value = response.payload;
    }
  }

  // ── Permission ───────────────────────────────────────────────────────────────

  Future<bool> requestPermission() async {
    final android = _plugin.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();
    return await android?.requestNotificationsPermission() ?? false;
  }

  // ── Check-in notification ────────────────────────────────────────────────────

  Future<void> scheduleCheckin({required int hour, required int minute}) async {
    await _plugin.cancel(_checkinId);
    await _plugin.zonedSchedule(
      _checkinId,
      '✅ Daily Check-in',
      'How are you doing today? Tap to log your check-in and keep your streak going.',
      _nextDaily(hour, minute),
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'checkin_ch', 'Daily Check-in',
          channelDescription: 'Your daily recovery check-in reminder',
          importance: Importance.high,
          priority: Priority.high,
          icon: '@mipmap/ic_launcher',
        ),
        iOS: DarwinNotificationDetails(
          presentAlert: true, presentBadge: true, presentSound: true,
        ),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.time,
      payload: '/dashboard',
    );
  }

  Future<void> cancelCheckin() => _plugin.cancel(_checkinId);

  // ── Craving Shield notifications ─────────────────────────────────────────────

  Future<void> scheduleCravingSlots({
    required String addictionKey,
    required List<TimeOfDay> slots,
  }) async {
    for (int i = 0; i < 5; i++) {
      await _plugin.cancel(_cravingBase + i);
    }
    for (int i = 0; i < slots.length && i < 5; i++) {
      final slot = slots[i];
      await _plugin.zonedSchedule(
        _cravingBase + i,
        '🛡️ Craving Shield',
        _body(addictionKey),
        _nextDaily(slot.hour, slot.minute),
        const NotificationDetails(
          android: AndroidNotificationDetails(
            'craving_ch', 'Craving Shield',
            channelDescription: 'Your craving awareness alerts',
            importance: Importance.high,
            priority: Priority.high,
            icon: '@mipmap/ic_launcher',
          ),
          iOS: DarwinNotificationDetails(
            presentAlert: true, presentBadge: true, presentSound: true,
          ),
        ),
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
        matchDateTimeComponents: DateTimeComponents.time,
        payload: '/craving-shield?addiction=$addictionKey',
      );
    }
  }

  Future<void> cancelCravingSlots() async {
    for (int i = 0; i < 5; i++) {
      await _plugin.cancel(_cravingBase + i);
    }
  }

  // ── Helpers ──────────────────────────────────────────────────────────────────

  tz.TZDateTime _nextDaily(int hour, int minute) {
    final now = tz.TZDateTime.now(tz.local);
    var t = tz.TZDateTime(tz.local, now.year, now.month, now.day, hour, minute);
    if (t.isBefore(now)) t = t.add(const Duration(days: 1));
    return t;
  }

  static const _bodies = {
    'alcohol':      'Is this when you usually drink? Pause — 60 seconds can change tonight.',
    'drugs':        'Your body is calling. Your future self is asking you to pause first.',
    'gambling':     'The urge is peaking. See what it really costs before you act.',
    'smoking':      'Craving a cigarette? Take a deep breath — see what you\'re protecting.',
    'social_media': 'About to scroll mindlessly? See what it\'s doing to your mind first.',
    'other':        'You have a craving right now. Pause for 60 seconds before you act.',
  };

  String _body(String key) => _bodies[key] ?? _bodies['other']!;
}
