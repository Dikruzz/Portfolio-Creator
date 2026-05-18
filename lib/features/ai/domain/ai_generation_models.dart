import '../../portfolio/domain/project_creation_models.dart';

enum AiGenerationType { headline, about, projectSummary, structure, fullPortfolio }

enum AiGenerationStatus { idle, loading, success, failure }

class AiGenerationRequest {
  const AiGenerationRequest({
    required this.type,
    required this.profession,
    required this.tone,
    required this.portfolioData,
    this.project,
  });

  final AiGenerationType type;
  final String profession;
  final String tone;
  final PortfolioData portfolioData;
  final PortfolioProjectDraft? project;
}

class AiGeneratedContent {
  const AiGeneratedContent({
    required this.headline,
    required this.about,
    required this.projectSummaries,
    required this.sections,
    required this.structure,
  });

  final String headline;
  final String about;
  final List<GeneratedPortfolioSection> projectSummaries;
  final List<GeneratedPortfolioSection> sections;
  final List<String> structure;

  factory AiGeneratedContent.empty() {
    return const AiGeneratedContent(
      headline: '',
      about: '',
      projectSummaries: [],
      sections: [],
      structure: [],
    );
  }

  AiGeneratedContent copyWith({
    String? headline,
    String? about,
    List<GeneratedPortfolioSection>? projectSummaries,
    List<GeneratedPortfolioSection>? sections,
    List<String>? structure,
  }) {
    return AiGeneratedContent(
      headline: headline ?? this.headline,
      about: about ?? this.about,
      projectSummaries: projectSummaries ?? this.projectSummaries,
      sections: sections ?? this.sections,
      structure: structure ?? this.structure,
    );
  }
}

class AiPromptMessage {
  const AiPromptMessage({required this.role, required this.content});

  final String role;
  final String content;

  Map<String, Object?> toJson() => {'role': role, 'content': content};
}

class OpenAiResponsePayload {
  const OpenAiResponsePayload({required this.text, this.rawJson});

  final String text;
  final Map<String, Object?>? rawJson;
}
