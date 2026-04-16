import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../core/theme/app_colors.dart';

/// Donation screen — no Google Play IAP involved.
/// All payments are external (UPI deeplink, PayPal, Ko-fi).
/// Google Play policy allows this for donations where no in-app
/// features or digital goods are sold in exchange.
///
/// Replace the placeholder IDs below with your actual payment handles
/// before publishing.
class DonationScreen extends StatelessWidget {
  const DonationScreen({super.key});

  // ── Replace these with your actual payment handles ──────────────────
  static const _upiId      = 'your@upi';          // e.g. yourname@paytm
  static const _paypalUrl  = 'https://paypal.me/yourhandle';
  static const _kofiUrl    = 'https://ko-fi.com/yourhandle';
  static const _upiName    = 'Reclaim App';
  // ────────────────────────────────────────────────────────────────────

  Future<void> _launchUrl(BuildContext context, String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not open payment link.')),
        );
      }
    }
  }

  Future<void> _launchUpi(BuildContext context, int amount) async {
    final url =
        'upi://pay?pa=$_upiId&pn=${Uri.encodeComponent(_upiName)}'
        '&am=$amount&cu=INR&tn=${Uri.encodeComponent("Support Reclaim App")}';
    await _launchUrl(context, url);
  }

  void _copyUpi(BuildContext context) {
    Clipboard.setData(const ClipboardData(text: _upiId));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('UPI ID copied to clipboard.'),
        backgroundColor: AppColors.teal600,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.colBackground,
      appBar: AppBar(
        title: const Text('Support Reclaim'),
        backgroundColor: context.colSurface,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Hero
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF1A8C73), Color(0xFF2EB89A)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('🌱', style: TextStyle(fontSize: 40)),
                  const SizedBox(height: 14),
                  const Text(
                    'Keep Reclaim free\nfor everyone.',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.w700,
                      height: 1.3,
                    ),
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    'Reclaim is free, has no ads, and locks nothing away. '
                    'It runs on server costs and the goodwill of people like you.',
                    style: TextStyle(color: Colors.white70, fontSize: 14, height: 1.5),
                  ),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.favorite, size: 14, color: Colors.white),
                        SizedBox(width: 6),
                        Text(
                          '100% of donations go to server costs',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 28),

            // UPI quick-donate
            Text(
              'UPI — Quick Donate',
              style: Theme.of(context).textTheme.labelLarge,
            ),
            const SizedBox(height: 4),
            Text(
              'Works with GPay, PhonePe, Paytm, BHIM, and all UPI apps.',
              style: TextStyle(fontSize: 12, color: context.colTextSec),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                _AmountButton(label: '₹21',  onTap: () => _launchUpi(context, 21)),
                const SizedBox(width: 10),
                _AmountButton(label: '₹51',  onTap: () => _launchUpi(context, 51)),
                const SizedBox(width: 10),
                _AmountButton(label: '₹101', onTap: () => _launchUpi(context, 101)),
                const SizedBox(width: 10),
                _AmountButton(label: '₹251', onTap: () => _launchUpi(context, 251)),
              ],
            ),
            const SizedBox(height: 12),

            // UPI ID copy row
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: context.colSurface,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: context.colBorder),
              ),
              child: Row(
                children: [
                  const Icon(Icons.account_balance_wallet_outlined,
                      size: 18, color: AppColors.teal600),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'UPI ID',
                          style: TextStyle(fontSize: 11, color: context.colTextHint),
                        ),
                        Text(
                          _upiId,
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            color: context.colText,
                          ),
                        ),
                      ],
                    ),
                  ),
                  TextButton.icon(
                    onPressed: () => _copyUpi(context),
                    icon: const Icon(Icons.copy, size: 14),
                    label: const Text('Copy'),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 28),

            // International options
            Text(
              'International Donations',
              style: Theme.of(context).textTheme.labelLarge,
            ),
            const SizedBox(height: 12),
            _DonationOptionCard(
              emoji: '☕',
              title: 'Ko-fi — Buy Me a Coffee',
              subtitle: 'One-time or recurring. Any amount. No account needed.',
              buttonLabel: 'Open Ko-fi',
              buttonColor: const Color(0xFFFF5E5B),
              onTap: () => _launchUrl(context, _kofiUrl),
            ),
            const SizedBox(height: 10),
            _DonationOptionCard(
              emoji: '🅿️',
              title: 'PayPal',
              subtitle: 'Secure international donation via PayPal.',
              buttonLabel: 'Open PayPal',
              buttonColor: const Color(0xFF003087),
              onTap: () => _launchUrl(context, _paypalUrl),
            ),
            const SizedBox(height: 32),

            // Why donate
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: context.colTint(AppColors.slate50, AppColors.slate50Dk),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Where does the money go?',
                    style: Theme.of(context).textTheme.labelLarge,
                  ),
                  const SizedBox(height: 12),
                  ...[
                    ('🔥', 'Firebase hosting & database (Firestore, Auth, Storage)'),
                    ('📨', 'Push notifications & email infrastructure'),
                    ('🛠️', 'Development time & maintenance'),
                    ('🌍', 'Keeping the app completely free for everyone'),
                  ].map((item) => Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(item.$1, style: const TextStyle(fontSize: 16)),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            item.$2,
                            style: TextStyle(
                              fontSize: 13,
                              height: 1.4,
                              color: context.colTextSec,
                            ),
                          ),
                        ),
                      ],
                    ),
                  )),
                ],
              ),
            ),
            const SizedBox(height: 20),

            Center(
              child: Text(
                'No donation is too small. Thank you. 🙏',
                style: TextStyle(
                  fontSize: 13,
                  color: context.colTextSec,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
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
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: AppColors.teal50,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: AppColors.teal400),
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
      ),
    );
  }
}

class _DonationOptionCard extends StatelessWidget {
  const _DonationOptionCard({
    required this.emoji,
    required this.title,
    required this.subtitle,
    required this.buttonLabel,
    required this.buttonColor,
    required this.onTap,
  });

  final String emoji, title, subtitle, buttonLabel;
  final Color buttonColor;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: context.colSurface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: context.colBorder),
      ),
      child: Row(
        children: [
          Text(emoji, style: const TextStyle(fontSize: 26)),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                    color: context.colText,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: TextStyle(fontSize: 12, color: context.colTextSec),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          ElevatedButton(
            onPressed: onTap,
            style: ElevatedButton.styleFrom(
              backgroundColor: buttonColor,
              foregroundColor: Colors.white,
              minimumSize: Size.zero,
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              textStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
            ),
            child: Text(buttonLabel),
          ),
        ],
      ),
    );
  }
}

