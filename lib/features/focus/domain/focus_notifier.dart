import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/focus_model.dart';
import '../data/focus_repository.dart';

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

  Future<void> setUsageLimit({required bool enabled, int? minutes}) =>
      _save(state.copyWith(
        usageLimitEnabled: enabled,
        dailyLimitMinutes: minutes ?? state.dailyLimitMinutes,
      ));

  Future<void> setSchedule({
    required bool enabled,
    int? startHour,
    int? endHour,
  }) =>
      _save(state.copyWith(
        scheduleEnabled: enabled,
        scheduleStartHour: startHour ?? state.scheduleStartHour,
        scheduleEndHour: endHour ?? state.scheduleEndHour,
      ));

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

  /// Snooze all locks for [minutes] minutes (soft bypass).
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

// ── Usage tracking ───────────────────────────────────────────────────────────

class UsageNotifier extends StateNotifier<int> {
  UsageNotifier() : super(0) {
    _init();
  }

  DateTime? _sessionStart;
  AppLifecycleListener? _listener;

  Future<void> _init() async {
    await _focusRepo.pruneOldUsage();
    state = await _focusRepo.loadTodayUsageSeconds();
    _sessionStart = DateTime.now(); // app already in foreground at init
    _listener = AppLifecycleListener(
      onResume:   () => _sessionStart = DateTime.now(),
      onPause:    _flush,
      onInactive: _flush,
      onHide:     _flush,
    );
  }

  @override
  void dispose() {
    _flush();
    _listener?.dispose();
    super.dispose();
  }

  void _flush() {
    if (_sessionStart == null) return;
    final elapsed = DateTime.now().difference(_sessionStart!).inSeconds;
    _sessionStart = null;
    if (elapsed <= 0) return;
    state = state + elapsed;
    _focusRepo.saveTodayUsageSeconds(state);
  }

  /// Called each second from the UI ticker so `isAppLockedProvider` reacts live.
  void tick() {
    if (_sessionStart == null) return;
    final now = DateTime.now();
    final total = state + now.difference(_sessionStart!).inSeconds;
    if (total != state) state = total;
  }
}

final usageNotifierProvider =
    StateNotifierProvider<UsageNotifier, int>((_) => UsageNotifier());

/// True when the app should be locked (limit hit or outside schedule),
/// unless snoozed.
final isAppLockedProvider = Provider<bool>((ref) {
  final settings = ref.watch(focusSettingsProvider);
  if (settings.isSnoozed) return false;

  // Outside schedule window
  if (settings.isOutsideSchedule) return true;

  // Daily usage limit exceeded
  if (settings.usageLimitEnabled) {
    final usedSeconds = ref.watch(usageNotifierProvider);
    if (usedSeconds >= settings.dailyLimitMinutes * 60) return true;
  }

  return false;
});

/// Returns the block reason string, or null if not locked.
final lockReasonProvider = Provider<String?>((ref) {
  final settings = ref.watch(focusSettingsProvider);
  if (settings.isSnoozed) return null;

  if (settings.isOutsideSchedule) {
    final start = _fmt(settings.scheduleStartHour);
    final end   = _fmt(settings.scheduleEndHour);
    return 'App is scheduled to be available $start – $end.\nCome back then.';
  }

  if (settings.usageLimitEnabled) {
    final usedSeconds = ref.watch(usageNotifierProvider);
    if (usedSeconds >= settings.dailyLimitMinutes * 60) {
      return "You've reached your ${settings.dailyLimitMinutes}-minute daily limit.\nTime to step away and practice in real life.";
    }
  }

  return null;
});

String _fmt(int hour) {
  final suffix = hour < 12 ? 'AM' : 'PM';
  final h = hour == 0 ? 12 : (hour > 12 ? hour - 12 : hour);
  return '$h:00 $suffix';
}
