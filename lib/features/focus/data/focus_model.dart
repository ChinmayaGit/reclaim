/// Snaps minutes to 5-step grid (5–240) for dropdowns and storage.
int snapFocusLimitMinutes(int minutes) {
  final m = minutes.clamp(5, 240);
  return (((m + 2) ~/ 5) * 5).clamp(5, 240);
}

/// Tracked app: [limitEnabled] shows/enforces per-app daily cap; when off, usage is shown only.
class AppUsageTrackedApp {
  const AppUsageTrackedApp({
    required this.packageName,
    required this.displayName,
    required this.limitMinutes,
    this.limitEnabled = false,
  });

  final String packageName;
  final String displayName;
  final int limitMinutes;
  final bool limitEnabled;

  Map<String, dynamic> toJson() => {
        'p': packageName,
        'n': displayName,
        'm': limitMinutes,
        'e': limitEnabled,
      };

  factory AppUsageTrackedApp.fromJson(Map<String, dynamic> j) {
    return AppUsageTrackedApp(
      packageName: j['p'] as String,
      displayName: j['n'] as String,
      limitMinutes: snapFocusLimitMinutes((j['m'] as num).toInt()),
      limitEnabled: j['e'] as bool? ?? false,
    );
  }

  AppUsageTrackedApp copyWith({
    String? displayName,
    int? limitMinutes,
    bool? limitEnabled,
  }) =>
      AppUsageTrackedApp(
        packageName: packageName,
        displayName: displayName ?? this.displayName,
        limitMinutes: limitMinutes ?? this.limitMinutes,
        limitEnabled: limitEnabled ?? this.limitEnabled,
      );
}

class FocusSettings {
  const FocusSettings({
    this.trackedAppUsage = const [],
    this.scheduleEnabled = false,
    this.scheduleStartHour = 7,
    this.scheduleEndHour = 22,
    this.linkBlockingEnabled = false,
    this.blockedDomains = const [],
    this.snoozeUntil,
  });

  /// Apps to show usage for; optional per-app daily limit when [AppUsageTrackedApp.limitEnabled].
  final List<AppUsageTrackedApp> trackedAppUsage;
  final bool scheduleEnabled;
  final int scheduleStartHour; // 0–23
  final int scheduleEndHour; // 0–23
  final bool linkBlockingEnabled;
  final List<String> blockedDomains;
  final DateTime? snoozeUntil; // temporary override

  bool get isSnoozed =>
      snoozeUntil != null && snoozeUntil!.isAfter(DateTime.now());

  /// True when current time is outside the allowed schedule window.
  bool get isOutsideSchedule {
    if (!scheduleEnabled) return false;
    final hour = DateTime.now().hour;
    if (scheduleStartHour <= scheduleEndHour) {
      return hour < scheduleStartHour || hour >= scheduleEndHour;
    }
    return hour >= scheduleEndHour && hour < scheduleStartHour;
  }

  FocusSettings copyWith({
    List<AppUsageTrackedApp>? trackedAppUsage,
    bool? scheduleEnabled,
    int? scheduleStartHour,
    int? scheduleEndHour,
    bool? linkBlockingEnabled,
    List<String>? blockedDomains,
    DateTime? snoozeUntil,
    bool clearSnooze = false,
  }) {
    return FocusSettings(
      trackedAppUsage: trackedAppUsage ?? this.trackedAppUsage,
      scheduleEnabled: scheduleEnabled ?? this.scheduleEnabled,
      scheduleStartHour: scheduleStartHour ?? this.scheduleStartHour,
      scheduleEndHour: scheduleEndHour ?? this.scheduleEndHour,
      linkBlockingEnabled: linkBlockingEnabled ?? this.linkBlockingEnabled,
      blockedDomains: blockedDomains ?? this.blockedDomains,
      snoozeUntil: clearSnooze ? null : (snoozeUntil ?? this.snoozeUntil),
    );
  }
}
