import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../domain/focus_notifier.dart';
import '../data/usage_channel.dart';
import '../data/vpn_channel.dart';
import '../data/notification_prefs.dart';
import '../../../core/theme/app_colors.dart';
import '../../../services/local_notification_service.dart';
import '../../../shared/constants/app_constants.dart';

class FocusScreen extends ConsumerWidget {
  const FocusScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(focusSettingsProvider);

    return Scaffold(
      backgroundColor: context.colBackground,
      appBar: AppBar(
        title: const Text('Focus & Block'),
        backgroundColor: context.colSurface,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // ── Pomodoro timer ───────────────────────────────────────────────
          const _PomodoroCard(),
          const SizedBox(height: 20),

          // ── Notification settings ────────────────────────────────────────
          const _CheckinNotifCard(),
          const SizedBox(height: 12),
          const _CravingShieldCard(),
          const SizedBox(height: 20),

          // ── Tracked apps (usage + optional per-app daily limit) ──────────
          const _TrackedAppsSection(),
          const SizedBox(height: 20),

          // ── App Schedule ────────────────────────────────────────────────
          _SectionCard(
            icon: Icons.schedule_outlined,
            iconColor: AppColors.purple600,
            iconBg: context.colTint(AppColors.purple50, AppColors.purple50Dk),
            title: 'App Schedule',
            subtitle: 'Only allow access during specific hours',
            trailing: Switch(
              value: settings.scheduleEnabled,
              onChanged: (v) => ref
                  .read(focusSettingsProvider.notifier)
                  .setSchedule(enabled: v),
            ),
            child: settings.scheduleEnabled
                ? _SchedulePicker(
                    startHour: settings.scheduleStartHour,
                    endHour: settings.scheduleEndHour,
                    onStartChanged: (h) => ref
                        .read(focusSettingsProvider.notifier)
                        .setSchedule(enabled: true, startHour: h),
                    onEndChanged: (h) => ref
                        .read(focusSettingsProvider.notifier)
                        .setSchedule(enabled: true, endHour: h),
                  )
                : null,
          ),
          const SizedBox(height: 12),

          // ── Link Blocker (DNS VPN) ──────────────────────────────────────
          _SectionCard(
            icon: Icons.dns_outlined,
            iconColor: AppColors.coral600,
            iconBg: context.colTint(AppColors.coral50, AppColors.coral50Dk),
            title: 'Website Blocker',
            subtitle: 'Block trigger sites at the DNS level — works across all apps',
            trailing: Switch(
              value: settings.linkBlockingEnabled,
              onChanged: (v) async {
                if (v) {
                  // Request VPN system consent if not yet granted
                  final hasPerm = await VpnChannel.hasPermission();
                  if (!hasPerm) {
                    final granted = await VpnChannel.requestConsent();
                    if (!granted) return;
                  }
                  if (!context.mounted) return;
                  ref.read(focusSettingsProvider.notifier).setLinkBlocking(true);
                  await VpnChannel.start(settings.blockedDomains);
                } else {
                  ref.read(focusSettingsProvider.notifier).setLinkBlocking(false);
                  await VpnChannel.stop();
                }
              },
            ),
            child: settings.linkBlockingEnabled
                ? Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Active VPN badge
                      Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          color: AppColors.teal400.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                              color: AppColors.teal400.withValues(alpha: 0.4)),
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.shield_outlined,
                                color: AppColors.teal600, size: 14),
                            SizedBox(width: 6),
                            Text(
                              'DNS filter active — blocked sites return NXDOMAIN',
                              style: TextStyle(
                                  fontSize: 11,
                                  color: AppColors.teal600,
                                  fontWeight: FontWeight.w500),
                            ),
                          ],
                        ),
                      ),
                      _DomainList(
                        domains: settings.blockedDomains,
                        onAdd: (d) async {
                          ref
                              .read(focusSettingsProvider.notifier)
                              .addDomain(d);
                          // Restart VPN so the new domain is enforced immediately
                          final updated = [
                            ...settings.blockedDomains,
                            d,
                          ];
                          await VpnChannel.start(updated);
                        },
                        onRemove: (d) async {
                          ref
                              .read(focusSettingsProvider.notifier)
                              .removeDomain(d);
                          final updated = settings.blockedDomains
                              .where((x) => x != d)
                              .toList();
                          if (updated.isEmpty) {
                            await VpnChannel.stop();
                          } else {
                            await VpnChannel.start(updated);
                          }
                        },
                      ),
                    ],
                  )
                : null,
          ),
          const SizedBox(height: 20),

          // ── How it works ─────────────────────────────────────────────────
          const _InfoBox(),
          const SizedBox(height: 80),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────

