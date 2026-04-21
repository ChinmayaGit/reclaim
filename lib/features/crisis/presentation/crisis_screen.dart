import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../core/theme/app_colors.dart';
import '../data/crisis_data.dart';

const _kPrefCountry = 'crisis_selected_country';

class CrisisScreen extends ConsumerStatefulWidget {
  const CrisisScreen({super.key});

  @override
  ConsumerState<CrisisScreen> createState() => _CrisisScreenState();
}

class _CrisisScreenState extends ConsumerState<CrisisScreen>
    with SingleTickerProviderStateMixin {
  // ── Breathing ──────────────────────────────────────────────────────────────
  late AnimationController _breathCtrl;
  late Animation<double> _breathAnim;
  bool _isBreathing = false;
  String _breathPhase = 'Tap to start';
  int _breathStep = 0;
  final _steps = ['Inhale…', 'Hold…', 'Exhale…', 'Hold…'];
  final _durations = [4, 4, 4, 4];

  // ── Country selection ──────────────────────────────────────────────────────
  String? _selectedCountryName;
  bool _loadingPrefs = true;

  @override
  void initState() {
    super.initState();
    _breathCtrl = AnimationController(
        vsync: this, duration: const Duration(seconds: 4));
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
    _loadCountry();
  }

  Future<void> _loadCountry() async {
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getString(_kPrefCountry);
    if (!mounted) return;
    setState(() {
      _selectedCountryName = saved;
      _loadingPrefs = false;
    });
    if (saved == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _pickCountry());
    }
  }

  Future<void> _saveCountry(String name) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_kPrefCountry, name);
    if (!mounted) return;
    setState(() => _selectedCountryName = name);
  }

  CrisisCountry? get _country => _selectedCountryName == null
      ? null
      : kCrisisCountries.firstWhere(
          (c) => c.name == _selectedCountryName,
          orElse: () => kCrisisCountries.first,
        );

  // ── Country picker ─────────────────────────────────────────────────────────
  void _pickCountry() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      isDismissible: _selectedCountryName != null,
      enableDrag: _selectedCountryName != null,
      builder: (_) => _CountryPickerSheet(
        onSelected: (country) {
          Navigator.of(context).pop();
          _saveCountry(country.name);
        },
      ),
    );
  }

  // ── Breathing helpers ──────────────────────────────────────────────────────
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

  @override
  void dispose() {
    _breathCtrl.dispose();
    super.dispose();
  }

  // ── Build ──────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D1B2A),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.white,
        title: const Text('Crisis Support',
            style: TextStyle(color: Colors.white)),
        elevation: 0,
      ),
      body: _loadingPrefs
          ? const Center(
              child: CircularProgressIndicator(color: AppColors.teal400))
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
          // ── Emergency relapse button ─────────────────────────────────
          _EmergencyButton(onTrigger: () => _showRelapseFlow(context)),
          const SizedBox(height: 20),

          _groundingBanner(),
          const SizedBox(height: 24),
          _breathingSection(),
          const SizedBox(height: 28),
          _hotlinesSection(),
          const SizedBox(height: 24),
          _groundingTechnique(),
          const SizedBox(height: 40),
                ],
              ),
            ),
    );
  }

  // ── Grounding banner ───────────────────────────────────────────────────────
  void _showRelapseFlow(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      isDismissible: true,
      builder: (_) => const _RelapsePreventionSheet(),
    );
  }

  Widget _groundingBanner() {
    return Container(
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
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.w700)),
          SizedBox(height: 8),
          Text(
            'Take a breath. This moment will pass. You are stronger than this urge.',
            style: TextStyle(color: Colors.white70, fontSize: 14, height: 1.6),
          ),
        ],
      ),
    );
  }

  // ── Breathing section ──────────────────────────────────────────────────────
  Widget _breathingSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Breathing Exercise',
            style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
                fontSize: 16)),
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
                  width: size,
                  height: size,
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
                        style: const TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.w600),
                      ),
                      if (!_isBreathing)
                        const Text('Tap to begin',
                            style: TextStyle(
                                color: Colors.white54, fontSize: 12)),
                    ],
                  ),
                );
              },
            ),
          ),
        ),
      ],
    );
  }

  // ── Hotlines section ───────────────────────────────────────────────────────
  Widget _hotlinesSection() {
    final country = _country;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Text('Crisis Hotlines',
                style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                    fontSize: 16)),
            const Spacer(),
            if (country != null) ...[
              Text('${country.flag}  ${country.name}',
                  style: const TextStyle(
                      color: Colors.white70, fontSize: 13)),
              const SizedBox(width: 8),
              GestureDetector(
                onTap: _pickCountry,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: AppColors.teal400.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                        color: AppColors.teal400.withValues(alpha: 0.4)),
                  ),
                  child: const Text('Change',
                      style: TextStyle(
                          color: AppColors.teal400,
                          fontSize: 12,
                          fontWeight: FontWeight.w500)),
                ),
              ),
            ],
          ],
        ),
        const SizedBox(height: 14),
        if (country == null)
          _noCountryPlaceholder()
        else
          ...country.hotlines
              .map((h) => _HotlineTile(hotline: h)),
      ],
    );
  }

  Widget _noCountryPlaceholder() {
    return GestureDetector(
      onTap: _pickCountry,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
              color: AppColors.teal400.withValues(alpha: 0.4),
              style: BorderStyle.solid),
        ),
        child: Column(
          children: [
            Icon(Icons.public,
                color: AppColors.teal400.withValues(alpha: 0.7), size: 36),
            const SizedBox(height: 10),
            const Text('Select your country',
                style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                    fontSize: 15)),
            const SizedBox(height: 6),
            const Text(
              'Tap to choose your country and see relevant crisis hotlines.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.white54, fontSize: 13),
            ),
          ],
        ),
      ),
    );
  }

  // ── Grounding technique ────────────────────────────────────────────────────
  Widget _groundingTechnique() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.purple900.withValues(alpha: 0.6),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
            color: AppColors.purple400.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('5-4-3-2-1 Grounding',
              style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                  fontSize: 15)),
          const SizedBox(height: 12),
          ...['👁 5 things you can see',
            '✋ 4 things you can touch',
            '👂 3 things you can hear',
            '👃 2 things you can smell',
            '👅 1 thing you can taste'].map((s) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Text(s,
                  style: const TextStyle(
                      color: Colors.white70, fontSize: 13)),
            )),
        ],
      ),
    );
  }
}

