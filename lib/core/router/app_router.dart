import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/providers/core_providers.dart';
import '../../shared/constants/app_constants.dart';
import '../../features/auth/presentation/login_screen.dart';
import '../../features/auth/presentation/register_screen.dart';
import '../../features/auth/presentation/onboarding_screen.dart';
import '../../features/dashboard/presentation/dashboard_screen.dart';
import '../../features/journal/presentation/journal_list_screen.dart';
import '../../features/journal/presentation/entry_editor_screen.dart';
import '../../features/tracker/presentation/tracker_screen.dart';
import '../../features/tracker/presentation/milestones_screen.dart';
import '../../features/resources/presentation/resources_screen.dart';
import '../../features/community/presentation/community_screen.dart';
import '../../features/sessions/presentation/sessions_screen.dart';
import '../../features/crisis/presentation/crisis_screen.dart';
import '../../features/reports/presentation/reports_screen.dart';
import '../../features/settings/presentation/settings_screen.dart';
import '../../features/admin/presentation/admin_screen.dart';
import '../../features/donation/presentation/donation_screen.dart';
import '../../features/focus/presentation/focus_screen.dart';
import '../../features/focus/presentation/craving_shield_screen.dart';
import '../../features/resources/presentation/ambient_player_screen.dart';
import '../../features/resources/presentation/resource_detail_screen.dart';
import '../../features/resources/data/resource_model.dart';
import '../../features/health/presentation/water_screen.dart';
import '../../features/health/presentation/sleep_screen.dart';
import '../../features/discipline/presentation/discipline_screen.dart';
import '../../features/workout_log/presentation/workout_log_screen.dart';
import '../navigation/nav_key.dart';
import '../shell/main_shell.dart';

final _shellNavigatorKey = GlobalKey<NavigatorState>();

// Notifies GoRouter when auth state changes so redirect is re-evaluated
// without recreating the entire GoRouter instance.
class _RouterNotifier extends ChangeNotifier {
  void refresh() => notifyListeners();
}

