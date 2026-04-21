import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/app_colors.dart';
import '../domain/water_notifier.dart';
import '../data/water_model.dart';

class WaterScreen extends ConsumerStatefulWidget {
  const WaterScreen({super.key});

  @override
  ConsumerState<WaterScreen> createState() => _WaterScreenState();
}

class _WaterScreenState extends ConsumerState<WaterScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _ripple;

  @override
  void initState() {
    super.initState();
    _ripple =
        AnimationController(vsync: this, duration: const Duration(seconds: 2))
          ..repeat(reverse: true);
  }

  @override
  void dispose() {
    _ripple.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(waterProvider);
    final notifier = ref.read(waterProvider.notifier);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: context.colBackground,
      appBar: AppBar(
        backgroundColor: context.colSurface,
        title: const Text('Water Tracker'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            onPressed: () => _showSettings(context, state, notifier),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          // ── Progress ring ──────────────────────────────────────────────────
          Center(
            child: AnimatedBuilder(
              animation: _ripple,
              builder: (_, __) => _WaterRing(
                progress: state.progress,
                totalMl: state.totalTodayMl,
                goalMl: state.goalMl,
                ripple: _ripple.value,
              ),
            ),
          ),
          const SizedBox(height: 8),
          Center(
            child: Text(
              state.goalReached ? 'Goal reached! Keep it up!' : 'Stay hydrated',
              style: TextStyle(
                color:
                    state.goalReached ? AppColors.teal600 : context.colTextSec,
                fontSize: 13,
                fontWeight:
                    state.goalReached ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
          ),
          const SizedBox(height: 28),

          // ── Quick-add buttons ──────────────────────────────────────────────
          Text('Add Water',
              style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: context.colText,
                  fontSize: 14)),
          const SizedBox(height: 10),
          Row(
            children: [
              _QuickAdd(ml: 100, notifier: notifier),
              const SizedBox(width: 8),
              _QuickAdd(ml: 200, notifier: notifier),
              const SizedBox(width: 8),
              _QuickAdd(ml: 350, notifier: notifier),
              const SizedBox(width: 8),
              _QuickAdd(ml: 500, notifier: notifier),
              const SizedBox(width: 8),
              Expanded(
                child: GestureDetector(
                  onTap: () => _showCustomAdd(context, notifier),
                  child: Container(
                    height: 48,
                    decoration: BoxDecoration(
                      color: context.colTint(
                          AppColors.slate100, AppColors.slate100Dk),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: context.colBorder),
                    ),
                    child: Icon(Icons.add, color: context.colTextSec, size: 20),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 28),

          // ── Today's log ────────────────────────────────────────────────────
          if (state.entries.isNotEmpty) ...[
            Row(
              children: [
                Text("Today's Log",
                    style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: context.colText,
                        fontSize: 14)),
                const Spacer(),
                Text(
                  '${state.entries.length} entries',
                  style: TextStyle(fontSize: 12, color: context.colTextSec),
                ),
              ],
            ),
            const SizedBox(height: 10),
            ...state.entries.asMap().entries.map((e) => _EntryRow(
                  entry: e.value,
                  index: e.key,
                  onDelete: () => notifier.removeEntry(e.key),
                  isDark: isDark,
                )),
            const SizedBox(height: 16),
          ],

          // ── Reminder banner ────────────────────────────────────────────────
          _ReminderBanner(state: state, notifier: notifier),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  void _showCustomAdd(BuildContext context, WaterNotifier notifier) {
    int customMl = 300;
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
              Text('Custom Amount',
                  style: TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 18,
                      color: context.colText)),
              const SizedBox(height: 20),
              Text('$customMl ml',
                  style: const TextStyle(
                      fontSize: 36,
                      fontWeight: FontWeight.w800,
                      color: AppColors.blue400)),
              Slider(
                value: customMl.toDouble(),
                min: 50,
                max: 1000,
                divisions: 19,
                activeColor: AppColors.blue400,
                onChanged: (v) => setSt(() => customMl = v.round()),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.blue400,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                  onPressed: () {
                    Navigator.pop(ctx);
                    notifier.addWater(customMl);
                  },
                  child: Text('Add $customMl ml'),
                ),
              ),
            ],
          );
        }),
      ),
    );
  }

  void _showSettings(
      BuildContext context, WaterState state, WaterNotifier notifier) {
    int goal = state.goalMl;
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
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                    width: 40,
                    height: 4,
                    margin: const EdgeInsets.only(bottom: 20),
                    decoration: BoxDecoration(
                        color: Colors.grey.shade300,
                        borderRadius: BorderRadius.circular(2))),
              ),
              Text('Daily Goal',
                  style: TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 18,
                      color: context.colText)),
              const SizedBox(height: 16),
              Center(
                child: Text('$goal ml',
                    style: const TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.w800,
                        color: AppColors.blue400)),
              ),
              Slider(
                value: goal.toDouble(),
                min: 1000,
                max: 5000,
                divisions: 16,
                activeColor: AppColors.blue400,
                onChanged: (v) => setSt(() => goal = v.round()),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('1L',
                      style:
                          TextStyle(color: context.colTextHint, fontSize: 11)),
                  Text('5L',
                      style:
                          TextStyle(color: context.colTextHint, fontSize: 11)),
                ],
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.blue400,
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

