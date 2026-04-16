import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../domain/auth_notifier.dart';
import '../../../core/providers/core_providers.dart';
import '../../../core/theme/app_colors.dart';
import '../../../shared/constants/app_constants.dart';
import '../../../shared/widgets/reclaim_button.dart';

class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  final _pageCtrl = PageController();
  int _currentPage = 0;
  final int _totalPages = 3;

  List<String> _selectedTypes = [];
  String? _selectedSubType;
  DateTime _sobrietyDate = DateTime.now();

  void _next() {
    if (_currentPage < _totalPages - 1) {
      _pageCtrl.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      _finish();
    }
  }

  Future<void> _finish() async {
    final uid = ref.read(currentUserProvider)?.uid;
    if (uid == null) return;
    await ref.read(authNotifierProvider.notifier).completeOnboarding(
      uid,
      recoveryTypes: _selectedTypes,
      recoverySubType: _selectedSubType ?? '',
      sobrietyDate: _sobrietyDate,
    );
    if (mounted) context.go(AppConstants.routeHome);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            // Progress bar
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 20, 24, 0),
              child: Row(
                children: List.generate(_totalPages, (i) => Expanded(
                  child: Container(
                    height: 4,
                    margin: EdgeInsets.only(right: i < _totalPages - 1 ? 6 : 0),
                    decoration: BoxDecoration(
                      color: i <= _currentPage ? AppColors.teal400 : AppColors.slate200,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                )),
              ),
            ),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Step ${_currentPage + 1} of $_totalPages',
                      style: theme.textTheme.bodySmall),
                  if (_currentPage == 0)
                    TextButton(
                      onPressed: _finish,
                      child: const Text('Skip'),
                    ),
                ],
              ),
            ),
            Expanded(
              child: PageView(
                controller: _pageCtrl,
                physics: const NeverScrollableScrollPhysics(),
                onPageChanged: (p) => setState(() => _currentPage = p),
                children: [
                  _RecoveryTypePage(
                    selected: _selectedTypes,
                    onChanged: (types) => setState(() => _selectedTypes = types),
                  ),
                  _SubTypePage(
                    types: _selectedTypes,
                    selected: _selectedSubType,
                    onChanged: (s) => setState(() => _selectedSubType = s),
                  ),
                  _SobrietyDatePage(
                    date: _sobrietyDate,
                    onChanged: (d) => setState(() => _sobrietyDate = d),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(24),
              child: ReclaimButton(
                label: _currentPage == _totalPages - 1 ? 'Start My Journey' : 'Continue',
                onPressed: _next,
                icon: _currentPage == _totalPages - 1 ? Icons.check : null,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _RecoveryTypePage extends StatelessWidget {
  const _RecoveryTypePage({required this.selected, required this.onChanged});
  final List<String> selected;
  final ValueChanged<List<String>> onChanged;

  static const _items = [
    _TypeItem('addiction', '🔗', 'Addiction', 'Substance or behavioural addiction', AppColors.coral50, AppColors.coral400),
    _TypeItem('breakup', '💔', 'Breakup & Loss', 'Heartbreak, divorce, or relationship grief', AppColors.purple50, AppColors.purple400),
    _TypeItem('trauma', '🌧', 'Trauma & Grief', 'Processing past trauma or loss', AppColors.amber50, AppColors.amber400),
    _TypeItem('stress', '😤', 'Stress & Anxiety', 'Managing daily stress and anxiety', AppColors.teal50, AppColors.teal400),
  ];

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('What brings you here?', style: Theme.of(context).textTheme.displaySmall),
          const SizedBox(height: 6),
          Text('Select all that apply — we\'ll personalise your journey.',
              style: Theme.of(context).textTheme.bodyMedium),
          const SizedBox(height: 24),
          ..._items.map((item) {
            final isSelected = selected.contains(item.key);
            return GestureDetector(
              onTap: () {
                final list = [...selected];
                isSelected ? list.remove(item.key) : list.add(item.key);
                onChanged(list);
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: isSelected ? item.bgColor : AppColors.surface,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isSelected ? item.borderColor : AppColors.border,
                    width: isSelected ? 2 : 1,
                  ),
                ),
                child: Row(
                  children: [
                    Text(item.emoji, style: const TextStyle(fontSize: 24)),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(item.title,
                              style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                          Text(item.subtitle,
                              style: const TextStyle(color: AppColors.textSecondary, fontSize: 12)),
                        ],
                      ),
                    ),
                    if (isSelected)
                      Icon(Icons.check_circle, color: item.borderColor),
                  ],
                ),
              ),
            );
          }),
        ],
      ),
    );
  }
}

class _TypeItem {
  const _TypeItem(this.key, this.emoji, this.title, this.subtitle, this.bgColor, this.borderColor);
  final String key, emoji, title, subtitle;
  final Color bgColor, borderColor;
}

class _SubTypePage extends StatelessWidget {
  const _SubTypePage({required this.types, required this.selected, required this.onChanged});
  final List<String> types;
  final String? selected;
  final ValueChanged<String?> onChanged;

  @override
  Widget build(BuildContext context) {
    final subTypes = types.isNotEmpty
        ? (AppConstants.recoverySubTypes[types.first] ?? [])
        : AppConstants.recoverySubTypes['addiction']!;

    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Tell us more', style: Theme.of(context).textTheme.displaySmall),
          const SizedBox(height: 6),
          Text('This helps us personalise your content.', style: Theme.of(context).textTheme.bodyMedium),
          const SizedBox(height: 24),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: subTypes.map((sub) {
              final isSelected = selected == sub;
              return ChoiceChip(
                label: Text(sub.replaceAll('_', ' ').toUpperCase()),
                selected: isSelected,
                selectedColor: AppColors.teal50,
                onSelected: (_) => onChanged(isSelected ? null : sub),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}

class _SobrietyDatePage extends StatelessWidget {
  const _SobrietyDatePage({required this.date, required this.onChanged});
  final DateTime date;
  final ValueChanged<DateTime> onChanged;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final days = DateTime.now().difference(date).inDays;

    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('When did you start?', style: theme.textTheme.displaySmall),
          const SizedBox(height: 6),
          Text('Your sobriety or healing start date.', style: theme.textTheme.bodyMedium),
          const SizedBox(height: 32),
          GestureDetector(
            onTap: () async {
              final picked = await showDatePicker(
                context: context,
                initialDate: date,
                firstDate: DateTime(2000),
                lastDate: DateTime.now(),
              );
              if (picked != null) onChanged(picked);
            },
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.teal50,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.teal100, width: 2),
              ),
              child: Row(
                children: [
                  const Icon(Icons.calendar_today, color: AppColors.teal600),
                  const SizedBox(width: 14),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${date.day}/${date.month}/${date.year}',
                        style: theme.textTheme.headlineSmall?.copyWith(color: AppColors.teal900),
                      ),
                      Text('Tap to change', style: theme.textTheme.bodySmall),
                    ],
                  ),
                ],
              ),
            ),
          ),
          if (days > 0) ...[
            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.green50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.green100),
              ),
              child: Row(
                children: [
                  const Text('🎉', style: TextStyle(fontSize: 24)),
                  const SizedBox(width: 12),
                  Text(
                    'You\'re already $days days in!\nThat\'s incredible.',
                    style: theme.textTheme.bodyMedium?.copyWith(color: AppColors.green600),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}
