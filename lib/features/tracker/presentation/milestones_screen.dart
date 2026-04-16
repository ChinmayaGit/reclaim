import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../domain/tracker_notifier.dart';
import '../../../core/theme/app_colors.dart';
import '../../../shared/constants/app_constants.dart';

class MilestonesScreen extends ConsumerWidget {
  const MilestonesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tracker = ref.watch(trackerProvider).value;
    final earned = tracker?.milestones ?? [];
    final streakDays = tracker?.currentStreakDays ?? 0;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('Milestones')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [AppColors.amber600, AppColors.amber400],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('🏆 Your Milestones',
                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 18)),
                const SizedBox(height: 6),
                Text(
                  '${earned.length} of ${AppConstants.milestoneDays.length} earned',
                  style: const TextStyle(color: Colors.white70, fontSize: 13),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          ...AppConstants.milestoneDays.map((days) {
            final label = '${days}d';
            final isEarned = earned.contains(label);
            final isNext = !isEarned && streakDays < days;
            final daysLeft = days - streakDays;

            return _MilestoneTile(
              days: days,
              isEarned: isEarned,
              isNext: isNext && daysLeft <= 14,
              daysLeft: daysLeft,
            );
          }),
          const SizedBox(height: 40),
        ],
      ),
    );
  }
}

class _MilestoneTile extends StatelessWidget {
  const _MilestoneTile({
    required this.days,
    required this.isEarned,
    required this.isNext,
    required this.daysLeft,
  });

  final int days;
  final bool isEarned;
  final bool isNext;
  final int daysLeft;

  String get _emoji {
    if (days >= 365) return '🌟';
    if (days >= 180) return '💎';
    if (days >= 90) return '🥇';
    if (days >= 30) return '🎖';
    if (days >= 7) return '🏅';
    return '⭐';
  }

  String get _label {
    if (days >= 365) return '${days ~/ 365} Year${days ~/ 365 > 1 ? 's' : ''}';
    if (days >= 30) return '${days ~/ 30} Month${days ~/ 30 > 1 ? 's' : ''}';
    return '$days Days';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isEarned
            ? AppColors.amber50
            : isNext
                ? AppColors.teal50
                : AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isEarned
              ? AppColors.amber400
              : isNext
                  ? AppColors.teal400
                  : AppColors.border,
          width: isEarned || isNext ? 2 : 1,
        ),
      ),
      child: Row(
        children: [
          Text(
            isEarned ? _emoji : '🔒',
            style: TextStyle(fontSize: isEarned ? 28 : 22),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _label,
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 15,
                    color: isEarned ? AppColors.amber900 : AppColors.textPrimary,
                  ),
                ),
                Text(
                  isEarned
                      ? 'Earned! ✓'
                      : isNext
                          ? '$daysLeft more days to go'
                          : '$daysLeft days remaining',
                  style: TextStyle(
                    fontSize: 12,
                    color: isEarned
                        ? AppColors.amber600
                        : AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          if (isEarned)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.amber400,
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Text('EARNED',
                  style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w700)),
            ),
        ],
      ),
    );
  }
}
