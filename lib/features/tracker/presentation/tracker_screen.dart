import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../domain/tracker_notifier.dart';
import '../../../core/theme/app_colors.dart';
import '../../../shared/constants/app_constants.dart';
import '../../../shared/models/tracker_model.dart';
import '../../../shared/widgets/streak_card.dart';

class TrackerScreen extends ConsumerWidget {
  const TrackerScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tracker = ref.watch(trackerProvider);
    final urgeLogs = ref.watch(urgeLogsProvider).value ?? [];

    return Scaffold(
      backgroundColor: context.colBackground,
      appBar: AppBar(
        title: const Text('Recovery Tracker'),
        actions: [
          TextButton.icon(
            onPressed: () => context.push('${AppConstants.routeTracker}/milestones'),
            icon: const Icon(Icons.emoji_events_outlined, size: 18),
            label: const Text('Milestones'),
          ),
        ],
      ),
      body: tracker.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (data) {
          if (data == null) {
            return const Center(child: Text('No tracker data yet.'));
          }
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              StreakCard(
                tracker: data,
                onCheckIn: () => _checkIn(context, ref),
              ),
              const SizedBox(height: 16),
              _CountersSection(tracker: data),
              const SizedBox(height: 16),
              _UrgeLogSection(logs: urgeLogs, onLog: () => _showUrgeDialog(context, ref)),
              const SizedBox(height: 16),
              _RelapseSection(onRelapse: () => _confirmRelapse(context, ref)),
              const SizedBox(height: 80),
            ],
          );
        },
      ),
    );
  }

  Future<void> _checkIn(BuildContext context, WidgetRef ref) async {
    await ref.read(trackerNotifierProvider.notifier).checkIn();
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('✓ Checked in! Keep going.')),
      );
    }
  }

  void _showUrgeDialog(BuildContext context, WidgetRef ref) {
    int intensity = 5;
    final triggerCtrl = TextEditingController();
    String outcome = 'resisted';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
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
                value: intensity.toDouble(),
                min: 1, max: 10, divisions: 9,
                onChanged: (v) => setS(() => intensity = v.toInt()),
              ),
              const SizedBox(height: 14),
              TextField(
                controller: triggerCtrl,
                decoration: const InputDecoration(
                  labelText: 'What triggered it?',
                  hintText: 'e.g. stress at work, social situation…',
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
                    onTap: () => setS(() => outcome = 'resisted'),
                  ),
                  const SizedBox(width: 10),
                  _OutcomeChip(
                    label: '🔄 Relapsed',
                    selected: outcome == 'relapsed',
                    color: AppColors.coral400,
                    bg: AppColors.coral50,
                    onTap: () => setS(() => outcome = 'relapsed'),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () async {
                    await ref.read(trackerNotifierProvider.notifier).logUrge(
                      UrgeLog(
                        intensity: intensity,
                        trigger: triggerCtrl.text.trim(),
                        outcome: outcome,
                        loggedAt: DateTime.now(),
                      ),
                    );
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

  void _confirmRelapse(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Log a Relapse'),
        content: const Text(
          'It\'s okay. This is part of recovery. Logging it honestly is a courageous step.\n\nThis will reset your streak counter.',
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.coral400),
            onPressed: () async {
              await ref.read(trackerNotifierProvider.notifier).logRelapse();
              if (ctx.mounted) {
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('You came back. That counts.')),
                );
              }
            },
            child: const Text('Log Relapse'),
          ),
        ],
      ),
    );
  }
}

class _OutcomeChip extends StatelessWidget {
  const _OutcomeChip({required this.label, required this.selected, required this.color, required this.bg, required this.onTap});
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
          color: selected ? bg : context.colTint(AppColors.slate50, AppColors.slate50Dk),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: selected ? color : context.colBorder, width: selected ? 2 : 1),
        ),
        child: Text(label, style: TextStyle(color: selected ? color : context.colTextSec, fontWeight: FontWeight.w600)),
      ),
    );
  }
}

class _CountersSection extends StatelessWidget {
  const _CountersSection({required this.tracker});
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
          Text('Recovery Counters', style: Theme.of(context).textTheme.headlineSmall),
          const SizedBox(height: 14),
          ...tracker.counters.map((c) => _CounterRow(counter: c)),
        ],
      ),
    );
  }
}

class _CounterRow extends StatelessWidget {
  const _CounterRow({required this.counter});
  final RecoveryCounter counter;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: context.colTint(AppColors.teal50, AppColors.teal50Dk),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: context.colTint(AppColors.teal100, AppColors.teal50Dk)),
      ),
      child: Row(
        children: [
          const Icon(Icons.emoji_events_outlined, color: AppColors.teal600),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(counter.label, style: const TextStyle(fontWeight: FontWeight.w600)),
                Text(
                  'Since ${DateFormat('MMM d, yyyy').format(counter.startDate)}',
                  style: TextStyle(fontSize: 12, color: context.colTextSec),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: AppColors.teal400,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              '${counter.daysSince}d',
              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 13),
            ),
          ),
        ],
      ),
    );
  }
}

class _UrgeLogSection extends StatelessWidget {
  const _UrgeLogSection({required this.logs, required this.onLog});
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
              Text('Urge Log', style: Theme.of(context).textTheme.headlineSmall),
              TextButton.icon(
                onPressed: onLog,
                icon: const Icon(Icons.add, size: 16),
                label: const Text('Log Urge'),
              ),
            ],
          ),
          if (logs.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: Text('No urges logged yet.', style: Theme.of(context).textTheme.bodyMedium),
            )
          else
            ...logs.take(5).map((log) => _UrgeRow(log: log)),
        ],
      ),
    );
  }
}

class _UrgeRow extends StatelessWidget {
  const _UrgeRow({required this.log});
  final UrgeLog log;

  @override
  Widget build(BuildContext context) {
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
          Text(isResisted ? '💪' : '🔄', style: const TextStyle(fontSize: 18)),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(log.trigger.isEmpty ? 'Urge logged' : log.trigger,
                    style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 13)),
                Text('Intensity: ${log.intensity}/10',
                    style: TextStyle(fontSize: 11, color: context.colTextSec)),
              ],
            ),
          ),
          Text(
            DateFormat('MMM d').format(log.loggedAt),
            style: TextStyle(fontSize: 11, color: context.colTextHint),
          ),
        ],
      ),
    );
  }
}

class _RelapseSection extends StatelessWidget {
  const _RelapseSection({required this.onRelapse});
  final VoidCallback onRelapse;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: context.colTint(AppColors.coral50, AppColors.coral50Dk),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: context.colTint(AppColors.coral100, AppColors.coral50Dk)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Had a relapse?', style: TextStyle(fontWeight: FontWeight.w600, color: AppColors.coral600)),
          const SizedBox(height: 4),
          Text(
            "It's part of recovery. Logging it honestly is strength, not failure.",
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
