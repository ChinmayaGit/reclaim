import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';

import '../../../core/providers/core_providers.dart';
import '../../../core/theme/app_colors.dart';
import '../../../shared/constants/app_constants.dart';
import '../../../shared/models/journal_model.dart';
import '../../journal/domain/journal_notifier.dart';
import '../../tracker/domain/tracker_notifier.dart';

double _avgMood(List<MoodCheckin> history) {
  if (history.isEmpty) return 0;
  return history.map((m) => m.moodScore).reduce((a, b) => a + b) /
      history.length;
}

/// Former Progress Reports content — embedded in Your day below check-in.
class DayRecapProgressSection extends ConsumerWidget {
  const DayRecapProgressSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isPremium = ref.watch(isPremiumProvider);
    final moodHistory = ref.watch(moodHistoryProvider).value ?? [];
    final tracker = ref.watch(trackerProvider).value;
    final journalEntries = ref.watch(journalEntriesProvider).value ?? [];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _DayRecapStatsRow(
          streakDays: tracker?.currentStreakDays ?? 0,
          journalCount: journalEntries.length,
          avgMood: _avgMood(moodHistory),
        ),
        const SizedBox(height: 20),
        _DayRecapMoodChart(history: moodHistory),
        const SizedBox(height: 20),
        if (tracker != null)
          _DayRecapStreakSummary(tracker.currentStreakDays, tracker.longestStreak),
        if (tracker != null) const SizedBox(height: 20),
        _DayRecapJournalActivity(entries: journalEntries),
        const SizedBox(height: 20),
        _DayRecapReportDownloads(isPremium: isPremium),
      ],
    );
  }
}

class _DayRecapStatsRow extends StatelessWidget {
  const _DayRecapStatsRow({
    required this.streakDays,
    required this.journalCount,
    required this.avgMood,
  });

  final int streakDays;
  final int journalCount;
  final double avgMood;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _DayRecapStatCard(
          '🔥',
          '$streakDays',
          'Day Streak',
          context.colTint(AppColors.teal50, AppColors.teal50Dk),
          AppColors.teal600,
        ),
        const SizedBox(width: 10),
        _DayRecapStatCard(
          '📓',
          '$journalCount',
          'Entries',
          context.colTint(AppColors.amber50, AppColors.amber50Dk),
          AppColors.amber600,
        ),
        const SizedBox(width: 10),
        _DayRecapStatCard(
          AppConstants.moodEmojis[avgMood.clamp(1, 5).toInt() - 1],
          avgMood.toStringAsFixed(1),
          'Avg Mood',
          context.colTint(AppColors.purple50, AppColors.purple50Dk),
          AppColors.purple600,
        ),
      ],
    );
  }
}

class _DayRecapStatCard extends StatelessWidget {
  const _DayRecapStatCard(this.emoji, this.value, this.label, this.bg, this.fg);

