import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../shared/models/tracker_model.dart';

class StreakCard extends StatelessWidget {
  const StreakCard({super.key, required this.tracker, this.onCheckIn});

  final TrackerModel tracker;
  final VoidCallback? onCheckIn;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final checkedIn = tracker.checkedInToday;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.teal600, AppColors.teal400],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.teal400.withValues(alpha: 0.3),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.local_fire_department, color: Colors.white, size: 22),
              const SizedBox(width: 8),
              Text(
                'Recovery Streak',
                style: theme.textTheme.labelLarge?.copyWith(color: Colors.white70),
              ),
              const Spacer(),
              if (checkedIn)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Text(
                    '✓ Checked in',
                    style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w600),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 12),
          RichText(
            text: TextSpan(
              children: [
                TextSpan(
                  text: '${tracker.currentStreakDays}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 48,
                    fontWeight: FontWeight.w700,
                    height: 1,
                  ),
                ),
                const TextSpan(
                  text: ' days',
                  style: TextStyle(color: Colors.white70, fontSize: 18),
                ),
              ],
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Best: ${tracker.longestStreak} days',
            style: const TextStyle(color: Colors.white60, fontSize: 12),
          ),
          if (!checkedIn) ...[
            const SizedBox(height: 14),
            GestureDetector(
              onTap: onCheckIn,
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Text(
                  'Check In Today',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: AppColors.teal600,
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
