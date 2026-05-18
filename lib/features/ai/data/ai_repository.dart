import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/config/app_config.dart';
import '../domain/ai_prompt.dart';

final aiRepositoryProvider = Provider<AiRepository>((ref) {
  return const AiRepository();
});

class AiRepository {
  const AiRepository();

  Future<AiDraft> generateDraft(AiPrompt prompt) async {
    await Future<void>.delayed(const Duration(milliseconds: 450));

    return AiDraft(
      title: 'AI-polished ${prompt.goal}',
      body: 'Using a ${prompt.tone} tone, Portique will transform "${prompt.context}" into concise portfolio copy. Connect this method to ${appConfig.aiEndpoint} when your backend is ready.',
    );
  }
}
