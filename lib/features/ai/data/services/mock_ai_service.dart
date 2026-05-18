import '../../../portfolio/domain/project_creation_models.dart';
import '../../domain/ai_generation_models.dart';

class MockAiService {
  const MockAiService();

  Future<String> generate(AiGenerationRequest request) async {
    await Future<void>.delayed(const Duration(milliseconds: 900));
    final project = request.project ?? (request.portfolioData.projects.isEmpty ? null : request.portfolioData.projects.first);
    return switch (request.type) {
      AiGenerationType.headline => _headline(request),
      AiGenerationType.about => _about(request),
      AiGenerationType.projectSummary => _projectSummary(project, request.profession),
      AiGenerationType.structure => _structure(request),
      AiGenerationType.fullPortfolio => '${_headline(request)}\n\n${_about(request)}\n\n${_projectSummary(project, request.profession)}\n\n${_structure(request)}',
    };
  }

  String _headline(AiGenerationRequest request) {
    return '''
${request.portfolioData.ownerName}: ${request.profession} crafting precise digital experiences
Premium systems for ambitious brands
Portfolio stories shaped around clarity, craft, and measurable impact
''';
  }

  String _about(AiGenerationRequest request) {
    final tools = request.portfolioData.projects.expand((project) => project.tools).toSet().take(4).join(', ');
    return '''
${request.portfolioData.ownerName} is a ${request.profession} focused on turning complex ideas into polished portfolio-ready products. Their work combines strategy, execution, and visual clarity${tools.isEmpty ? '' : ' across $tools'}.

Portique recommends positioning this portfolio around measurable outcomes, strong project sequencing, and a concise voice that feels premium without losing specificity.
''';
  }

  String _projectSummary(PortfolioProjectDraft? project, String profession) {
    if (project == null) return 'Add a project draft to generate a tailored summary.';
    final bullets = project.bulletPoints.isEmpty
        ? '- Clarified the user journey\n- Built a more persuasive presentation\n- Prepared assets for launch'
        : project.bulletPoints.take(3).map((point) => '- $point').join('\n');
    return '''
${project.name}: refined ${profession.toLowerCase()} case study
${project.shortDescription} Portique would frame this as a focused story of craft, constraints, and outcome-driven decisions.
$bullets
''';
  }

  String _structure(AiGenerationRequest request) {
    return '''
1. Hero — State the positioning and strongest proof point.
2. Selected Work — Lead with the most relevant project stories.
3. Process — Explain how ${request.portfolioData.ownerName} thinks and collaborates.
4. Outcomes — Surface metrics, client value, and before/after changes.
5. About — Humanize the expertise behind the work.
6. Contact — Create a confident conversion path.
''';
  }
}