class _SectionCard extends StatelessWidget {
  const _SectionCard({
    required this.icon,
    required this.iconColor,
    required this.iconBg,
    required this.title,
    required this.subtitle,
    required this.trailing,
    this.child,
  });

  final IconData icon;
  final Color iconColor, iconBg;
  final String title, subtitle;
  final Widget trailing;
  final Widget? child;

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
          Row(
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(color: iconBg, borderRadius: BorderRadius.circular(10)),
                child: Icon(icon, color: iconColor, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title,
                        style: TextStyle(
                            fontWeight: FontWeight.w600, color: context.colText)),
                    Text(subtitle,
                        style: TextStyle(fontSize: 12, color: context.colTextSec)),
                  ],
                ),
              ),
              trailing,
            ],
          ),
          if (child != null) ...[
            const Divider(height: 24),
            child!,
          ],
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────

class _SchedulePicker extends StatelessWidget {
  const _SchedulePicker({
    required this.startHour,
    required this.endHour,
    required this.onStartChanged,
    required this.onEndChanged,
  });
  final int startHour, endHour;
  final ValueChanged<int> onStartChanged, onEndChanged;

  String _fmt(int h) {
    final suf = h < 12 ? 'AM' : 'PM';
    final disp = h == 0 ? 12 : (h > 12 ? h - 12 : h);
    return '$disp:00 $suf';
  }

  Future<void> _pick(BuildContext context, int current, ValueChanged<int> cb) async {
    final picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay(hour: current, minute: 0),
      helpText: 'Select hour',
    );
    if (picked != null) cb(picked.hour);
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _TimeButton(
            label: 'Available from',
            time: _fmt(startHour),
            onTap: () => _pick(context, startHour, onStartChanged),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: Text('→', style: TextStyle(color: context.colTextSec, fontSize: 18)),
        ),
        Expanded(
          child: _TimeButton(
            label: 'Until',
            time: _fmt(endHour),
            onTap: () => _pick(context, endHour, onEndChanged),
          ),
        ),
      ],
    );
  }
}

class _TimeButton extends StatelessWidget {
  const _TimeButton({required this.label, required this.time, required this.onTap});
  final String label, time;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: context.colTint(AppColors.purple50, AppColors.purple50Dk),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: AppColors.purple400.withValues(alpha: 0.4),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: TextStyle(fontSize: 10, color: context.colTextSec)),
            const SizedBox(height: 2),
            Text(time,
                style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                    color: AppColors.purple600)),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────

class _DomainList extends ConsumerStatefulWidget {
  const _DomainList({
    required this.domains,
    required this.onAdd,
    required this.onRemove,
  });
  final List<String> domains;
  final ValueChanged<String> onAdd;
  final ValueChanged<String> onRemove;

  @override
  ConsumerState<_DomainList> createState() => _DomainListState();
}

class _DomainListState extends ConsumerState<_DomainList> {
  final _ctrl = TextEditingController();

  static const _suggested = [
    'instagram.com',
    'tiktok.com',
    'twitter.com',
    'facebook.com',
    'reddit.com',
    'youtube.com',
    'swiggy.com',
    'zomato.com',
    'betway.com',
    'draftkings.com',
    'pornhub.com',
  ];

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  void _add() {
    final v = _ctrl.text.trim();
    if (v.isEmpty) return;
    widget.onAdd(v);
    _ctrl.clear();
  }

