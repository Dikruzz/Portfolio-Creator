import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

import '../domain/project_creation_models.dart';
import 'local/project_draft_store.dart';

final imagePickerProvider = Provider<ImagePicker>((ref) => ImagePicker());
final projectDraftStoreProvider = Provider<ProjectDraftStore>((ref) => const ProjectDraftStore());

final projectCreationRepositoryProvider = Provider<ProjectCreationRepository>((ref) {
  return ProjectCreationRepository(
    imagePicker: ref.watch(imagePickerProvider),
    draftStore: ref.watch(projectDraftStoreProvider),
  );
});

class ProjectCreationRepository {
  const ProjectCreationRepository({
    required this.imagePicker,
    required this.draftStore,
  });

  final ImagePicker imagePicker;
  final ProjectDraftStore draftStore;

  Future<PortfolioProjectDraft?> restoreDraft() => draftStore.readDraft();
  Future<void> saveDraft(PortfolioProjectDraft draft) => draftStore.saveDraft(draft);
  Future<void> clearDraft() => draftStore.clearDraft();
  Future<void> saveProjectOrder(List<String> orderedProjectIds) => draftStore.saveProjectOrder(orderedProjectIds);

  Future<List<ProjectImageAsset>> pickImages() async {
    final files = await imagePicker.pickMultiImage(imageQuality: 88);
    return files.map(_assetFromXFile).toList();
  }

  Future<ProjectImageAsset?> pickReplacementImage() async {
    final file = await imagePicker.pickImage(source: ImageSource.gallery, imageQuality: 88);
    if (file == null) return null;
    return _assetFromXFile(file);
  }

  ProjectImageAsset _assetFromXFile(XFile file) {
    return ProjectImageAsset(
      id: 'image-${DateTime.now().microsecondsSinceEpoch}-${file.name.hashCode}',
      name: file.name,
      path: file.path,
      mimeType: file.mimeType,
    );
  }
}
