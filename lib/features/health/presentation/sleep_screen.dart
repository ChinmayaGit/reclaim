import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/app_colors.dart';
import '../domain/sleep_notifier.dart';
import '../data/sleep_model.dart';

class SleepScreen extends ConsumerWidget {
  const SleepScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(sleepProvider);
    final notifier = ref.read(sleepProvider.notifier);

    return Scaffold(
      backgroundColor: context.colBackground,
      appBar: AppBar(
        backgroundColor: context.colSurface,
        title: const Text('Sleep Tracker'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            onPressed: () => _showSettings(context, state, notifier),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: AppColors.purple600,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.bedtime_outlined),
        label: const Text('Log Sleep'),
        onPressed: () => _logSleep(context, notifier),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          // ── Last night card ────────────────────────────────────────────────
          _LastNightCard(state: state),
          const SizedBox(height: 20),

          // ── 7-day history ──────────────────────────────────────────────────
          if (state.last7.isNotEmpty) ...[
            Text('Last 7 Days',
                style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: context.colText,
                    fontSize: 14)),
            const SizedBox(height: 12),
            _SleepBarChart(entries: state.last7, goalHours: state.goalHours),
            const SizedBox(height: 20),

            // Log list
            Text('Sleep Log',
                style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: context.colText,
                    fontSize: 14)),
            const SizedBox(height: 10),
            ...state.entries.reversed.take(7).toList().asMap().entries.map(
                  (e) => _SleepRow(
                    entry: e.value,
                    onDelete: () =>
                        notifier.deleteEntry(state.entries.length - 1 - e.key),
                  ),
                ),
            const SizedBox(height: 20),
          ],

          // ── Reminder card ──────────────────────────────────────────────────
          _BedtimeReminder(state: state, notifier: notifier),
          const SizedBox(height: 80),
        ],
      ),
    );
  }

  void _logSleep(BuildContext context, SleepNotifier notifier) async {
    final now = DateTime.now();
    DateTime bedtime = now.subtract(const Duration(hours: 8));
    DateTime wakeTime = now;

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) => _LogSleepSheet(
        initialBedtime: bedtime,
        initialWakeTime: wakeTime,
        onSave: (b, w) {
          Navigator.pop(ctx);
          notifier.logSleep(bedtime: b, wakeTime: w);
        },
      ),
    );
  }

  void _showSettings(
      BuildContext context, SleepState state, SleepNotifier notifier) {
    double goal = state.goalHours;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) => Padding(
        padding: EdgeInsets.fromLTRB(
            24, 20, 24, MediaQuery.of(ctx).padding.bottom + 24),
        child: StatefulBuilder(builder: (ctx, setSt) {
          return Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 20),
                  decoration: BoxDecoration(
                      color: Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(2))),
              Text('Sleep Goal',
                  style: TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 18,
                      color: context.colText)),
              const SizedBox(height: 16),
              Text('${goal.toStringAsFixed(1)} hours',
                  style: const TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.w800,
                      color: AppColors.purple400)),
              Slider(
                value: goal,
                min: 4,
                max: 12,
                divisions: 16,
                activeColor: AppColors.purple400,
                onChanged: (v) => setSt(() => goal = v),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.purple600,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                  onPressed: () {
                    Navigator.pop(ctx);
                    notifier.setGoal(goal);
                  },
                  child: const Text('Save Goal'),
                ),
              ),
            ],
          );
        }),
      ),
    );
  }
}

// ── Sub-widgets ───────────────────────────────────────────────────────────────

class _LastNightCard extends StatelessWidget {
  const _LastNightCard({required this.state});
  final SleepState state;

  Color _qualityColor(double? hours, double goal) {
    if (hours == null) return AppColors.slate400;
    final ratio = hours / goal;
    if (ratio >= 0.9) return AppColors.green400;
    if (ratio >= 0.7) return AppColors.amber400;
    return AppColors.coral400;
  }

  String _qualityLabel(double? hours, double goal) {
    if (hours == null) return 'No data yet';
    final ratio = hours / goal;
    if (ratio >= 0.9) return 'Great sleep';
    if (ratio >= 0.7) return 'Okay sleep';
    return 'Needs improvement';
  }

