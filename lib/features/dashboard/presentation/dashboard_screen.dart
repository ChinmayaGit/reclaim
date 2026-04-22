import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../core/providers/core_providers.dart';
import '../../../core/theme/app_colors.dart';
import '../../../shared/constants/app_constants.dart';
import '../../../shared/widgets/streak_card.dart';
import '../../../shared/widgets/mood_picker.dart';
import '../../../features/tracker/domain/tracker_notifier.dart';
import '../../../features/journal/domain/journal_notifier.dart';
import '../../../features/discipline/data/habit_model.dart';
import '../../../features/discipline/domain/discipline_notifier.dart';
import '../../../features/discipline/presentation/add_habit_sheet.dart';
import '../../../features/discipline/presentation/habit_icon_avatar.dart';
import '../../../shared/models/journal_model.dart';
import '../../../shared/models/tracker_model.dart';

class DashboardScreen extends ConsumerStatefulWidget {
  const DashboardScreen({super.key});

  @override
  ConsumerState<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends ConsumerState<DashboardScreen> {
  int _moodValue = 3;
  bool _moodSubmitted = false;

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(userProfileProvider).value;
    final tracker = ref.watch(trackerProvider).value;
    final moodHistory = ref.watch(moodHistoryProvider).value ?? [];
    final urgeLogs = ref.watch(urgeLogsProvider).value ?? [];

    return Scaffold(
      backgroundColor: context.colBackground,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            floating: true,
            backgroundColor: context.colSurface,
            title: Text(
              'Reclaim',
              style: Theme.of(context)
                  .textTheme
                  .displaySmall
                  ?.copyWith(fontSize: 22),
            ),
            actions: [
              IconButton(
                onPressed: () => context.push(AppConstants.routeSettings),
                icon: const Icon(Icons.settings_outlined),
              ),
              if (user?.isAdmin == true)
                IconButton(
                  onPressed: () => context.push(AppConstants.routeAdmin),
                  icon: const Icon(Icons.admin_panel_settings_outlined),
                ),
              const SizedBox(width: 8),
            ],
          ),
          SliverPadding(
            padding: const EdgeInsets.all(16),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                _GreetingCard(name: user?.displayName ?? 'Friend'),
                const SizedBox(height: 16),
                const _AffirmationCard(),
                const SizedBox(height: 20),
                if (tracker != null) ...[
                  StreakCard(
                    tracker: tracker,
                    onCheckIn: () => _checkIn(context),
                  ),
                  const SizedBox(height: 12),
                  _CheckInCalendar(checkInDates: tracker.checkInDates),
                  const SizedBox(height: 16),
                ],

                if (!_moodSubmitted && (tracker?.checkedInToday == false)) ...[
                  _MoodCheckinCard(
                    moodValue: _moodValue,
                    onMoodChanged: (v) => setState(() => _moodValue = v),
                    onSubmit: () => _submitMood(context),
                  ),
                  const SizedBox(height: 16),
                ],

                if (moodHistory.isNotEmpty) ...[
                  _MoodHistoryRow(history: moodHistory.take(7).toList()),
                  const SizedBox(height: 16),
                ],
                // ── Health & Habits ───────────────────────────────────────
                const _HealthHubSection(),
                const SizedBox(height: 16),
                const _DisciplineTrainingHub(),
                const SizedBox(height: 16),

                const _DailyTipCard(),
                const SizedBox(height: 16),

                // ── Recovery Tracking ────────────────────────────────────
                if (tracker != null && tracker.counters.isNotEmpty) ...[
                  _CountersSectionHome(tracker: tracker),
                  const SizedBox(height: 16),
                ],

                _UrgeLogSectionHome(
                  logs: urgeLogs,
                  onLog: () => _showUrgeDialog(context),
                ),
                const SizedBox(height: 16),
                const _QuickActions(),
                const SizedBox(height: 16),
                _RelapseSectionHome(
                  onRelapse: () => _confirmRelapse(context),
                ),
                const SizedBox(height: 80),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _checkIn(BuildContext context) async {
    final messenger = ScaffoldMessenger.of(context);
    await ref.read(trackerNotifierProvider.notifier).checkIn();
    if (!mounted) return;
    messenger.showSnackBar(
      const SnackBar(content: Text('✓ Checked in! Keep going.')),
    );
  }

  void _showUrgeDialog(BuildContext context) {
    int intensity = 5;
    final triggerCtrl = TextEditingController();
    String outcome = 'resisted';
    final notifier = ref.read(trackerNotifierProvider.notifier);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(
          left: 24,
          right: 24,
          top: 24,
          bottom: MediaQuery.of(ctx).viewInsets.bottom + 24,
        ),
        child: StatefulBuilder(
          builder: (ctx, setS) => Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Log an Urge',
                  style: Theme.of(ctx).textTheme.headlineMedium),
              const SizedBox(height: 20),
              Text('Intensity: $intensity/10',
                  style: Theme.of(ctx).textTheme.labelLarge),
              Slider(
                value: intensity.toDouble(),
                min: 1,
                max: 10,
                divisions: 9,
                onChanged: (v) => setS(() => intensity = v.toInt()),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: triggerCtrl,
                decoration: const InputDecoration(
                  labelText: 'What triggered it?',
                  hintText: 'e.g. stress, boredom, social situation…',
                ),
              ),
              const SizedBox(height: 14),
              Text('Outcome', style: Theme.of(ctx).textTheme.labelLarge),
              const SizedBox(height: 8),
              Row(
                children: [
                  _OutcomeChip(
                      label: '💪 Resisted',
                      selected: outcome == 'resisted',
                      color: AppColors.green400,
                      bg: AppColors.green50,
                      onTap: () => setS(() => outcome = 'resisted')),
                  const SizedBox(width: 10),
                  _OutcomeChip(
                      label: '🔄 Relapsed',
                      selected: outcome == 'relapsed',
                      color: AppColors.coral400,
                      bg: AppColors.coral50,
                      onTap: () => setS(() => outcome = 'relapsed')),
                ],
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () async {
                    await notifier.logUrge(UrgeLog(
                      intensity: intensity,
                      trigger: triggerCtrl.text.trim(),
                      outcome: outcome,
                      loggedAt: DateTime.now(),
                    ));
                    if (ctx.mounted) Navigator.pop(ctx);
                  },
                  child: const Text('Save'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _confirmRelapse(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Log a Relapse'),
        content: const Text(
          "It's okay. This is part of recovery. Logging it honestly is a courageous step.\n\nThis will reset your streak counter.",
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
            style:
                ElevatedButton.styleFrom(backgroundColor: AppColors.coral400),
            onPressed: () async {
              await ref.read(trackerNotifierProvider.notifier).logRelapse();
              if (ctx.mounted) {
                Navigator.pop(ctx);
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                        content: Text('You came back. That counts.')),
                  );
                }
              }
            },
            child: const Text('Log Relapse',
                style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  Future<void> _submitMood(BuildContext context) async {
    final uid = ref.read(currentUserProvider)?.uid;
    if (uid == null) return;
    final messenger = ScaffoldMessenger.of(context);
    await ref.read(journalNotifierProvider.notifier).saveMoodCheckin(
          MoodCheckin(
            userId: uid,
            moodScore: _moodValue,
            checkinDate: DateTime.now(),
          ),
        );
    if (!mounted) return;
    setState(() => _moodSubmitted = true);
    messenger.showSnackBar(
      const SnackBar(
        content: Text('Mood saved. Keep checking in daily.'),
        backgroundColor: AppColors.teal600,
      ),
    );
  }
}

// ─── Greeting ─────────────────────────────────────────────────────────────────

class _GreetingCard extends StatelessWidget {
  const _GreetingCard({required this.name});
  final String name;

  String get _greeting {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good morning';
    if (hour < 17) return 'Good afternoon';
    return 'Good evening';
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('$_greeting,',
                  style: Theme.of(context).textTheme.bodyMedium),
              Text(
                name.split(' ').first,
                style: Theme.of(context).textTheme.displaySmall,
              ),
            ],
          ),
        ),
        GestureDetector(
          onTap: () => context.push(AppConstants.routeSettings),
          child: Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: context.colTint(AppColors.teal50, AppColors.teal50Dk),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.notifications_outlined,
                color: AppColors.teal600),
          ),
        ),
      ],
    );
  }
}