// ── Hotline tile ───────────────────────────────────────────────────────────────

class _HotlineTile extends StatelessWidget {
  const _HotlineTile({required this.hotline});
  final CrisisHotline hotline;

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
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(hotline.name,
                    style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w500,
                        fontSize: 13)),
                const SizedBox(height: 3),
                Text(hotline.number,
                    style: const TextStyle(
                        color: Colors.white60, fontSize: 12)),
              ],
            ),
          ),
          const SizedBox(width: 12),
          _ActionButton(hotline: hotline),
        ],
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  const _ActionButton({required this.hotline});
  final CrisisHotline hotline;

  Future<void> _launch() async {
    final clean = hotline.number.replaceAll(RegExp(r'[\s\-]'), '');
    final uri = hotline.isText
        ? Uri.parse('sms:$clean')
        : Uri.parse('tel:$clean');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isText = hotline.isText;
    return GestureDetector(
      onTap: _launch,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: isText ? AppColors.teal400 : AppColors.coral400,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isText ? Icons.message_rounded : Icons.phone_rounded,
              color: Colors.white,
              size: 15,
            ),
            const SizedBox(width: 6),
            Text(
              isText ? 'Text' : 'Call',
              style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                  fontSize: 13),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Country picker bottom sheet ────────────────────────────────────────────────

class _CountryPickerSheet extends StatefulWidget {
  const _CountryPickerSheet({required this.onSelected});
  final void Function(CrisisCountry) onSelected;

  @override
  State<_CountryPickerSheet> createState() => _CountryPickerSheetState();
}

class _CountryPickerSheetState extends State<_CountryPickerSheet> {
  final _searchCtrl = TextEditingController();
  List<CrisisCountry> _filtered = kCrisisCountries;

  @override
  void initState() {
    super.initState();
    _searchCtrl.addListener(() {
      final q = _searchCtrl.text.trim().toLowerCase();
      setState(() {
        _filtered = q.isEmpty
            ? kCrisisCountries
            : kCrisisCountries
                .where((c) => c.name.toLowerCase().contains(q))
                .toList();
      });
    });
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final h = MediaQuery.of(context).size.height * 0.75;
    return Container(
      height: h,
      decoration: const BoxDecoration(
        color: Color(0xFF0D1B2A),
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        children: [
          // Handle
          const SizedBox(height: 12),
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.white24,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Title
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Select Your Country',
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w700)),
                SizedBox(height: 4),
                Text('We\'ll show crisis hotlines relevant to your region.',
                    style: TextStyle(color: Colors.white54, fontSize: 13)),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Search bar
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: TextField(
              controller: _searchCtrl,
              style: const TextStyle(color: Colors.white),
              cursorColor: AppColors.teal400,
              decoration: InputDecoration(
                hintText: 'Search country…',
                hintStyle:
                    const TextStyle(color: Colors.white38, fontSize: 14),
                prefixIcon: const Icon(Icons.search,
                    color: Colors.white38, size: 20),
                filled: true,
                fillColor: Colors.white.withValues(alpha: 0.07),
                contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16, vertical: 12),
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none),
                enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(
                        color: Colors.white.withValues(alpha: 0.1))),
                focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(
                        color: AppColors.teal400, width: 1.5)),
              ),
            ),
          ),
          const SizedBox(height: 12),

          // Country list
          Expanded(
            child: _filtered.isEmpty
                ? Center(
                    child: Text('No countries found',
                        style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.4),
                            fontSize: 14)),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: _filtered.length,
                    itemBuilder: (_, i) {
                      final c = _filtered[i];
                      return _CountryTile(
                        country: c,
                        onTap: () => widget.onSelected(c),
                      );
                    },
                  ),
          ),
          SizedBox(height: MediaQuery.of(context).padding.bottom + 12),
        ],
      ),
    );
  }
}

