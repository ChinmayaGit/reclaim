import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:reclaim/features/discipline/data/habit_model.dart';
import 'package:reclaim/shared/constants/app_constants.dart';
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
  static const _habitBase = 4000;
  static const _habitSlots = 64;

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
    String? largeIconPath,
  }) async {
    for (int i = 0; i < 5; i++) {
      await _plugin.cancel(_cravingBase + i);
    }
    for (int i = 0; i < slots.length && i < 5; i++) {
      final slot = slots[i];
      final details = _cravingNotificationDetails(
        addictionKey: addictionKey,
        largeIconPath: largeIconPath,
      );
      await _plugin.zonedSchedule(
        _cravingBase + i,
        '🛡️ Craving Shield',
        _body(addictionKey),
        _nextDaily(slot.hour, slot.minute),
        details,
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
        matchDateTimeComponents: DateTimeComponents.time,
        payload: '/craving-shield?addiction=$addictionKey',
      );
    }
  }

  NotificationDetails _cravingNotificationDetails({
    required String addictionKey,
    String? largeIconPath,
  }) {
    final path = largeIconPath?.trim();
    final hasImg = path != null &&
        path.isNotEmpty &&
        File(path).existsSync();

    final androidBitmap =
        hasImg ? FilePathAndroidBitmap(path) : null;

    return NotificationDetails(
      android: AndroidNotificationDetails(
        'craving_ch', 'Craving Shield',
        channelDescription: 'Your craving awareness alerts',
        importance: Importance.high,
        priority: Priority.high,
        icon: '@mipmap/ic_launcher',
        largeIcon: androidBitmap,
        styleInformation: hasImg && androidBitmap != null
            ? BigPictureStyleInformation(
                androidBitmap,
                largeIcon: androidBitmap,
                contentTitle: 'Craving Shield',
                summaryText: _body(addictionKey),
                hideExpandedLargeIcon: false,
              )
            : null,
      ),
      iOS: DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
        attachments: hasImg ? [DarwinNotificationAttachment(path)] : null,
      ),
    );
  }

  Future<void> cancelCravingSlots() async {
    for (int i = 0; i < 5; i++) {
      await _plugin.cancel(_cravingBase + i);
    }
  }

  // ── Habit reminders (daily at chosen time) ───────────────────────────────────

  /// Schedules one repeating daily notification per habit with reminders on.
  Future<void> syncHabitReminders(List<HabitItem> habits) async {
    for (var i = 0; i < _habitSlots; i++) {
      await _plugin.cancel(_habitBase + i);
    }
    var slot = 0;
    for (final h in habits) {
      if (!h.reminderEnabled) continue;
      if (slot >= _habitSlots) break;
      final hour = h.reminderHour.clamp(0, 23);
      final minute = h.reminderMinute.clamp(0, 59);
      final id = _habitBase + slot;
      slot++;
      await _plugin.zonedSchedule(
        id,
        '⏰ ${h.name}',
        h.dailyGoal > 1
            ? 'Log another step toward your goal (${h.dailyGoal} today).'
            : 'Time for this habit — tap to open.',
        _nextDaily(hour, minute),
        NotificationDetails(
          android: AndroidNotificationDetails(
            'habit_ch', 'Habit reminders',
            channelDescription: 'Daily nudges for your discipline habits',
            importance: Importance.defaultImportance,
            priority: Priority.defaultPriority,
            icon: '@mipmap/ic_launcher',
          ),
          iOS: const DarwinNotificationDetails(
            presentAlert: true,
            presentBadge: true,
            presentSound: true,
          ),
        ),
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
        matchDateTimeComponents: DateTimeComponents.time,
        payload: '${AppConstants.routeHabitDetail}?id=${Uri.encodeComponent(h.id)}',
      );
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