  @override
  Widget build(BuildContext context) {
    final h = state.lastNightHours;
    final color = _qualityColor(h, state.goalHours);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: context.colSurface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: context.colBorder),
      ),
      child: Row(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.bedtime, color: color, size: 28),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Last Night',
                    style: TextStyle(color: context.colTextSec, fontSize: 12)),
                const SizedBox(height: 4),
                Text(
                  h != null ? '${h.toStringAsFixed(1)} hrs' : '— hrs',
                  style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.w800,
                      color: context.colText),
                ),
                Text(_qualityLabel(h, state.goalHours),
                    style: TextStyle(
                        color: color,
                        fontSize: 12,
                        fontWeight: FontWeight.w500)),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text('Goal',
                  style: TextStyle(fontSize: 11, color: context.colTextSec)),
              Text('${state.goalHours.toStringAsFixed(0)}h',
                  style: TextStyle(
                      fontWeight: FontWeight.w700, color: context.colText)),
            ],
          ),
        ],
      ),
    );
  }
}

class _SleepBarChart extends StatelessWidget {
  const _SleepBarChart({required this.entries, required this.goalHours});
  final List<SleepEntry> entries;
  final double goalHours;

  @override
  Widget build(BuildContext context) {
    final maxH = [goalHours, ...entries.map((e) => e.hours)]
        .reduce((a, b) => a > b ? a : b);

    return Container(
      height: 120,
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      decoration: BoxDecoration(
        color: context.colSurface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: context.colBorder),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: entries.map((e) {
          final ratio = (e.hours / maxH).clamp(0.0, 1.0);
          final isGood = e.hours >= goalHours * 0.9;
          final color = isGood ? AppColors.purple400 : AppColors.amber400;
          return Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 3),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Text(
                    e.hours.toStringAsFixed(1),
                    style: TextStyle(fontSize: 9, color: context.colTextHint),
                  ),
                  const SizedBox(height: 2),
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 400),
                    height: 80 * ratio,
                    decoration: BoxDecoration(
                      color: color,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    DateFormat('E').format(e.wakeTime),
                    style: TextStyle(fontSize: 9, color: context.colTextSec),
                  ),
                ],
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

class _SleepRow extends StatelessWidget {
  const _SleepRow({required this.entry, required this.onDelete});
  final SleepEntry entry;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final bed = DateFormat('MMM d, h:mm a').format(entry.bedtime);
    final wake = DateFormat('h:mm a').format(entry.wakeTime);
    final h = entry.hours;

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: context.colSurface,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: context.colBorder),
      ),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: AppColors.purple400.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(Icons.bedtime_outlined,
                color: AppColors.purple400, size: 18),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('$bed → $wake',
                    style: TextStyle(fontSize: 12, color: context.colTextSec)),
                Text(
                  '${h.toStringAsFixed(1)} hours',
                  style: TextStyle(
                      fontWeight: FontWeight.w600, color: context.colText),
                ),
              ],
            ),
          ),
          GestureDetector(
            onTap: onDelete,
            child: Icon(Icons.close, size: 16, color: context.colTextHint),
          ),
        ],
      ),
    );
  }
}

class _BedtimeReminder extends StatelessWidget {
  const _BedtimeReminder({required this.state, required this.notifier});
  final SleepState state;
  final SleepNotifier notifier;

