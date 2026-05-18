import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/project_creation_repository.dart';
import '../domain/project_creation_models.dart';

enum ProjectCreationStep {
  name,
  description,
  bullets,
  images,
  toolsAndTags,
  links,
  ordering,
  review,
}

class ProjectCreationState {
  const ProjectCreationState({
    this.step = ProjectCreationStep.name,
    this.draft = const PortfolioProjectDraft(),
    this.isRestoring = true,
    this.isSaving = false,
    this.isPickingImages = false,
    this.lastSavedAt,
    this.errorMessage,
  });

  final ProjectCreationStep step;
  final PortfolioProjectDraft draft;
  final bool isRestoring;
  final bool isSaving;
  final bool isPickingImages;
  final DateTime? lastSavedAt;
  final String? errorMessage;

  static int get totalSteps => ProjectCreationStep.values.length;
  int get stepIndex => ProjectCreationStep.values.indexOf(step);
  double get progress => (stepIndex + 1) / totalSteps;
  bool get isBusy => isRestoring || isSaving || isPickingImages;

  String? get validationMessage {
    return switch (step) {
      ProjectCreationStep.name => draft.name.trim().length < 3 ? 'Add a project name with at least 3 characters.' : null,
      ProjectCreationStep.description => draft.shortDescription.trim().length < 12 ? 'Write a short description with at least 12 characters.' : null,
      ProjectCreationStep.bullets => draft.bulletPoints.where((point) => point.trim().isNotEmpty).length < 2 ? 'Add at least two proof bullets.' : null,
      ProjectCreationStep.images => draft.images.isEmpty ? 'Upload at least one project image.' : null,
      ProjectCreationStep.toolsAndTags => draft.tools.isEmpty || draft.tags.isEmpty ? 'Add at least one tool and one tag.' : null,
      ProjectCreationStep.links => null,
      ProjectCreationStep.ordering => null,
      ProjectCreationStep.review => null,
    };
  }

  bool get canContinue => validationMessage == null && !isBusy;

  ProjectCreationState copyWith({
    ProjectCreationStep? step,
    PortfolioProjectDraft? draft,
    bool? isRestoring,
    bool? isSaving,
    bool? isPickingImages,
    DateTime? lastSavedAt,
    String? errorMessage,
    bool clearError = false,
  }) {
    return ProjectCreationState(
      step: step ?? this.step,
      draft: draft ?? this.draft,
      isRestoring: isRestoring ?? this.isRestoring,
      isSaving: isSaving ?? this.isSaving,
      isPickingImages: isPickingImages ?? this.isPickingImages,
      lastSavedAt: lastSavedAt ?? this.lastSavedAt,
      errorMessage: clearError ? null : errorMessage ?? this.errorMessage,
    );
  }
}

final projectCreationControllerProvider = StateNotifierProvider<ProjectCreationController, ProjectCreationState>((ref) {
  return ProjectCreationController(ref.watch(projectCreationRepositoryProvider));
});

class ProjectCreationController extends StateNotifier<ProjectCreationState> {
  ProjectCreationController(this._repository) : super(const ProjectCreationState()) {
    restoreDraft();
  }

  final ProjectCreationRepository _repository;
  Timer? _autosaveTimer;

  @override
  void dispose() {
    _autosaveTimer?.cancel();
    super.dispose();
  }

  Future<void> restoreDraft() async {
    try {
      final draft = await _repository.restoreDraft();
      if (!mounted) return;
      state = state.copyWith(
        draft: draft ?? state.draft,
        isRestoring: false,
        clearError: true,
      );
    } catch (_) {
      if (!mounted) return;
      state = state.copyWith(
        isRestoring: false,
        errorMessage: 'We could not restore your local draft.',
      );
    }
  }

  void updateName(String value) => _updateDraft(state.draft.copyWith(name: value));
  void updateDescription(String value) => _updateDraft(state.draft.copyWith(shortDescription: value));
  void updateBehance(String value) => _updateDraft(state.draft.copyWith(behanceUrl: value));
  void updateFigma(String value) => _updateDraft(state.draft.copyWith(figmaUrl: value));
  void updateDribbble(String value) => _updateDraft(state.draft.copyWith(dribbbleUrl: value));
  void updateClientName(String value) => _updateDraft(state.draft.copyWith(clientName: value));

  void addBullet(String value) {
    final trimmed = value.trim();
    if (trimmed.isEmpty) return;
    _updateDraft(state.draft.copyWith(bulletPoints: [...state.draft.bulletPoints, trimmed]));
  }

