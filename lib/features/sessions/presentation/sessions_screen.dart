import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/providers/core_providers.dart';
import '../../../core/theme/app_colors.dart';

class SessionsScreen extends ConsumerWidget {
  const SessionsScreen({super.key});

  static const _counselors = [
    _Counselor('Dr. Priya Nair', 'Clinical Psychologist', 'Addiction & Trauma', '⭐ 4.9', 'therapist', AppColors.purple50, AppColors.purple400),
    _Counselor('Rohan Mehta', 'Certified Peer Counselor', 'Heartbreak & Grief', '⭐ 4.8', 'peer', AppColors.teal50, AppColors.teal400),
    _Counselor('Sarah Chen', 'Trauma Therapist', 'PTSD & Trauma', '⭐ 4.9', 'therapist', AppColors.coral50, AppColors.coral400),
    _Counselor('Arjun Sharma', 'Recovery Coach', 'Addiction & Relapse', '⭐ 4.7', 'peer', AppColors.amber50, AppColors.amber400),
    _Counselor('Dr. Maya Singh', 'Psychiatrist', 'Anxiety & Depression', '⭐ 5.0', 'therapist', AppColors.green50, AppColors.green400),
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isPremium = ref.watch(isPremiumProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('Therapy Sessions')),
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (!isPremium) _UpgradeBanner(),
                  const SizedBox(height: 6),
                  _UpcomingSession(),
                  const SizedBox(height: 20),
                  Text('Our Counselors', style: Theme.of(context).textTheme.headlineSmall),
                  const SizedBox(height: 4),
                  Text('Licensed professionals & trained peer supporters.',
                      style: Theme.of(context).textTheme.bodyMedium),
                  const SizedBox(height: 14),
                ],
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate(
                (ctx, i) => _CounselorCard(counselor: _counselors[i], isPremium: isPremium),
                childCount: _counselors.length,
              ),
            ),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 40)),
        ],
      ),
    );
  }
}

class _UpgradeBanner extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.purple900, AppColors.purple600],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          const Text('🔒', style: TextStyle(fontSize: 26)),
          const SizedBox(width: 12),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Premium Feature', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 14)),
                Text('Upgrade to book 1-on-1 therapy and video sessions.',
                    style: TextStyle(color: Colors.white70, fontSize: 12)),
              ],
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: AppColors.purple600,
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              minimumSize: Size.zero,
            ),
            onPressed: () {},
            child: const Text('Upgrade', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );
  }
}

class _UpcomingSession extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.teal50,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.teal100),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.teal400,
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.video_call, color: Colors.white, size: 22),
          ),
          const SizedBox(width: 14),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('No upcoming sessions', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                Text('Book a session with a counselor below.',
                    style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Counselor {
  const _Counselor(this.name, this.title, this.specialty, this.rating, this.type, this.bg, this.accent);
  final String name, title, specialty, rating, type;
  final Color bg, accent;
}

class _CounselorCard extends StatelessWidget {
  const _CounselorCard({required this.counselor, required this.isPremium});
  final _Counselor counselor;
  final bool isPremium;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Container(
            width: 52, height: 52,
            decoration: BoxDecoration(
              color: counselor.bg,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: counselor.accent.withValues(alpha: 0.4)),
            ),
            child: Center(
              child: Text(
                counselor.name.split(' ').first[0] + (counselor.name.split(' ').length > 1 ? counselor.name.split(' ').last[0] : ''),
                style: TextStyle(color: counselor.accent, fontSize: 18, fontWeight: FontWeight.w700),
              ),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(counselor.name, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                Text(counselor.title, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                      decoration: BoxDecoration(
                        color: counselor.bg,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(counselor.specialty,
                          style: TextStyle(fontSize: 10, color: counselor.accent, fontWeight: FontWeight.w500)),
                    ),
                    const SizedBox(width: 8),
                    Text(counselor.rating, style: const TextStyle(fontSize: 11, color: AppColors.textSecondary)),
                  ],
                ),
              ],
            ),
          ),
          Column(
            children: [
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: isPremium ? counselor.accent : AppColors.slate200,
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  minimumSize: Size.zero,
                ),
                onPressed: isPremium ? () => _bookSession(context, counselor) : null,
                child: Text(
                  'Book',
                  style: TextStyle(
                    fontSize: 12,
                    color: isPremium ? Colors.white : AppColors.textHint,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _bookSession(BuildContext context, _Counselor c) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Book with ${c.name}'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Select session type:'),
            const SizedBox(height: 14),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _SessionTypeBtn(icon: Icons.video_call, label: 'Video'),
                _SessionTypeBtn(icon: Icons.chat_bubble_outline, label: 'Chat'),
              ],
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
        ],
      ),
    );
  }
}

class _SessionTypeBtn extends StatelessWidget {
  const _SessionTypeBtn({required this.icon, required this.label});
  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('$label session booked!')),
        );
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        decoration: BoxDecoration(
          color: AppColors.teal50,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.teal400),
        ),
        child: Column(
          children: [
            Icon(icon, color: AppColors.teal600),
            const SizedBox(height: 4),
            Text(label, style: const TextStyle(color: AppColors.teal600, fontWeight: FontWeight.w600)),
          ],
        ),
      ),
    );
  }
}
