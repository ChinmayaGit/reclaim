import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../data/workout_models.dart';
import '../domain/workout_notifier.dart';

class WorkoutLogScreen extends ConsumerWidget {
  const WorkoutLogScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final st = ref.watch(workoutLogProvider);
    final active = st.active;
    if (active == null) {
      return Scaffold(
        backgroundColor: context.colBackground,
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    final stats = st.weekStats(DateTime.now());
    final notifier = ref.read(workoutLogProvider.notifier);

    return Scaffold(
      backgroundColor: context.colBackground,
      appBar: AppBar(
        backgroundColor: context.colSurface,
        title: const Text('Log workout'),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => _confirmExit(context, ref),
        ),
        actions: [
          TextButton(
            onPressed: () => _finish(context, ref),
            child: const Text(
              'FINISH',
              style: TextStyle(
                fontWeight: FontWeight.w800,
                color: AppColors.teal600,
              ),
            ),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _StatsRow(stats: stats),
          const SizedBox(height: 12),
          _WeekSparkline(history: st.history),
          const SizedBox(height: 20),
          ...active.exercises.map(
            (ex) => _ExerciseCard(
              exercise: ex,
              prev: st.lastMatchForExercise(ex.name),
              onRemove: () => notifier.removeExercise(ex.id),
              onAddSet: () => notifier.addSet(ex.id),
              onUpdateSet: (setId, {kg, reps, done}) =>
                  notifier.updateSet(ex.id, setId, kg: kg, reps: reps, done: done),
            ),
          ),
          const SizedBox(height: 24),
          OutlinedButton.icon(
            onPressed: () => _addExerciseDialog(context, notifier),
            icon: const Icon(Icons.add),
            label: const Text('Add exercise'),
          ),
          const SizedBox(height: 80),
        ],
      ),
    );
  }

  Future<void> _confirmExit(BuildContext context, WidgetRef ref) async {
    final leave = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Leave workout?'),
        content: const Text('Your draft is saved. You can continue later from Home → Gym log.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Stay')),
          FilledButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Leave')),
        ],
      ),
    );
    if (leave == true && context.mounted) context.pop();
  }

  Future<void> _finish(BuildContext context, WidgetRef ref) async {
    await ref.read(workoutLogProvider.notifier).finishSession();
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Workout saved. New session started.')),
      );
    }
  }

  Future<void> _addExerciseDialog(
      BuildContext context, WorkoutLogNotifier notifier) async {
    final ctrl = TextEditingController();
    final muscle = TextEditingController();
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Add exercise'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: ctrl,
              decoration: const InputDecoration(
                labelText: 'Name',
                hintText: 'e.g. Bench press',
              ),
              autofocus: true,
            ),
            const SizedBox(height: 12),
            TextField(
              controller: muscle,
              decoration: const InputDecoration(
                labelText: 'Focus (optional)',
                hintText: 'e.g. CHEST',
              ),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
          FilledButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Add')),
        ],
      ),
    );
    if (ok == true && ctrl.text.trim().isNotEmpty) {
      await notifier.addExercise(ctrl.text.trim(),
          muscleGroup: muscle.text.trim());
    }
  }
}

class _StatsRow extends StatelessWidget {
  const _StatsRow({required this.stats});
  final WorkoutWeekStats stats;

  @override
  Widget build(BuildContext context) {
    String vol = stats.totalVolumeKg >= 1000
        ? '${(stats.totalVolumeKg / 1000).toStringAsFixed(1)}k'
        : '${stats.totalVolumeKg}';
    return Row(
      children: [
        Expanded(
          child: _StatCell(
            label: 'Sessions',
            value: '${stats.sessionCount}',
            sub: '7 days',
          ),
        ),
        Expanded(
          child: _StatCell(
            label: 'Sets',
            value: '${stats.totalSets}',
            sub: 'logged',
          ),
        ),
        Expanded(
          child: _StatCell(
            label: 'Volume',
            value: vol,
            sub: 'kg×reps',
          ),
        ),
      ],
    );
  }
}

class _StatCell extends StatelessWidget {
  const _StatCell({
    required this.label,
    required this.value,
    required this.sub,
  });
  final String label, value, sub;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
      decoration: BoxDecoration(
        color: context.colSurface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: context.colBorder),
      ),
      child: Column(
        children: [
          Text(label,
              style: TextStyle(fontSize: 11, color: context.colTextSec)),
          const SizedBox(height: 4),
          Text(value,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: context.colText,
              )),
          Text(sub,
              style: TextStyle(fontSize: 10, color: context.colTextHint)),
        ],
      ),
    );
  }
}

class _WeekSparkline extends StatelessWidget {
  const _WeekSparkline({required this.history});
  final List<FinishedWorkout> history;

  @override
  Widget build(BuildContext context) {
    final today = DateTime.now();
    final today0 = DateTime(today.year, today.month, today.day);
    final days = List.generate(7, (i) {
      final d = today0.subtract(Duration(days: 6 - i));
      var vol = 0;
      for (final w in history) {
        final wd = DateTime(w.finishedAt.year, w.finishedAt.month, w.finishedAt.day);
        if (wd == d) vol += w.totalVolume;
      }
      return (d, vol);
    });
    var maxV = days.fold<int>(0, (a, b) => a > b.$2 ? a : b.$2);
    if (maxV < 1) maxV = 1;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Last 7 days',
            style: TextStyle(fontSize: 12, color: context.colTextSec)),
        const SizedBox(height: 8),
        SizedBox(
          height: 72,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: List.generate(7, (i) {
              final vol = days[i].$2;
              final h = 8.0 + (vol / maxV) * 56;
              return Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 3),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Container(
                        height: h,
                        decoration: BoxDecoration(
                          color: AppColors.teal400.withValues(alpha: 0.85),
                          borderRadius:
                              const BorderRadius.vertical(top: Radius.circular(4)),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${days[i].$1.day}',
                        style: TextStyle(fontSize: 9, color: context.colTextHint),
                      ),
                    ],
                  ),
                ),
              );
            }),
          ),
        ),
      ],
    );
  }
}

