import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../core/providers/core_providers.dart';
import '../../../core/theme/app_colors.dart';
import 'day_recap_progress_widgets.dart';
import '../../../shared/constants/app_constants.dart';
import '../../../shared/models/journal_model.dart';
import '../../../shared/models/tracker_model.dart';
import '../../discipline/domain/discipline_notifier.dart';
import '../../health/data/sleep_model.dart';
import '../../health/data/water_model.dart';
import '../../focus/domain/focus_notifier.dart';
import '../../health/data/water_repository.dart';
import '../../health/domain/sleep_notifier.dart';
import '../../journal/domain/journal_notifier.dart';
import '../../tracker/domain/tracker_notifier.dart';
import '../../workout_log/domain/workout_notifier.dart';
import '../../workout_log/data/workout_models.dart';

bool _sameDay(DateTime a, DateTime b) =>
    a.year == b.year && a.month == b.month && a.day == b.day;

class DayRecapScreen extends ConsumerStatefulWidget {
  const DayRecapScreen({super.key, required this.day});

  /// Calendar date (time ignored).
  final DateTime day;

  @override
  ConsumerState<DayRecapScreen> createState() => _DayRecapScreenState();
}

class _DayRecapScreenState extends ConsumerState<DayRecapScreen> {
  Map<String, int> _habitProgressMap = {};
  List<WaterEntry> _waterEntries = [];
  int _waterGoalMl = 3000;
  bool _localLoaded = false;