  String _fmt(int h, int m) {
    final suf = h < 12 ? 'AM' : 'PM';
    final d = h == 0 ? 12 : (h > 12 ? h - 12 : h);
    return '$d:${m.toString().padLeft(2, '0')} $suf';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: context.colTint(AppColors.purple50, AppColors.purple50Dk),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.purple400.withValues(alpha: 0.3)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              const Icon(Icons.notifications_outlined,
                  color: AppColors.purple400, size: 20),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Bedtime Reminder',
                        style: TextStyle(
                            fontWeight: FontWeight.w600,
                            color: context.colText,
                            fontSize: 13)),
                    Text(
                      state.bedtimeReminderEnabled
                          ? 'Reminds at ${_fmt(state.bedtimeHour, state.bedtimeMinute)}'
                          : 'Tap to enable',
                      style: TextStyle(fontSize: 11, color: context.colTextSec),
                    ),
                  ],
                ),
              ),
              Switch(
                value: state.bedtimeReminderEnabled,
                onChanged: (v) => notifier.setReminder(enabled: v),
                activeThumbColor: AppColors.purple400,
              ),
            ],
          ),
          if (state.bedtimeReminderEnabled) ...[
            const Divider(height: 16),
            GestureDetector(
              onTap: () async {
                final picked = await showTimePicker(
                  context: context,
                  initialTime: TimeOfDay(
                      hour: state.bedtimeHour, minute: state.bedtimeMinute),
                );
                if (picked != null) {
                  notifier.setReminder(
                      enabled: true, hour: picked.hour, minute: picked.minute);
                }
              },
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                decoration: BoxDecoration(
                  color: AppColors.purple400.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.access_time,
                        color: AppColors.purple600, size: 16),
                    const SizedBox(width: 8),
                    Text(
                      _fmt(state.bedtimeHour, state.bedtimeMinute),
                      style: const TextStyle(
                          fontWeight: FontWeight.w700,
                          color: AppColors.purple600),
                    ),
                    const SizedBox(width: 4),
                    const Icon(Icons.edit,
                        size: 12, color: AppColors.purple600),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _LogSleepSheet extends StatefulWidget {
  const _LogSleepSheet({
    required this.initialBedtime,
    required this.initialWakeTime,
    required this.onSave,
  });
  final DateTime initialBedtime, initialWakeTime;
  final void Function(DateTime bedtime, DateTime wakeTime) onSave;

  @override
  State<_LogSleepSheet> createState() => _LogSleepSheetState();
}

class _LogSleepSheetState extends State<_LogSleepSheet> {
  late DateTime _bedtime, _wakeTime;

  @override
  void initState() {
    super.initState();
    _bedtime = widget.initialBedtime;
    _wakeTime = widget.initialWakeTime;
  }

  Future<void> _pickTime(bool isBedtime) async {
    final current = isBedtime ? _bedtime : _wakeTime;
    final picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(current),
    );
    if (picked == null) return;
    final now = DateTime.now();
    var dt = DateTime(now.year, now.month, now.day, picked.hour, picked.minute);
    if (isBedtime) {
      if (dt.isAfter(_wakeTime)) dt = dt.subtract(const Duration(days: 1));
      setState(() => _bedtime = dt);
    } else {
      if (dt.isBefore(_bedtime)) dt = dt.add(const Duration(days: 1));
      setState(() => _wakeTime = dt);
    }
  }

  double get _hours => _wakeTime.difference(_bedtime).inMinutes / 60.0;

  String _fmt(DateTime dt) => DateFormat('MMM d, h:mm a').format(dt);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(
          24, 20, 24, MediaQuery.of(context).padding.bottom + 24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(bottom: 20),
              decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2))),
          Text('Log Sleep',
              style: TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 18,
                  color: context.colText)),
          const SizedBox(height: 20),

          // Duration display
          Container(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: Column(
              children: [
                Text(
                  '${_hours.toStringAsFixed(1)} hours',
                  style: const TextStyle(
                      fontSize: 38,
                      fontWeight: FontWeight.w800,
                      color: AppColors.purple400),
                ),
                Text('sleep duration',
                    style: TextStyle(color: context.colTextSec, fontSize: 13)),
              ],
            ),
          ),

          // Bedtime picker
          _TimeRow(
            label: 'Bedtime',
            icon: Icons.bedtime_outlined,
            time: _fmt(_bedtime),
            onTap: () => _pickTime(true),
          ),
          const SizedBox(height: 10),
          _TimeRow(
            label: 'Wake Time',
            icon: Icons.wb_sunny_outlined,
            time: _fmt(_wakeTime),
            onTap: () => _pickTime(false),
          ),
          const SizedBox(height: 20),

          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.purple600,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
              onPressed: () => widget.onSave(_bedtime, _wakeTime),
              child: const Text('Save Sleep Log'),
            ),
          ),
        ],
      ),
    );
  }
}

class _TimeRow extends StatelessWidget {
  const _TimeRow({
    required this.label,
    required this.icon,
    required this.time,
    required this.onTap,
  });
  final String label, time;
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: AppColors.purple400.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.purple400.withValues(alpha: 0.3)),
        ),
        child: Row(
          children: [
            Icon(icon, color: AppColors.purple600, size: 18),
            const SizedBox(width: 10),
            Expanded(
              child: Text(label,
                  style: TextStyle(color: context.colTextSec, fontSize: 13)),
            ),
            Text(time,
                style: const TextStyle(
                    fontWeight: FontWeight.w700, color: AppColors.purple600)),
            const SizedBox(width: 4),
            const Icon(Icons.edit_outlined,
                color: AppColors.purple400, size: 14),
          ],
        ),
      ),
    );
  }
}