  void removeBullet(int index) {
    final updated = [...state.draft.bulletPoints]..removeAt(index);
    _updateDraft(state.draft.copyWith(bulletPoints: updated));
  }

  void addTool(String value) => _addUnique(value, state.draft.tools, (items) => state.draft.copyWith(tools: items));
  void removeTool(String value) => _updateDraft(state.draft.copyWith(tools: [...state.draft.tools]..remove(value)));
  void addTag(String value) => _addUnique(value, state.draft.tags, (items) => state.draft.copyWith(tags: items));
  void removeTag(String value) => _updateDraft(state.draft.copyWith(tags: [...state.draft.tags]..remove(value)));

  Future<void> addImages() async {
    state = state.copyWith(isPickingImages: true, clearError: true);
    try {
      final images = await _repository.pickImages();
      if (!mounted) return;
      if (images.isNotEmpty) {
        _updateDraft(state.draft.copyWith(images: [...state.draft.images, ...images]));
      }
      state = state.copyWith(isPickingImages: false);
    } catch (_) {
      if (!mounted) return;
      state = state.copyWith(
        isPickingImages: false,
        errorMessage: 'Image selection failed. Check platform permissions and try again.',
      );
    }
  }

  Future<void> replaceImage(String id) async {
    state = state.copyWith(isPickingImages: true, clearError: true);
    try {
      final image = await _repository.pickReplacementImage();
      if (!mounted) return;
      if (image != null) {
        final updated = state.draft.images.map((item) => item.id == id ? image : item).toList();
        _updateDraft(state.draft.copyWith(images: updated));
      }
      state = state.copyWith(isPickingImages: false);
    } catch (_) {
      if (!mounted) return;
      state = state.copyWith(
        isPickingImages: false,
        errorMessage: 'Image replacement failed. Try again.',
      );
    }
  }

  void removeImage(String id) {
    _updateDraft(state.draft.copyWith(images: state.draft.images.where((image) => image.id != id).toList()));
  }

  void reorderImages(int oldIndex, int newIndex) {
    final images = [...state.draft.images];
    if (newIndex > oldIndex) newIndex -= 1;
    final image = images.removeAt(oldIndex);
    images.insert(newIndex, image);
    _updateDraft(state.draft.copyWith(images: images));
  }

  void next() {
    final validationMessage = state.validationMessage;
    if (validationMessage != null) {
      state = state.copyWith(errorMessage: validationMessage);
      return;
    }
    if (state.step == ProjectCreationStep.review) return;
    state = state.copyWith(
      step: ProjectCreationStep.values[state.stepIndex + 1],
      clearError: true,
    );
    saveNow();
  }

  void back() {
    if (state.step == ProjectCreationStep.name) return;
    state = state.copyWith(
      step: ProjectCreationStep.values[state.stepIndex - 1],
      clearError: true,
    );
  }

  void goToStep(ProjectCreationStep step) {
    state = state.copyWith(step: step, clearError: true);
  }

  Future<void> saveNow() async {
    state = state.copyWith(isSaving: true, clearError: true);
    try {
      await _repository.saveDraft(state.draft);
      if (!mounted) return;
      state = state.copyWith(isSaving: false, lastSavedAt: DateTime.now());
    } catch (_) {
      if (!mounted) return;
      state = state.copyWith(
        isSaving: false,
        errorMessage: 'Autosave failed. Your latest changes are still on screen.',
      );
    }
  }

  AiProjectPromptPayload toPromptPayload() {
    return AiProjectPromptPayload(
      project: state.draft,
      intent: 'Generate a premium portfolio case study with summary, process, impact, and role sections.',
      tone: 'cinematic, premium, confident, concise',
    );
  }

  void _addUnique(String value, List<String> current, PortfolioProjectDraft Function(List<String>) builder) {
    final trimmed = value.trim();
    if (trimmed.isEmpty) return;
    final exists = current.any((item) => item.toLowerCase() == trimmed.toLowerCase());
    if (exists) return;
    _updateDraft(builder([...current, trimmed]));
  }

  void _updateDraft(PortfolioProjectDraft draft) {
    state = state.copyWith(draft: draft, clearError: true);
    _scheduleAutosave();
  }

  void _scheduleAutosave() {
    _autosaveTimer?.cancel();
    _autosaveTimer = Timer(const Duration(milliseconds: 700), saveNow);
  }
}
