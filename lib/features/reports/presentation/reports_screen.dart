import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import '../../../core/providers/core_providers.dart';
import '../../../core/theme/app_colors.dart';
import '../../../features/journal/domain/journal_notifier.dart';
import '../../../features/tracker/domain/tracker_notifier.dart';
import '../../../shared/constants/app_constants.dart';
import '../../../shared/models/journal_model.dart';

class ReportsScreen extends ConsumerWidget {
  const ReportsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isPremium = ref.watch(isPremiumProvider);
    final moodHistory = ref.watch(moodHistoryProvider).value ?? [];
    final tracker = ref.watch(trackerProvider).value;
    final journalEntries = ref.watch(journalEntriesProvider).value ?? [];

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Progress Reports'),
        actions: [
          if (isPremium)
            TextButton.icon(
              onPressed: () => ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Generating PDF report…')),
              ),
              icon: const Icon(Icons.picture_as_pdf_outlined, size: 18),
              label: const Text('Export PDF'),
            ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Stats overview
          _StatsRow(
            streakDays: tracker?.currentStreakDays ?? 0,
            journalCount: journalEntries.length,
            avgMood: _avgMood(moodHistory),
          ),
          const SizedBox(height: 20),

          // Mood chart
          _MoodChart(history: moodHistory),
          const SizedBox(height: 20),

          // Streak history
          if (tracker != null) _StreakSummary(tracker.currentStreakDays, tracker.longestStreak),
          const SizedBox(height: 20),

          // Journal activity
          _JournalActivity(entries: journalEntries),
          const SizedBox(height: 20),

          // Reports / downloads
          _ReportDownloads(isPremium: isPremium),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  double _avgMood(List<MoodCheckin> history) {
    if (history.isEmpty) return 0;
    return history.map((m) => m.moodScore).reduce((a, b) => a + b) / history.length;
  }
}

class _StatsRow extends StatelessWidget {
  const _StatsRow({required this.streakDays, required this.journalCount, required this.avgMood});
  final int streakDays, journalCount;
  final double avgMood;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _StatCard('🔥', '$streakDays', 'Day Streak', AppColors.teal50, AppColors.teal600),
        const SizedBox(width: 10),
        _StatCard('📓', '$journalCount', 'Entries', AppColors.amber50, AppColors.amber600),
        const SizedBox(width: 10),
        _StatCard(
          AppConstants.moodEmojis[avgMood.clamp(1, 5).toInt() - 1],
          avgMood.toStringAsFixed(1),
          'Avg Mood',
          AppColors.purple50,
          AppColors.purple600,
        ),
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard(this.emoji, this.value, this.label, this.bg, this.fg);
  final String emoji, value, label;
  final Color bg, fg;

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
            Text(value, style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: fg)),
            Text(label, style: TextStyle(fontSize: 11, color: fg.withValues(alpha: 0.8))),
          ],
        ),
      ),
    );
  }
}

class _MoodChart extends StatelessWidget {
  const _MoodChart({required this.history});
  final List<MoodCheckin> history;

  @override
  Widget build(BuildContext context) {
    final sorted = [...history]..sort((a, b) => a.checkinDate.compareTo(b.checkinDate));
    final last14 = sorted.length > 14 ? sorted.sublist(sorted.length - 14) : sorted;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Mood Trend (Last 14 days)', style: Theme.of(context).textTheme.headlineSmall),
          const SizedBox(height: 20),
          if (last14.isEmpty)
            const SizedBox(
              height: 100,
              child: Center(child: Text('No mood data yet — check in daily!',
                  style: TextStyle(color: AppColors.textHint))),
            )
          else
            SizedBox(
              height: 160,
              child: LineChart(
                LineChartData(
                  minY: 1, maxY: 5,
                  gridData: FlGridData(
                    show: true,
                    drawVerticalLine: false,
                    horizontalInterval: 1,
                    getDrawingHorizontalLine: (_) => FlLine(
                      color: AppColors.border, strokeWidth: 1,
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
                          AppConstants.moodEmojis[v.toInt() - 1],
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
                          if (idx < 0 || idx >= last14.length) return const SizedBox();
                          return Text(
                            DateFormat('d/M').format(last14[idx].checkinDate),
                            style: const TextStyle(fontSize: 9, color: AppColors.textHint),
                          );
                        },
                      ),
                    ),
                    topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  ),
                  lineBarsData: [
                    LineChartBarData(
                      spots: last14.asMap().entries.map((e) =>
                          FlSpot(e.key.toDouble(), e.value.moodScore.toDouble())).toList(),
                      isCurved: true,
                      color: AppColors.teal400,
                      barWidth: 2.5,
                      belowBarData: BarAreaData(
                        show: true,
                        color: AppColors.teal400.withValues(alpha: 0.1),
                      ),
                      dotData: FlDotData(
                        show: true,
                        getDotPainter: (_, __, ___, ____) => FlDotCirclePainter(
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

class _StreakSummary extends StatelessWidget {
  const _StreakSummary(this.current, this.longest);
  final int current, longest;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Streak Summary', style: Theme.of(context).textTheme.headlineSmall),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.teal50,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Column(
                    children: [
                      Text('$current', style: const TextStyle(fontSize: 32, fontWeight: FontWeight.w700, color: AppColors.teal600)),
                      const Text('Current', style: TextStyle(fontSize: 12, color: AppColors.teal600)),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.amber50,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Column(
                    children: [
                      Text('$longest', style: const TextStyle(fontSize: 32, fontWeight: FontWeight.w700, color: AppColors.amber600)),
                      const Text('Best Ever', style: TextStyle(fontSize: 12, color: AppColors.amber600)),
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

class _JournalActivity extends StatelessWidget {
  const _JournalActivity({required this.entries});
  final List entries;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Journal Activity', style: Theme.of(context).textTheme.headlineSmall),
          const SizedBox(height: 12),
          Row(
            children: [
              const Icon(Icons.book_outlined, color: AppColors.amber400),
              const SizedBox(width: 10),
              Text('${entries.length} total entries written',
                  style: const TextStyle(fontWeight: FontWeight.w500)),
            ],
          ),
          const SizedBox(height: 8),
          LinearProgressIndicator(
            value: (entries.length / 30).clamp(0.0, 1.0),
            backgroundColor: AppColors.slate100,
            color: AppColors.amber400,
            borderRadius: BorderRadius.circular(4),
            minHeight: 8,
          ),
          const SizedBox(height: 6),
          Text('${entries.length}/30 entries this month',
              style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
        ],
      ),
    );
  }
}

class _ReportDownloads extends StatelessWidget {
  const _ReportDownloads({required this.isPremium});
  final bool isPremium;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Download Reports', style: Theme.of(context).textTheme.headlineSmall),
          const SizedBox(height: 14),
          _buildDownloadRow('📊 Weekly Progress Report', 'PDF', isPremium, context),
          _buildDownloadRow('📓 Journal Export', 'PDF / CSV', isPremium, context),
          _buildDownloadRow('🏆 Achievement Certificate', 'PDF', isPremium, context),
          _buildDownloadRow('💾 Full Data Export (GDPR)', 'ZIP', true, context),
        ],
      ),
    );
  }

  Widget _buildDownloadRow(String title, String format, bool available, BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: available ? AppColors.slate50 : AppColors.amber50.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: available ? AppColors.border : AppColors.amber100),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 13)),
                Text(format, style: const TextStyle(fontSize: 11, color: AppColors.textHint)),
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
