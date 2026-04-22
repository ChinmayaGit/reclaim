import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/focus_model.dart';
import '../data/focus_repository.dart';
import '../data/usage_channel.dart';

export '../data/usage_channel.dart' show AppUsageStat;
export '../data/focus_model.dart'
    show AppScheduleEntry, AppUsageTrackedApp, FocusSettings, snapFocusLimitMinutes;

// ── Repository singleton ─────────────────────────────────────────────────────

final _focusRepo = FocusRepository();

// ── Focus settings ───────────────────────────────────────────────────────────

class FocusNotifier extends StateNotifier<FocusSettings> {
  FocusNotifier() : super(const FocusSettings()) {
    _load();
  }

  Future<void> _load() async {
    state = await _focusRepo.load();
  }

  Future<void> _save(FocusSettings s) async {
    state = s;
    await _focusRepo.save(s);
  }

  Future<void> setScheduleEnabled(bool enabled) =>
      _save(state.copyWith(scheduleEnabled: enabled));

  Future<void> addScheduleApp({
    required String packageName,
    required String displayName,
  }) async {
    if (state.scheduleApps.any((e) => e.packageName == packageName)) {
      return;
    }
    await _save(state.copyWith(scheduleApps: [
      ...state.scheduleApps,
      AppScheduleEntry(
        packageName: packageName,
        displayName: displayName,
        startHour: 7,
        endHour: 22,
      ),
    ]));
  }

  Future<void> removeScheduleApp(String packageName) async {
    final list = state.scheduleApps
        .where((e) => e.packageName != packageName)
        .toList();
    await _save(state.copyWith(scheduleApps: list));
  }

  Future<void> setScheduleAppHours(
    String packageName, {
    required int startHour,
    required int endHour,
  }) async {
    final sh = startHour.clamp(0, 23);
    final eh = endHour.clamp(0, 23);
    final list = state.scheduleApps
        .map((e) => e.packageName == packageName
            ? e.copyWith(startHour: sh, endHour: eh)
            : e)
        .toList();
    await _save(state.copyWith(scheduleApps: list));
  }

  Future<void> setLinkBlocking(bool enabled) =>
      _save(state.copyWith(linkBlockingEnabled: enabled));

  Future<void> addDomain(String domain) {
    final d = _normalizeDomain(domain);
    if (d.isEmpty || state.blockedDomains.contains(d)) return Future.value();
    return _save(state.copyWith(
      blockedDomains: [...state.blockedDomains, d],
    ));
  }

  Future<void> removeDomain(String domain) {
    return _save(state.copyWith(
      blockedDomains: state.blockedDomains.where((x) => x != domain).toList(),
    ));
  }

  /// Add to tracked list immediately (picker switch on).
  Future<void> addTrackedApp({
    required String packageName,
    required String displayName,
  }) async {
    if (state.trackedAppUsage.any((e) => e.packageName == packageName)) {
      return;
    }
    await _save(state.copyWith(trackedAppUsage: [
      ...state.trackedAppUsage,
      AppUsageTrackedApp(
        packageName: packageName,
        displayName: displayName,
        limitMinutes: snapFocusLimitMinutes(60),
        limitEnabled: false,
      ),
    ]));
  }

  Future<void> removeMonitoredApp(String packageName) async {
    final list = state.trackedAppUsage
        .where((e) => e.packageName != packageName)
        .toList();
    await _save(state.copyWith(trackedAppUsage: list));
  }

  Future<void> setTrackedAppLimit(String packageName, int limitMinutes) async {
    final lim = snapFocusLimitMinutes(limitMinutes);
    final list = state.trackedAppUsage
        .map((e) =>
            e.packageName == packageName ? e.copyWith(limitMinutes: lim) : e)
        .toList();
    await _save(state.copyWith(trackedAppUsage: list));
  }

  Future<void> setTrackedAppLimitEnabled(
      String packageName, bool limitEnabled) async {
    final list = state.trackedAppUsage
        .map((e) => e.packageName == packageName
            ? e.copyWith(limitEnabled: limitEnabled)
            : e)
        .toList();
    await _save(state.copyWith(trackedAppUsage: list));
  }