  @override
  Widget build(BuildContext context) {
    final notBlocked = _suggested
        .where((s) => !widget.domains.contains(s))
        .toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Add custom domain
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: _ctrl,
                decoration: InputDecoration(
                  hintText: 'e.g. instagram.com',
                  hintStyle: TextStyle(color: context.colTextHint, fontSize: 13),
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(color: context.colBorder),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(color: context.colBorder),
                  ),
                ),
                onSubmitted: (_) => _add(),
              ),
            ),
            const SizedBox(width: 8),
            ElevatedButton(
              onPressed: _add,
              style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.coral600,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12)),
              child: const Text('Block'),
            ),
          ],
        ),

        // Blocked list
        if (widget.domains.isNotEmpty) ...[
          const SizedBox(height: 14),
          Text('Blocked sites',
              style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: context.colTextSec)),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 6,
            children: widget.domains
                .map((d) => _DomainChip(domain: d, onRemove: () => widget.onRemove(d)))
                .toList(),
          ),
        ],

        // Suggestions
        if (notBlocked.isNotEmpty) ...[
          const SizedBox(height: 14),
          Text('Quick-block common triggers',
              style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: context.colTextSec)),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 6,
            children: notBlocked
                .map((d) => ActionChip(
                      label: Text(d, style: const TextStyle(fontSize: 12)),
                      avatar: const Icon(Icons.add, size: 14),
                      onPressed: () => widget.onAdd(d),
                    ))
                .toList(),
          ),
        ],
      ],
    );
  }
}

class _DomainChip extends StatelessWidget {
  const _DomainChip({required this.domain, required this.onRemove});
  final String domain;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: context.colTint(AppColors.coral50, AppColors.coral50Dk),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.coral400.withValues(alpha: 0.5)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.block, size: 12, color: AppColors.coral600),
          const SizedBox(width: 4),
          Text(domain,
              style: const TextStyle(fontSize: 12, color: AppColors.coral600)),
          const SizedBox(width: 6),
          GestureDetector(
            onTap: onRemove,
            child: const Icon(Icons.close, size: 14, color: AppColors.coral600),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────

class _InfoBox extends StatelessWidget {
  const _InfoBox();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: context.colTint(AppColors.amber50, AppColors.amber50Dk),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.amber400.withValues(alpha: 0.4),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Text('💡', style: TextStyle(fontSize: 16)),
              SizedBox(width: 8),
              Text('How it works',
                  style: TextStyle(
                      fontWeight: FontWeight.w600, color: AppColors.amber600)),
            ],
          ),
          const SizedBox(height: 10),
          _InfoRow('Tracked apps: use Edit app list and turn Track on to add an app immediately. Turn Daily limit on per app to set minutes and lock Reclaim when that app hits the cap.'),
          _InfoRow('App Schedule locks Reclaim outside your allowed hours until the window opens (or you snooze).'),
          _InfoRow('Turn off the schedule switch to use the app any time.'),
          _InfoRow('Website Blocker runs a local DNS VPN — blocked domains return NXDOMAIN across all apps on your device.'),
          _InfoRow('You can always snooze locks for 5–15 minutes, or tap the crisis button.'),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Daily Check-in Notification Card
// ─────────────────────────────────────────────────────────────────────────────

class _CheckinNotifCard extends ConsumerWidget {
  const _CheckinNotifCard();

