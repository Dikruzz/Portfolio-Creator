class AiPrompt {
  const AiPrompt({
    required this.goal,
    required this.context,
    required this.tone,
  });

  final String goal;
  final String context;
  final String tone;
}

class AiDraft {
  const AiDraft({required this.title, required this.body});

  final String title;
  final String body;
}
