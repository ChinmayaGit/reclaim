import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../shared/constants/app_constants.dart';
import '../domain/discipline_notifier.dart';
import '../data/habit_model.dart';
import 'add_habit_sheet.dart';
import 'habit_icon_avatar.dart';

class DisciplineScreen extends ConsumerWidget {
  const DisciplineScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(disciplineProvider);

    return Scaffold(
      backgroundColor: context.colBackground,
      appBar: AppBar(
        backgroundColor: context.colSurface,
        title: const Text('Daily Discipline'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => showAddHabitSheet(context, ref),
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
            _EmptyState(onAdd: () => showAddHabitSheet(context, ref))
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
                count: state.countFor(habit.id),
                satisfied: state.isHabitSatisfied(habit),
                onTap: () =>
                    ref.read(disciplineProvider.notifier).tapHabit(habit.id),
                onUndo: () => ref
                    .read(disciplineProvider.notifier)
                    .decrementHabit(habit.id),
                onDelete: () =>
                    ref.read(disciplineProvider.notifier).removeHabit(habit.id),
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
}

// ── Widgets ───────────────────────────────────────────────────────────────────

class _ScoreHeader extends StatelessWidget {
  const _ScoreHeader({required this.state});
  final DisciplineState state;

  @override
  Widget build(BuildContext context) {
    final pct = (state.pointsProgress * 100).round();
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
                    Text("Today's performance",
                        style: TextStyle(
                            color: context.colTextSec, fontSize: 12)),
                    const SizedBox(height: 4),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.baseline,
                      textBaseline: TextBaseline.alphabetic,
                      children: [
                        Text(
                          '${state.earnedPointsToday}',
                          style: TextStyle(
                              fontSize: 40,
                              fontWeight: FontWeight.w800,
                              color: context.colText),
                        ),
                        Text(
                          ' / ${state.totalPointsToday}',
                          style: TextStyle(
                              fontSize: 20,
                              color: context.colTextSec),
                        ),
                      ],
                    ),
                    Text('points (by habit difficulty)',
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
                      value: state.pointsProgress,
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
              value: state.pointsProgress,
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
    required this.count,
    required this.satisfied,
    required this.onTap,
    required this.onUndo,
    required this.onDelete,
  });

  final HabitItem habit;
  final int count;
  final bool satisfied;
  final VoidCallback onTap, onUndo, onDelete;

  @override
  Widget build(BuildContext context) {
    final color = Color(habit.colorValue);
    final goal = habit.dailyGoal.clamp(1, 999);
    final subtitle = goal > 1
        ? '$count / $goal today · up to ${habit.pointsWeight} pt'
        : '${habit.pointsWeight} pt · tap for details';
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: satisfied
            ? color.withValues(alpha: 0.1)
            : context.colSurface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
            color: satisfied
                ? color.withValues(alpha: 0.5)
                : context.colBorder,
            width: satisfied ? 1.5 : 1),
      ),
      child: Row(
        children: [
          Expanded(
            child: InkWell(
              borderRadius: BorderRadius.circular(13),
              onTap: () => context.push(
                '${AppConstants.routeHabitDetail}?id=${habit.id}',
              ),
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                child: Row(
                  children: [
                    HabitIconAvatar(habit: habit, done: satisfied, size: 38),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            habit.name,
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 14,
                              color: satisfied ? color : context.colText,
                              decoration: satisfied
                                  ? TextDecoration.lineThrough
                                  : null,
                              decorationColor: color,
                            ),
                          ),
                          Text(
                            subtitle,
                            style: TextStyle(
                              fontSize: 11,
                              color: context.colTextHint,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          IconButton(
            tooltip: satisfied
                ? (goal > 1 ? 'Add another (or long-press to undo)' : 'Undo')
                : (goal > 1 ? 'Log once' : 'Mark done'),
            onPressed: onTap,
            onLongPress: onUndo,
            icon: AnimatedSwitcher(
              duration: const Duration(milliseconds: 200),
              child: satisfied
                  ? Icon(Icons.check_circle,
                      key: const ValueKey('done'),
                      color: color,
                      size: 22)
                  : Icon(Icons.radio_button_unchecked,
                      key: const ValueKey('undone'),
                      color: context.colTextHint,
                      size: 22),
            ),
          ),
          IconButton(
            tooltip: 'Remove habit',
            onPressed: onDelete,
            icon: Icon(Icons.delete_outline,
                size: 20, color: context.colTextHint),
          ),
        ],
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