class _CountryTile extends StatelessWidget {
  const _CountryTile({required this.country, required this.onTap});
  final CrisisCountry country;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
        decoration: BoxDecoration(
          border: Border(
              bottom: BorderSide(
                  color: Colors.white.withValues(alpha: 0.06))),
        ),
        child: Row(
          children: [
            Text(country.flag, style: const TextStyle(fontSize: 26)),
            const SizedBox(width: 14),
            Expanded(
              child: Text(country.name,
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 15,
                      fontWeight: FontWeight.w500)),
            ),
            Text('${country.hotlines.length} lines',
                style: const TextStyle(
                    color: Colors.white38, fontSize: 12)),
            const SizedBox(width: 8),
            const Icon(Icons.chevron_right,
                color: Colors.white24, size: 18),
          ],
        ),
      ),
    );
  }
}

// ── Emergency Button ──────────────────────────────────────────────────────────

class _EmergencyButton extends StatelessWidget {
  const _EmergencyButton({required this.onTrigger});
  final VoidCallback onTrigger;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTrigger,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 18),
        decoration: BoxDecoration(
          color: AppColors.coral400.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
              color: AppColors.coral400.withValues(alpha: 0.7), width: 2),
        ),
        child: const Column(
          children: [
            Icon(Icons.warning_amber_rounded, color: AppColors.coral400, size: 32),
            SizedBox(height: 8),
            Text("I'm about to relapse",
                style: TextStyle(
                    color: AppColors.coral400,
                    fontSize: 17,
                    fontWeight: FontWeight.w800)),
            SizedBox(height: 4),
            Text('Tap for immediate help',
                style: TextStyle(color: Colors.white54, fontSize: 12)),
          ],
        ),
      ),
    );
  }
}

// ── Relapse Prevention Sheet ──────────────────────────────────────────────────

class _RelapsePreventionSheet extends StatefulWidget {
  const _RelapsePreventionSheet();

  @override
  State<_RelapsePreventionSheet> createState() => _RelapsePreventionSheetState();
}

class _RelapsePreventionSheetState extends State<_RelapsePreventionSheet> {
  int _step = 0;
  int _countdown = 5 * 60;
  Timer? _timer;