class _ExerciseCard extends StatelessWidget {
  const _ExerciseCard({
    required this.exercise,
    required this.prev,
    required this.onRemove,
    required this.onAddSet,
    required this.onUpdateSet,
  });

  final GymExercise exercise;
  final GymExercise? prev;
  final VoidCallback onRemove;
  final VoidCallback onAddSet;
  final void Function(String setId, {double? kg, int? reps, bool? done}) onUpdateSet;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      color: context.colSurface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: BorderSide(color: context.colBorder),
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (exercise.muscleGroup.isNotEmpty)
                        Text(
                          exercise.muscleGroup.toUpperCase(),
                          style: const TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w800,
                            color: AppColors.amber600,
                            letterSpacing: 0.6,
                          ),
                        ),
                      Text(
                        exercise.name,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: context.colText,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.delete_outline, size: 20),
                  color: context.colTextHint,
                  onPressed: onRemove,
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                _th(context, 'SET', flex: 1),
                _th(context, 'PREV', flex: 2),
                _th(context, 'KG', flex: 2),
                _th(context, 'REPS', flex: 2),
                _th(context, '✓', flex: 1),
              ],
            ),
            const Divider(height: 1),
            ...exercise.sets.asMap().entries.map((e) {
              final idx = e.key;
              final s = e.value;
              final prevEx = prev;
              final prevTxt = (prevEx != null && idx < prevEx.sets.length)
                  ? '${_fmtNum(prevEx.sets[idx].kg)}×${prevEx.sets[idx].reps}'
                  : '—';
              return _SetRow(
                key: ValueKey(s.id),
                setIndex: idx + 1,
                setId: s.id,
                prevText: prevTxt,
                kg: s.kg,
                reps: s.reps,
                done: s.done,
                onChanged: onUpdateSet,
              );
            }),
            const SizedBox(height: 8),
            TextButton.icon(
              onPressed: onAddSet,
              icon: const Icon(Icons.add, size: 18),
              label: const Text('Add set'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _th(BuildContext context, String t, {required int flex}) {
    return Expanded(
      flex: flex,
      child: Text(
        t,
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w700,
          color: context.colTextHint,
        ),
      ),
    );
  }
}

String _fmtNum(double v) {
  if (v == v.roundToDouble()) return v.toInt().toString();
  return v.toStringAsFixed(1);
}

class _SetRow extends StatefulWidget {
  const _SetRow({
    super.key,
    required this.setIndex,
    required this.setId,
    required this.prevText,
    required this.kg,
    required this.reps,
    required this.done,
    required this.onChanged,
  });

  final int setIndex;
  final String setId;
  final String prevText;
  final double kg;
  final int reps;
  final bool done;
  final void Function(String setId, {double? kg, int? reps, bool? done}) onChanged;

  @override
  State<_SetRow> createState() => _SetRowState();
}

class _SetRowState extends State<_SetRow> {
  late final TextEditingController _kg;
  late final TextEditingController _reps;

  @override
  void initState() {
    super.initState();
    _kg = TextEditingController(
        text: widget.kg > 0 ? _fmtNum(widget.kg) : '');
    _reps = TextEditingController(
        text: widget.reps > 0 ? '${widget.reps}' : '');
  }

  @override
  void didUpdateWidget(covariant _SetRow old) {
    super.didUpdateWidget(old);
    if (old.kg != widget.kg &&
        (double.tryParse(_kg.text) ?? 0) != widget.kg) {
      _kg.text = widget.kg > 0 ? _fmtNum(widget.kg) : '';
    }
    if (old.reps != widget.reps &&
        (int.tryParse(_reps.text) ?? 0) != widget.reps) {
      _reps.text = widget.reps > 0 ? '${widget.reps}' : '';
    }
  }

  @override
  void dispose() {
    _kg.dispose();
    _reps.dispose();
    super.dispose();
  }

  void _push() {
    final kg = double.tryParse(_kg.text.trim()) ?? 0;
    final reps = int.tryParse(_reps.text.trim()) ?? 0;
    widget.onChanged(widget.setId, kg: kg, reps: reps);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            flex: 1,
            child: Text(
              '${widget.setIndex}',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: widget.done ? AppColors.teal600 : context.colText,
              ),
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              widget.prevText,
              style: TextStyle(fontSize: 12, color: context.colTextSec),
            ),
          ),
          Expanded(
            flex: 2,
            child: TextField(
              controller: _kg,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 13),
              decoration: const InputDecoration(
                isDense: true,
                contentPadding: EdgeInsets.symmetric(vertical: 8, horizontal: 4),
              ),
              onEditingComplete: _push,
            ),
          ),
          Expanded(
            flex: 2,
            child: TextField(
              controller: _reps,
              keyboardType: TextInputType.number,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 13),
              decoration: const InputDecoration(
                isDense: true,
                contentPadding: EdgeInsets.symmetric(vertical: 8, horizontal: 4),
              ),
              onEditingComplete: _push,
            ),
          ),
          Expanded(
            flex: 1,
            child: Checkbox(
              value: widget.done,
              onChanged: (v) {
                _push();
                widget.onChanged(widget.setId, done: v ?? false);
              },
            ),
          ),
        ],
      ),
    );
  }
}
