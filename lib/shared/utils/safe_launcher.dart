import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../features/focus/domain/focus_notifier.dart';
import '../../core/theme/app_colors.dart';
import '../widgets/donation_unlock_sheet.dart';

/// Opens [url] after checking the blocklist.
/// Pass [ref] when inside a ConsumerWidget; pass null to skip the check.
Future<void> openUrl(
  BuildContext context,
  String url, {
  WidgetRef? ref,
}) async {
  if (ref != null) {
    final settings = ref.read(focusSettingsProvider);
    if (settings.linkBlockingEnabled) {
      final domain = _domainOf(url);
      final blocked = settings.blockedDomains
          .any((d) => domain == d || domain.endsWith('.$d'));
      if (blocked) {
        if (context.mounted) _showBlockedDialog(context, domain, ref);
        return;
      }
    }
  }

  final uri = Uri.tryParse(url);
  if (uri == null) return;
  if (!await canLaunchUrl(uri)) return;
  await launchUrl(uri, mode: LaunchMode.externalApplication);
}

String _domainOf(String url) {
  return url
      .trim()
      .toLowerCase()
      .replaceAll(RegExp(r'^https?://'), '')
      .replaceAll(RegExp(r'^www\.'), '')
      .split('/')[0]
      .split('?')[0];
}

void _showBlockedDialog(BuildContext context, String domain, WidgetRef ref) {
  showDialog(
    context: context,
    builder: (ctx) => AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: const Row(
        children: [
          Text('🚫', style: TextStyle(fontSize: 22)),
          SizedBox(width: 10),
          Text('Site Blocked'),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: AppColors.coral50,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: AppColors.coral100),
            ),
            child: Text(
              domain,
              style: const TextStyle(
                fontFamily: 'monospace',
                color: AppColors.coral600,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const SizedBox(height: 12),
          const Text(
            'You blocked this site to protect your recovery. '
            'The urge will pass.',
            style: TextStyle(height: 1.5),
          ),
          const SizedBox(height: 8),
          _MotivationalQuote(),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(ctx),
          child: const Text('Stay Strong'),
        ),
        TextButton(
          onPressed: () {
            Navigator.pop(ctx);
            // "Open Anyway" requires a donation nudge first
            showDonationUnlockSheet(
              context,
              snoozeMinutes: 0, // no app snooze — just unblocks this link
              headline: 'Unblock $domain',
              subline:
                  'You blocked this site to protect your recovery. '
                  'Support Reclaim with a small donation to open it — '
                  'or stay strong and close this.',
              onGranted: () => _launchDomain(domain),
              onSkip:    () => _launchDomain(domain),
            );
          },
          style: TextButton.styleFrom(foregroundColor: AppColors.coral600),
          child: const Text('Open Anyway'),
        ),
      ],
    ),
  );
}

Future<void> _launchDomain(String domain) async {
  final uri = Uri.parse('https://$domain');
  if (await canLaunchUrl(uri)) {
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }
}

class _MotivationalQuote extends StatelessWidget {
  static const _quotes = [
    '"Pause. Breathe. You got this."',
    '"Your future self is watching. Choose wisely."',
    '"Every time you resist, you get stronger."',
    '"The urge is loud. So is your strength."',
  ];

  @override
  Widget build(BuildContext context) {
    final q = _quotes[DateTime.now().second % _quotes.length];
    return Text(
      q,
      style: const TextStyle(
        fontStyle: FontStyle.italic,
        color: AppColors.teal600,
        fontSize: 13,
      ),
    );
  }
}
