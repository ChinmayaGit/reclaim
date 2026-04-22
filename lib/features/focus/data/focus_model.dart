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

/// Allowed hours for a specific app (same semantics as the old global window: Reclaim is
/// available only while the current hour falls inside at least one entry’s window).
class AppScheduleEntry {
  const AppScheduleEntry({
    required this.packageName,
    required this.displayName,
    required this.startHour,
    required this.endHour,
  });

  final String packageName;
  final String displayName;
  /// Inclusive start hour 0–23.
  final int startHour;
  /// Exclusive end hour (same rule as the old global picker: current hour must be before end).
  final int endHour;

  Map<String, dynamic> toJson() => {
        'p': packageName,
        'n': displayName,
        's': startHour,
        'e': endHour,
      };

  factory AppScheduleEntry.fromJson(Map<String, dynamic> j) {
    return AppScheduleEntry(
      packageName: j['p'] as String? ?? '',
      displayName: j['n'] as String? ?? 'App',
      startHour: (j['s'] as num?)?.toInt() ?? 7,
      endHour: (j['e'] as num?)?.toInt() ?? 22,
    );
  }

  AppScheduleEntry copyWith({
    String? packageName,
    String? displayName,
    int? startHour,
    int? endHour,
  }) =>
      AppScheduleEntry(
        packageName: packageName ?? this.packageName,
        displayName: displayName ?? this.displayName,
        startHour: startHour ?? this.startHour,
        endHour: endHour ?? this.endHour,
      );

  /// Current hour [0..23] falls inside the allowed window (supports overnight spans).
  static bool hourInAllowedWindow(int hour, int start, int end) {
    if (start <= end) {
      return hour >= start && hour < end;
    }
    return hour >= start || hour < end;
  }
}

class FocusSettings {
  const FocusSettings({
    this.trackedAppUsage = const [],
    this.scheduleEnabled = false,
    this.scheduleApps = const [],
    this.linkBlockingEnabled = false,
    this.blockedDomains = const [],
    this.snoozeUntil,
  });

  /// Apps to show usage for; optional per-app daily limit when [AppUsageTrackedApp.limitEnabled].
  final List<AppUsageTrackedApp> trackedAppUsage;
  final bool scheduleEnabled;
  /// Per-app allowed time windows. Reclaim stays available if the current hour is inside
  /// **any** window. Empty list + enabled → no time lock until the user adds apps.
  final List<AppScheduleEntry> scheduleApps;
  final bool linkBlockingEnabled;
  final List<String> blockedDomains;
  final DateTime? snoozeUntil; // temporary override

  bool get isSnoozed =>
      snoozeUntil != null && snoozeUntil!.isAfter(DateTime.now());

  /// True when schedule is on, at least one window exists, and the current hour is outside every window.
  bool get isOutsideSchedule {
    if (!scheduleEnabled) return false;
    if (scheduleApps.isEmpty) return false;
    final hour = DateTime.now().hour;
    return !scheduleApps.any(
      (e) => AppScheduleEntry.hourInAllowedWindow(
        hour,
        e.startHour,
        e.endHour,
      ),
    );
  }

  FocusSettings copyWith({
    List<AppUsageTrackedApp>? trackedAppUsage,
    bool? scheduleEnabled,
    List<AppScheduleEntry>? scheduleApps,
    bool? linkBlockingEnabled,
    List<String>? blockedDomains,
    DateTime? snoozeUntil,
    bool clearSnooze = false,
  }) {
    return FocusSettings(
      trackedAppUsage: trackedAppUsage ?? this.trackedAppUsage,
      scheduleEnabled: scheduleEnabled ?? this.scheduleEnabled,
      scheduleApps: scheduleApps ?? this.scheduleApps,
      linkBlockingEnabled: linkBlockingEnabled ?? this.linkBlockingEnabled,
      blockedDomains: blockedDomains ?? this.blockedDomains,
      snoozeUntil: clearSnooze ? null : (snoozeUntil ?? this.snoozeUntil),
    );
  }
}
