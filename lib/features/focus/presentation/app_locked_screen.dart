import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../domain/focus_notifier.dart';
import '../../../core/theme/app_colors.dart';
import '../../../shared/widgets/donation_unlock_sheet.dart';

class AppLockedOverlay extends ConsumerStatefulWidget {
  const AppLockedOverlay({super.key});

  @override
  ConsumerState<AppLockedOverlay> createState() => _AppLockedOverlayState();
}

class _AppLockedOverlayState extends ConsumerState<AppLockedOverlay>
    with TickerProviderStateMixin {
  late final AnimationController _breathCtrl;
  late final Animation<double> _breathAnim;

  @override
  void initState() {
    super.initState();
    _breathCtrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat(reverse: true);
    _breathAnim = Tween<double>(begin: 0.85, end: 1.15).animate(
      CurvedAnimation(parent: _breathCtrl, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _breathCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final reason = ref.watch(lockReasonProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Material(
      color: isDark ? AppColors.backgroundDk : AppColors.background,
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Breathing circle
              ScaleTransition(
                scale: _breathAnim,
                child: Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: const RadialGradient(
                      colors: [AppColors.teal400, AppColors.teal900],
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.teal400.withValues(alpha: 0.4),
                        blurRadius: 30,
                        spreadRadius: 5,
                      ),
                    ],
                  ),
                  child: const Icon(Icons.self_improvement,
                      color: Colors.white, size: 52),
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'Breathe',
                style: TextStyle(
                  fontSize: 13,
                  color: AppColors.teal600,
                  fontWeight: FontWeight.w500,
                  letterSpacing: 2,
                ),
              ),
              const SizedBox(height: 40),

              Text(
                'App Locked',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w700,
                  color: isDark ? AppColors.textPrimaryDk : AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 16),
              if (reason != null)
                Text(
                  reason,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 15,
                    height: 1.6,
                    color: isDark ? AppColors.textSecondaryDk : AppColors.textSecondary,
                  ),
                ),
              const SizedBox(height: 12),
              _AffirmationText(),

              const SizedBox(height: 48),

              // Donate to unlock — primary CTA
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.teal600,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14)),
                  ),
                  icon: const Icon(Icons.favorite, size: 18),
                  label: const Text(
                    'Support Reclaim — Unlock 1 Hour',
                    style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15),
                  ),
                  onPressed: () => showDonationUnlockSheet(
                    context,
                    snoozeMinutes: 60,
                    headline: 'Unlock 1 More Hour',
                    subline:
                        'Reclaim is free and ad-free. A small donation keeps '
                        'the servers running and unlocks 1 hour for you.',
                    onGranted: () =>
                        ref.read(focusSettingsProvider.notifier).snooze(60),
                    onSkip: () =>
                        ref.read(focusSettingsProvider.notifier).snooze(10),
                  ),
                ),
              ),
              const SizedBox(height: 32),

              // Crisis bypass — always free, no donation gate
              TextButton.icon(
                onPressed: () =>
                    ref.read(focusSettingsProvider.notifier).snooze(10),
                icon: const Icon(Icons.emergency,
                    size: 16, color: AppColors.coral600),
                label: const Text(
                  'I need crisis support — open app',
                  style: TextStyle(color: AppColors.coral600, fontSize: 12),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}


class _AffirmationText extends StatelessWidget {
  static const _quotes = [
    '"The urge will pass. You don\'t have to act on it."',
    '"Step outside. The world is still there."',
    '"Your mind needs rest, not more screens."',
    '"Closing the app is an act of self-care."',
    '"Recovery happens in real life, not on a screen."',
    '"Every boundary you set is a promise to yourself."',
  ];

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final q = _quotes[DateTime.now().minute % _quotes.length];
    return Container(
      margin: const EdgeInsets.only(top: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? AppColors.teal50Dk : AppColors.teal50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.teal200.withValues(alpha: isDark ? 0.3 : 0.8),
        ),
      ),
      child: Text(
        q,
        textAlign: TextAlign.center,
        style: TextStyle(
          fontSize: 13,
          fontStyle: FontStyle.italic,
          color: isDark ? AppColors.textSecondaryDk : AppColors.teal900,
          height: 1.5,
        ),
      ),
    );
  }
}