  DateTime get d => DateTime(widget.day.year, widget.day.month, widget.day.day);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadLocal());
  }

  Future<void> _loadLocal() async {
    final progress =
        await ref.read(disciplineProvider.notifier).progressMapOn(d);
    final waterRepo = WaterRepository();
    final entries = await waterRepo.loadEntriesForDay(d);
    final goal = await waterRepo.loadGoalMl();
    if (!mounted) return;
    setState(() {
      _habitProgressMap = progress;
      _waterEntries = entries;
      _waterGoalMl = goal;
      _localLoaded = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    final dateStr =
        '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';
    final tracker = ref.watch(trackerProvider).value;
    final checkedIn = tracker?.checkInDates.contains(dateStr) ?? false;

    final moods = ref.watch(moodHistoryProvider).value ?? [];
    MoodCheckin? moodThatDay;
    for (final m in moods) {
      if (_sameDay(m.checkinDate, d)) {
        moodThatDay = m;
        break;
      }
    }

    final journalAsync = ref.watch(journalEntriesProvider);
    final entries = journalAsync.value ?? [];
    final journalsToday =
        entries.where((e) => _sameDay(e.createdAt, d)).toList();

    final urges = ref.watch(urgeLogsProvider).value ?? [];
    final urgesToday = urges.where((u) => _sameDay(u.loggedAt, d)).toList();

    final workouts = ref.watch(workoutLogProvider).history;
    final workoutsToday =
        workouts.where((w) => _sameDay(w.finishedAt, d)).toList();

    final sleep = ref.watch(sleepProvider);
    final sleepThatDay = sleep.entries
        .where((e) => _sameDay(e.wakeTime, d))
        .toList();

    final habits = ref.watch(disciplineProvider).habits;
    var habitPoints = 0;
    final doneHabitNames = <String>[];
    for (final h in habits) {
      final c = _habitProgressMap[h.id] ?? 0;
      final g = h.dailyGoal.clamp(1, 999);
      if (c > 0) {
        habitPoints +=
            ((c * h.pointsWeight.clamp(1, 100)) / g).round();
      }
      if (c >= g) doneHabitNames.add(h.name);
    }
    final habitIds = habits.map((e) => e.id).toSet();
    final orphan = _habitProgressMap.entries
        .where((e) => e.value > 0 && !habitIds.contains(e.key))
        .length;

    final isToday = _sameDay(d, DateTime.now());
    final usage = isToday ? ref.watch(usageNotifierProvider) : null;
    final focusSettings = isToday ? ref.watch(focusSettingsProvider) : null;

    final title = DateFormat('EEEE, MMM d, y').format(d);
    final isPremium = ref.watch(isPremiumProvider);

    return Scaffold(
      backgroundColor: context.colBackground,
      appBar: AppBar(
        backgroundColor: context.colSurface,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Your day'),
            Text(
              title,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w400,
                color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.65),
              ),
            ),
          ],
        ),
        actions: [
          if (isPremium)
            TextButton.icon(
              onPressed: () => ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Generating PDF report…')),
              ),
              icon: const Icon(Icons.picture_as_pdf_outlined, size: 18),
              label: const Text('Export PDF'),
            ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
        children: [
          _HeroCard(
            dateLabel: title,
            checkedIn: checkedIn,
            habitPoints: habitPoints,
            journalCount: journalsToday.length,
            workoutCount: workoutsToday.length,
          ),
          const SizedBox(height: 20),
          _sectionLabel(context, 'Recovery & mood'),
          _tile(
            context,
            icon: checkedIn ? Icons.verified : Icons.event_busy_outlined,
            iconColor: AppColors.teal600,
            title: 'Check-in',
            subtitle: checkedIn
                ? 'You checked in on Reclaim this day.'
                : 'No check-in recorded for this day.',
          ),
          if (moodThatDay != null) ...[
            const SizedBox(height: 10),
            _tile(
              context,
              icon: Icons.mood,
              iconColor: AppColors.purple400,
              title: 'Mood',
              subtitle:
                  '${AppConstants.moodEmojis[(moodThatDay.moodScore - 1).clamp(0, 4)]} '
                  '${AppConstants.moodLabels[(moodThatDay.moodScore - 1).clamp(0, 4)]}',
            ),
          ],

          const SizedBox(height: 20),
          _sectionLabel(context, 'Progress & insights'),
          const DayRecapProgressSection(),

          const SizedBox(height: 20),
          _sectionLabel(context, 'Habits & discipline'),
          if (!_localLoaded)
            const Center(child: Padding(
              padding: EdgeInsets.all(16),
              child: CircularProgressIndicator(strokeWidth: 2),
            ))
          else if (doneHabitNames.isEmpty && orphan == 0)
            _emptyLine(context, 'No habits marked done for this day.')
          else ...[
            for (final name in doneHabitNames)
              _bulletLine(context, name, AppColors.teal600),
            if (orphan > 0)
              _emptyLine(
                context,
                '$orphan habit(s) were logged but are not on your current list.',
              ),
            const SizedBox(height: 6),
            Text(
              'Points from habits that day: $habitPoints',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: AppColors.green600,
                fontSize: 13,
              ),
            ),
          ],

          const SizedBox(height: 20),
          _sectionLabel(context, 'Journal'),
          if (journalsToday.isEmpty)
            _emptyLine(context, 'No journal entries written this day.')
          else
            ...journalsToday.map(
              (e) => _JournalCard(entry: e),
            ),

          const SizedBox(height: 20),
          _sectionLabel(context, 'Urges & logging'),
          if (urgesToday.isEmpty)
            _emptyLine(context, 'No urge / intensity logs this day.')
          else
            ...urgesToday.map((u) => _UrgeCard(log: u)),

          const SizedBox(height: 20),
          _sectionLabel(context, 'Gym & workouts'),
          if (workoutsToday.isEmpty)
            _emptyLine(context, 'No finished gym sessions logged this day.')
          else
            ...workoutsToday.map((w) => _WorkoutCard(workout: w)),

          const SizedBox(height: 20),
          _sectionLabel(context, 'Sleep'),
          if (sleepThatDay.isEmpty)
            _emptyLine(
              context,
              'No sleep entry with wake-up on this calendar day.',
            )
          else
            ...sleepThatDay.map((e) => _SleepLine(entry: e)),

          const SizedBox(height: 20),
          _sectionLabel(context, 'Water'),
          if (!_localLoaded)
            const SizedBox.shrink()
          else if (_waterEntries.isEmpty)
            _emptyLine(context, 'No water log saved for this day (or data was cleared).')
          else
            _WaterDaySummary(entries: _waterEntries, goalMl: _waterGoalMl),

          const SizedBox(height: 20),
          _sectionLabel(context, 'Focus & screen time'),
          if (!isToday)
            _emptyLine(
              context,
              'Per-app usage breakdown is only available for today. '
              'Open Focus for live stats.',
            )
          else if (usage == null || !usage.hasUsagePermission)
            _emptyLine(
              context,
              'Usage access is off or unavailable — open Focus to enable.',
            )
          else ...[
            Text(
              'Total tracked time (other apps): '
              '${(usage.totalOtherAppsSeconds / 3600).toStringAsFixed(1)} h',
              style: TextStyle(fontSize: 13, color: context.colText),
            ),
            const SizedBox(height: 8),
            if (focusSettings != null && focusSettings.trackedAppUsage.isNotEmpty)
              ...focusSettings.trackedAppUsage.take(12).map((t) {
                final sec = usage.secondsByPackage[t.packageName] ?? 0;
                final m = sec ~/ 60;
                return Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          t.displayName,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(fontSize: 12, color: context.colTextSec),
                        ),
                      ),
                      Text(
                        m > 0 ? '${m}m' : '—',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: context.colText,
                        ),
                      ),
                    ],
                  ),
                );
              }),
          ],
        ],
      ),
    );
  }
}

