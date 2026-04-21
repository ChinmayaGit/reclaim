import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../domain/discipline_notifier.dart';
import '../data/habit_model.dart';

class DisciplineScreen extends ConsumerWidget {
  const DisciplineScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(disciplineProvider);
    final notifier = ref.read(disciplineProvider.notifier);

    return Scaffold(
      backgroundColor: context.colBackground,
      appBar: AppBar(
        backgroundColor: context.colSurface,
        title: const Text('Daily Discipline'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => _addHabitSheet(context, notifier),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          // ── Score header ───────────────────────────────────────────────────
          _ScoreHeader(state: state),
          const SizedBox(height: 24),

          // ── Streak banner ──────────────────────────────────────────────────
          if (state.streak > 0) ...[
            _StreakBanner(streak: state.streak),
            const SizedBox(height: 20),
          ],

          // ── Habit list ─────────────────────────────────────────────────────
          if (state.habits.isEmpty)
            _EmptyState(onAdd: () => _addHabitSheet(context, notifier))
          else ...[
            Text('Today',
                style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: context.colText,
                    fontSize: 14)),
            const SizedBox(height: 12),
            ...state.habits.map(
              (habit) => _HabitTile(
                habit: habit,
                done: state.completedToday.contains(habit.id),
                onToggle: () => notifier.toggleHabit(habit.id),
                onDelete: () => notifier.removeHabit(habit.id),
              ),
            ),
          ],
          const SizedBox(height: 28),

          // ── All-done celebration ───────────────────────────────────────────
          if (state.allDone) ...[
            _AllDoneBanner(),
            const SizedBox(height: 20),
          ],

          // ── How it works tip ───────────────────────────────────────────────
          _TipBox(),
          const SizedBox(height: 80),
        ],
      ),
    );
  }

  void _addHabitSheet(BuildContext context, DisciplineNotifier notifier) {
    final ctrl = TextEditingController();
    int selected = 0;
    const icons = [
      (Icons.water_drop, AppColors.blue400),
      (Icons.fitness_center, AppColors.amber400),
      (Icons.menu_book, AppColors.purple400),
      (Icons.no_cell, AppColors.coral400),
      (Icons.self_improvement, AppColors.teal400),
      (Icons.directions_run, AppColors.green400),
      (Icons.nightlight, AppColors.purple600),
      (Icons.apple, AppColors.coral600),
    ];

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) => Padding(
        padding: EdgeInsets.fromLTRB(
            24, 20, 24, MediaQuery.of(ctx).viewInsets.bottom + MediaQuery.of(ctx).padding.bottom + 24),
        child: StatefulBuilder(builder: (ctx, setSt) {
          return Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                    width: 40, height: 4,
                    margin: const EdgeInsets.only(bottom: 20),
                    decoration: BoxDecoration(
                        color: Colors.grey.shade300,
                        borderRadius: BorderRadius.circular(2))),
              ),
              Text('Add Habit',
                  style: TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 18,
                      color: context.colText)),
              const SizedBox(height: 16),
              TextField(
                controller: ctrl,
                autofocus: true,
                decoration: InputDecoration(
                  hintText: 'e.g. Drink water, No smoking...',
                  hintStyle:
                      TextStyle(color: context.colTextHint, fontSize: 13),
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10)),
                  contentPadding: const EdgeInsets.symmetric(
                      horizontal: 14, vertical: 12),
                ),
              ),
              const SizedBox(height: 16),
              Text('Pick an icon',
                  style: TextStyle(
                      color: context.colTextSec, fontSize: 13)),
              const SizedBox(height: 10),
              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: icons.asMap().entries.map((e) {
                  final (icon, color) = e.value;
                  final isSel = e.key == selected;
                  return GestureDetector(
                    onTap: () => setSt(() => selected = e.key),
                    child: Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: isSel
                            ? color.withValues(alpha: 0.18)
                            : context.colTint(AppColors.slate100,
                                AppColors.slate100Dk),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                            color: isSel
                                ? color
                                : context.colBorder),
                      ),
                      child: Icon(icon,
                          color: isSel ? color : context.colTextSec,
                          size: 20),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.teal600,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                  onPressed: () {
                    final name = ctrl.text.trim();
                    if (name.isEmpty) return;
                    final (icon, color) = icons[selected];
                    final habit = HabitItem(
                      id:
                          'habit_${DateTime.now().millisecondsSinceEpoch}',
                      name: name,
                      iconCode: icon.codePoint,
                      colorValue: color.value,
                    );
                    Navigator.pop(ctx);
                    notifier.addHabit(habit);
                  },
                  child: const Text('Add Habit'),
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

class _ScoreHeader extends StatelessWidget {
  const _ScoreHeader({required this.state});
  final DisciplineState state;

  @override
  Widget build(BuildContext context) {
    final pct = (state.progress * 100).round();
    final color = pct >= 80
        ? AppColors.teal600
        : pct >= 40
            ? AppColors.amber600
            : AppColors.coral600;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: context.colSurface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: context.colBorder),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("Today's Score",
                        style: TextStyle(
                            color: context.colTextSec, fontSize: 12)),
                    const SizedBox(height: 4),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.baseline,
                      textBaseline: TextBaseline.alphabetic,
                      children: [
                        Text(
                          '${state.completedCount}',
                          style: TextStyle(
                              fontSize: 40,
                              fontWeight: FontWeight.w800,
                              color: context.colText),
                        ),
                        Text(
                          ' / ${state.totalCount}',
                          style: TextStyle(
                              fontSize: 20,
                              color: context.colTextSec),
                        ),
                      ],
                    ),
                    Text('habits completed',
                        style: TextStyle(
                            color: context.colTextSec, fontSize: 12)),
                  ],
                ),
              ),
              Stack(
                alignment: Alignment.center,
                children: [
                  SizedBox(
                    width: 72,
                    height: 72,
                    child: CircularProgressIndicator(
                      value: state.progress,
                      backgroundColor:
                          context.colBorder,
                      valueColor:
                          AlwaysStoppedAnimation(color),
                      strokeWidth: 7,
                    ),
                  ),
                  Text('$pct%',
                      style: TextStyle(
                          fontWeight: FontWeight.w800,
                          fontSize: 16,
                          color: color)),
                ],
              ),
            ],
          ),
          const SizedBox(height: 14),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: state.progress,
              minHeight: 6,
              backgroundColor: context.colBorder,
              valueColor: AlwaysStoppedAnimation(color),
            ),
          ),
        ],
      ),
    );
  }
}

