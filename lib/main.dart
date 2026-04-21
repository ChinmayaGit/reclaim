import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'core/router/app_router.dart';
import 'core/navigation/nav_key.dart';
import 'core/theme/app_theme.dart';
import 'core/providers/theme_provider.dart';
import 'firebase_options.dart';
import 'services/local_notification_service.dart';

// Background FCM handler — must be top-level
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // Crashlytics
  FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterFatalError;
  PlatformDispatcher.instance.onError = (error, stack) {
    FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
    return true;
  };

  // FCM background handler
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  // Local notifications
  await LocalNotificationService.instance.init();

  runApp(const ProviderScope(child: ReclaimApp()));
}

class ReclaimApp extends ConsumerStatefulWidget {
  const ReclaimApp({super.key});

  @override
  ConsumerState<ReclaimApp> createState() => _ReclaimAppState();
}

class _ReclaimAppState extends ConsumerState<ReclaimApp> {
  @override
  void initState() {
    super.initState();
    // Handle notification taps that arrive while the app is running
    LocalNotificationService.instance.pendingRoute.addListener(_onPendingRoute);
  }

  @override
  void dispose() {
    LocalNotificationService.instance.pendingRoute.removeListener(_onPendingRoute);
    super.dispose();
  }

  void _onPendingRoute() {
    final route = LocalNotificationService.instance.pendingRoute.value;
    if (route == null) return;
    LocalNotificationService.instance.pendingRoute.value = null;
    // Delay slightly so the router is ready
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final ctx = rootNavigatorKey.currentContext;
      if (ctx != null && ctx.mounted) {
        // Use GoRouter via the context
        // ignore: use_build_context_synchronously
        rootNavigatorKey.currentContext?.go(route);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final router = ref.watch(appRouterProvider);
    final themeMode = ref.watch(themeModeProvider);

    return MaterialApp.router(
      title: 'Reclaim',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: themeMode,
      routerConfig: router,
    );
  }
}
