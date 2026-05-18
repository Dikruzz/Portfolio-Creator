import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/ai_repository.dart';
import '../domain/ai_prompt.dart';

final aiControllerProvider = StateNotifierProvider<AiController, AsyncValue<AiDraft?>>((ref) {
  return AiController(ref.read(aiRepositoryProvider));
});

class AiController extends StateNotifier<AsyncValue<AiDraft?>> {
  AiController(this._repository) : super(const AsyncValue.data(null));

  final AiRepository _repository;

  Future<void> generate(AiPrompt prompt) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => _repository.generateDraft(prompt));
  }
}