// ── Widgets ─────────────────────────────────────────────────────────────────

Widget _sectionLabel(BuildContext context, String text) {
  return Padding(
    padding: const EdgeInsets.only(bottom: 8),
    child: Text(
      text,
      style: TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.w800,
        letterSpacing: 0.3,
        color: context.colText,
      ),
    ),
  );
}

Widget _emptyLine(BuildContext context, String text) {
  return Padding(
    padding: const EdgeInsets.only(bottom: 8),
    child: Text(
      text,
      style: TextStyle(fontSize: 13, height: 1.4, color: context.colTextSec),
    ),
  );
}

Widget _bulletLine(BuildContext context, String text, Color c) {
  return Padding(
    padding: const EdgeInsets.only(bottom: 6),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(Icons.check_circle, size: 18, color: c),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: TextStyle(fontSize: 14, color: context.colText),
          ),
        ),
      ],
    ),
  );
}

class _HeroCard extends StatelessWidget {
  const _HeroCard({
    required this.dateLabel,
    required this.checkedIn,
    required this.habitPoints,
    required this.journalCount,
    required this.workoutCount,
  });

  final String dateLabel;
  final bool checkedIn;
  final int habitPoints;
  final int journalCount;
  final int workoutCount;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.teal600.withValues(alpha: 0.9),
            AppColors.purple600.withValues(alpha: 0.85),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Day overview',
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.85),
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            dateLabel,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.w800,
              height: 1.2,
            ),
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              _HeroChip(
                icon: Icons.verified_outlined,
                label: checkedIn ? 'Checked in' : 'No check-in',
              ),
              _HeroChip(
                icon: Icons.stars_outlined,
                label: '$habitPoints habit pts',
              ),
              _HeroChip(
                icon: Icons.book_outlined,
                label: '$journalCount journal',
              ),
              _HeroChip(
                icon: Icons.fitness_center,
                label: '$workoutCount workout',
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _HeroChip extends StatelessWidget {
  const _HeroChip({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.18),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withValues(alpha: 0.35)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: Colors.white),
          const SizedBox(width: 6),
          Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 11,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

Widget _tile(
  BuildContext context, {
  required IconData icon,
  required Color iconColor,
  required String title,
  required String subtitle,
}) {
  return Container(
    margin: const EdgeInsets.only(bottom: 10),
    padding: const EdgeInsets.all(14),
    decoration: BoxDecoration(
      color: context.colSurface,
      borderRadius: BorderRadius.circular(14),
      border: Border.all(color: context.colBorder),
    ),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: iconColor, size: 22),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 14,
                  color: context.colText,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: TextStyle(fontSize: 13, color: context.colTextSec, height: 1.35),
              ),
            ],
          ),
        ),
      ],
    ),
  );
}

class _JournalCard extends StatelessWidget {
  const _JournalCard({required this.entry});

  final JournalEntry entry;

