import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/providers/core_providers.dart';
import '../../../core/theme/app_colors.dart';

class AdminScreen extends ConsumerWidget {
  const AdminScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isAdmin = ref.watch(isAdminProvider);
    if (!isAdmin) {
      return Scaffold(
        appBar: AppBar(title: const Text('Admin')),
        body: const Center(child: Text('Access denied.')),
      );
    }

    return DefaultTabController(
      length: 4,
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          title: const Text('Admin Panel'),
          bottom: const TabBar(
            isScrollable: true,
            tabs: [
              Tab(text: 'Users'),
              Tab(text: 'Content'),
              Tab(text: 'Moderation'),
              Tab(text: 'Analytics'),
            ],
          ),
        ),
        body: const TabBarView(
          children: [
            _UsersTab(),
            _ContentTab(),
            _ModerationTab(),
            _AnalyticsTab(),
          ],
        ),
      ),
    );
  }
}

class _UsersTab extends StatelessWidget {
  const _UsersTab();

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _AdminStatRow(),
        const SizedBox(height: 20),
        Text('Recent Users', style: Theme.of(context).textTheme.headlineSmall),
        const SizedBox(height: 12),
        ..._mockUsers.map((u) => _UserRow(user: u)),
      ],
    );
  }
}

class _AdminStatRow extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      childAspectRatio: 2,
      children: const [
        _AdminStat('Total Users', '12,408', Icons.people, AppColors.teal50, AppColors.teal600),
        _AdminStat('Premium', '3,241', Icons.star, AppColors.amber50, AppColors.amber600),
        _AdminStat('Counselors', '47', Icons.psychology, AppColors.purple50, AppColors.purple600),
        _AdminStat('Active Today', '891', Icons.trending_up, AppColors.green50, AppColors.green600),
      ],
    );
  }
}

class _AdminStat extends StatelessWidget {
  const _AdminStat(this.label, this.value, this.icon, this.bg, this.fg);
  final String label, value;
  final IconData icon;
  final Color bg, fg;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: fg.withValues(alpha: 0.2)),
      ),
      child: Row(
        children: [
          Icon(icon, color: fg, size: 22),
          const SizedBox(width: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(value, style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: fg)),
              Text(label, style: TextStyle(fontSize: 10, color: fg.withValues(alpha: 0.8))),
            ],
          ),
        ],
      ),
    );
  }
}

const _mockUsers = [
  _AdminUser('Aanya Gupta', 'aanya@email.com', 'premium', true),
  _AdminUser('Rahul Verma', 'rahul@email.com', 'free', true),
  _AdminUser('Dr. Priya Nair', 'priya@clinic.com', 'counselor', true),
  _AdminUser('Meera Singh', 'meera@email.com', 'free', false),
];

class _AdminUser {
  const _AdminUser(this.name, this.email, this.role, this.active);
  final String name, email, role;
  final bool active;
}

class _UserRow extends StatelessWidget {
  const _UserRow({required this.user});
  final _AdminUser user;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: AppColors.teal50,
            child: Text(user.name[0], style: const TextStyle(color: AppColors.teal600, fontWeight: FontWeight.w700)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(user.name, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                Text(user.email, style: const TextStyle(fontSize: 11, color: AppColors.textSecondary)),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              _RoleBadge(user.role),
              const SizedBox(height: 4),
              Container(
                width: 8, height: 8,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: user.active ? AppColors.green400 : AppColors.slate400,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _RoleBadge extends StatelessWidget {
  const _RoleBadge(this.role);
  final String role;

  @override
  Widget build(BuildContext context) {
    Color bg, fg;
    switch (role) {
      case 'premium': bg = AppColors.amber50; fg = AppColors.amber600; break;
      case 'counselor': bg = AppColors.purple50; fg = AppColors.purple600; break;
      case 'admin': bg = AppColors.coral50; fg = AppColors.coral600; break;
      default: bg = AppColors.slate100; fg = AppColors.slate600;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(4)),
      child: Text(role.toUpperCase(),
          style: TextStyle(fontSize: 9, fontWeight: FontWeight.w700, color: fg)),
    );
  }
}

class _ContentTab extends StatelessWidget {
  const _ContentTab();

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        ElevatedButton.icon(
          onPressed: () {},
          icon: const Icon(Icons.add),
          label: const Text('Add New Resource'),
        ),
        const SizedBox(height: 20),
        Text('Published Resources', style: Theme.of(context).textTheme.headlineSmall),
        const SizedBox(height: 12),
        ...['Understanding Triggers (Article)', 'Morning Meditation (Audio)', 'Recovery Stories (Video)']
            .map((r) => ListTile(
                  title: Text(r),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(onPressed: () {}, icon: const Icon(Icons.edit_outlined, size: 18)),
                      IconButton(onPressed: () {}, icon: const Icon(Icons.delete_outline, size: 18, color: AppColors.coral400)),
                    ],
                  ),
                )),
      ],
    );
  }
}

class _ModerationTab extends StatelessWidget {
  const _ModerationTab();

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: AppColors.coral50,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.coral100),
          ),
          child: const Row(
            children: [
              Icon(Icons.flag, color: AppColors.coral600),
              SizedBox(width: 10),
              Text('3 posts flagged for review',
                  style: TextStyle(color: AppColors.coral600, fontWeight: FontWeight.w600)),
            ],
          ),
        ),
        const SizedBox(height: 16),
        ...['Post #1423: Flagged by 2 users', 'Post #1401: Flagged by 1 user', 'Post #1388: Flagged by 3 users']
            .map((p) => Card(
                  margin: const EdgeInsets.only(bottom: 10),
                  child: ListTile(
                    title: Text(p),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        TextButton(onPressed: () {}, child: const Text('Keep')),
                        TextButton(
                          onPressed: () {},
                          child: const Text('Remove', style: TextStyle(color: AppColors.coral600)),
                        ),
                      ],
                    ),
                  ),
                )),
      ],
    );
  }
}

class _AnalyticsTab extends StatelessWidget {
  const _AnalyticsTab();

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text('Platform Analytics', style: Theme.of(context).textTheme.headlineSmall),
        const SizedBox(height: 16),
        ...[
          ('Daily Active Users', '891', '+12% vs last week'),
          ('New Signups (Today)', '47', '+5% vs yesterday'),
          ('Check-ins Today', '634', '71% of DAU'),
          ('Journal Entries (Today)', '1,203', 'Avg 1.3/user'),
          ('Premium Conversion Rate', '26.1%', '+2.3% this month'),
          ('Avg Session Length', '8m 42s', '-30s vs last week'),
        ].map((stat) => Container(
              margin: const EdgeInsets.only(bottom: 10),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.border),
              ),
              child: Row(
                children: [
                  Expanded(child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(stat.$1, style: const TextStyle(fontSize: 13, color: AppColors.textSecondary)),
                      Text(stat.$2, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w700)),
                    ],
                  )),
                  Text(stat.$3, style: const TextStyle(fontSize: 12, color: AppColors.green600, fontWeight: FontWeight.w500)),
                ],
              ),
            )),
      ],
    );
  }
}
