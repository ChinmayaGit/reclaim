import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../domain/focus_notifier.dart';
import '../../../core/theme/app_colors.dart';

class FocusScreen extends ConsumerWidget {
  const FocusScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(focusSettingsProvider);
    final usedSeconds = ref.watch(usageNotifierProvider);
    final usedMinutes = usedSeconds ~/ 60;

    return Scaffold(
      backgroundColor: context.colBackground,
      appBar: AppBar(
        title: const Text('Focus & Block'),
        backgroundColor: context.colSurface,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // ── Today's usage ───────────────────────────────────────────────
          _UsageBanner(
            usedMinutes: usedMinutes,
            limitMinutes: settings.usageLimitEnabled ? settings.dailyLimitMinutes : null,
          ),
          const SizedBox(height: 20),

          // ── App Usage Limit ─────────────────────────────────────────────
          _SectionCard(
            icon: Icons.timer_outlined,
            iconColor: AppColors.teal600,
            iconBg: context.colTint(AppColors.teal50, AppColors.teal50Dk),
            title: 'Daily Usage Limit',
            subtitle: 'Lock the app after you\'ve used it for too long',
            trailing: Switch(
              value: settings.usageLimitEnabled,
              onChanged: (v) => ref
                  .read(focusSettingsProvider.notifier)
                  .setUsageLimit(enabled: v),
            ),
            child: settings.usageLimitEnabled
                ? _LimitSlider(
                    value: settings.dailyLimitMinutes,
                    onChanged: (v) => ref
                        .read(focusSettingsProvider.notifier)
                        .setUsageLimit(enabled: true, minutes: v),
                  )
                : null,
          ),
          const SizedBox(height: 12),

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

          // ── Link Blocker ────────────────────────────────────────────────
          _SectionCard(
            icon: Icons.block_outlined,
            iconColor: AppColors.coral600,
            iconBg: context.colTint(AppColors.coral50, AppColors.coral50Dk),
            title: 'Website Blocker',
            subtitle: 'Block trigger sites from opening in the browser',
            trailing: Switch(
              value: settings.linkBlockingEnabled,
              onChanged: (v) => ref
                  .read(focusSettingsProvider.notifier)
                  .setLinkBlocking(v),
            ),
            child: settings.linkBlockingEnabled
                ? _DomainList(
                    domains: settings.blockedDomains,
                    onAdd: (d) =>
                        ref.read(focusSettingsProvider.notifier).addDomain(d),
                    onRemove: (d) =>
                        ref.read(focusSettingsProvider.notifier).removeDomain(d),
                  )
                : null,
          ),
          const SizedBox(height: 20),

          // ── How it works ─────────────────────────────────────────────────
          _InfoBox(),
          const SizedBox(height: 80),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────

class _UsageBanner extends StatelessWidget {
  const _UsageBanner({required this.usedMinutes, this.limitMinutes});
  final int usedMinutes;
  final int? limitMinutes;

  @override
  Widget build(BuildContext context) {
    final pct = limitMinutes != null
        ? (usedMinutes / limitMinutes!).clamp(0.0, 1.0)
        : null;
    final color = pct == null
        ? AppColors.teal600
        : (pct >= 0.9 ? AppColors.coral600 : pct >= 0.6 ? AppColors.amber600 : AppColors.teal600);

    return Container(
      padding: const EdgeInsets.all(18),
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
              Icon(Icons.access_time, color: color, size: 18),
              const SizedBox(width: 8),
              Text(
                'Today\'s Usage',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: context.colText,
                ),
              ),
              const Spacer(),
              Text(
                limitMinutes != null
                    ? '${usedMinutes}m / ${limitMinutes}m'
                    : '${usedMinutes}m used',
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 15,
                  color: color,
                ),
              ),
            ],
          ),
          if (pct != null) ...[
            const SizedBox(height: 10),
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: pct,
                minHeight: 6,
                backgroundColor: context.colBorder,
                valueColor: AlwaysStoppedAnimation(color),
              ),
            ),
          ],
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

class _LimitSlider extends StatelessWidget {
  const _LimitSlider({required this.value, required this.onChanged});
  final int value;
  final ValueChanged<int> onChanged;

  String _label(int m) {
    if (m < 60) return '${m}m';
    final h = m ~/ 60;
    final rem = m % 60;
    return rem == 0 ? '${h}h' : '${h}h ${rem}m';
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Daily Limit', style: TextStyle(color: context.colTextSec, fontSize: 13)),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: context.colTint(AppColors.teal50, AppColors.teal50Dk),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                _label(value),
                style: const TextStyle(
                    fontWeight: FontWeight.w700, color: AppColors.teal600),
              ),
            ),
          ],
        ),
        Slider(
          value: value.toDouble(),
          min: 5,
          max: 240,
          divisions: 47,
          activeColor: AppColors.teal600,
          onChanged: (v) => onChanged(v.round()),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('5 min', style: TextStyle(fontSize: 11, color: context.colTextHint)),
            Text('4 hrs', style: TextStyle(fontSize: 11, color: context.colTextHint)),
          ],
        ),
      ],
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
          _InfoRow('Usage Limit locks the app after your set time each day. Resets at midnight.'),
          _InfoRow('App Schedule only allows the app between your chosen hours.'),
          _InfoRow('Website Blocker intercepts any link from this app that matches your list.'),
          _InfoRow('You can always snooze locks for 5–15 minutes, or tap the crisis button.'),
        ],
      ),
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