  @override
  Widget build(BuildContext context) {
    final preview = entry.text.trim();
    final short = preview.length > 160 ? '${preview.substring(0, 160)}…' : preview;
    final time = DateFormat.jm().format(entry.createdAt);
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: context.colSurface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: context.colBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                time,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: context.colTextHint,
                ),
              ),
              const Spacer(),
              Text(
                'Mood ${entry.moodScore}/10',
                style: TextStyle(fontSize: 11, color: context.colTextSec),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            short.isEmpty ? '(No text)' : short,
            style: TextStyle(fontSize: 13, height: 1.45, color: context.colText),
          ),
        ],
      ),
    );
  }
}

class _UrgeCard extends StatelessWidget {
  const _UrgeCard({required this.log});

  final UrgeLog log;

  @override
  Widget build(BuildContext context) {
    final t = DateFormat.jm().format(log.loggedAt);
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: context.colSurface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: context.colBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '$t · Intensity ${log.intensity}/10',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: context.colTextHint,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            log.trigger.isEmpty ? '—' : log.trigger,
            style: TextStyle(fontSize: 13, color: context.colText),
          ),
          Text(
            'Outcome: ${log.outcome}',
            style: TextStyle(fontSize: 12, color: context.colTextSec),
          ),
        ],
      ),
    );
  }
}

class _WorkoutCard extends StatelessWidget {
  const _WorkoutCard({required this.workout});

  final FinishedWorkout workout;

  @override
  Widget build(BuildContext context) {
    final t = DateFormat.jm().format(workout.finishedAt);
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: context.colSurface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: context.colBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.fitness_center, color: AppColors.amber600, size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  workout.title,
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 15,
                    color: context.colText,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            'Finished at $t · ${workout.totalSets} sets · ${workout.totalVolume} kg volume',
            style: TextStyle(fontSize: 12, color: context.colTextSec),
          ),
          if (workout.exercises.isNotEmpty) ...[
            const SizedBox(height: 8),
            ...workout.exercises.take(6).map(
                  (e) => Padding(
                    padding: const EdgeInsets.only(bottom: 2),
                    child: Text(
                      '· ${e.name} (${e.sets.where((s) => s.done).length} sets)',
                      style: TextStyle(fontSize: 12, color: context.colTextSec),
                    ),
                  ),
                ),
            if (workout.exercises.length > 6)
              Text(
                '… and ${workout.exercises.length - 6} more exercise(s)',
                style: TextStyle(fontSize: 11, color: context.colTextHint),
              ),
          ],
        ],
      ),
    );
  }
}

class _SleepLine extends StatelessWidget {
  const _SleepLine({required this.entry});

  final SleepEntry entry;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        '${DateFormat.MMMd().format(entry.bedtime)} bed → '
        '${DateFormat.jm().format(entry.wakeTime)} wake · '
        '${entry.hours.toStringAsFixed(1)} h',
        style: TextStyle(fontSize: 13, color: context.colText),
      ),
    );
  }
}

class _WaterDaySummary extends StatelessWidget {
  const _WaterDaySummary({required this.entries, required this.goalMl});

  final List<WaterEntry> entries;
  final int goalMl;

  @override
  Widget build(BuildContext context) {
    final total = entries.fold<int>(0, (s, e) => s + e.amountMl);
    final pct = goalMl > 0 ? (total / goalMl).clamp(0.0, 1.0) : 0.0;
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: context.colSurface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: context.colBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '${(total / 1000).toStringAsFixed(2)} L of ${(goalMl / 1000).toStringAsFixed(1)} L goal',
            style: TextStyle(
              fontWeight: FontWeight.w700,
              fontSize: 14,
              color: context.colText,
            ),
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: pct,
              minHeight: 6,
              backgroundColor: AppColors.blue400.withValues(alpha: 0.15),
              valueColor: const AlwaysStoppedAnimation(AppColors.blue400),
            ),
          ),
          const SizedBox(height: 10),
          Text(
            'Log (${entries.length})',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: context.colTextHint,
            ),
          ),
          ...entries.take(8).map(
                (e) => Text(
                  '· ${DateFormat.jm().format(e.time)} — ${e.amountMl} ml',
                  style: TextStyle(fontSize: 12, color: context.colTextSec),
                ),
              ),
          if (entries.length > 8)
            Text(
              '… ${entries.length - 8} more',
              style: TextStyle(fontSize: 11, color: context.colTextHint),
            ),
        ],
      ),
    );
  }
}
