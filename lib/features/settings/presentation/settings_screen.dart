import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/providers/core_providers.dart';
import '../../../core/providers/theme_provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../features/auth/domain/auth_notifier.dart';
import '../../../shared/constants/app_constants.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(userProfileProvider).value;
    final themeMode = ref.watch(themeModeProvider);
    final isDark = themeMode == ThemeMode.dark ||
        (themeMode == ThemeMode.system &&
            MediaQuery.platformBrightnessOf(context) == Brightness.dark);

    return Scaffold(
      backgroundColor: context.colBackground,
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        children: [
          // Profile section
          _ProfileHeader(
            name: user?.displayName ?? 'User',
            email: user?.email ?? '',
            role: user?.role ?? 'free',
          ),

          const _SectionHeader('Account'),
          _SettingsTile(icon: Icons.person_outline, title: 'Edit Profile', onTap: () {}),
          _SettingsTile(icon: Icons.lock_outline, title: 'Change Password', onTap: () {}),
          _SettingsTile(icon: Icons.contact_emergency_outlined, title: 'Emergency Contacts', onTap: () {}),
          _SettingsTile(icon: Icons.verified_user_outlined, title: 'Two-Factor Authentication', onTap: () {}),

          const _SectionHeader('Appearance'),
          _SettingsTileSwitch(
            icon: Icons.dark_mode_outlined,
            title: 'Dark Mode',
            subtitle: 'Easier on the eyes at night',
            value: isDark,
            onChanged: (v) => ref.read(themeModeProvider.notifier)
                .setMode(v ? ThemeMode.dark : ThemeMode.light),
          ),

          const _SectionHeader('Support Reclaim'),
          _SettingsTile(
            icon: Icons.favorite_outline,
            title: 'Donate — Keep Reclaim Free',
            subtitle: 'No ads, no paywalls — just your support',
            color: AppColors.coral600,
            onTap: () => context.push(AppConstants.routeDonation),
          ),
          _SettingsTile(
            icon: Icons.star_rate_outlined,
            title: 'Rate the App',
            subtitle: 'Help others find Reclaim',
            onTap: () {},
          ),

          const _SectionHeader('Focus & Block'),
          _SettingsTile(
            icon: Icons.shield_moon_outlined,
            title: 'App Limiter & Site Blocker',
            subtitle: 'Track app usage, schedules, and block trigger sites',
            color: AppColors.teal600,
            onTap: () => context.push(AppConstants.routeFocus),
          ),

          const _SectionHeader('Notifications'),
          _SettingsTile(icon: Icons.notifications_outlined, title: 'Notification Preferences', onTap: () {}),
          _SettingsTile(icon: Icons.bedtime_outlined, title: 'Quiet Hours', onTap: () {}),

          const _SectionHeader('Privacy & Data'),
          _SettingsTile(icon: Icons.shield_outlined, title: 'Privacy Settings', onTap: () {}),
          _SettingsTile(
            icon: Icons.download_outlined,
            title: 'Export My Data (GDPR)',
            subtitle: 'Download all your data as a ZIP',
            onTap: () => _showGdprExport(context),
          ),
          _SettingsTile(
            icon: Icons.delete_outline,
            title: 'Delete Account',
            color: AppColors.coral600,
            onTap: () => _showDeleteAccount(context, ref),
          ),

          const _SectionHeader('About'),
          _SettingsTile(icon: Icons.info_outline, title: 'About Reclaim', onTap: () {}),
          _SettingsTile(icon: Icons.description_outlined, title: 'Terms of Service', onTap: () {}),
          _SettingsTile(icon: Icons.privacy_tip_outlined, title: 'Privacy Policy', onTap: () {}),
          _SettingsTile(icon: Icons.help_outline, title: 'Help & Support', onTap: () {}),

          const SizedBox(height: 10),
          Padding(
            padding: const EdgeInsets.all(16),
            child: OutlinedButton.icon(
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.coral600,
                side: const BorderSide(color: AppColors.coral400),
                minimumSize: const Size(48, 50),
              ),
              onPressed: () => _signOut(context, ref),
              icon: const Icon(Icons.logout),
              label: const Text('Sign Out'),
            ),
          ),
          Center(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 32),
              child: Text('Reclaim v1.0.0',
                  style: Theme.of(context).textTheme.bodySmall),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _signOut(BuildContext context, WidgetRef ref) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Sign Out'),
        content: const Text('Are you sure you want to sign out?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
          ElevatedButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Sign Out')),
        ],
      ),
    );
    if (confirmed == true) {
      await ref.read(authNotifierProvider.notifier).signOut();
      if (context.mounted) context.go(AppConstants.routeLogin);
    }
  }

  void _showGdprExport(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Export Your Data'),
        content: const Text(
          'We will compile all your data (journal entries, mood logs, tracker data) into a ZIP file and email it to you within 24 hours.',
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Export requested. You\'ll receive an email within 24 hours.')),
              );
            },
            child: const Text('Request Export'),
          ),
        ],
      ),
    );
  }

  void _showDeleteAccount(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Account'),
        content: const Text(
          'This will permanently delete your account and all data within 30 days. This cannot be undone.',
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.coral400),
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Delete Account'),
          ),
        ],
      ),
    );
  }
}

