import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_colors.dart';
import '../../core/providers/core_providers.dart';
import '../../shared/constants/app_constants.dart';
import '../../features/focus/domain/focus_notifier.dart';
import '../../features/focus/presentation/app_locked_screen.dart';

class MainShell extends ConsumerStatefulWidget {
  const MainShell({super.key, required this.child});

  final Widget child;

  @override
  ConsumerState<MainShell> createState() => _MainShellState();
}

class _MainShellState extends ConsumerState<MainShell> {
  Timer? _ticker;

  @override
  void initState() {
    super.initState();
    // Tick the usage counter every second so isAppLockedProvider reacts live.
    _ticker = Timer.periodic(const Duration(seconds: 1), (_) {
      ref.read(usageNotifierProvider.notifier).tick();
    });
  }

  @override
  void dispose() {
    _ticker?.cancel();
    super.dispose();
  }

  static const _tabs = [
    _Tab(icon: Icons.book_outlined,     activeIcon: Icons.book,         label: 'Journal',   route: AppConstants.routeJournal),
    _Tab(icon: Icons.timer_outlined,    activeIcon: Icons.timer,        label: 'App Limit', route: AppConstants.routeFocus),
    _Tab(icon: Icons.home_outlined,     activeIcon: Icons.home,         label: 'Home',      route: AppConstants.routeDashboard),
    _Tab(icon: Icons.library_books_outlined, activeIcon: Icons.library_books, label: 'Resources', route: AppConstants.routeResources),
    _Tab(icon: Icons.people_outline,    activeIcon: Icons.people,       label: 'Community', route: AppConstants.routeCommunity),
  ];

  @override
  Widget build(BuildContext context) {
    final isLocked = ref.watch(isAppLockedProvider);

    // Show lock overlay on top of everything when the app is locked.
    if (isLocked) return const AppLockedOverlay();

    final location = GoRouterState.of(context).matchedLocation;
    ref.watch(isAdminProvider);

    int currentIndex = _tabs.indexWhere((t) => location.startsWith(t.route));
    if (currentIndex < 0) currentIndex = 0;

    final isDark = Theme.of(context).brightness == Brightness.dark;
    final navBg = isDark ? const Color(0xFF1E2633) : AppColors.surface;
    final sosBorder = isDark ? AppColors.coral600.withValues(alpha: 0.5) : AppColors.coral100;
    final sosBg = isDark ? const Color(0xFF2A1A1A) : AppColors.coral50;

    return Scaffold(
      body: widget.child,
      // No FAB — SOS lives in the bottom bar strip to avoid overlapping
      // child-screen FABs (e.g. community "Share" button).
      bottomNavigationBar: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // ── SOS Crisis strip ──────────────────────────────────────────
          Material(
            color: navBg,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(16, 6, 16, 0),
              decoration: BoxDecoration(
                border: Border(top: BorderSide(color: sosBorder, width: 1)),
              ),
              child: GestureDetector(
                onTap: () => context.push(AppConstants.routeCrisis),
                child: Container(
                  height: 34,
                  decoration: BoxDecoration(
                    color: sosBg,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: AppColors.coral400.withValues(alpha: 0.6)),
                  ),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.emergency, size: 14, color: AppColors.coral600),
                      SizedBox(width: 6),
                      Text(
                        'Crisis Support — tap if you need help now',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: AppColors.coral600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // ── Bottom navigation ─────────────────────────────────────────
          NavigationBar(
            selectedIndex: currentIndex,
            onDestinationSelected: (i) => context.go(_tabs[i].route),
            backgroundColor: navBg,
            indicatorColor: AppColors.teal50,
            destinations: _tabs.map((t) => NavigationDestination(
              icon: Icon(t.icon),
              selectedIcon: Icon(t.activeIcon, color: AppColors.teal600),
              label: t.label,
            )).toList(),
          ),
        ],
      ),
    );
  }
}

class _Tab {
  const _Tab({
    required this.icon,
    required this.activeIcon,
    required this.label,
    required this.route,
  });

  final IconData icon;
  final IconData activeIcon;
  final String label;
  final String route;
}