// ── Widgets ───────────────────────────────────────────────────────────────────

class _WaterRing extends StatelessWidget {
  const _WaterRing({
    required this.progress,
    required this.totalMl,
    required this.goalMl,
    required this.ripple,
  });

  final double progress;
  final int totalMl, goalMl;
  final double ripple;

  @override
  Widget build(BuildContext context) {
    final size = 200.0;
    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          CustomPaint(
            size: Size(size, size),
            painter: _RingPainter(progress: progress, ripple: ripple),
          ),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                _fmt(totalMl),
                style: TextStyle(
                  fontSize: 30,
                  fontWeight: FontWeight.w800,
                  color: context.colText,
                ),
              ),
              Text(
                'of ${_fmt(goalMl)}',
                style: TextStyle(fontSize: 13, color: context.colTextSec),
              ),
              const SizedBox(height: 4),
              Text(
                '${(progress * 100).round()}%',
                style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppColors.blue400),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _fmt(int ml) =>
      ml >= 1000 ? '${(ml / 1000).toStringAsFixed(1)}L' : '${ml}ml';
}

class _RingPainter extends CustomPainter {
  _RingPainter({required this.progress, required this.ripple});
  final double progress, ripple;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 12;
    const strokeW = 14.0;

    // Track
    canvas.drawCircle(
        center,
        radius,
        Paint()
          ..color = AppColors.blue400.withValues(alpha: 0.12)
          ..style = PaintingStyle.stroke
          ..strokeWidth = strokeW);

    // Progress arc
    if (progress > 0) {
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        -math.pi / 2,
        2 * math.pi * progress,
        false,
        Paint()
          ..color = AppColors.blue400
          ..style = PaintingStyle.stroke
          ..strokeWidth = strokeW
          ..strokeCap = StrokeCap.round,
      );
    }

    // Ripple ring when < 100%
    if (progress < 1.0) {
      canvas.drawCircle(
          center,
          radius * (0.7 + ripple * 0.3),
          Paint()
            ..color = AppColors.blue400.withValues(alpha: (1 - ripple) * 0.15)
            ..style = PaintingStyle.stroke
            ..strokeWidth = 2);
    }
  }

  @override
  bool shouldRepaint(_RingPainter old) =>
      old.progress != progress || old.ripple != ripple;
}

class _QuickAdd extends StatelessWidget {
  const _QuickAdd({required this.ml, required this.notifier});
  final int ml;
  final WaterNotifier notifier;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: () => notifier.addWater(ml),
        child: Container(
          height: 48,
          decoration: BoxDecoration(
            color: AppColors.blue400.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(10),
            border:
                Border.all(color: AppColors.blue400.withValues(alpha: 0.35)),
          ),
          alignment: Alignment.center,
          child: Text(
            ml >= 1000 ? '${ml ~/ 1000}L' : '+${ml}ml',
            style: const TextStyle(
                color: AppColors.blue400,
                fontWeight: FontWeight.w700,
                fontSize: 13),
          ),
        ),
      ),
    );
  }
}

class _EntryRow extends StatelessWidget {
  const _EntryRow({
    required this.entry,
    required this.index,
    required this.onDelete,
    required this.isDark,
  });

  final WaterEntry entry;
  final int index;
  final VoidCallback onDelete;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    final time = DateFormat('h:mm a').format(entry.time);
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: context.colSurface,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: context.colBorder),
      ),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: AppColors.blue400.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(Icons.water_drop_outlined,
                color: AppColors.blue400, size: 16),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              '${entry.amountMl} ml',
              style: TextStyle(
                  fontWeight: FontWeight.w600, color: context.colText),
            ),
          ),
          Text(time, style: TextStyle(fontSize: 12, color: context.colTextSec)),
          const SizedBox(width: 8),
          GestureDetector(
            onTap: onDelete,
            child: Icon(Icons.close, size: 16, color: context.colTextHint),
          ),
        ],
      ),
    );
  }
}

class _ReminderBanner extends StatelessWidget {
  const _ReminderBanner({required this.state, required this.notifier});
  final WaterState state;
  final WaterNotifier notifier;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: context.colTint(AppColors.blue50, AppColors.blue50Dk),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.blue400.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          const Icon(Icons.notifications_outlined,
              color: AppColors.blue400, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Hydration Reminders',
                    style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: context.colText,
                        fontSize: 13)),
                Text(
                  state.reminderEnabled
                      ? 'Every ${state.reminderIntervalHours}h'
                      : 'Tap to enable',
                  style: TextStyle(fontSize: 11, color: context.colTextSec),
                ),
              ],
            ),
          ),
          Switch(
            value: state.reminderEnabled,
            onChanged: (v) => notifier.setReminder(enabled: v),
            activeThumbColor: AppColors.blue400,
          ),
        ],
      ),
    );
  }
}
