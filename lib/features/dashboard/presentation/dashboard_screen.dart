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
              style: Theme.of(context).textTheme.displaySmall?.copyWith(fontSize: 22),
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

                if (tracker != null) ...[
                  StreakCard(
                    tracker: tracker,
                    onCheckIn: () => _checkIn(context),
                  ),
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

                const _QuickActions(),
                const SizedBox(height: 16),

                const _DailyTipCard(),
                const SizedBox(height: 16),

                const _AffirmationCard(),
                const SizedBox(height: 20),

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
          left: 24, right: 24, top: 24,
          bottom: MediaQuery.of(ctx).viewInsets.bottom + 24,
        ),
        child: StatefulBuilder(
          builder: (ctx, setS) => Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Log an Urge', style: Theme.of(ctx).textTheme.headlineMedium),
              const SizedBox(height: 20),
              Text('Intensity: $intensity/10', style: Theme.of(ctx).textTheme.labelLarge),
              Slider(
                value: intensity.toDouble(), min: 1, max: 10, divisions: 9,
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
                  _OutcomeChip(label: '💪 Resisted', selected: outcome == 'resisted',
                      color: AppColors.green400, bg: AppColors.green50,
                      onTap: () => setS(() => outcome = 'resisted')),
                  const SizedBox(width: 10),
                  _OutcomeChip(label: '🔄 Relapsed', selected: outcome == 'relapsed',
                      color: AppColors.coral400, bg: AppColors.coral50,
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
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.coral400),
            onPressed: () async {
              await ref.read(trackerNotifierProvider.notifier).logRelapse();
              if (ctx.mounted) {
                Navigator.pop(ctx);
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('You came back. That counts.')),
                  );
                }
              }
            },
            child: const Text('Log Relapse', style: TextStyle(color: Colors.white)),
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
              Text('$_greeting,', style: Theme.of(context).textTheme.bodyMedium),
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
            width: 44, height: 44,
            decoration: BoxDecoration(
              color: context.colTint(AppColors.teal50, AppColors.teal50Dk),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.notifications_outlined, color: AppColors.teal600),
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
          Text('How are you right now?', style: Theme.of(context).textTheme.headlineSmall),
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
              Text('Mood This Week', style: Theme.of(context).textTheme.labelLarge),
              TextButton(
                onPressed: () => GoRouter.of(context).push(AppConstants.routeReports),
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
      _Action('Journal',   Icons.book_outlined,           isDark ? AppColors.amber50Dk  : AppColors.amber50,  AppColors.amber600,  AppConstants.routeJournal),
      _Action('Tracker',   Icons.bar_chart,                isDark ? AppColors.teal50Dk   : AppColors.teal50,   AppColors.teal600,   AppConstants.routeTracker),
      _Action('Resources', Icons.library_books_outlined,   isDark ? AppColors.blue50Dk   : AppColors.blue50,   AppColors.blue600,   AppConstants.routeResources),
      _Action('Sessions',  Icons.person_outlined,          isDark ? AppColors.purple50Dk : AppColors.purple50, AppColors.purple600, AppConstants.routeSessions),
      _Action('Reports',   Icons.picture_as_pdf_outlined,  isDark ? AppColors.green50Dk  : AppColors.green50,  AppColors.green600,  AppConstants.routeReports),
      _Action('Crisis',    Icons.sos_outlined,             isDark ? AppColors.coral50Dk  : AppColors.coral50,  AppColors.coral600,  AppConstants.routeCrisis),
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
    ('✋', 'HALT Check', 'Before acting on any urge, ask: Am I Hungry, Angry, Lonely, or Tired? Address that need first.'),
    ('🌊', 'Urge Surfing', 'Urges peak in 15–20 minutes then pass. Ride it like a wave — you don\'t have to act on it.'),
    ('📞', 'Reach Out', 'Isolation fuels struggle. Send one text to a safe person today, even just to say hello.'),
    ('💧', 'Hydrate First', 'Dehydration mimics anxiety. Drink a glass of water before responding to any strong emotion.'),
    ('🚶', 'Move Your Body', '5 minutes of movement — a walk, stretching, even jumping jacks — shifts your emotional state.'),
    ('📖', 'Name It', '"I notice I feel anxious" creates space between you and the feeling. Name it to tame it.'),
    ('🛡️', 'Your Why', 'When it gets hard, return to your reason. Write it down and keep it somewhere visible.'),
    ('😮‍💨', 'Box Breathing', 'In for 4, hold 4, out for 4, hold 4. Do this three times when stress peaks.'),
    ('🌱', 'Small Wins', 'Recovery is built one small decision at a time. Each right choice, however small, is real progress.'),
    ('🌙', 'Sleep Matters', 'Fatigue is one of the biggest relapse triggers. Protecting your sleep protects your recovery.'),
    ('🤍', 'Self-Compassion', 'You would forgive a friend for struggling. You deserve the same kindness from yourself.'),
    ('🔄', 'Routine', 'Structure reduces decision fatigue. The fewer choices you have under stress, the better.'),
  ];

  @override
  Widget build(BuildContext context) {
    final (emoji, title, body) = _tips[DateTime.now().day % _tips.length];

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: context.colSurface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.teal200.withValues(alpha: context.isDark ? 0.3 : 1)),
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
                child: const Icon(Icons.tips_and_updates_outlined, size: 16, color: AppColors.teal600),
              ),
              const SizedBox(width: 8),
              const Text(
                'Daily Recovery Tip',
                style: TextStyle(fontSize: 12, color: AppColors.teal600, fontWeight: FontWeight.w600),
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
            style: TextStyle(color: Colors.white60, fontSize: 12, fontWeight: FontWeight.w500),
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
