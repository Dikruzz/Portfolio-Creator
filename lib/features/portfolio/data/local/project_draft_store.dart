import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../../domain/project_creation_models.dart';

class ProjectDraftStore {
  const ProjectDraftStore();

  static const _draftKey = 'portique.portfolio.projectDraft';
  static const _projectOrderKey = 'portique.portfolio.projectOrder';

  Future<PortfolioProjectDraft?> readDraft() async {
    final preferences = await SharedPreferences.getInstance();
    final rawDraft = preferences.getString(_draftKey);
    if (rawDraft == null || rawDraft.isEmpty) return null;

    final decoded = jsonDecode(rawDraft) as Map<String, dynamic>;
    return PortfolioProjectDraft.fromJson(decoded.cast<String, Object?>());
  }

  Future<void> saveDraft(PortfolioProjectDraft draft) async {
    final preferences = await SharedPreferences.getInstance();
    final now = DateTime.now();
    final stampedDraft = draft.copyWith(
      id: draft.id ?? 'project-${now.millisecondsSinceEpoch}',
      createdAt: draft.createdAt ?? now,
      updatedAt: now,
    );
    await preferences.setString(_draftKey, jsonEncode(stampedDraft.toJson()));
  }

  Future<void> clearDraft() async {
    final preferences = await SharedPreferences.getInstance();
    await preferences.remove(_draftKey);
  }

  Future<List<String>> readProjectOrder() async {
    final preferences = await SharedPreferences.getInstance();
    return preferences.getStringList(_projectOrderKey) ?? const [];
  }

  Future<void> saveProjectOrder(List<String> orderedProjectIds) async {
    final preferences = await SharedPreferences.getInstance();
    await preferences.setStringList(_projectOrderKey, orderedProjectIds);
  }
}
