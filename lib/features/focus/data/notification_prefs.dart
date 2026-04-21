import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../services/local_notification_service.dart';

// ── Model ─────────────────────────────────────────────────────────────────────

class NotificationPrefs {
  const NotificationPrefs({
    this.checkinEnabled    = false,
    this.checkinHour       = 9,
    this.checkinMinute     = 0,
    this.cravingEnabled    = false,
    this.addictionKey      = 'alcohol',
    this.cravingSlots      = const [TimeOfDay(hour: 20, minute: 0)],
  });

  final bool checkinEnabled;
  final int  checkinHour, checkinMinute;
  final bool cravingEnabled;
  final String addictionKey;
  final List<TimeOfDay> cravingSlots;

  NotificationPrefs copyWith({
    bool?           checkinEnabled,
    int?            checkinHour,
    int?            checkinMinute,
    bool?           cravingEnabled,
    String?         addictionKey,
    List<TimeOfDay>? cravingSlots,
  }) => NotificationPrefs(
    checkinEnabled:  checkinEnabled  ?? this.checkinEnabled,
    checkinHour:     checkinHour     ?? this.checkinHour,
    checkinMinute:   checkinMinute   ?? this.checkinMinute,
    cravingEnabled:  cravingEnabled  ?? this.cravingEnabled,
    addictionKey:    addictionKey    ?? this.addictionKey,
    cravingSlots:    cravingSlots    ?? this.cravingSlots,
  );
}

// ── Notifier ──────────────────────────────────────────────────────────────────

class NotificationPrefsNotifier extends StateNotifier<NotificationPrefs> {
  NotificationPrefsNotifier() : super(const NotificationPrefs()) {
    _load();
  }

  static const _pCheckinEnabled  = 'notif_checkin_enabled';
  static const _pCheckinHour     = 'notif_checkin_hour';
  static const _pCheckinMinute   = 'notif_checkin_minute';
  static const _pCravingEnabled  = 'notif_craving_enabled';
  static const _pAddictionKey    = 'notif_addiction_key';
  static const _pCravingSlots    = 'notif_craving_slots'; // encoded as "h:m,h:m"

  Future<void> _load() async {
    final p = await SharedPreferences.getInstance();
    final slotsRaw = p.getString(_pCravingSlots) ?? '20:0';
    final slots = slotsRaw.split(',').map((s) {
      final parts = s.split(':');
      return TimeOfDay(hour: int.tryParse(parts[0]) ?? 20, minute: int.tryParse(parts[1]) ?? 0);
    }).toList();
    state = NotificationPrefs(
      checkinEnabled: p.getBool(_pCheckinEnabled)   ?? false,
      checkinHour:    p.getInt(_pCheckinHour)        ?? 9,
      checkinMinute:  p.getInt(_pCheckinMinute)      ?? 0,
      cravingEnabled: p.getBool(_pCravingEnabled)   ?? false,
      addictionKey:   p.getString(_pAddictionKey)   ?? 'alcohol',
      cravingSlots:   slots,
    );
  }

  Future<void> _save(NotificationPrefs s) async {
    state = s;
    final p = await SharedPreferences.getInstance();
    await p.setBool(_pCheckinEnabled,  s.checkinEnabled);
    await p.setInt(_pCheckinHour,      s.checkinHour);
    await p.setInt(_pCheckinMinute,    s.checkinMinute);
    await p.setBool(_pCravingEnabled,  s.cravingEnabled);
    await p.setString(_pAddictionKey,  s.addictionKey);
    final slotsStr = s.cravingSlots.map((t) => '${t.hour}:${t.minute}').join(',');
    await p.setString(_pCravingSlots,  slotsStr);
  }

  Future<void> setCheckin({required bool enabled, int? hour, int? minute}) async {
    final ns = state.copyWith(
      checkinEnabled: enabled,
      checkinHour:    hour,
      checkinMinute:  minute,
    );
    await _save(ns);
    if (ns.checkinEnabled) {
      await LocalNotificationService.instance
          .scheduleCheckin(hour: ns.checkinHour, minute: ns.checkinMinute);
    } else {
      await LocalNotificationService.instance.cancelCheckin();
    }
  }

  Future<void> setCraving({
    required bool enabled,
    String? addictionKey,
    List<TimeOfDay>? slots,
  }) async {
    final ns = state.copyWith(
      cravingEnabled: enabled,
      addictionKey:   addictionKey,
      cravingSlots:   slots,
    );
    await _save(ns);
    if (ns.cravingEnabled) {
      await LocalNotificationService.instance.scheduleCravingSlots(
        addictionKey: ns.addictionKey,
        slots: ns.cravingSlots,
      );
    } else {
      await LocalNotificationService.instance.cancelCravingSlots();
    }
  }

  Future<void> addSlot(TimeOfDay t) async {
    if (state.cravingSlots.length >= 3) return;
    final ns = state.copyWith(cravingSlots: [...state.cravingSlots, t]);
    await _save(ns);
    if (ns.cravingEnabled) {
      await LocalNotificationService.instance.scheduleCravingSlots(
        addictionKey: ns.addictionKey, slots: ns.cravingSlots,
      );
    }
  }

  Future<void> removeSlot(int index) async {
    final slots = [...state.cravingSlots]..removeAt(index);
    final ns = state.copyWith(cravingSlots: slots);
    await _save(ns);
    if (ns.cravingEnabled) {
      await LocalNotificationService.instance.scheduleCravingSlots(
        addictionKey: ns.addictionKey, slots: ns.cravingSlots,
      );
    }
  }
}

final notificationPrefsProvider =
    StateNotifierProvider<NotificationPrefsNotifier, NotificationPrefs>(
  (_) => NotificationPrefsNotifier(),
);