// ─── Mood check-in ────────────────────────────────────────────────────────────

class _MoodCheckinCard extends StatelessWidget {
  const _MoodCheckinCard({
    required this.moodValue,
    required this.onMoodChanged,
    required this.onSubmit,
  });
  final int moodValue;
  final ValueChanged<int> onMoodChanged;
  final VoidCallback onSubmit;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: context.colSurface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: context.colBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('How are you right now?',
              style: Theme.of(context).textTheme.headlineSmall),
          const SizedBox(height: 4),
          Text(
            'Honest check-ins help you spot patterns over time.',
            style: TextStyle(fontSize: 12, color: context.colTextSec),
          ),
          const SizedBox(height: 16),
          MoodPicker(initialValue: moodValue, onChanged: onMoodChanged),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: onSubmit,
              child: const Text('Save Check-in'),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Mood history ─────────────────────────────────────────────────────────────

class _MoodHistoryRow extends StatelessWidget {
  const _MoodHistoryRow({required this.history});
  final List<MoodCheckin> history;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: context.colSurface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: context.colBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Mood This Week',
                  style: Theme.of(context).textTheme.labelLarge),
              TextButton(
                onPressed: () => GoRouter.of(context).push(
                  '${AppConstants.routeDayRecap}?date=${AppConstants.dateKey(DateTime.now())}',
                ),
                child: const Text('View All'),
              ),
            ],
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 54,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: history.reversed.map((m) {
                return Column(
                  children: [
                    Text(
                      AppConstants.moodEmojis[m.moodScore - 1],
                      style: const TextStyle(fontSize: 22),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _dayLabel(m.checkinDate),
                      style: TextStyle(fontSize: 9, color: context.colTextHint),
                    ),
                  ],
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  String _dayLabel(DateTime d) {
    const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    return days[d.weekday - 1];
  }
}

// ─── Quick actions ────────────────────────────────────────────────────────────

class _QuickActions extends StatelessWidget {
  const _QuickActions();

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDark;

    final actions = [
      _Action(
          'Journal',
          Icons.book_outlined,
          isDark ? AppColors.amber50Dk : AppColors.amber50,
          AppColors.amber600,
          AppConstants.routeJournal),
      _Action(
          'Tracker',
          Icons.bar_chart,
          isDark ? AppColors.teal50Dk : AppColors.teal50,
          AppColors.teal600,
          AppConstants.routeTracker),
      _Action(
          'Resources',
          Icons.library_books_outlined,
          isDark ? AppColors.blue50Dk : AppColors.blue50,
          AppColors.blue600,
          AppConstants.routeResources),
      _Action(
          'Discipline',
          Icons.checklist_outlined,
          isDark ? AppColors.green50Dk : AppColors.green50,
          AppColors.green600,
          AppConstants.routeDiscipline),
      _Action(
          'Your day',
          Icons.calendar_view_day_outlined,
          isDark ? AppColors.purple50Dk : AppColors.purple50,
          AppColors.purple600,
          '${AppConstants.routeDayRecap}?date=${AppConstants.dateKey(DateTime.now())}'),
      _Action(
          'Crisis',
          Icons.sos_outlined,
          isDark ? AppColors.coral50Dk : AppColors.coral50,
          AppColors.coral600,
          AppConstants.routeCrisis),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Quick Actions', style: Theme.of(context).textTheme.labelLarge),
        const SizedBox(height: 12),
        GridView.count(
          crossAxisCount: 3,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          mainAxisSpacing: 10,
          crossAxisSpacing: 10,
          children: actions.map((a) => _ActionTile(action: a)).toList(),
        ),
      ],
    );
  }
}