class _StreakBanner extends StatelessWidget {
  const _StreakBanner({required this.streak});
  final int streak;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.amber400.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(12),
        border:
            Border.all(color: AppColors.amber400.withValues(alpha: 0.4)),
      ),
      child: Row(
        children: [
          const Icon(Icons.local_fire_department,
              color: AppColors.amber400, size: 22),
          const SizedBox(width: 10),
          Expanded(
            child: RichText(
              text: TextSpan(
                style: TextStyle(color: context.colText),
                children: [
                  TextSpan(
                    text: '$streak-day streak! ',
                    style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        color: AppColors.amber600,
                        fontSize: 14),
                  ),
                  TextSpan(
                    text: 'Complete all habits to keep it going.',
                    style: TextStyle(
                        color: context.colTextSec, fontSize: 13),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _HabitTile extends StatelessWidget {
  const _HabitTile({
    required this.habit,
    required this.done,
    required this.onToggle,
    required this.onDelete,
  });

  final HabitItem habit;
  final bool done;
  final VoidCallback onToggle, onDelete;

  @override
  Widget build(BuildContext context) {
    final color = Color(habit.colorValue);
    return GestureDetector(
      onTap: onToggle,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: done
              ? color.withValues(alpha: 0.1)
              : context.colSurface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
              color: done
                  ? color.withValues(alpha: 0.5)
                  : context.colBorder,
              width: done ? 1.5 : 1),
        ),
        child: Row(
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: done
                    ? color
                    : color.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                IconData(habit.iconCode,
                    fontFamily: 'MaterialIcons'),
                color: done ? Colors.white : color,
                size: 18,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                habit.name,
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                  color: done ? color : context.colText,
                  decoration: done
                      ? TextDecoration.lineThrough
                      : null,
                  decorationColor: color,
                ),
              ),
            ),
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 200),
              child: done
                  ? Icon(Icons.check_circle,
                      key: const ValueKey('done'),
                      color: color,
                      size: 22)
                  : Icon(Icons.radio_button_unchecked,
                      key: const ValueKey('undone'),
                      color: context.colTextHint,
                      size: 22),
            ),
            const SizedBox(width: 8),
            GestureDetector(
              onTap: onDelete,
              child: Icon(Icons.delete_outline,
                  size: 16, color: context.colTextHint),
            ),
          ],
        ),
      ),
    );
  }
}

class _AllDoneBanner extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.teal400.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
            color: AppColors.teal400.withValues(alpha: 0.5)),
      ),
      child: Column(
        children: [
          const Icon(Icons.celebration,
              color: AppColors.teal400, size: 32),
          const SizedBox(height: 8),
          const Text(
            'All habits done today!',
            style: TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 16,
                color: AppColors.teal600),
          ),
          const SizedBox(height: 4),
          Text(
            'You\'re building an unbreakable discipline.',
            style: TextStyle(
                color: context.colTextSec, fontSize: 13),
          ),
        ],
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.onAdd});
  final VoidCallback onAdd;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: context.colSurface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: context.colBorder),
      ),
      child: Column(
        children: [
          Icon(Icons.checklist_outlined,
              size: 48, color: context.colTextHint),
          const SizedBox(height: 12),
          Text('No habits yet',
              style: TextStyle(
                  fontWeight: FontWeight.w700,
                  color: context.colText,
                  fontSize: 16)),
          const SizedBox(height: 6),
          Text('Add your daily habits to start building discipline.',
              textAlign: TextAlign.center,
              style: TextStyle(
                  color: context.colTextSec, fontSize: 13)),
          const SizedBox(height: 20),
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.teal600,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
            ),
            icon: const Icon(Icons.add, size: 16),
            label: const Text('Add First Habit'),
            onPressed: onAdd,
          ),
        ],
      ),
    );
  }
}

class _TipBox extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: context.colTint(AppColors.amber50, AppColors.amber50Dk),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
            color: AppColors.amber400.withValues(alpha: 0.4)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(children: [
            Icon(Icons.lightbulb_outline,
                color: AppColors.amber600, size: 16),
            SizedBox(width: 6),
            Text('How streaks work',
                style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: AppColors.amber600)),
          ]),
          const SizedBox(height: 8),
          Text(
            'Complete ALL habits before midnight to grow your streak. '
            'Missing a day resets it to zero. Consistency is everything.',
            style: TextStyle(
                color: context.colTextSec, fontSize: 12, height: 1.6),
          ),
        ],
      ),
    );
  }
}
