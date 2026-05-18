import 'package:flutter_riverpod/flutter_riverpod.dart';

final onboardingIndexProvider = StateProvider<int>((ref) => 0);
final onboardingCompletedProvider = StateProvider<bool>((ref) => false);