class _Action {
  const _Action(this.label, this.icon, this.bg, this.fg, this.route);
  final String label, route;
  final IconData icon;
  final Color bg, fg;
}

class _ActionTile extends StatelessWidget {
  const _ActionTile({required this.action});
  final _Action action;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => context.push(action.route),
      child: Container(
        decoration: BoxDecoration(
          color: action.bg,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: action.fg.withValues(alpha: 0.3)),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(action.icon, color: action.fg, size: 22),
            const SizedBox(height: 6),
            Text(
              action.label,
              style: TextStyle(
                fontSize: 11,
                color: action.fg,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Daily tip ────────────────────────────────────────────────────────────────

class _DailyTipCard extends StatelessWidget {
  const _DailyTipCard();

  static const _tips = [
    (
      '✋',
      'HALT Check',
      'Before acting on any urge, ask: Am I Hungry, Angry, Lonely, or Tired? Address that need first.'
    ),
    (
      '🌊',
      'Urge Surfing',
      'Urges peak in 15–20 minutes then pass. Ride it like a wave — you don\'t have to act on it.'
    ),
    (
      '📞',
      'Reach Out',
      'Isolation fuels struggle. Send one text to a safe person today, even just to say hello.'
    ),
    (
      '💧',
      'Hydrate First',
      'Dehydration mimics anxiety. Drink a glass of water before responding to any strong emotion.'
    ),
    (
      '🚶',
      'Move Your Body',
      '5 minutes of movement — a walk, stretching, even jumping jacks — shifts your emotional state.'
    ),
    (
      '📖',
      'Name It',
      '"I notice I feel anxious" creates space between you and the feeling. Name it to tame it.'
    ),
    (
      '🛡️',
      'Your Why',
      'When it gets hard, return to your reason. Write it down and keep it somewhere visible.'
    ),
    (
      '😮‍💨',
      'Box Breathing',
      'In for 4, hold 4, out for 4, hold 4. Do this three times when stress peaks.'
    ),
    (
      '🌱',
      'Small Wins',
      'Recovery is built one small decision at a time. Each right choice, however small, is real progress.'
    ),
    (
      '🌙',
      'Sleep Matters',
      'Fatigue is one of the biggest relapse triggers. Protecting your sleep protects your recovery.'
    ),
    (
      '🤍',
      'Self-Compassion',
      'You would forgive a friend for struggling. You deserve the same kindness from yourself.'
    ),
    (
      '🔄',
      'Routine',
      'Structure reduces decision fatigue. The fewer choices you have under stress, the better.'
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final (emoji, title, body) = _tips[DateTime.now().day % _tips.length];

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: context.colSurface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
            color:
                AppColors.teal200.withValues(alpha: context.isDark ? 0.3 : 1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: context.colTint(AppColors.teal50, AppColors.teal50Dk),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.tips_and_updates_outlined,
                    size: 16, color: AppColors.teal600),
              ),
              const SizedBox(width: 8),
              const Text(
                'Daily Recovery Tip',
                style: TextStyle(
                    fontSize: 12,
                    color: AppColors.teal600,
                    fontWeight: FontWeight.w600),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(emoji, style: const TextStyle(fontSize: 24)),
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
                      body,
                      style: TextStyle(
                        fontSize: 13,
                        color: context.colTextSec,
                        height: 1.5,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ─── Outcome chip (urge dialog) ───────────────────────────────────────────────

class _OutcomeChip extends StatelessWidget {
  const _OutcomeChip({
    required this.label,
    required this.selected,
    required this.color,
    required this.bg,
    required this.onTap,
  });
  final String label;
  final bool selected;
  final Color color, bg;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: selected
              ? bg
              : context.colTint(AppColors.slate50, AppColors.slate50Dk),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
              color: selected ? color : context.colBorder,
              width: selected ? 2 : 1),
        ),
        child: Text(label,
            style: TextStyle(
                color: selected ? color : context.colTextSec,
                fontWeight: FontWeight.w600)),
      ),
    );
  }
}

// ─── Recovery counters (home) ─────────────────────────────────────────────────

class _CountersSectionHome extends StatelessWidget {
  const _CountersSectionHome({required this.tracker});
  final TrackerModel tracker;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: context.colSurface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: context.colBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Recovery Counters',
                  style: Theme.of(context).textTheme.headlineSmall),
              TextButton(
                onPressed: () => GoRouter.of(context)
                    .push('${AppConstants.routeTracker}/milestones'),
                child: const Text('Milestones'),
              ),
            ],
          ),
          const SizedBox(height: 10),
          ...tracker.counters.map((c) => Container(
                margin: const EdgeInsets.only(bottom: 8),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: context.colTint(AppColors.teal50, AppColors.teal50Dk),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                      color: context.colTint(
                          AppColors.teal100, AppColors.teal50Dk)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.emoji_events_outlined,
                        color: AppColors.teal600),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(c.label,
                              style:
                                  const TextStyle(fontWeight: FontWeight.w600)),
                          Text(
                            'Since ${DateFormat('MMM d, yyyy').format(c.startDate)}',
                            style: TextStyle(
                                fontSize: 12, color: context.colTextSec),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: AppColors.teal400,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        '${c.daysSince}d',
                        style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                            fontSize: 13),
                      ),
                    ),
                  ],
                ),
              )),
        ],
      ),
    );
  }
}

