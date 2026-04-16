class FocusSettings {
  const FocusSettings({
    this.usageLimitEnabled = false,
    this.dailyLimitMinutes = 60,
    this.scheduleEnabled = false,
    this.scheduleStartHour = 7,
    this.scheduleEndHour = 22,
    this.linkBlockingEnabled = false,
    this.blockedDomains = const [],
    this.snoozeUntil,
  });

  final bool usageLimitEnabled;
  final int dailyLimitMinutes;     // 1 – 480
  final bool scheduleEnabled;
  final int scheduleStartHour;     // 0–23
  final int scheduleEndHour;       // 0–23
  final bool linkBlockingEnabled;
  final List<String> blockedDomains;
  final DateTime? snoozeUntil;     // temporary override

  bool get isSnoozed =>
      snoozeUntil != null && snoozeUntil!.isAfter(DateTime.now());

  /// True if current time is outside the allowed schedule window.
  bool get isOutsideSchedule {
    if (!scheduleEnabled) return false;
    final hour = DateTime.now().hour;
    if (scheduleStartHour <= scheduleEndHour) {
      return hour < scheduleStartHour || hour >= scheduleEndHour;
    }
    // Overnight window (e.g. 22–06)
    return hour >= scheduleEndHour && hour < scheduleStartHour;
  }

  FocusSettings copyWith({
    bool? usageLimitEnabled,
    int? dailyLimitMinutes,
    bool? scheduleEnabled,
    int? scheduleStartHour,
    int? scheduleEndHour,
    bool? linkBlockingEnabled,
    List<String>? blockedDomains,
    DateTime? snoozeUntil,
    bool clearSnooze = false,
  }) {
    return FocusSettings(
      usageLimitEnabled: usageLimitEnabled ?? this.usageLimitEnabled,
      dailyLimitMinutes: dailyLimitMinutes ?? this.dailyLimitMinutes,
      scheduleEnabled: scheduleEnabled ?? this.scheduleEnabled,
      scheduleStartHour: scheduleStartHour ?? this.scheduleStartHour,
      scheduleEndHour: scheduleEndHour ?? this.scheduleEndHour,
      linkBlockingEnabled: linkBlockingEnabled ?? this.linkBlockingEnabled,
      blockedDomains: blockedDomains ?? this.blockedDomains,
      snoozeUntil: clearSnooze ? null : (snoozeUntil ?? this.snoozeUntil),
    );
  }
}
