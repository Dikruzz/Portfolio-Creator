# Portique

Portique is a premium, AI-assisted portfolio builder foundation for Flutter. The project is organized around feature modules, Riverpod state management, reusable UI primitives, a responsive design system, cinematic onboarding, and Firebase integration placeholders.

## What's included

- Flutter app entry point with `ProviderScope`
- Clean feature-first architecture
- Riverpod providers/controllers for app, onboarding, auth, portfolio, and AI flows
- Splash screen and Duolingo-inspired step-by-step onboarding flow
- Profession and style preference selection cards
- Dark premium Material 3 theme with subtle gradients and animation-ready UI primitives
- Responsive breakpoints and adaptive layout helpers
- Reusable components for cards, buttons, forms, shells, and loading states
- Firebase Auth/Firestore repository placeholders with Google, email, and anonymous guest auth paths
- Local SharedPreferences-backed auth session placeholder until Firebase is configured
- Guided project creation with autosaved local drafts, image picking, review, and AI preparation payloads
- AI repository placeholder ready for a backend, Firebase Function, or OpenAI proxy

## Local setup

> This repository contains the Flutter source foundation. If your clone does not yet have native platform folders, generate them locally with Flutter before running.

```bash
flutter pub get
flutter create . --platforms=ios,android,web,macos,windows,linux
flutter run
```

## Firebase setup

1. Create a Firebase project.
2. Install and run the FlutterFire CLI:

```bash
dart pub global activate flutterfire_cli
flutterfire configure
```

3. Wire the generated `lib/firebase_options.dart` into `lib/main.dart` when ready.
4. Update `lib/core/firebase/firebase_placeholders.dart` to return `FirebaseAuth.instance` and `FirebaseFirestore.instance`.
5. Configure Google Sign In for each target platform in Firebase/Google Cloud.
6. Replace remaining placeholder repository methods with production Firebase calls.

## Project structure

```text
lib/
  app/                 App shell, routes, and app-level providers
  core/                Cross-cutting config, Firebase placeholders, responsive system, theme, widgets
  features/            Feature modules: onboarding, auth, portfolio, AI
    onboarding/        Splash screen, cinematic intro, profession/style preference steps
    auth/              Google, email, guest, persistent-session auth flow
    portfolio/         Dashboard, drag ordering, guided project upload, review flow
  main.dart            Application bootstrap

test/                  Widget smoke tests
```