// ─── Urge log section (home) ──────────────────────────────────────────────────

class _UrgeLogSectionHome extends StatelessWidget {
  const _UrgeLogSectionHome({required this.logs, required this.onLog});
  final List<UrgeLog> logs;
  final VoidCallback onLog;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: context.colSurface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: context.colBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Urge Log',
                  style: Theme.of(context).textTheme.headlineSmall),
              TextButton.icon(
                onPressed: onLog,
                icon: const Icon(Icons.add, size: 16),
                label: const Text('Log Urge'),
              ),
            ],
          ),
          if (logs.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 10),
              child: Text('No urges logged yet.',
                  style: TextStyle(color: context.colTextSec)),
            )
          else
            ...logs.take(3).map((log) {
              final isResisted = log.outcome == 'resisted';
              return Container(
                margin: const EdgeInsets.only(top: 8),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: isResisted
                      ? context.colTint(AppColors.green50, AppColors.green50Dk)
                      : context.colTint(AppColors.coral50, AppColors.coral50Dk),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Text(isResisted ? '💪' : '🔄',
                        style: const TextStyle(fontSize: 18)),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            log.trigger.isEmpty ? 'Urge logged' : log.trigger,
                            style: const TextStyle(
                                fontWeight: FontWeight.w500, fontSize: 13),
                          ),
                          Text('Intensity: ${log.intensity}/10',
                              style: TextStyle(
                                  fontSize: 11, color: context.colTextSec)),
                        ],
                      ),
                    ),
                    Text(
                      DateFormat('MMM d').format(log.loggedAt),
                      style:
                          TextStyle(fontSize: 11, color: context.colTextHint),
                    ),
                  ],
                ),
              );
            }),
        ],
      ),
    );
  }
}