  void snooze(int minutes) {
    state = state.copyWith(
      snoozeUntil: DateTime.now().add(Duration(minutes: minutes)),
    );
  }

  void clearSnooze() {
    state = state.copyWith(clearSnooze: true);
  }

  static String _normalizeDomain(String raw) {
    return raw
        .trim()
        .toLowerCase()
        .replaceAll(RegExp(r'^https?://'), '')
        .replaceAll(RegExp(r'^www\.'), '')
        .split('/')[0];
  }
}

final focusSettingsProvider =
    StateNotifierProvider<FocusNotifier, FocusSettings>(
  (_) => FocusNotifier(),
);

// ── Usage (Android UsageStats) ───────────────────────────────────────────────

class UsageStatsSnapshot {
  const UsageStatsSnapshot({
    required this.hasUsagePermission,
    required this.totalOtherAppsSeconds,
    required this.secondsByPackage,
    required this.appsSorted,
  });

  final bool hasUsagePermission;
  final int totalOtherAppsSeconds;
  final Map<String, int> secondsByPackage;
  final List<AppUsageStat> appsSorted;

  static const empty = UsageStatsSnapshot(
    hasUsagePermission: false,
    totalOtherAppsSeconds: 0,
    secondsByPackage: {},
    appsSorted: [],
  );
}

class UsageNotifier extends StateNotifier<UsageStatsSnapshot> {
  UsageNotifier() : super(UsageStatsSnapshot.empty) {
    _init();
  }

  AppLifecycleListener? _listener;

  Future<void> _init() async {
    _listener = AppLifecycleListener(
      onResume: () => unawaited(refresh()),
      onPause: () => unawaited(refresh()),
      onInactive: () => unawaited(refresh()),
      onHide: () => unawaited(refresh()),
    );
    await refresh();
  }

  @override
  void dispose() {
    _listener?.dispose();
    super.dispose();
  }

  Future<void> refresh() async {
    final permitted = await UsageChannel.hasPermission();
    if (!permitted) {
      state = UsageStatsSnapshot.empty;
      return;
    }
    final list = await UsageChannel.getAppUsage();
    final map = <String, int>{
      for (final s in list) s.packageName: s.secondsToday,
    };
    final total = list.fold<int>(0, (a, s) => a + s.secondsToday);
    final sorted = [...list]
      ..sort((a, b) => b.secondsToday.compareTo(a.secondsToday));
    state = UsageStatsSnapshot(
      hasUsagePermission: true,
      totalOtherAppsSeconds: total,
      secondsByPackage: map,
      appsSorted: sorted,
    );
  }

  void tick() => unawaited(refresh());
}

final usageNotifierProvider =
    StateNotifierProvider<UsageNotifier, UsageStatsSnapshot>(
  (_) => UsageNotifier(),
);

final isAppLockedProvider = Provider<bool>((ref) {
  final settings = ref.watch(focusSettingsProvider);
  if (settings.isSnoozed) return false;
  if (settings.isOutsideSchedule) return true;

  final snap = ref.watch(usageNotifierProvider);
  if (!snap.hasUsagePermission) return false;
  for (final t in settings.trackedAppUsage) {
    if (!t.limitEnabled) continue;
    final sec = snap.secondsByPackage[t.packageName] ?? 0;
    if (sec >= t.limitMinutes * 60) return true;
  }
  return false;
});

final lockReasonProvider = Provider<String?>((ref) {
  final settings = ref.watch(focusSettingsProvider);
  if (settings.isSnoozed) return null;

  if (settings.isOutsideSchedule) {
    return 'You’re outside the hours when Reclaim is allowed on this device.\n'
        'Open Focus & Block → App schedule to review each app’s allowed window.';
  }

  final snap = ref.watch(usageNotifierProvider);
  if (!snap.hasUsagePermission) return null;
  for (final t in settings.trackedAppUsage) {
    if (!t.limitEnabled) continue;
    final sec = snap.secondsByPackage[t.packageName] ?? 0;
    if (sec >= t.limitMinutes * 60) {
      return '${t.displayName} hit its ${t.limitMinutes}m daily limit today.\nTime to step away and practice in real life.';
    }
  }
  return null;
});
