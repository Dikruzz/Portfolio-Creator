import '../../../portfolio/domain/project_creation_models.dart';
import '../ai_generation_models.dart';

class PortfolioPromptBuilder {
  const PortfolioPromptBuilder();

  static const developerInstructions = '''
You are Portique, a premium portfolio strategist and copy director.
Write polished, specific portfolio content that sounds human, confident, and concise.
Avoid generic superlatives. Use concrete project inputs, tools, tags, outcomes, and profession context.
Return only the requested content. No markdown fences.
''';

  List<AiPromptMessage> build(AiGenerationRequest request) {
    return [
      const AiPromptMessage(role: 'developer', content: developerInstructions),
      AiPromptMessage(role: 'user', content: _userPrompt(request)),
    ];
  }

  String buildPlainText(AiGenerationRequest request) {
    return build(request).map((message) => '${message.role.toUpperCase()}: ${message.content}').join('\n\n');
  }

  String _userPrompt(AiGenerationRequest request) {
    final portfolio = request.portfolioData;
    final project = request.project ?? (portfolio.projects.isEmpty ? null : portfolio.projects.first);
    final projectContext = project == null ? 'No project selected.' : _projectContext(project);
    final portfolioContext = portfolio.projects.map(_projectContext).join('\n---\n');

    return switch (request.type) {
      AiGenerationType.headline => '''
Generate 5 premium portfolio headline options for a ${request.profession}.
Tone: ${request.tone}.
Portfolio owner: ${portfolio.ownerName}.
Projects:
$portfolioContext
Each headline must be under 12 words and emphasize positioning.
''',
      AiGenerationType.about => '''
Write an About section for ${portfolio.ownerName}, optimized for a ${request.profession}.
Tone: ${request.tone}.
Use 2 short paragraphs and include a crisp value proposition.
Projects:
$portfolioContext
''',
      AiGenerationType.projectSummary => '''
Enhance this project summary for a ${request.profession} portfolio.
Tone: ${request.tone}.
Return: 1 title line, 1 refined summary paragraph, and 3 impact bullets.
Project:
$projectContext
''',
      AiGenerationType.structure => '''
Create a portfolio structure for ${portfolio.ownerName}, a ${request.profession}.
Tone: ${request.tone}.
Return 6 ordered section names with a one-sentence purpose for each.
Projects:
$portfolioContext
''',
      AiGenerationType.fullPortfolio => '''
Generate a complete portfolio content package for ${portfolio.ownerName}, a ${request.profession}.
Tone: ${request.tone}.
Include headline, about section, project summaries, and recommended structure.
Projects:
$portfolioContext
''',
    };
  }

  String _projectContext(PortfolioProjectDraft project) {
    return '''
Name: ${project.name}
Description: ${project.shortDescription}
Client: ${project.clientName.isEmpty ? 'Not provided' : project.clientName}
Proof points: ${project.bulletPoints.join('; ')}
Tools: ${project.tools.join(', ')}
Tags: ${project.tags.join(', ')}
Links: Behance=${project.behanceUrl}; Figma=${project.figmaUrl}; Dribbble=${project.dribbbleUrl}
Images: ${project.images.length} uploaded references
''';
  }
}