// ─── Relapse section (home) ───────────────────────────────────────────────────

class _RelapseSectionHome extends StatelessWidget {
  const _RelapseSectionHome({required this.onRelapse});
  final VoidCallback onRelapse;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: context.colTint(AppColors.coral50, AppColors.coral50Dk),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
            color: context.colTint(AppColors.coral100, AppColors.coral50Dk)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Had a relapse?',
              style: TextStyle(
                  fontWeight: FontWeight.w600, color: AppColors.coral600)),
          const SizedBox(height: 4),
          Text(
            "It's part of recovery. Logging it honestly is strength.",
            style: TextStyle(fontSize: 12, color: context.colTextSec),
          ),
          const SizedBox(height: 12),
          OutlinedButton(
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.coral600,
              side: const BorderSide(color: AppColors.coral400),
            ),
            onPressed: onRelapse,
            child: const Text('Log a Relapse'),
          ),
        ],
      ),
    );
  }
}

// ─── Check-in Calendar ────────────────────────────────────────────────────────

class _CheckInCalendar extends ConsumerStatefulWidget {
  const _CheckInCalendar({required this.checkInDates});
  final List<String> checkInDates;

  @override
  ConsumerState<_CheckInCalendar> createState() => _CheckInCalendarState();
}

class _CheckInCalendarState extends ConsumerState<_CheckInCalendar> {
  late DateTime _viewing;
  late Set<String> _dates;