  String _fmt(int h, int m) {
    final suf = h < 12 ? 'AM' : 'PM';
    final disp = h == 0 ? 12 : (h > 12 ? h - 12 : h);
    return '$disp:${m.toString().padLeft(2, '0')} $suf';
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final prefs = ref.watch(notificationPrefsProvider);

    return _SectionCard(
      icon: Icons.check_circle_outline,
      iconColor: AppColors.green400,
      iconBg: context.colTint(AppColors.green50, AppColors.green50Dk),
      title: 'Daily Check-in Reminder',
      subtitle: 'Remind you every day to log your check-in',
      trailing: Switch(
        value: prefs.checkinEnabled,
        onChanged: (v) async {
          if (v) await LocalNotificationService.instance.requestPermission();
          ref.read(notificationPrefsProvider.notifier)
              .setCheckin(enabled: v);
        },
      ),
      child: prefs.checkinEnabled
          ? ListTile(
              contentPadding: EdgeInsets.zero,
              dense: true,
              title: Text('Reminder time',
                  style: TextStyle(fontSize: 13, color: context.colText)),
              trailing: TextButton(
                onPressed: () async {
                  final picked = await showTimePicker(
                    context: context,
                    initialTime: TimeOfDay(
                        hour: prefs.checkinHour, minute: prefs.checkinMinute),
                  );
                  if (picked != null && context.mounted) {
                    ref.read(notificationPrefsProvider.notifier).setCheckin(
                          enabled: true,
                          hour: picked.hour,
                          minute: picked.minute,
                        );
                  }
                },
                child: Text(
                  _fmt(prefs.checkinHour, prefs.checkinMinute),
                  style: const TextStyle(
                      fontWeight: FontWeight.w700, color: AppColors.teal400),
                ),
              ),
            )
          : null,
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Craving Shield Card
// ─────────────────────────────────────────────────────────────────────────────

class _CravingShieldCard extends ConsumerWidget {
  const _CravingShieldCard();

  static const _addictions = [
    ('alcohol',      '🍺 Alcohol'),
    ('drugs',        '💊 Drugs'),
    ('gambling',     '🎰 Gambling'),
    ('smoking',      '🚬 Smoking'),
    ('social_media', '📱 Social Media'),
    ('other',        '🔄 Other'),
  ];

  String _fmt(TimeOfDay t) {
    final suf = t.hour < 12 ? 'AM' : 'PM';
    final h = t.hour == 0 ? 12 : (t.hour > 12 ? t.hour - 12 : t.hour);
    return '$h:${t.minute.toString().padLeft(2, '0')} $suf';
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final prefs = ref.watch(notificationPrefsProvider);
    final notifier = ref.read(notificationPrefsProvider.notifier);

    return _SectionCard(
      icon: Icons.shield_outlined,
      iconColor: AppColors.coral600,
      iconBg: context.colTint(AppColors.coral50, AppColors.coral50Dk),
      title: 'Craving Shield',
      subtitle: 'At your craving times, get a notification that opens real consequences',
      trailing: Switch(
        value: prefs.cravingEnabled,
        onChanged: (v) async {
          if (v) await LocalNotificationService.instance.requestPermission();
          notifier.setCraving(enabled: v);
        },
      ),
      child: prefs.cravingEnabled
          ? Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Addiction type picker
                Text('Addiction type',
                    style: TextStyle(fontSize: 12, color: context.colTextSec)),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 6,
                  children: _addictions.map(((String key, String label) a) {
                    final sel = prefs.addictionKey == a.$1;
                    return ChoiceChip(
                      label: Text(a.$2, style: TextStyle(fontSize: 12)),
                      selected: sel,
                      onSelected: (_) => notifier.setCraving(
                          enabled: true, addictionKey: a.$1),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 14),

                // Craving time slots
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Craving times (up to 3)',
                        style: TextStyle(fontSize: 12, color: context.colTextSec)),
                    if (prefs.cravingSlots.length < 3)
                      TextButton.icon(
                        onPressed: () async {
                          final t = await showTimePicker(
                            context: context,
                            initialTime: const TimeOfDay(hour: 20, minute: 0),
                          );
                          if (t != null) notifier.addSlot(t);
                        },
                        icon: const Icon(Icons.add, size: 14),
                        label: const Text('Add time'),
                        style: TextButton.styleFrom(
                            visualDensity: VisualDensity.compact),
                      ),
                  ],
                ),
                const SizedBox(height: 4),
                ...prefs.cravingSlots.asMap().entries.map((e) => ListTile(
                      contentPadding: EdgeInsets.zero,
                      dense: true,
                      leading: Container(
                        width: 32, height: 32,
                        decoration: BoxDecoration(
                          color: context.colTint(
                              AppColors.coral50, AppColors.coral50Dk),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(Icons.access_alarm,
                            size: 16, color: AppColors.coral600),
                      ),
                      title: Text(_fmt(e.value),
                          style: TextStyle(
                              fontWeight: FontWeight.w700,
                              color: AppColors.coral600)),
                      trailing: IconButton(
                        icon: const Icon(Icons.close, size: 16),
                        onPressed: () => notifier.removeSlot(e.key),
                        color: context.colTextHint,
                        visualDensity: VisualDensity.compact,
                      ),
                    )),

                const SizedBox(height: 10),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.coral600,
                      side: const BorderSide(color: AppColors.coral400),
                      minimumSize: const Size(0, 40),
                    ),
                    onPressed: () => context.push(
                      '${AppConstants.routeCravingShield}?addiction=${prefs.addictionKey}',
                    ),
                    icon: const Icon(Icons.preview_outlined, size: 16),
                    label: const Text('Preview Craving Shield Content'),
                  ),
                ),
              ],
            )
          : null,
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow(this.text);
  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('• ',
              style: TextStyle(color: AppColors.amber600, fontWeight: FontWeight.w700)),
          Expanded(
            child: Text(text,
                style: TextStyle(fontSize: 12, color: context.colTextSec, height: 1.5)),
          ),
        ],
      ),
    );
  }
}

