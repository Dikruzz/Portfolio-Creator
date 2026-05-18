import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/ai_repository.dart';
import '../domain/ai_generation_models.dart';
import '../domain/ai_prompt.dart';

enum AiOperation { headline, about, projectSummary, structure, fullPortfolio }

class AiStudioState {
  const AiStudioState({
    this.status = AiGenerationStatus.idle,
    this.activeOperation,
    this.content,
    this.legacyDraft,
    this.lastRequest,
    this.lastPackageProfession,
    this.lastPackageTone,
    this.errorMessage,
  });

  final AiGenerationStatus status;
  final AiOperation? activeOperation;
  final AiGeneratedContent? content;
  final AiDraft? legacyDraft;
  final AiGenerationRequest? lastRequest;
  final String? lastPackageProfession;
  final String? lastPackageTone;
  final String? errorMessage;

  bool get isLoading => status == AiGenerationStatus.loading;

  AiStudioState copyWith({
    AiGenerationStatus? status,
    AiOperation? activeOperation,
    bool clearActiveOperation = false,
    AiGeneratedContent? content,
    AiDraft? legacyDraft,
    AiGenerationRequest? lastRequest,
    String? lastPackageProfession,
    String? lastPackageTone,
    String? errorMessage,
    bool clearError = false,
  }) {
    return AiStudioState(
      status: status ?? this.status,
      activeOperation: clearActiveOperation ? null : activeOperation ?? this.activeOperation,
      content: content ?? this.content,
      legacyDraft: legacyDraft ?? this.legacyDraft,
      lastRequest: lastRequest ?? this.lastRequest,
      lastPackageProfession: lastPackageProfession ?? this.lastPackageProfession,
      lastPackageTone: lastPackageTone ?? this.lastPackageTone,
      errorMessage: clearError ? null : errorMessage ?? this.errorMessage,
    );
  }
}

final aiControllerProvider = StateNotifierProvider<AiController, AiStudioState>((ref) {
  return AiController(ref.read(aiRepositoryProvider));
});

class AiController extends StateNotifier<AiStudioState> {
  AiController(this._repository) : super(const AiStudioState());

  final AiRepository _repository;

  Future<void> generate(AiPrompt prompt) async {
    state = state.copyWith(
      status: AiGenerationStatus.loading,
      activeOperation: AiOperation.projectSummary,
      clearError: true,
    );
    try {
      final draft = await _repository.generateDraft(prompt);
      if (!mounted) return;
      state = state.copyWith(
        status: AiGenerationStatus.success,
        legacyDraft: draft,
        clearActiveOperation: true,
      );
    } catch (error) {
      _fail(error);
    }
  }

  Future<void> generatePortfolioPackage({
    required String profession,
    required String tone,
  }) async {
    state = state.copyWith(
      status: AiGenerationStatus.loading,
      activeOperation: AiOperation.fullPortfolio,
      lastPackageProfession: profession,
      lastPackageTone: tone,
      clearError: true,
    );
    try {
      final content = await _repository.generatePortfolioPackage(profession: profession, tone: tone);
      if (!mounted) return;
      state = state.copyWith(
        status: AiGenerationStatus.success,
        content: content,
        clearActiveOperation: true,
      );
    } catch (error) {
      _fail(error);
    }
  }

  Future<void> prepareAndGenerateSingle({
    required AiGenerationType type,
    required String profession,
    required String tone,
  }) async {
    final portfolioData = await _repository.buildPortfolioData();
    await generateSingle(
      AiGenerationRequest(
        type: type,
        profession: profession,
        tone: tone,
        portfolioData: portfolioData,
        project: portfolioData.projects.isEmpty ? null : portfolioData.projects.first,
      ),
    );
  }

  Future<void> generateSingle(AiGenerationRequest request) async {
    final operation = _operationFor(request.type);
    state = state.copyWith(
      status: AiGenerationStatus.loading,
      activeOperation: operation,
      lastRequest: request,
      clearError: true,
    );
    try {
      final text = await _repository.generateText(request);
      if (!mounted) return;
      final current = state.content ?? AiGeneratedContent.empty();
      state = state.copyWith(
        status: AiGenerationStatus.success,
        content: _merge(current, request.type, text, request.project?.name),
        clearActiveOperation: true,
      );
    } catch (error) {
      _fail(error);
    }
  }

  Future<void> retry() async {
    final request = state.lastRequest;
    if (request != null) {
      await generateSingle(request);
      return;
    }
    final profession = state.lastPackageProfession;
    final tone = state.lastPackageTone;
    if (profession == null || tone == null) return;
    await generatePortfolioPackage(profession: profession, tone: tone);
  }

  AiOperation _operationFor(AiGenerationType type) {
    return switch (type) {
      AiGenerationType.headline => AiOperation.headline,
      AiGenerationType.about => AiOperation.about,
      AiGenerationType.projectSummary => AiOperation.projectSummary,
      AiGenerationType.structure => AiOperation.structure,
      AiGenerationType.fullPortfolio => AiOperation.fullPortfolio,
    };
  }

  AiGeneratedContent _merge(AiGeneratedContent current, AiGenerationType type, String text, String? projectName) {
    return switch (type) {
      AiGenerationType.headline => current.copyWith(headline: text),
      AiGenerationType.about => current.copyWith(about: text),
      AiGenerationType.structure => current.copyWith(structure: text.split('\n').where((line) => line.trim().isNotEmpty).toList()),
      AiGenerationType.projectSummary => current.copyWith(
          projectSummaries: [
            ...current.projectSummaries,
            GeneratedPortfolioSection(
              id: 'summary-${DateTime.now().microsecondsSinceEpoch}',
              title: projectName ?? 'Project summary',
              body: text,
              kind: 'projectSummary',
            ),
          ],
        ),
      AiGenerationType.fullPortfolio => current,
    };
  }

  void _fail(Object error) {
    if (!mounted) return;
    state = state.copyWith(
      status: AiGenerationStatus.failure,
      clearActiveOperation: true,
      errorMessage: error.toString(),
    );
  }
}
