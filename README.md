# Portique

Portique is a premium, AI-assisted portfolio builder foundation for Flutter. The project is organized around feature modules, Riverpod state management, reusable UI primitives, a responsive design system, and Firebase integration placeholders.

## What's included

- Flutter app entry point with `ProviderScope`
- Clean feature-first architecture
- Riverpod providers/controllers for app, onboarding, auth, portfolio, and AI flows
- Dark premium Material 3 theme
- Responsive breakpoints and adaptive layout helpers
- Reusable components for cards, buttons, forms, shells, and loading states
- Firebase Auth/Firestore repository placeholders
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
4. Replace placeholder repository methods with production Firebase calls.

## Project structure

```text
lib/
  app/                 App shell, routes, and app-level providers
  core/                Cross-cutting config, Firebase placeholders, responsive system, theme, widgets
  features/            Feature modules: onboarding, auth, portfolio, AI
  main.dart            Application bootstrap

test/                  Widget smoke tests
```