  static const _steps = [
    _RPStep(icon: Icons.pause_circle_outline, title: 'Pause right now', color: AppColors.coral400,
        body: 'Before you do anything — just stop. The urge feels urgent but it will peak and fade in 5–10 minutes.\n\nYou have done this before. You can do it again.'),
    _RPStep(icon: Icons.air_outlined, title: 'Take 5 deep breaths', color: AppColors.teal400,
        body: 'Inhale slowly for 4 counts.\nHold for 4 counts.\nExhale for 4 counts.\n\nDo this 5 times. Your nervous system will calm.'),
    _RPStep(icon: Icons.timer_outlined, title: 'Wait 5 minutes', color: AppColors.amber400, showTimer: true,
        body: 'Most cravings last under 20 minutes.\n\nStart the timer. Sit with the discomfort — don\'t fight it, just watch it. It will pass.'),
    _RPStep(icon: Icons.directions_walk, title: 'Change your location', color: AppColors.green400,
        body: 'Go to a different room. Step outside. Walk to the nearest window.\n\nA physical change breaks the mental loop. Movement releases natural dopamine.'),
    _RPStep(icon: Icons.phone_outlined, title: 'Reach out to someone', color: AppColors.purple400,
        body: 'Text or call someone you trust.\n\nYou don\'t have to explain everything. Just say "Hey, can we talk?" That connection is enough.'),
    _RPStep(icon: Icons.emoji_events_outlined, title: 'You made it through', color: AppColors.teal400,
        body: 'The urge passed. It always does.\n\nEvery time you face a craving and don\'t act on it, you get stronger. This moment built your discipline.'),
  ];

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _startTimer() {
    _timer?.cancel();
    setState(() => _countdown = 5 * 60);
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (_countdown > 0) {
        setState(() => _countdown--);
      } else {
        _timer?.cancel();
      }
    });
  }

  String get _countdownStr {
    final m = _countdown ~/ 60;
    final s = _countdown % 60;
    return '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final step = _steps[_step];
    final isLast = _step == _steps.length - 1;

    return Container(
      decoration: const BoxDecoration(
        color: Color(0xFF0D1B2A),
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: EdgeInsets.fromLTRB(
          24, 16, 24, MediaQuery.of(context).padding.bottom + 24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Center(
            child: Container(width: 40, height: 4,
                decoration: BoxDecoration(
                    color: Colors.white24, borderRadius: BorderRadius.circular(2))),
          ),
          const SizedBox(height: 16),
          // Progress dots
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(_steps.length, (i) => AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              margin: const EdgeInsets.symmetric(horizontal: 3),
              width: i == _step ? 20 : 6, height: 6,
              decoration: BoxDecoration(
                color: i == _step ? step.color : Colors.white24,
                borderRadius: BorderRadius.circular(3),
              ),
            )),
          ),
          const SizedBox(height: 24),
          Container(
            width: 64, height: 64,
            decoration: BoxDecoration(
              color: step.color.withValues(alpha: 0.15), shape: BoxShape.circle),
            child: Icon(step.icon, color: step.color, size: 30),
          ),
          const SizedBox(height: 16),
          Text(step.title, textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w800)),
          const SizedBox(height: 12),
          Text(step.body, textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.white70, fontSize: 14, height: 1.7)),
          if (step.showTimer) ...[
            const SizedBox(height: 20),
            GestureDetector(
              onTap: _startTimer,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                decoration: BoxDecoration(
                  color: AppColors.amber400.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: AppColors.amber400.withValues(alpha: 0.5)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(_timer?.isActive == true
                        ? Icons.timer : Icons.play_circle_outline,
                        color: AppColors.amber400),
                    const SizedBox(width: 10),
                    Text(_countdownStr,
                        style: const TextStyle(
                            color: AppColors.amber400, fontSize: 28,
                            fontWeight: FontWeight.w800,
                            fontFeatures: [FontFeature.tabularFigures()])),
                  ],
                ),
              ),
            ),
          ],
          const SizedBox(height: 28),
          Row(
            children: [
              if (_step > 0) ...[
                Expanded(
                  child: OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.white54,
                      side: const BorderSide(color: Colors.white24),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    onPressed: () => setState(() => _step--),
                    child: const Text('Back'),
                  ),
                ),
                const SizedBox(width: 12),
              ],
              Expanded(
                flex: 2,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: step.color,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  onPressed: isLast
                      ? () => Navigator.pop(context)
                      : () => setState(() => _step++),
                  child: Text(isLast ? "I'm okay now" : 'Next',
                      style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15)),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _RPStep {
  const _RPStep({
    required this.icon,
    required this.title,
    required this.body,
    required this.color,
    this.showTimer = false,
  });
  final IconData icon;
  final String title, body;
  final Color color;
  final bool showTimer;
}