// ── Tracked apps (usage) ─────────────────────────────────────────────────────

final _limitMinuteChoices =
    List<int>.generate((240 - 5) ~/ 5 + 1, (i) => 5 + i * 5);

String _fmtAppUsageSeconds(int sec) {
  if (sec <= 0) return '0s';
  final h = sec ~/ 3600;
  final m = (sec % 3600) ~/ 60;
  final s = sec % 60;
  if (h > 0) return '${h}h ${m}m';
  if (m > 0) return '${m}m ${s}s';
  return '${s}s';
}

Future<bool> _showUsageAccessSheet(BuildContext context) async {
  await showModalBottomSheet<void>(
    context: context,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (ctx) => Padding(
      padding: EdgeInsets.fromLTRB(
        24, 20, 24, MediaQuery.paddingOf(ctx).bottom + 24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            'Usage access',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 10),
          Text(
            'Reclaim needs Usage access to read today’s screen time for your apps.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 13, height: 1.5, color: ctx.colTextSec),
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              onPressed: () async {
                Navigator.pop(ctx);
                await UsageChannel.openPermissionSettings();
              },
              icon: const Icon(Icons.settings_outlined, size: 18),
              label: const Text('Open settings'),
            ),
          ),
        ],
      ),
    ),
  );
  await Future.delayed(const Duration(milliseconds: 400));
  return UsageChannel.hasPermission();
}

Future<void> _openTrackedAppsPicker(BuildContext context, WidgetRef ref) async {
  if (!await UsageChannel.hasPermission()) {
    if (!context.mounted) return;
    final ok = await _showUsageAccessSheet(context);
    if (!ok || !context.mounted) return;
    await ref.read(usageNotifierProvider.notifier).refresh();
  }
  if (!context.mounted) return;
  await showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (_) => const _TrackedAppsPickerSheet(),
  );
}

class _TrackedAppsSection extends ConsumerWidget {
  const _TrackedAppsSection();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final snap = ref.watch(usageNotifierProvider);
    final tracked =
        ref.watch(focusSettingsProvider.select((s) => s.trackedAppUsage));

