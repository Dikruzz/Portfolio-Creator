import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Firebase is intentionally not initialized at bootstrap yet.
///
/// Run `flutterfire configure`, uncomment Firebase initialization in `main.dart`,
/// and replace these providers with live instances when production credentials are
/// available.
final firebaseAppProvider = Provider<FirebaseApp?>((ref) => null);
final firebaseAuthProvider = Provider<FirebaseAuth?>((ref) => null);
final firestoreProvider = Provider<FirebaseFirestore?>((ref) => null);
