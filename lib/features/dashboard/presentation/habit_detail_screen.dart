import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_colors.dart';
import '../../../shared/constants/app_constants.dart';
import '../../discipline/data/habit_model.dart';
import '../../discipline/domain/discipline_notifier.dart';
import '../../discipline/presentation/habit_icon_avatar.dart';

String _difficultyLabel(int points) => switch (points) {
      1 => 'Easy',
      2 => 'Medium',
      3 => 'Hard',
      5 => 'Expert',
      _ => '$points points',
    };

/// Detail view for one habit — opened from dashboard or discipline list.
class HabitDetailScreen extends ConsumerWidget {
  const HabitDetailScreen({super.key, required this.habitId});

  final String habitId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(disciplineProvider);
    HabitItem? found;
    for (final x in state.habits) {
      if (x.id == habitId) {
        found = x;
        break;
      }
    }

    if (found == null) {
      return Scaffold(
        backgroundColor: context.colBackground,
        appBar: AppBar(
          backgroundColor: context.colSurface,
          title: const Text('Habit'),
        ),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.search_off, size: 48, color: context.colTextHint),
                const SizedBox(height: 12),
                Text(
                  'This habit is no longer on your list.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: context.colTextSec),
                ),
                const SizedBox(height: 20),
                FilledButton(
                  onPressed: () => context.pop(),
                  child: const Text('Go back'),
                ),
              ],
            ),
          ),
        ),
      );
    }

    final habit = found;
    final count = state.countFor(habit.id);
    final goal = habit.dailyGoal.clamp(1, 999);
    final satisfied = state.isHabitSatisfied(habit);
    final color = Color(habit.colorValue);
    final statusLabel = goal > 1
        ? (satisfied ? 'Goal met ($goal/$goal)' : '$count / $goal today')
        : (satisfied ? 'Done today' : 'Not done yet');

    return Scaffold(
      backgroundColor: context.colBackground,
      appBar: AppBar(
        backgroundColor: context.colSurface,
        title: const Text('Habit details'),
        actions: [
          TextButton(
            onPressed: () =>
                context.push(AppConstants.routeDiscipline),
            child: const Text('Full list'),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: context.colSurface,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: context.colBorder),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 72,
                  height: 72,
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: Center(
                    child: HabitIconAvatar(
                      habit: habit,
                      size: 56,
                      done: satisfied,
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        habit.name,
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.w800,
                            ),
                      ),
                      const SizedBox(height: 8),
                      _StatusChip(
                        label: statusLabel,
                        highlight: satisfied,
                        color: color,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          Text(
            'About this habit',
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
          ),
          const SizedBox(height: 10),
          _InfoTile(
            icon: Icons.stars_outlined,
            title: 'Points & difficulty',
            body: goal > 1
                ? 'You can log up to $goal times today. When the goal is fully met you earn '
                    '${habit.pointsWeight} point(s) toward today’s score (partial credit along the way). '
                    'Difficulty band: ${_difficultyLabel(habit.pointsWeight)}.'
                : 'Completing this habit earns ${habit.pointsWeight} point(s) toward today’s score. '
                    'Difficulty band: ${_difficultyLabel(habit.pointsWeight)}.',
          ),
          if (habit.reminderEnabled) ...[
            const SizedBox(height: 12),
            _InfoTile(
              icon: Icons.notifications_active_outlined,
              title: 'Reminder',
              body:
                  'Daily alert at ${habit.reminderHour.toString().padLeft(2, '0')}:'
                  '${habit.reminderMinute.toString().padLeft(2, '0')}.',
            ),
          ],
          const SizedBox(height: 12),
          _InfoTile(
            icon: Icons.local_fire_department_outlined,
            title: 'Streak',
            body: state.streak > 0
                ? 'Your current discipline streak is ${state.streak} day(s). '
                    'You need every habit’s daily goal met before midnight to grow it.'
                : 'Meet every habit’s goal today to start a streak.',
          ),
          const SizedBox(height: 12),
          _InfoTile(
            icon: Icons.today_outlined,
            title: 'Today',
            body: satisfied
                ? (goal > 1
                    ? 'You hit today’s target — great consistency. Long-press the check '
                        'on Home / Discipline to step back one log if you tapped by mistake.'
                    : 'Marked done for today — nice work. Tap the action below or the '
                        'check on Home / Discipline to undo.')
                : (goal > 1
                    ? 'Tap Log once each time you complete this habit (e.g. another glass of water). '
                        'Long-press the check on the dashboard row to undo the last log.'
                    : 'Not completed yet today. Use Log below or the check on the dashboard '
                        'when you finish.'),
          ),
          const SizedBox(height: 24),
          FilledButton.icon(
            onPressed: (satisfied && goal > 1)
                ? null
                : () async {
                    await ref
                        .read(disciplineProvider.notifier)
                        .tapHabit(habit.id);
                  },
            icon: Icon(satisfied && goal == 1 ? Icons.undo : Icons.add_task),
            label: Text(
              satisfied && goal == 1
                  ? 'Undo for today'
                  : (goal > 1
                      ? (satisfied ? 'Today’s goal met' : 'Log once')
                      : 'Mark done for today'),
            ),
          ),
          const SizedBox(height: 10),
          OutlinedButton.icon(
            onPressed: count <= 0
                ? null
                : () async {
                    await ref
                        .read(disciplineProvider.notifier)
                        .decrementHabit(habit.id);
                  },
            icon: const Icon(Icons.remove_circle_outline),
            label: const Text('Undo last log'),
          ),
          const SizedBox(height: 12),
          OutlinedButton.icon(
            onPressed: () => context.push(AppConstants.routeDiscipline),
            icon: const Icon(Icons.checklist_outlined),
            label: const Text('Open daily checklist'),
          ),
        ],
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  const _StatusChip({
    required this.label,
    required this.highlight,
    required this.color,
  });

  final String label;
  final bool highlight;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: highlight ? color.withValues(alpha: 0.15) : context.colTint(
            AppColors.slate100, AppColors.slate100Dk),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: highlight ? color.withValues(alpha: 0.5) : context.colBorder,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            highlight ? Icons.check_circle : Icons.pending_outlined,
            size: 18,
            color: highlight ? color : context.colTextSec,
          ),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 13,
              color: highlight ? color : context.colTextSec,
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoTile extends StatelessWidget {
  const _InfoTile({
    required this.icon,
    required this.title,
    required this.body,
  });

  final IconData icon;
  final String title;
  final String body;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: context.colSurface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: context.colBorder),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: AppColors.teal600, size: 22),
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
                const SizedBox(height: 6),
                Text(
                  body,
                  style: TextStyle(
                    fontSize: 13,
                    height: 1.45,
                    color: context.colTextSec,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