  final String emoji;
  final String value;
  final String label;
  final Color bg;
  final Color fg;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: fg.withValues(alpha: 0.2)),
        ),
        child: Column(
          children: [
            Text(emoji, style: const TextStyle(fontSize: 22)),
            const SizedBox(height: 4),
            Text(
              value,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: fg,
              ),
            ),
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                color: fg.withValues(alpha: 0.85),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DayRecapMoodChart extends StatelessWidget {
  const _DayRecapMoodChart({required this.history});

  final List<MoodCheckin> history;

  @override
  Widget build(BuildContext context) {
    final sorted = [...history]..sort((a, b) => a.checkinDate.compareTo(b.checkinDate));
    final last14 = sorted.length > 14 ? sorted.sublist(sorted.length - 14) : sorted;
    final border = context.colBorder;
    final hint = context.colTextHint;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: context.colSurface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Mood trend (last 14 days)',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: context.colText,
                ),
          ),
          const SizedBox(height: 20),
          if (last14.isEmpty)
            SizedBox(
              height: 100,
              child: Center(
                child: Text(
                  'No mood data yet — check in daily!',
                  style: TextStyle(color: hint),
                ),
              ),
            )
          else
            SizedBox(
              height: 160,
              child: LineChart(
                LineChartData(
                  minY: 1,
                  maxY: 5,
                  gridData: FlGridData(
                    show: true,
                    drawVerticalLine: false,
                    horizontalInterval: 1,
                    getDrawingHorizontalLine: (_) => FlLine(
                      color: border,
                      strokeWidth: 1,
                    ),
                  ),
                  borderData: FlBorderData(show: false),
                  titlesData: FlTitlesData(
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        interval: 1,
                        reservedSize: 28,
                        getTitlesWidget: (v, _) => Text(
                          AppConstants.moodEmojis[(v.toInt() - 1).clamp(0, 4)],
                          style: const TextStyle(fontSize: 12),
                        ),
                      ),
                    ),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        interval: 2,
                        getTitlesWidget: (v, _) {
                          final idx = v.toInt();
                          if (idx < 0 || idx >= last14.length) {
                            return const SizedBox();
                          }
                          return Text(
                            DateFormat('d/M').format(last14[idx].checkinDate),
                            style: TextStyle(fontSize: 9, color: hint),
                          );
                        },
                      ),
                    ),
                    topTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    rightTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                  ),
                  lineBarsData: [
                    LineChartBarData(
                      spots: last14
                          .asMap()
                          .entries
                          .map((e) => FlSpot(
                                e.key.toDouble(),
                                e.value.moodScore.toDouble(),
                              ))
                          .toList(),
                      isCurved: true,
                      color: AppColors.teal400,
                      barWidth: 2.5,
                      belowBarData: BarAreaData(
                        show: true,
                        color: AppColors.teal400.withValues(alpha: 0.1),
                      ),
                      dotData: FlDotData(
                        show: true,
                        getDotPainter: (_, __, ___, ____) =>
                            FlDotCirclePainter(
                          radius: 3,
                          color: AppColors.teal400,
                          strokeWidth: 0,
                        ),
                      ),
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

class _DayRecapStreakSummary extends StatelessWidget {
  const _DayRecapStreakSummary(this.current, this.longest);

  final int current;
  final int longest;

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
          Text(
            'Streak summary',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: context.colText,
                ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: context.colTint(AppColors.teal50, AppColors.teal50Dk),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Column(
                    children: [
                      Text(
                        '$current',
                        style: const TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.w700,
                          color: AppColors.teal600,
                        ),
                      ),
                      const Text(
                        'Current',
                        style: TextStyle(fontSize: 12, color: AppColors.teal600),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color:
                        context.colTint(AppColors.amber50, AppColors.amber50Dk),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Column(
                    children: [
                      Text(
                        '$longest',
                        style: const TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.w700,
                          color: AppColors.amber600,
                        ),
                      ),
                      const Text(
                        'Best ever',
                        style: TextStyle(fontSize: 12, color: AppColors.amber600),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _DayRecapJournalActivity extends StatelessWidget {
  const _DayRecapJournalActivity({required this.entries});

  final List<JournalEntry> entries;

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
          Text(
            'Journal activity',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: context.colText,
                ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              const Icon(Icons.book_outlined, color: AppColors.amber400),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  '${entries.length} total entries written',
                  style: TextStyle(
                    fontWeight: FontWeight.w500,
                    color: context.colText,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: (entries.length / 30).clamp(0.0, 1.0),
              backgroundColor:
                  context.colTint(AppColors.slate100, AppColors.slate100Dk),
              color: AppColors.amber400,
              minHeight: 8,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            '${entries.length}/30 entries this month',
            style: TextStyle(fontSize: 12, color: context.colTextSec),
          ),
        ],
      ),
    );
  }
}

class _DayRecapReportDownloads extends StatelessWidget {
  const _DayRecapReportDownloads({required this.isPremium});

  final bool isPremium;

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
          Text(
            'Download reports',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: context.colText,
                ),
          ),
          const SizedBox(height: 14),
          _buildDownloadRow(
            context,
            '📊 Weekly progress report',
            'PDF',
            isPremium,
          ),
          _buildDownloadRow(
            context,
            '📓 Journal export',
            'PDF / CSV',
            isPremium,
          ),
          _buildDownloadRow(
            context,
            '🏆 Achievement certificate',
            'PDF',
            isPremium,
          ),
          _buildDownloadRow(
            context,
            '💾 Full data export (GDPR)',
            'ZIP',
            true,
          ),
        ],
      ),
    );
  }

  Widget _buildDownloadRow(
    BuildContext context,
    String title,
    String format,
    bool available,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: available
            ? context.colTint(AppColors.slate50, AppColors.slate50Dk)
            : context.colTint(AppColors.amber50, AppColors.amber50Dk),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: available ? context.colBorder : AppColors.amber100,
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontWeight: FontWeight.w500,
                    fontSize: 13,
                    color: context.colText,
                  ),
                ),
                Text(
                  format,
                  style: TextStyle(fontSize: 11, color: context.colTextHint),
                ),
              ],
            ),
          ),
          if (!available)
            const Icon(Icons.lock, size: 16, color: AppColors.amber600)
          else
            TextButton(
              onPressed: () => ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Generating $title…')),
              ),
              child: const Text('Download'),
            ),
        ],
      ),
    );
  }
}
