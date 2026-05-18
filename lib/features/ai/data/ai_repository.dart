import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;

import '../../../core/config/app_config.dart';
import '../../portfolio/data/local/project_draft_store.dart';
import '../../portfolio/domain/project_creation_models.dart';
import '../domain/ai_generation_models.dart';
import '../domain/ai_prompt.dart';
import '../domain/builders/portfolio_prompt_builder.dart';
import 'services/mock_ai_service.dart';
import 'services/openai_client.dart';

final httpClientProvider = Provider<http.Client>((ref) {
  final client = http.Client();
  ref.onDispose(client.close);
  return client;
});

final openAiClientProvider = Provider<OpenAiClient>((ref) {
  return OpenAiClient(
    httpClient: ref.watch(httpClientProvider),
    apiKey: const String.fromEnvironment('OPENAI_API_KEY'),
    model: const String.fromEnvironment('OPENAI_MODEL', defaultValue: 'gpt-5.2'),
  );
});

final portfolioPromptBuilderProvider = Provider<PortfolioPromptBuilder>((ref) {
  return const PortfolioPromptBuilder();
});

final mockAiServiceProvider = Provider<MockAiService>((ref) {
  return const MockAiService();
});

final aiRepositoryProvider = Provider<AiRepository>((ref) {
  return AiRepository(
    openAiClient: ref.watch(openAiClientProvider),
    promptBuilder: ref.watch(portfolioPromptBuilderProvider),
    mockAiService: ref.watch(mockAiServiceProvider),
    draftStore: ref.watch(projectDraftStoreProvider),
  );
});

class AiRepository {
  const AiRepository({
    required this.openAiClient,
    required this.promptBuilder,
    required this.mockAiService,
    required this.draftStore,
  });

  final OpenAiClient openAiClient;
  final PortfolioPromptBuilder promptBuilder;
  final MockAiService mockAiService;
  final ProjectDraftStore draftStore;

  Future<AiDraft> generateDraft(AiPrompt prompt) async {
    final request = AiGenerationRequest(
      type: AiGenerationType.projectSummary,
      profession: prompt.goal,
      tone: prompt.tone,
      portfolioData: PortfolioData(
        ownerName: 'Portique Creator',
        projects: [
          PortfolioProjectDraft(
            name: prompt.goal,
            shortDescription: prompt.context,
            bulletPoints: [prompt.context],
          ),
        ],
      ),
    );
    final text = await generateText(request);
    return AiDraft(title: 'AI-polished ${prompt.goal}', body: text);
  }

  Future<AiGeneratedContent> generatePortfolioPackage({
    required String profession,
    required String tone,
  }) async {
    final portfolioData = await buildPortfolioData();
    final headline = await generateText(
      AiGenerationRequest(
        type: AiGenerationType.headline,
        profession: profession,
        tone: tone,
        portfolioData: portfolioData,
      ),
    );
    final about = await generateText(
      AiGenerationRequest(
        type: AiGenerationType.about,
        profession: profession,
        tone: tone,
        portfolioData: portfolioData,
      ),
    );
    final structureText = await generateText(
      AiGenerationRequest(
        type: AiGenerationType.structure,
        profession: profession,
        tone: tone,
        portfolioData: portfolioData,
      ),
    );

    final projectSummaries = <GeneratedPortfolioSection>[];
    for (final project in portfolioData.projects) {
      final summary = await generateText(
        AiGenerationRequest(
          type: AiGenerationType.projectSummary,
          profession: profession,
          tone: tone,
          portfolioData: portfolioData,
          project: project,
        ),
      );
      projectSummaries.add(
        GeneratedPortfolioSection(
          id: 'summary-${project.id ?? project.name.hashCode}',
          title: project.name.isEmpty ? 'Project summary' : project.name,
          body: summary,
          kind: 'projectSummary',
        ),
      );
    }

    return AiGeneratedContent(
      headline: headline,
      about: about,
      projectSummaries: projectSummaries,
      sections: [
        GeneratedPortfolioSection(id: 'headline', title: 'Headline', body: headline, kind: 'headline'),
        GeneratedPortfolioSection(id: 'about', title: 'About', body: about, kind: 'about'),
        GeneratedPortfolioSection(id: 'structure', title: 'Structure', body: structureText, kind: 'structure'),
      ],
      structure: structureText.split('\n').where((line) => line.trim().isNotEmpty).toList(),
    );
  }

  Future<String> generateText(AiGenerationRequest request) async {
    if (!openAiClient.isConfigured) {
      return mockAiService.generate(request);
    }

    final messages = promptBuilder.build(request);
    final response = await openAiClient.createResponse(messages: messages);
    return response.text;
  }

  Future<PortfolioData> buildPortfolioData() async {
    final draft = await draftStore.readDraft();
    return PortfolioData(
      ownerName: 'Portique Creator',
      projects: [if (draft != null) draft else _fallbackProject()],
    );
  }

  PortfolioProjectDraft _fallbackProject() {
    return const PortfolioProjectDraft(
      id: 'sample-project',
      name: 'Portique Launch System',
      shortDescription: 'A premium portfolio builder that turns project inputs into AI-ready case studies.',
      bulletPoints: [
        'Created a guided upload flow for project assets and proof points',
        'Prepared structured prompts for portfolio generation',
        'Designed a premium dark interface with responsive review states',
      ],
      tools: ['Flutter', 'Riverpod', 'Firebase', 'OpenAI'],
      tags: ['Portfolio', 'AI', 'Product Design'],
    );
  }
}
