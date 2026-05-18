import 'package:flutter_riverpod/flutter_riverpod.dart';

class OnboardingState {
  const OnboardingState({
    this.step = 0,
    this.professionId,
    this.styleId,
    this.completed = false,
  });

  final int step;
  final String? professionId;
  final String? styleId;
  final bool completed;

  static const totalSteps = 5;

  double get progress => (step + 1) / totalSteps;
  bool get canContinue {
    return switch (step) {
      3 => professionId != null,
      4 => styleId != null,
      _ => true,
    };
  }

  OnboardingState copyWith({
    int? step,
    String? professionId,
    String? styleId,
    bool? completed,
  }) {
    return OnboardingState(
      step: step ?? this.step,
      professionId: professionId ?? this.professionId,
      styleId: styleId ?? this.styleId,
      completed: completed ?? this.completed,
    );
  }
}

final onboardingControllerProvider = StateNotifierProvider<OnboardingController, OnboardingState>((ref) {
  return OnboardingController();
});

class OnboardingController extends StateNotifier<OnboardingState> {
  OnboardingController() : super(const OnboardingState());

  void next() {
    if (!state.canContinue) return;
    if (state.step >= OnboardingState.totalSteps - 1) {
      state = state.copyWith(completed: true);
      return;
    }
    state = state.copyWith(step: state.step + 1);
  }

  void back() {
    if (state.step == 0) return;
    state = state.copyWith(step: state.step - 1);
  }

  void selectProfession(String id) {
    state = state.copyWith(professionId: id);
  }

  void selectStyle(String id) {
    state = state.copyWith(styleId: id);
  }
}
