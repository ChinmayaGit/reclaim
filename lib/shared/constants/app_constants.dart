class AppConstants {
  // Roles
  static const String roleGuest = 'guest';
  static const String roleFree = 'free';
  static const String rolePremium = 'premium';
  static const String roleCounselor = 'counselor';
  static const String roleAdmin = 'admin';

  // Sub-roles
  static const String subRoleTrial = 'trial';
  static const String subRoleScholar = 'scholar';
  static const String subRoleTherapist = 'therapist';
  static const String subRolePeer = 'peer';
  static const String subRoleCrisis = 'crisis';

  // Recovery types
  static const List<String> recoveryTypes = [
    'addiction',
    'breakup',
    'trauma',
    'stress',
  ];

  static const Map<String, String> recoveryTypeLabels = {
    'addiction': 'Addiction Recovery',
    'breakup': 'Breakup & Heartbreak',
    'trauma': 'Trauma & Grief',
    'stress': 'Stress & Anxiety',
  };

  static const Map<String, List<String>> recoverySubTypes = {
    'addiction': ['alcohol', 'drugs', 'gambling', 'smoking', 'social_media', 'other'],
    'breakup': ['romantic', 'divorce', 'friendship', 'family'],
    'trauma': ['grief', 'abuse', 'accident', 'ptsd', 'other'],
    'stress': ['work', 'relationships', 'health', 'financial', 'other'],
  };

  // Mood emojis (1–5)
  static const List<String> moodEmojis = ['😞', '😕', '😐', '🙂', '😄'];
  static const List<String> moodLabels = ['Very Low', 'Low', 'Neutral', 'Good', 'Great'];

  // Emotion tags
  static const List<String> emotionTags = [
    'anxious', 'calm', 'hopeful', 'sad', 'angry',
    'grateful', 'lonely', 'proud', 'confused', 'relieved',
    'overwhelmed', 'motivated', 'numb', 'joyful', 'frustrated',
  ];

  // Milestone days
  static const List<int> milestoneDays = [1, 3, 7, 14, 30, 60, 90, 180, 365];

  // Free tier limits
  static const int freeJournalLimit = 10;
  static const int freeTrackerLimit = 1;

  // Storage paths
  static const String storageProfiles = 'profiles';
  static const String storageJournalVoice = 'journal/{uid}/voice';
  static const String storageJournalPhotos = 'journal/{uid}/photos';
  static const String storageMedical = 'medical/{uid}';
  static const String storageReports = 'reports/{uid}';
  static const String storageResources = 'resources';
  static const String storageExports = 'exports/{uid}';

  // Firestore collections
  static const String colUsers = 'users';
  static const String colJournal = 'journalEntries';
  static const String colTrackers = 'trackers';
  static const String colMoodCheckins = 'moodCheckins';
  static const String colCommunity = 'communityGroups';
  static const String colCommunityPosts = 'communityPosts';
  static const String colSessions = 'sessions';
  static const String colResources = 'resources';
  static const String colCrisis = 'crisis';

  // Navigation routes
  static const String routeLogin = '/login';
  static const String routeRegister = '/register';
  static const String routeOnboarding = '/onboarding';
  static const String routeHome = '/home';
  static const String routeDashboard = '/dashboard';
  static const String routeJournal = '/journal';
  static const String routeTracker = '/tracker';
  static const String routeResources = '/resources';
  static const String routeCommunity = '/community';
  static const String routeSessions = '/sessions';
  static const String routeCrisis = '/crisis';
  static const String routeReports = '/reports';
  static const String routeSettings = '/settings';
  static const String routeAdmin = '/admin';
  static const String routeUpgrade = '/upgrade';
  static const String routeDonation = '/donation';
  static const String routeFocus = '/focus';
  static const String routeAmbient = '/ambient';
  static const String routeResourceDetail = '/resources/detail';
  static const String routeCravingShield = '/craving-shield';

  // ── Phase 1 health routes ──────────────────────────────────────────────────
  static const String routeWater      = '/water';
  static const String routeSleep      = '/sleep';
  static const String routeDiscipline = '/discipline';
  static const String routeWorkoutLog = '/workout-log';
}