  @override
  void initState() {
    super.initState();
    _viewing = DateTime.now();
    _dates = widget.checkInDates.toSet();
  }

  @override
  void didUpdateWidget(_CheckInCalendar old) {
    super.didUpdateWidget(old);
    _dates = widget.checkInDates.toSet();
  }

  void _prevMonth() {
    setState(() {
      _viewing = DateTime(_viewing.year, _viewing.month - 1);
    });
  }

  void _nextMonth() {
    final now = DateTime.now();
    final next = DateTime(_viewing.year, _viewing.month + 1);
    if (next.isBefore(DateTime(now.year, now.month + 1))) {
      setState(() => _viewing = next);
    }
  }

  String _fmt(DateTime d) =>
      '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

  void _openDayDetail(String dateStr) {
    if (!mounted) return;
    context.push('${AppConstants.routeDayRecap}?date=$dateStr');
  }

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final first = DateTime(_viewing.year, _viewing.month, 1);
    final daysInMonth = DateTime(_viewing.year, _viewing.month + 1, 0).day;
    final startWeekday = first.weekday % 7; // 0=Sun

    final monthLabel = DateFormat('MMMM yyyy').format(first);
    final canGoNext = DateTime(_viewing.year, _viewing.month + 1)
        .isBefore(DateTime(now.year, now.month + 1));

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: context.colSurface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: context.colBorder),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                onPressed: _prevMonth,
                icon: const Icon(Icons.chevron_left, size: 20),
                visualDensity: VisualDensity.compact,
              ),
              Text(
                monthLabel,
                style: Theme.of(context).textTheme.labelLarge,
              ),
              IconButton(
                onPressed: canGoNext ? _nextMonth : null,
                icon: const Icon(Icons.chevron_right, size: 20),
                visualDensity: VisualDensity.compact,
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: const ['S', 'M', 'T', 'W', 'T', 'F', 'S']
                .map((d) => SizedBox(
                      width: 36,
                      child: Text(
                        d,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: context.colTextHint,
                        ),
                      ),
                    ))
                .toList(),
          ),
          const SizedBox(height: 6),
          ...List.generate(
            ((startWeekday + daysInMonth + 6) / 7).ceil(),
            (week) {
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 2),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: List.generate(7, (col) {
                    final dayNum = week * 7 + col - startWeekday + 1;
                    if (dayNum < 1 || dayNum > daysInMonth) {
                      return const SizedBox(width: 36, height: 36);
                    }

                    final date =
                        DateTime(_viewing.year, _viewing.month, dayNum);
                    final dateStr = _fmt(date);
                    final isChecked = _dates.contains(dateStr);
                    final isToday = date == today;
                    final isPast = date.isBefore(today);
                    final isMissed = isPast && !isChecked;

                    Color bg;
                    Color fg;
                    if (isChecked) {
                      bg = AppColors.teal400;
                      fg = Colors.white;
                    } else if (isToday) {
                      bg = context.isDark
                          ? Colors.white.withValues(alpha: 0.1)
                          : Colors.black.withValues(alpha: 0.06);
                      fg = context.colText;
                    } else if (isMissed) {
                      bg = context.isDark
                          ? AppColors.coral400.withValues(alpha: 0.15)
                          : AppColors.coral50;
                      fg = context.isDark
                          ? AppColors.coral400.withValues(alpha: 0.6)
                          : AppColors.coral400.withValues(alpha: 0.5);
                    } else {
                      bg = Colors.transparent;
                      fg = context.colTextSec;
                    }

                    return SizedBox(
                      width: 36,
                      height: 36,
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          customBorder: const CircleBorder(),
                          onTap: () => _openDayDetail(dateStr),
                          child: Container(
                            decoration: BoxDecoration(
                              color: bg,
                              shape: BoxShape.circle,
                              border: isToday && !isChecked
                                  ? Border.all(
                                      color: AppColors.teal400, width: 1.5)
                                  : null,
                            ),
                            alignment: Alignment.center,
                            child: Text(
                              '$dayNum',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: isChecked || isToday
                                    ? FontWeight.w700
                                    : FontWeight.w400,
                                color: fg,
                              ),
                            ),
                          ),
                        ),
                      ),
                    );
                  }),
                ),
              );
            },
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _CalLegend(color: AppColors.teal400, label: 'Checked in'),
              const SizedBox(width: 16),
              _CalLegend(
                color: context.isDark
                    ? AppColors.coral400.withValues(alpha: 0.4)
                    : AppColors.coral100,
                label: 'Missed',
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _CalLegend extends StatelessWidget {
  const _CalLegend({required this.color, required this.label});
  final Color color;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 4),
        Text(label, style: TextStyle(fontSize: 10, color: context.colTextHint)),
      ],
    );
  }
}