    return _SectionCard(
      icon: Icons.list_alt_outlined,
      iconColor: AppColors.blue600,
      iconBg: context.colTint(AppColors.blue50, AppColors.blue50Dk),
      title: 'Tracked apps',
      subtitle: snap.hasUsagePermission
          ? 'Track screen time; optional daily limit per app'
          : 'Grant usage access to load timers',
      trailing: snap.hasUsagePermission
          ? IconButton(
              tooltip: 'Refresh usage',
              onPressed: () =>
                  unawaited(ref.read(usageNotifierProvider.notifier).refresh()),
              icon: const Icon(Icons.refresh, size: 20),
              color: context.colTextHint,
            )
          : const SizedBox.shrink(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!snap.hasUsagePermission)
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Text(
                'Android hides app timers until you allow usage access for Reclaim.',
                style: TextStyle(fontSize: 12, color: context.colTextSec, height: 1.45),
              ),
            ),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () async {
                if (!snap.hasUsagePermission) {
                  final ok = await _showUsageAccessSheet(context);
                  if (!ok || !context.mounted) return;
                  await ref.read(usageNotifierProvider.notifier).refresh();
                  if (!context.mounted) return;
                }
                await _openTrackedAppsPicker(context, ref);
              },
              icon: const Icon(Icons.edit_outlined, size: 18),
              label: Text(tracked.isEmpty ? 'Add apps to track' : 'Edit app list'),
            ),
          ),
          if (snap.hasUsagePermission && tracked.isEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 14),
              child: Text(
                'No apps yet. Tap Add apps to track and switch Track on for each app you want — it saves right away.',
                style: TextStyle(fontSize: 12, color: context.colTextSec, height: 1.45),
              ),
            ),
          if (tracked.isNotEmpty) ...[
            const SizedBox(height: 14),
            ...tracked.map(
              (t) => _TrackedAppRow(
                app: t,
                secondsToday: snap.secondsByPackage[t.packageName] ?? 0,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _TrackedAppRow extends ConsumerWidget {
  const _TrackedAppRow({
    required this.app,
    required this.secondsToday,
  });

  final AppUsageTrackedApp app;
  final int secondsToday;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final col = secondsToday >= 3600
        ? AppColors.coral400
        : secondsToday >= 1800
            ? AppColors.amber400
            : AppColors.teal400;

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      app.displayName,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: context.colText,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      app.packageName,
                      style: TextStyle(
                        fontSize: 10,
                        color: context.colTextHint,
                        height: 1.2,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              Text(
                _fmtAppUsageSeconds(secondsToday),
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: col,
                ),
              ),
              IconButton(
                icon: const Icon(Icons.close, size: 18),
                color: context.colTextHint,
                visualDensity: VisualDensity.compact,
                tooltip: 'Stop tracking',
                onPressed: () => ref
                    .read(focusSettingsProvider.notifier)
                    .removeMonitoredApp(app.packageName),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              Expanded(
                child: Text(
                  'Daily limit',
                  style: TextStyle(fontSize: 12, color: context.colTextSec),
                ),
              ),
              Switch(
                value: app.limitEnabled,
                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                onChanged: (v) => ref
                    .read(focusSettingsProvider.notifier)
                    .setTrackedAppLimitEnabled(app.packageName, v),
              ),
            ],
          ),
          if (app.limitEnabled) ...[
            const SizedBox(height: 4),
            Row(
              children: [
                Text(
                  'Cap at ',
                  style: TextStyle(fontSize: 12, color: context.colTextSec),
                ),
                DropdownButtonHideUnderline(
                  child: DropdownButton<int>(
                    value: snapFocusLimitMinutes(app.limitMinutes),
                    isDense: true,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: AppColors.teal600,
                    ),
                    items: _limitMinuteChoices
                        .map(
                          (m) => DropdownMenuItem(
                            value: m,
                            child: Text('$m min'),
                          ),
                        )
                        .toList(),
                    onChanged: (m) {
                      if (m == null) return;
                      ref
                          .read(focusSettingsProvider.notifier)
                          .setTrackedAppLimit(app.packageName, m);
                    },
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

class _TrackedAppsPickerSheet extends ConsumerStatefulWidget {
  const _TrackedAppsPickerSheet();

  @override
  ConsumerState<_TrackedAppsPickerSheet> createState() =>
      _TrackedAppsPickerSheetState();
}

class _TrackedAppsPickerSheetState extends ConsumerState<_TrackedAppsPickerSheet> {
  final _search = TextEditingController();

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final snap = ref.watch(usageNotifierProvider);
    final tracked = ref.watch(focusSettingsProvider.select((s) => s.trackedAppUsage));
    final trackedPkgs = {for (final t in tracked) t.packageName};

    final q = _search.text.trim().toLowerCase();
    final apps = snap.appsSorted;
    final filtered = q.isEmpty
        ? apps
        : apps
            .where(
              (s) =>
                  s.appName.toLowerCase().contains(q) ||
                  s.packageName.toLowerCase().contains(q),
            )
            .toList();

    final h = MediaQuery.sizeOf(context).height;

    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(context).bottom),
      child: SizedBox(
        height: h * 0.88,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(top: 10, bottom: 12),
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Text(
                'Track apps',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: context.colText,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 6, 20, 10),
              child: Text(
                'Turn Track on to add an app right away. Turn it off to remove.',
                style: TextStyle(fontSize: 12, color: context.colTextSec, height: 1.35),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: TextField(
                controller: _search,
                decoration: InputDecoration(
                  hintText: 'Search apps…',
                  isDense: true,
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(color: context.colBorder),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(color: context.colBorder),
                  ),
                ),
                onChanged: (_) => setState(() {}),
              ),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: filtered.isEmpty
                  ? Center(
                      child: Text(
                        'No apps match.',
                        style: TextStyle(color: context.colTextSec),
                      ),
                    )
                  : ListView.separated(
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      itemCount: filtered.length,
                      separatorBuilder: (_, __) => const Divider(height: 1),
                      itemBuilder: (context, i) {
                        final s = filtered[i];
                        final on = trackedPkgs.contains(s.packageName);
                        return SwitchListTile(
                          dense: true,
                          title: Text(
                            s.appName,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              color: context.colText,
                            ),
                          ),
                          subtitle: Text(
                            '${_fmtAppUsageSeconds(s.secondsToday)} · ${s.packageName}',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 11,
                              color: context.colTextHint,
                            ),
                          ),
                          value: on,
                          onChanged: (v) async {
                            final n = ref.read(focusSettingsProvider.notifier);
                            if (v) {
                              await n.addTrackedApp(
                                packageName: s.packageName,
                                displayName: s.appName,
                              );
                            } else {
                              await n.removeMonitoredApp(s.packageName);
                            }
                          },
                        );
                      },
                    ),
            ),
            SafeArea(
              top: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
                child: FilledButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Done'),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Pomodoro Timer ─────────────────────────────────────────────────────────────

enum _PomPhase { work, shortBreak, longBreak }

class _PomodoroCard extends StatefulWidget {
  const _PomodoroCard();

  @override
  State<_PomodoroCard> createState() => _PomodoroCardState();
}

class _PomodoroCardState extends State<_PomodoroCard> {
  static const _workSecs       = 25 * 60;
  static const _shortBreakSecs = 5  * 60;
  static const _longBreakSecs  = 15 * 60;

  _PomPhase _phase    = _PomPhase.work;
  int       _remaining = _workSecs;
  int       _sessions  = 0;
  bool      _running   = false;
  Timer?    _timer;

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  int get _total {
    return switch (_phase) {
      _PomPhase.work       => _workSecs,
      _PomPhase.shortBreak => _shortBreakSecs,
      _PomPhase.longBreak  => _longBreakSecs,
    };
  }

  void _start() {
    _timer?.cancel();
    setState(() => _running = true);
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted) return;
      if (_remaining > 0) {
        setState(() => _remaining--);
      } else {
        _nextPhase();
      }
    });
  }

  void _pause() {
    _timer?.cancel();
    setState(() => _running = false);
  }

  void _reset() {
    _timer?.cancel();
    setState(() {
      _running   = false;
      _remaining = _total;
    });
  }

  void _nextPhase() {
    _timer?.cancel();
    if (!mounted) return;
    setState(() {
      if (_phase == _PomPhase.work) {
        _sessions++;
        _phase = (_sessions % 4 == 0)
            ? _PomPhase.longBreak
            : _PomPhase.shortBreak;
      } else {
        _phase = _PomPhase.work;
      }
      _remaining = _total;
      _running   = false;
    });
  }

  void _setPhase(_PomPhase p) {
    _timer?.cancel();
    setState(() {
      _phase     = p;
      _remaining = _total;
      _running   = false;
    });
  }

  String get _label => switch (_phase) {
        _PomPhase.work       => 'Focus',
        _PomPhase.shortBreak => 'Short Break',
        _PomPhase.longBreak  => 'Long Break',
      };

  Color get _color => switch (_phase) {
        _PomPhase.work       => AppColors.coral600,
        _PomPhase.shortBreak => AppColors.teal600,
        _PomPhase.longBreak  => AppColors.purple600,
      };

  String get _timeStr {
    final m = _remaining ~/ 60;
    final s = _remaining % 60;
    return '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final progress =
        (1 - _remaining / _total).clamp(0.0, 1.0);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: context.colSurface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: context.colBorder),
      ),
      child: Column(
        children: [
          // Header
          Row(
            children: [
              Container(
                width: 38, height: 38,
                decoration: BoxDecoration(
                  color: _color.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(Icons.timer_outlined, color: _color, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Pomodoro Timer',
                        style: TextStyle(
                            fontWeight: FontWeight.w600,
                            color: context.colText)),
                    Text('$_sessions sessions today',
                        style: TextStyle(
                            fontSize: 12, color: context.colTextSec)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Phase selector
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _PhaseChip(label: 'Focus',       active: _phase == _PomPhase.work,       color: AppColors.coral600,  onTap: () => _setPhase(_PomPhase.work)),
              const SizedBox(width: 8),
              _PhaseChip(label: 'Short Break', active: _phase == _PomPhase.shortBreak, color: AppColors.teal600,   onTap: () => _setPhase(_PomPhase.shortBreak)),
              const SizedBox(width: 8),
              _PhaseChip(label: 'Long Break',  active: _phase == _PomPhase.longBreak,  color: AppColors.purple600, onTap: () => _setPhase(_PomPhase.longBreak)),
            ],
          ),
          const SizedBox(height: 20),

          // Timer ring
          Stack(
            alignment: Alignment.center,
            children: [
              SizedBox(
                width: 140, height: 140,
                child: CircularProgressIndicator(
                  value: progress,
                  strokeWidth: 10,
                  backgroundColor: _color.withValues(alpha: 0.12),
                  valueColor: AlwaysStoppedAnimation(_color),
                ),
              ),
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    _timeStr,
                    style: TextStyle(
                        fontSize: 34,
                        fontWeight: FontWeight.w800,
                        color: context.colText,
                        fontFeatures: const [FontFeature.tabularFigures()]),
                  ),
                  Text(_label,
                      style: TextStyle(
                          fontSize: 12,
                          color: _color,
                          fontWeight: FontWeight.w500)),
                ],
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Controls
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton(
                onPressed: _reset,
                icon: const Icon(Icons.replay_outlined),
                color: context.colTextSec,
              ),
              const SizedBox(width: 12),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: _color,
                  foregroundColor: Colors.white,
                  minimumSize: const Size(120, 46),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
                onPressed: _running ? _pause : _start,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(_running ? Icons.pause : Icons.play_arrow, size: 18),
                    const SizedBox(width: 6),
                    Text(_running ? 'Pause' : 'Start',
                        style: const TextStyle(fontWeight: FontWeight.w700)),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              IconButton(
                onPressed: _nextPhase,
                icon: const Icon(Icons.skip_next_outlined),
                color: context.colTextSec,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _PhaseChip extends StatelessWidget {
  const _PhaseChip({
    required this.label,
    required this.active,
    required this.color,
    required this.onTap,
  });
  final String label;
  final bool active;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding:
            const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: active ? color : context.colTint(AppColors.slate100, AppColors.slate100Dk),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
              color: active ? color : context.colBorder),
        ),
        child: Text(
          label,
          style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: active ? Colors.white : context.colTextSec),
        ),
      ),
    );
  }
}