class _ProfileHeader extends StatelessWidget {
  const _ProfileHeader({required this.name, required this.email, required this.role});
  final String name, email, role;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: context.colSurface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: context.colBorder),
      ),
      child: Row(
        children: [
          Container(
            width: 56, height: 56,
            decoration: BoxDecoration(
              color: AppColors.teal50,
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.teal400, width: 2),
            ),
            child: Center(
              child: Text(
                name.isNotEmpty ? name[0].toUpperCase() : 'U',
                style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w700, color: AppColors.teal600),
              ),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name, style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16, color: context.colText)),
                Text(email, style: TextStyle(fontSize: 12, color: context.colTextSec)),
                const SizedBox(height: 4),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: context.colTint(AppColors.teal50, AppColors.teal50Dk),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    role.isNotEmpty ? role[0].toUpperCase() + role.substring(1) : 'User',
                    style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: AppColors.teal600),
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

class _SectionHeader extends StatelessWidget {
  const _SectionHeader(this.title);
  final String title;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Text(
        title.toUpperCase(),
        style: const TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.8,
          color: AppColors.textHint,
        ),
      ),
    );
  }
}

class _SettingsTile extends StatelessWidget {
  const _SettingsTile({
    required this.icon, required this.title, required this.onTap,
    this.subtitle, this.color,
  });
  final IconData icon;
  final String title;
  final String? subtitle;
  final Color? color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon, color: color ?? context.colTextSec, size: 22),
      title: Text(title, style: TextStyle(fontSize: 14, color: color ?? context.colText)),
      subtitle: subtitle != null
          ? Text(subtitle!, style: TextStyle(fontSize: 12, color: context.colTextSec))
          : null,
      trailing: Icon(Icons.chevron_right, color: context.colTextHint, size: 18),
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
    );
  }
}

class _SettingsTileSwitch extends StatelessWidget {
  const _SettingsTileSwitch({
    required this.icon,
    required this.title,
    required this.value,
    required this.onChanged,
    this.subtitle,
  });
  final IconData icon;
  final String title;
  final String? subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon, color: context.colTextSec, size: 22),
      title: Text(title, style: TextStyle(fontSize: 14, color: context.colText)),
      subtitle: subtitle != null
          ? Text(subtitle!, style: TextStyle(fontSize: 12, color: context.colTextSec))
          : null,
      trailing: Switch(
        value: value,
        onChanged: onChanged,
        activeThumbColor: AppColors.teal400,
        activeTrackColor: AppColors.teal100,
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
    );
  }
}