final appRouterProvider = Provider<GoRouter>((ref) {
  final notifier = _RouterNotifier();

  // Listen (not watch) so auth/profile changes trigger a redirect refresh
  // but do NOT rebuild this provider or recreate GoRouter.
  ref.listen(authStateProvider, (_, __) => notifier.refresh());
  ref.listen(userProfileProvider, (_, __) => notifier.refresh());

  return GoRouter(
    navigatorKey: rootNavigatorKey,
    initialLocation: AppConstants.routeLogin,
    refreshListenable: notifier,
    redirect: (context, state) {
      // ref.read — read latest values at redirect time without creating a dep
      final authState = ref.read(authStateProvider);
      final userProfile = ref.read(userProfileProvider);

      // Still loading — don't redirect yet
      if (authState.isLoading) return null;

      final isLoggedIn = authState.value != null;
      final isAuthRoute = state.matchedLocation == AppConstants.routeLogin ||
          state.matchedLocation == AppConstants.routeRegister;

      if (!isLoggedIn && !isAuthRoute) {
        return AppConstants.routeLogin;
      }

      if (isLoggedIn && isAuthRoute) {
        final profile = userProfile.value;
        if (profile != null && !profile.onboardingComplete) {
          return AppConstants.routeOnboarding;
        }
        return AppConstants.routeHome;
      }

      if (isLoggedIn) {
        final profile = userProfile.value;
        if (profile != null &&
            !profile.onboardingComplete &&
            state.matchedLocation != AppConstants.routeOnboarding) {
          return AppConstants.routeOnboarding;
        }
      }

      // Admin guard
      if (state.matchedLocation.startsWith(AppConstants.routeAdmin)) {
        final profile = userProfile.value;
        if (profile?.isAdmin != true) return AppConstants.routeHome;
      }

      return null;
    },
    routes: [
      // ─── Auth routes ────────────────────────────────────────────────────
      GoRoute(
        path: AppConstants.routeLogin,
        builder: (_, __) => const LoginScreen(),
      ),
      GoRoute(
        path: AppConstants.routeRegister,
        builder: (_, __) => const RegisterScreen(),
      ),
      GoRoute(
        path: AppConstants.routeOnboarding,
        builder: (_, __) => const OnboardingScreen(),
      ),

      // ─── Main shell (bottom nav) ─────────────────────────────────────────
      ShellRoute(
        navigatorKey: _shellNavigatorKey,
        builder: (_, __, child) => MainShell(child: child),
        routes: [
          GoRoute(
            path: AppConstants.routeHome,
            redirect: (_, __) => AppConstants.routeDashboard,
          ),
          GoRoute(
            path: AppConstants.routeDashboard,
            pageBuilder: (_, __) =>
                const NoTransitionPage(child: DashboardScreen()),
          ),
          GoRoute(
            path: AppConstants.routeJournal,
            pageBuilder: (_, __) =>
                const NoTransitionPage(child: JournalListScreen()),
            routes: [
              GoRoute(
                path: 'new',
                parentNavigatorKey: rootNavigatorKey,
                builder: (_, __) => const EntryEditorScreen(),
              ),
              GoRoute(
                path: 'edit/:id',
                parentNavigatorKey: rootNavigatorKey,
                builder: (_, state) =>
                    EntryEditorScreen(entryId: state.pathParameters['id']),
              ),
            ],
          ),
          GoRoute(
            path: AppConstants.routeTracker,
            pageBuilder: (_, __) =>
                const NoTransitionPage(child: TrackerScreen()),
            routes: [
              GoRoute(
                path: 'milestones',
                parentNavigatorKey: rootNavigatorKey,
                builder: (_, __) => const MilestonesScreen(),
              ),
            ],
          ),
          GoRoute(
            path: AppConstants.routeResources,
            pageBuilder: (_, __) =>
                const NoTransitionPage(child: ResourcesScreen()),
          ),
          GoRoute(
            path: AppConstants.routeCommunity,
            pageBuilder: (_, __) =>
                const NoTransitionPage(child: CommunityScreen()),
          ),
          GoRoute(
            path: AppConstants.routeFocus,
            pageBuilder: (_, __) =>
                const NoTransitionPage(child: FocusScreen()),
          ),
        ],
      ),

      // ─── Full-screen routes (no bottom nav) ─────────────────────────────
      GoRoute(
        path: AppConstants.routeSessions,
        builder: (_, __) => const SessionsScreen(),
      ),
      GoRoute(
        path: AppConstants.routeCrisis,
        builder: (_, __) => const CrisisScreen(),
      ),
      GoRoute(
        path: AppConstants.routeReports,
        builder: (_, __) => const ReportsScreen(),
      ),
      GoRoute(
        path: AppConstants.routeSettings,
        builder: (_, __) => const SettingsScreen(),
      ),
      GoRoute(
        path: AppConstants.routeAdmin,
        builder: (_, __) => const AdminScreen(),
      ),
      GoRoute(
        path: AppConstants.routeDonation,
        builder: (_, __) => const DonationScreen(),
      ),
      GoRoute(
        path: AppConstants.routeAmbient,
        builder: (_, state) {
          final trackId = state.uri.queryParameters['track'];
          return AmbientPlayerScreen(initialTrackId: trackId);
        },
      ),
      // Resource detail — outside ShellRoute so bottom nav is hidden
      GoRoute(
        path: AppConstants.routeResourceDetail,
        builder: (_, state) =>
            ResourceDetailScreen(resource: state.extra as ResourceItem),
      ),
      // Craving Shield — opened via notification tap or from Focus screen
      GoRoute(
        path: AppConstants.routeCravingShield,
        builder: (_, state) {
          final addiction = state.uri.queryParameters['addiction'] ?? 'other';
          return CravingShieldScreen(addictionKey: addiction);
        },
      ),

      // ── Phase 1 health routes ──────────────────────────────────────────────
      GoRoute(
        path: AppConstants.routeWater,
        builder: (_, __) => const WaterScreen(),
      ),
      GoRoute(
        path: AppConstants.routeSleep,
        builder: (_, __) => const SleepScreen(),
      ),
      GoRoute(
        path: AppConstants.routeDiscipline,
        builder: (_, __) => const DisciplineScreen(),
      ),
      GoRoute(
        path: AppConstants.routeWorkoutLog,
        builder: (_, __) => const WorkoutLogScreen(),
      ),
    ],
  );
});