// ─── Affirmation ──────────────────────────────────────────────────────────────

class _AffirmationCard extends StatelessWidget {
  const _AffirmationCard();

  static const _affirmations = [
    'You came back. That counts.',
    'One moment at a time.',
    "It's okay to feel this.",
    "Day by day. You're doing it.",
    'Small steps are still steps forward.',
    'You are stronger than your struggle.',
    'Progress, not perfection.',
  ];

  @override
  Widget build(BuildContext context) {
    final today = DateTime.now().day % _affirmations.length;
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF2A2260), AppColors.purple400],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Today's Affirmation",
            style: TextStyle(
                color: Colors.white60,
                fontSize: 12,
                fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 10),
          Text(
            '"${_affirmations[today]}"',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontStyle: FontStyle.italic,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Health Hub Section ────────────────────────────────────────────────────────

class _HealthHubSection extends ConsumerWidget {
  const _HealthHubSection();

  static const double _cardWidth = 132;
  static const double _addSlotWidth = 76;
  static const double _rowHeight = 122;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final discipline = ref.watch(disciplineProvider);
    final habits = discipline.habits;

    void addHabit() => showAddHabitSheet(context, ref);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Health & Habits', style: Theme.of(context).textTheme.labelLarge),
        const SizedBox(height: 12),
        SizedBox(
          height: _rowHeight,
          child: ListView(
            scrollDirection: Axis.horizontal,
            clipBehavior: Clip.none,
            children: [
              for (var i = 0; i < habits.length; i++) ...[
                if (i > 0) const SizedBox(width: 10),
                SizedBox(
                  width: _cardWidth,
                  height: _rowHeight,
                  child: _HealthHabitTile(habit: habits[i]),
                ),
              ],
              SizedBox(width: habits.isEmpty ? 0 : 10),
              SizedBox(
                width: _addSlotWidth,
                height: _rowHeight,
                child: _HealthAddHabitSlot(onTap: addHabit),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

/// One habit in the Health & Habits row — tap body for details, check to toggle.
class _HealthHabitTile extends ConsumerWidget {
  const _HealthHabitTile({required this.habit});

  final HabitItem habit;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final disc = ref.watch(disciplineProvider);
    final count = disc.countFor(habit.id);
    final goal = habit.dailyGoal.clamp(1, 999);
    final satisfied = disc.isHabitSatisfied(habit);
    final color = Color(habit.colorValue);
    final progress = goal > 0 ? (count / goal).clamp(0.0, 1.0) : 0.0;

    return Material(
      color: context.colSurface,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        height: _HealthHubSection._rowHeight,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color:
                satisfied ? color.withValues(alpha: 0.55) : context.colBorder,
            width: satisfied ? 1.5 : 1,
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: InkWell(
                borderRadius: const BorderRadius.horizontal(
                  left: Radius.circular(13),
                  right: Radius.circular(4),
                ),
                onTap: () => context.push(
                  '${AppConstants.routeHabitDetail}?id=${habit.id}',
                ),
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(10, 10, 4, 8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.max,
                    children: [
                      Row(
                        children: [
                          HabitIconAvatar(
                            habit: habit,
                            size: 28,
                            done: satisfied,
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Expanded(
                        child: Align(
                          alignment: Alignment.topLeft,
                          child: Text(
                            habit.name,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              height: 1.2,
                              color: context.colText,
                            ),
                          ),
                        ),
                      ),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(3),
                        child: LinearProgressIndicator(
                          value: progress,
                          minHeight: 3,
                          backgroundColor: color.withValues(alpha: 0.12),
                          valueColor:
                              AlwaysStoppedAnimation<Color>(color),
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        goal > 1
                            ? '$count/$goal · ${habit.pointsWeight} pt max'
                            : (satisfied
                                ? 'Done · ${habit.pointsWeight} pt'
                                : '${habit.pointsWeight} pt · details'),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 9,
                          color: context.colTextHint,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () => ref
                    .read(disciplineProvider.notifier)
                    .tapHabit(habit.id),
                onLongPress: () => ref
                    .read(disciplineProvider.notifier)
                    .decrementHabit(habit.id),
                borderRadius: const BorderRadius.horizontal(
                  right: Radius.circular(13),
                ),
                child: SizedBox(
                  width: 40,
                  child: Tooltip(
                    message: satisfied
                        ? (goal > 1
                            ? 'Tap +1 · long-press undo'
                            : 'Tap to undo')
                        : (goal > 1 ? 'Tap to log' : 'Mark done'),
                    child: Icon(
                      satisfied
                          ? Icons.check_circle
                          : Icons.circle_outlined,
                      size: 22,
                      color: satisfied ? color : context.colTextHint,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Trailing control in the Health & Habits row — scrolls right with the cards.
class _HealthAddHabitSlot extends StatelessWidget {
  const _HealthAddHabitSlot({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: context.colSurface,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          height: _HealthHubSection._rowHeight,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: AppColors.teal600.withValues(alpha: 0.45),
              width: 1.5,
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.add, size: 30, color: AppColors.teal600),
              const SizedBox(height: 6),
              Text(
                'Add',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: context.colTextSec,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Discipline & training (gym / habits / focus) ─────────────────────────────

class _DisciplineTrainingHub extends StatelessWidget {
  const _DisciplineTrainingHub();

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Discipline & training',
          style: Theme.of(context).textTheme.labelLarge,
        ),
        const SizedBox(height: 4),
        Text(
          'Choose a tracker — gym session log, daily habit checklist, or focus tools.',
          style: TextStyle(fontSize: 12, color: context.colTextSec, height: 1.35),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 118,
          child: ListView(
            scrollDirection: Axis.horizontal,
            clipBehavior: Clip.none,
            children: [
              _DisciplineTrackCard(
                title: 'Gym log',
                subtitle: 'Sets · reps · volume',
                icon: Icons.fitness_center,
                accent: AppColors.amber600,
                bg: isDark ? const Color(0xFF2A2318) : AppColors.amber50,
                onTap: () => context.push(AppConstants.routeWorkoutLog),
              ),
              _DisciplineTrackCard(
                title: 'Daily habits',
                subtitle: 'Checklist & streak',
                icon: Icons.checklist_outlined,
                accent: AppColors.green600,
                bg: isDark ? const Color(0xFF182418) : AppColors.green50,
                onTap: () => context.push(AppConstants.routeDiscipline),
              ),
              _DisciplineTrackCard(
                title: 'Focus & block',
                subtitle: 'Pomodoro · schedule',
                icon: Icons.timer_outlined,
                accent: AppColors.teal600,
                bg: isDark ? const Color(0xFF18262A) : AppColors.teal50,
                onTap: () => context.push(AppConstants.routeFocus),
              ),
              _DisciplineTrackCard(
                title: 'Guides',
                subtitle: 'Gym · habits · discipline',
                icon: Icons.library_books_outlined,
                accent: AppColors.blue600,
                bg: isDark ? const Color(0xFF1A2230) : AppColors.blue50,
                onTap: () => context.push(AppConstants.routeResources),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _DisciplineTrackCard extends StatelessWidget {
  const _DisciplineTrackCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.accent,
    required this.bg,
    required this.onTap,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final Color accent;
  final Color bg;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 12),
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          width: 152,
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: bg,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: accent.withValues(alpha: 0.35)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(icon, color: accent, size: 22),
              const Spacer(),
              Text(
                title,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                  color: context.colText,
                ),
              ),
              Text(
                subtitle,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 11,
                  height: 1.25,
                  color: context.colTextSec,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

