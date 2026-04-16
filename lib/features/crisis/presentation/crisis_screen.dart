import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../core/theme/app_colors.dart';

class CrisisScreen extends ConsumerStatefulWidget {
  const CrisisScreen({super.key});

  @override
  ConsumerState<CrisisScreen> createState() => _CrisisScreenState();
}

class _CrisisScreenState extends ConsumerState<CrisisScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _breathCtrl;
  late Animation<double> _breathAnim;
  bool _isBreathing = false;
  String _breathPhase = 'Tap to start';
  int _breathStep = 0;
  final _steps = ['Inhale…', 'Hold…', 'Exhale…', 'Hold…'];
  final _durations = [4, 4, 4, 4]; // Box breathing: 4-4-4-4

  @override
  void initState() {
    super.initState();
    _breathCtrl = AnimationController(vsync: this, duration: const Duration(seconds: 4));
    _breathAnim = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(parent: _breathCtrl, curve: Curves.easeInOut),
    );
    _breathCtrl.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        setState(() => _breathStep = (_breathStep + 1) % 4);
        _breathPhase = _steps[_breathStep];
        _breathCtrl.duration = Duration(seconds: _durations[_breathStep]);
        if (_breathStep % 2 == 0) {
          _breathCtrl.forward(from: 0);
        } else {
          _breathCtrl.reverse(from: 1);
        }
      }
    });
  }

  @override
  void dispose() {
    _breathCtrl.dispose();
    super.dispose();
  }

  void _toggleBreathing() {
    setState(() {
      _isBreathing = !_isBreathing;
      if (_isBreathing) {
        _breathStep = 0;
        _breathPhase = _steps[0];
        _breathCtrl.duration = Duration(seconds: _durations[0]);
        _breathCtrl.forward(from: 0);
      } else {
        _breathCtrl.stop();
        _breathPhase = 'Tap to start';
      }
    });
  }

  static const _hotlines = [
    _Hotline('iCall (India)', '9152987821', '🇮🇳'),
    _Hotline('Vandrevala Foundation', '1860-2662-345', '🇮🇳'),
    _Hotline('AASRA', '9820466627', '🇮🇳'),
    _Hotline('Crisis Text Line (US)', '741741', '🇺🇸', isText: true),
    _Hotline('National Suicide Prevention (US)', '988', '🇺🇸'),
    _Hotline('Samaritans (UK)', '116 123', '🇬🇧'),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D1B2A),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.white,
        title: const Text('Crisis Support', style: TextStyle(color: Colors.white)),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Grounding banner
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.teal900,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.teal400.withValues(alpha: 0.4)),
              ),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('You\'re safe right now.',
                      style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w700)),
                  SizedBox(height: 8),
                  Text(
                    'Take a breath. This moment will pass. You are stronger than this urge.',
                    style: TextStyle(color: Colors.white70, fontSize: 14, height: 1.6),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Breathing exercise
            const Text('Breathing Exercise',
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 16)),
            const SizedBox(height: 6),
            const Text('Box breathing: calm your nervous system in 2 minutes.',
                style: TextStyle(color: Colors.white54, fontSize: 12)),
            const SizedBox(height: 20),

            Center(
              child: GestureDetector(
                onTap: _toggleBreathing,
                child: AnimatedBuilder(
                  animation: _breathAnim,
                  builder: (_, __) {
                    final size = 160.0 + (_breathAnim.value * 60);
                    return Container(
                      width: size, height: size,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppColors.teal400.withValues(alpha: 0.2),
                        border: Border.all(color: AppColors.teal400, width: 2),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            _isBreathing ? _breathPhase : 'Start',
                            style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w600),
                          ),
                          if (!_isBreathing)
                            const Text('Tap to begin',
                                style: TextStyle(color: Colors.white54, fontSize: 12)),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ),
            const SizedBox(height: 28),

            // Hotlines
            const Text('Crisis Hotlines',
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 16)),
            const SizedBox(height: 14),
            ..._hotlines.map((h) => _HotlineTile(hotline: h)),
            const SizedBox(height: 24),

            // Grounding technique
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: AppColors.purple900.withValues(alpha: 0.6),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppColors.purple400.withValues(alpha: 0.3)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('5-4-3-2-1 Grounding',
                      style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 15)),
                  const SizedBox(height: 12),
                  ...['👁 5 things you can see',
                    '✋ 4 things you can touch',
                    '👂 3 things you can hear',
                    '👃 2 things you can smell',
                    '👅 1 thing you can taste'].map((s) => Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Text(s, style: const TextStyle(color: Colors.white70, fontSize: 13)),
                    )),
                ],
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}

class _Hotline {
  const _Hotline(this.name, this.number, this.flag, {this.isText = false});
  final String name, number, flag;
  final bool isText;
}

class _HotlineTile extends StatelessWidget {
  const _HotlineTile({required this.hotline});
  final _Hotline hotline;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
      ),
      child: Row(
        children: [
          Text(hotline.flag, style: const TextStyle(fontSize: 22)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(hotline.name, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w500, fontSize: 13)),
                Text(hotline.number, style: const TextStyle(color: Colors.white60, fontSize: 12)),
              ],
            ),
          ),
          GestureDetector(
            onTap: () async {
              final uri = hotline.isText
                  ? Uri.parse('sms:${hotline.number}')
                  : Uri.parse('tel:${hotline.number}');
              if (await canLaunchUrl(uri)) launchUrl(uri);
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: hotline.isText ? AppColors.teal400 : AppColors.coral400,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                hotline.isText ? 'Text' : 'Call',
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 13),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
