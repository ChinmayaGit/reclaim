<div align="center">

# Reclaim

**A mental health & addiction recovery companion built with Flutter + Firebase**

*Track your progress. Build discipline. Reclaim your life.*

</div>

---

## Screenshots

<div align="center">

<table>
  <tr>
    <td><img src="https://raw.githubusercontent.com/ChinmayaGit/reclaim/main/pics/photo_2026-05-11_01-33-46%20(10).jpg" width="200"/></td>
    <td><img src="https://raw.githubusercontent.com/ChinmayaGit/reclaim/main/pics/photo_2026-05-11_01-33-46%20(2).jpg" width="200"/></td>
    <td><img src="https://raw.githubusercontent.com/ChinmayaGit/reclaim/main/pics/photo_2026-05-11_01-33-46%20(3).jpg" width="200"/></td>
    <td><img src="https://raw.githubusercontent.com/ChinmayaGit/reclaim/main/pics/photo_2026-05-11_01-33-46%20(4).jpg" width="200"/></td>
  </tr>
  <tr>
    <td><img src="https://raw.githubusercontent.com/ChinmayaGit/reclaim/main/pics/photo_2026-05-11_01-33-46%20(5).jpg" width="200"/></td>
    <td><img src="https://raw.githubusercontent.com/ChinmayaGit/reclaim/main/pics/photo_2026-05-11_01-33-46%20(6).jpg" width="200"/></td>
    <td><img src="https://raw.githubusercontent.com/ChinmayaGit/reclaim/main/pics/photo_2026-05-11_01-33-46%20(7).jpg" width="200"/></td>
    <td><img src="https://raw.githubusercontent.com/ChinmayaGit/reclaim/main/pics/photo_2026-05-11_01-33-46%20(8).jpg" width="200"/></td>
  </tr>
  <tr>
    <td><img src="https://raw.githubusercontent.com/ChinmayaGit/reclaim/main/pics/photo_2026-05-11_01-33-46%20(9).jpg" width="200"/></td>
    <td><img src="https://raw.githubusercontent.com/ChinmayaGit/reclaim/main/pics/photo_2026-05-11_01-33-47.jpg.jpg" width="200"/></td>
    <td><img src="https://raw.githubusercontent.com/ChinmayaGit/reclaim/main/pics/photo_2026-05-11_01-33-46%20(11).jpg" width="200"/></td>
    <td><img src="https://raw.githubusercontent.com/ChinmayaGit/reclaim/main/pics/photo_2026-05-11_01-33-46%20(12).jpg" width="200"/></td>
  </tr>
  <tr>
    <td><img src="https://raw.githubusercontent.com/ChinmayaGit/reclaim/main/pics/photo_2026-05-11_01-33-46%20(13).jpg" width="200"/></td>
    <td><img src="https://raw.githubusercontent.com/ChinmayaGit/reclaim/main/pics/photo_2026-05-11_01-33-46%20(14).jpg" width="200"/></td>
    <td><img src="https://raw.githubusercontent.com/ChinmayaGit/reclaim/main/pics/photo_2026-05-11_01-33-46%20(15).jpg" width="200"/></td>
    <td><img src="https://raw.githubusercontent.com/ChinmayaGit/reclaim/main/pics/photo_2026-05-11_01-33-46%20(16).jpg" width="200"/></td>
  </tr>
</table>

</div>

---

## About

**Reclaim** is a Flutter application designed to support people on their journey through mental health challenges and addiction recovery. It combines habit tracking, journaling, focus tools, community support, and crisis resources into a single, privacy-aware app backed by Firebase.

---

## Features

| Module | Description |
|--------|-------------|
| **Dashboard** | Daily overview — streak counts, habit progress rings, day recap |
| **Recovery Tracker** | Track sobriety milestones, log urges, visualize progress over time |
| **Discipline / Habits** | Build custom habits with streaks, reminders, and completion tracking |
| **Focus Mode** | App & website blocker, craving shield, usage schedule management |
| **Journal** | Private journal entries with mood check-ins, sharing controls, and discovery feed |
| **Health** | Daily water intake and sleep logging |
| **Workout Log** | Log workouts, browse an exercise guide catalog, track fitness progress |
| **Resources** | Curated offline content — articles, audio guides, worksheets, ambient player |
| **Community** | Social feed with posts, reactions, and group discussions |
| **Crisis Support** | Country-specific emergency hotlines always one tap away |
| **Sessions** | Schedule and manage counselor sessions |
| **Settings** | Profile, notifications, preferences, and account management |
| **Donation** | Support the project from within the app |
| **Admin Panel** | User management and content moderation for admins |

---

## Tech Stack

**Frontend**
- Flutter (Android · iOS · Web)
- Riverpod 2.x — state management
- GoRouter — navigation & deep links
- fl_chart — recovery & progress charts
- google_fonts, cached_network_image

**Backend (Firebase)**
- Firebase Auth — email/password + Google Sign-In + custom role claims
- Cloud Firestore — real-time data sync
- Firebase Storage — media uploads
- Firebase Messaging — push notifications
- Cloud Functions — server-side logic
- Firebase Analytics, Crashlytics, Remote Config

**Audio & Media**
- just_audio + audio_session — ambient & guide audio playback
- webview_flutter — embedded video content
- image_picker — photo/media uploads

**Documents**
- pdf + printing — generate shareable progress reports

---

## Architecture

Clean 3-layer architecture per feature:

```
lib/
├── core/
│   ├── router/        # GoRouter config + auth guards
│   ├── shell/         # Bottom nav shell + SOS FAB
│   └── providers/     # Shared Riverpod providers (auth state, etc.)
└── features/
    └── <feature>/
        ├── data/          # Firebase data sources & repositories
        ├── domain/        # Models (Freezed), repository interfaces
        └── presentation/  # Screens, widgets, Riverpod notifiers
```

---

## User Roles

Access is controlled via **Firebase Custom Claims**:

| Role | Access |
|------|--------|
| `guest` | Onboarding, crisis hotlines, limited resources |
| `free` | Core tracking, journal, community (read), basic habits |
| `premium` | All free features + focus mode, workout log, counselor sessions |
| `counselor` | Sessions management, patient progress view |
| `admin` | Full admin panel, user and content management |

---

## Getting Started

### Prerequisites

- Flutter SDK `>=3.0.0`
- Dart SDK `>=3.0.0`
- A Firebase project

### 1. Clone the repo

```bash
git clone https://github.com/ChinmayaGit/reclaim.git
cd reclaim
```

### 2. Install dependencies

```bash
flutter pub get
```

### 3. Connect Firebase

Install the FlutterFire CLI and run configure to generate `firebase_options.dart`:

```bash
dart pub global activate flutterfire_cli
flutterfire configure
```

> The file at `lib/firebase_options.dart` is a placeholder. **The app will not run** until you replace it with values from your own Firebase project.

### 4. Run the app

```bash
flutter run
```

---

## Project Status

> Active development — some modules (`notifications`, `reports`) are scaffolded but not yet implemented.

---

## License

This project is for personal and educational use. See [LICENSE](LICENSE) for details.
