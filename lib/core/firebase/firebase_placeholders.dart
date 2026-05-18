import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Firebase is intentionally not initialized at bootstrap yet.
///
/// Run `flutterfire configure`, initialize Firebase in `main.dart` with the
/// generated `firebase_options.dart`, then change these providers to return
/// `FirebaseAuth.instance` and `FirebaseFirestore.instance`.
///
/// Firebase Auth will persist email, Google, and anonymous guest sessions on
/// supported platforms. Until Firebase is wired, Portique uses a local
/// SharedPreferences-backed placeholder session for development.
final firebaseAppProvider = Provider<FirebaseApp?>((ref) => null);
final firebaseAuthProvider = Provider<FirebaseAuth?>((ref) => null);
final firestoreProvider = Provider<FirebaseFirestore?>((ref) => null);
