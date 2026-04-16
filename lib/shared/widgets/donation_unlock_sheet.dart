import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../core/theme/app_colors.dart';

/// Shows a bottom sheet that prompts a donation before granting
/// [snoozeMinutes] minutes of unlocked access (or unblocking a link).
///
/// [onGranted] is called when the user taps any payment option
/// or "I already donated". [onSkip] is called if they dismiss
/// without donating — still grants access but shows a softer message.
Future<void> showDonationUnlockSheet(
  BuildContext context, {
  required int snoozeMinutes,
  required VoidCallback onGranted,
  VoidCallback? onSkip,
  String? headline,
  String? subline,
}) {
  return showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => _DonationUnlockSheet(
      snoozeMinutes: snoozeMinutes,
      onGranted: onGranted,
      onSkip: onSkip,
      headline: headline,
      subline: subline,
    ),
  );
}

// ─── Replace these with your real handles ────────────────────────────────────
const _upiId     = 'your@upi';
const _upiName   = 'Reclaim App';
const _paypalUrl = 'https://paypal.me/yourhandle';
const _kofiUrl   = 'https://ko-fi.com/yourhandle';
// ─────────────────────────────────────────────────────────────────────────────

class _DonationUnlockSheet extends StatelessWidget {
  const _DonationUnlockSheet({
    required this.snoozeMinutes,
    required this.onGranted,
    this.onSkip,
    this.headline,
    this.subline,
  });

  final int snoozeMinutes;
  final VoidCallback onGranted;
  final VoidCallback? onSkip;
  final String? headline;
  final String? subline;

  Future<void> _upi(BuildContext ctx, int amount) async {
    final url =
        'upi://pay?pa=$_upiId&pn=${Uri.encodeComponent(_upiName)}'
        '&am=$amount&cu=INR&tn=${Uri.encodeComponent("Support Reclaim App")}';
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      // Fallback: copy UPI ID
      await Clipboard.setData(const ClipboardData(text: _upiId));
      if (ctx.mounted) {
        ScaffoldMessenger.of(ctx).showSnackBar(
          const SnackBar(
            content: Text('UPI app not found — ID copied: $_upiId'),
            backgroundColor: AppColors.teal600,
          ),
        );
      }
    }
    if (ctx.mounted) {
      Navigator.pop(ctx);
      onGranted();
    }
  }

  Future<void> _external(BuildContext ctx, String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
    if (ctx.mounted) {
      Navigator.pop(ctx);
      onGranted();
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = isDark ? AppColors.surfaceDk : AppColors.surface;

    return Container(
      decoration: BoxDecoration(
        color: bg,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: EdgeInsets.fromLTRB(
        24, 16, 24,
        MediaQuery.of(context).viewInsets.bottom + 32,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle
          Container(
            width: 40, height: 4,
            decoration: BoxDecoration(
              color: AppColors.teal200.withValues(alpha: 0.5),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 20),

          // Heart icon
          Container(
            width: 56, height: 56,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [AppColors.teal600, AppColors.teal400],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Icon(Icons.favorite, color: Colors.white, size: 28),
          ),
          const SizedBox(height: 16),

          Text(
            headline ?? 'Support Reclaim to Continue',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: isDark ? AppColors.textPrimaryDk : AppColors.textPrimary,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            subline ??
                'Reclaim is free and ad-free. A small donation keeps the servers '
                'running and unlocks $snoozeMinutes more minutes for you.',
            style: TextStyle(
              fontSize: 13,
              height: 1.5,
              color: isDark ? AppColors.textSecondaryDk : AppColors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),

          // UPI quick amounts
          Text(
            'Quick donate (UPI)',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: AppColors.teal600,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 10),
          Row(
            children: [21, 51, 101, 251].map((amt) {
              return Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: _AmountButton(
                    label: '₹$amt',
                    onTap: () => _upi(context, amt),
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 16),

          // Other options
          Row(
            children: [
              Expanded(
                child: _OutlineBtn(
                  icon: Icons.paypal,
                  label: 'PayPal',
                  color: const Color(0xFF003087),
                  onTap: () => _external(context, _paypalUrl),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _OutlineBtn(
                  icon: Icons.local_cafe_outlined,
                  label: 'Ko-fi',
                  color: const Color(0xFFFF5E5B),
                  onTap: () => _external(context, _kofiUrl),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // "I donated" — honour system
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.teal600,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
              onPressed: () {
                Navigator.pop(context);
                onGranted();
              },
              child: Text(
                '✓  I donated — unlock $snoozeMinutes min',
                style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
              ),
            ),
          ),
          const SizedBox(height: 10),

          // Skip — still unlocks but shows a nudge
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              if (onSkip != null) {
                onSkip!();
              } else {
                onGranted(); // fallback: grant anyway
              }
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text(
                      'Unlocked for a bit. Consider donating — it keeps us going.',
                    ),
                    backgroundColor: AppColors.amber600,
                    duration: Duration(seconds: 4),
                  ),
                );
              }
            },
            child: Text(
              'Maybe later — skip for now',
              style: TextStyle(
                fontSize: 13,
                color: isDark ? AppColors.textHintDk : AppColors.textHint,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _AmountButton extends StatelessWidget {
  const _AmountButton({required this.label, required this.onTap});
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: context.colTint(AppColors.teal50, AppColors.teal50Dk),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: AppColors.teal400.withValues(alpha: 0.5)),
        ),
        child: Center(
          child: Text(
            label,
            style: const TextStyle(
              fontWeight: FontWeight.w700,
              color: AppColors.teal600,
              fontSize: 15,
            ),
          ),
        ),
      ),
    );
  }
}

class _OutlineBtn extends StatelessWidget {
  const _OutlineBtn({required this.icon, required this.label, required this.color, required this.onTap});
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return OutlinedButton.icon(
      style: OutlinedButton.styleFrom(
        foregroundColor: color,
        side: BorderSide(color: color.withValues(alpha: 0.5)),
        padding: const EdgeInsets.symmetric(vertical: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
      onPressed: onTap,
      icon: Icon(icon, size: 18, color: color),
      label: Text(label,
          style: TextStyle(color: color, fontWeight: FontWeight.w600)),
    );
  }
}
