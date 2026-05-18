import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/responsive/breakpoints.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/glass_card.dart';
import '../../../../core/widgets/primary_button.dart';
import '../../domain/project_creation_models.dart';
import '../../state/project_creation_controller.dart';
import 'project_review_screen.dart';
import 'widgets/project_image_card.dart';

class ProjectCreationScreen extends ConsumerStatefulWidget {
  const ProjectCreationScreen({super.key});

  static const routeName = 'project-create';
  static const routePath = '/portfolio/create';

  @override
  ConsumerState<ProjectCreationScreen> createState() => _ProjectCreationScreenState();
}

class _ProjectCreationScreenState extends ConsumerState<ProjectCreationScreen> {
  final _bulletController = TextEditingController();
  final _toolController = TextEditingController();
  final _tagController = TextEditingController();

  @override
  void dispose() {
    _bulletController.dispose();
    _toolController.dispose();
    _tagController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(projectCreationControllerProvider);
    final controller = ref.read(projectCreationControllerProvider.notifier);

    ref.listen(projectCreationControllerProvider, (previous, next) {
      if (next.step == ProjectCreationStep.review && previous?.step != ProjectCreationStep.review) {
        context.go(ProjectReviewScreen.routePath);
      }
    });

    return Scaffold(
      body: DecoratedBox(
        decoration: const BoxDecoration(
          gradient: RadialGradient(
            center: Alignment.topRight,
            radius: 1.15,
            colors: [Color(0x337C5CFF), AppColors.ink],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: AppSpacing.maxContentWidth),
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.lg),
                child: Column(
                  children: [
                    _CreationTopBar(state: state, onBack: controller.back),
                    const SizedBox(height: AppSpacing.lg),
                    Expanded(
                      child: AnimatedSwitcher(
                        duration: const Duration(milliseconds: 420),
                        switchInCurve: Curves.easeOutCubic,
                        switchOutCurve: Curves.easeInCubic,
                        transitionBuilder: (child, animation) {
                          return FadeTransition(
                            opacity: animation,
                            child: SlideTransition(
                              position: Tween<Offset>(begin: const Offset(0.04, 0), end: Offset.zero).animate(animation),
                              child: child,
                            ),
                          );
                        },
                        child: _StepBody(
                          key: ValueKey(state.step),
                          state: state,
                          bulletController: _bulletController,
                          toolController: _toolController,
                          tagController: _tagController,
                          controller: controller,
                        ),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    _BottomControls(state: state, onNext: controller.next, onSave: controller.saveNow),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _CreationTopBar extends StatelessWidget {
  const _CreationTopBar({required this.state, required this.onBack});

  final ProjectCreationState state;
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        IconButton.filledTonal(
          onPressed: state.step == ProjectCreationStep.name ? null : onBack,
          icon: const Icon(Icons.arrow_back_rounded),
        ),
        const SizedBox(width: AppSpacing.md),
        Expanded(child: _ProjectProgress(value: state.progress)),
        const SizedBox(width: AppSpacing.md),
        Text(
          'Step ${state.stepIndex + 1}/${ProjectCreationState.totalSteps}',
          style: Theme.of(context).textTheme.labelLarge?.copyWith(color: AppColors.gold),
        ),
      ],
    );
  }
}

class _ProjectProgress extends StatelessWidget {
  const _ProjectProgress({required this.value});

  final double value;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(999),
      child: Container(
        height: 12,
        color: AppColors.surfaceElevated,
        child: TweenAnimationBuilder<double>(
          tween: Tween<double>(begin: 0, end: value),
          duration: const Duration(milliseconds: 360),
          curve: Curves.easeOutCubic,
          builder: (context, animatedValue, child) {
            return FractionallySizedBox(
              alignment: Alignment.centerLeft,
              widthFactor: animatedValue,
              child: child,
            );
          },
          child: Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(colors: [AppColors.gold, AppColors.aurora]),
            ),
          ),
        ),
      ),
    );
  }
}

class _StepBody extends StatelessWidget {
  const _StepBody({
    required this.state,
    required this.bulletController,
    required this.toolController,
    required this.tagController,
    required this.controller,
    super.key,
  });

  final ProjectCreationState state;
  final TextEditingController bulletController;
  final TextEditingController toolController;
  final TextEditingController tagController;
  final ProjectCreationController controller;

  @override
  Widget build(BuildContext context) {
    final draft = state.draft;
    final step = switch (state.step) {
      ProjectCreationStep.name => _TextStep(
          eyebrow: 'Project identity',
          title: 'What should this project be called?',
          subtitle: 'Use the public-facing name you want visitors and AI generation to remember.',
          initialValue: draft.name,
          label: 'Project name',
          hint: 'Example: Signal Studio redesign',
          onChanged: controller.updateName,
        ),
      ProjectCreationStep.description => _TextStep(
          eyebrow: 'Short description',
          title: 'Describe the project in one sharp sentence.',
          subtitle: 'This becomes the seed for summaries, hero copy, and case study intros.',
          initialValue: draft.shortDescription,
          label: 'Short description',
          hint: 'What did you create and why did it matter?',
          maxLines: 4,
          onChanged: controller.updateDescription,
        ),
      ProjectCreationStep.bullets => _ListCaptureStep(
          eyebrow: 'Proof points',
          title: 'Add the moments that prove your impact.',
          subtitle: 'Think outcomes, responsibilities, process details, and measurable wins.',
          controller: bulletController,
          items: draft.bulletPoints,
          hint: 'Example: Increased activation by 42%',
          addLabel: 'Add bullet',
          onAdd: controller.addBullet,
          onRemove: controller.removeBullet,
        ),
      ProjectCreationStep.images => _ImagesStep(state: state, controller: controller),
      ProjectCreationStep.toolsAndTags => _ToolsTagsStep(
          draft: draft,
          toolController: toolController,
          tagController: tagController,
          onAddTool: controller.addTool,
          onRemoveTool: controller.removeTool,
          onAddTag: controller.addTag,
          onRemoveTag: controller.removeTag,
        ),
      ProjectCreationStep.links => _LinksStep(draft: draft, controller: controller),
      ProjectCreationStep.ordering => _OrderingStep(draft: draft, controller: controller),
      ProjectCreationStep.review => _ReviewPreview(draft: draft, onEdit: controller.goToStep),
    };

    return ListView(
      children: [
        step,
        if (state.errorMessage != null) ...[
          const SizedBox(height: AppSpacing.lg),
          _InlineMessage(message: state.errorMessage!, isError: true),
        ] else if (state.validationMessage != null) ...[
          const SizedBox(height: AppSpacing.lg),
          _InlineMessage(message: state.validationMessage!, isError: false),
        ],
      ],
    );
  }
}

class _TextStep extends StatelessWidget {
  const _TextStep({
    required this.eyebrow,
    required this.title,
    required this.subtitle,
    required this.initialValue,
    required this.label,
    required this.hint,
    required this.onChanged,
    this.maxLines = 1,
  });

  final String eyebrow;
  final String title;
  final String subtitle;
  final String initialValue;
  final String label;
  final String hint;
  final ValueChanged<String> onChanged;
  final int maxLines;

  @override
  Widget build(BuildContext context) {
    return _StepCard(
      eyebrow: eyebrow,
      title: title,
      subtitle: subtitle,
      child: TextFormField(
        key: ValueKey('$label-$initialValue'),
        initialValue: initialValue,
        maxLines: maxLines,
        onChanged: onChanged,
        decoration: InputDecoration(labelText: label, hintText: hint),
      ),
    );
  }
}

class _ListCaptureStep extends StatelessWidget {
  const _ListCaptureStep({
    required this.eyebrow,
    required this.title,
    required this.subtitle,
    required this.controller,
    required this.items,
    required this.hint,
    required this.addLabel,
    required this.onAdd,
    required this.onRemove,
  });

  final String eyebrow;
  final String title;
  final String subtitle;
  final TextEditingController controller;
  final List<String> items;
  final String hint;
  final String addLabel;
  final ValueChanged<String> onAdd;
  final ValueChanged<int> onRemove;

  @override
  Widget build(BuildContext context) {
    return _StepCard(
      eyebrow: eyebrow,
      title: title,
      subtitle: subtitle,
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: controller,
                  decoration: InputDecoration(labelText: addLabel, hintText: hint),
                  onSubmitted: (_) => _submit(),
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              IconButton.filled(
                onPressed: _submit,
                icon: const Icon(Icons.add_rounded),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          if (items.isEmpty)
            const _EmptyHint(message: 'No bullets yet. Add two or more proof points to continue.')
          else
            ...items.indexed.map(
              (entry) => _DismissibleListTile(
                index: entry.$1,
                text: entry.$2,
                onRemove: () => onRemove(entry.$1),
              ),
            ),
        ],
      ),
    );
  }

  void _submit() {
    onAdd(controller.text);
    controller.clear();
  }
}

class _ImagesStep extends StatelessWidget {
  const _ImagesStep({required this.state, required this.controller});

  final ProjectCreationState state;
  final ProjectCreationController controller;

  @override
  Widget build(BuildContext context) {
    return _StepCard(
      eyebrow: 'Image upload',
      title: 'Upload the visuals that tell the story.',
      subtitle: 'Pick multiple images, preview them, replace weaker shots, and remove anything that does not fit.',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          OutlinedButton.icon(
            onPressed: state.isPickingImages ? null : controller.addImages,
            icon: state.isPickingImages
                ? const SizedBox.square(dimension: 18, child: CircularProgressIndicator(strokeWidth: 2))
                : const Icon(Icons.upload_rounded),
            label: Text(state.isPickingImages ? 'Opening image picker...' : 'Upload project images'),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: AppSpacing.md),
              side: const BorderSide(color: AppColors.border),
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          if (state.draft.images.isEmpty)
            const _EmptyHint(message: 'Upload at least one image. Multiple images can be reordered in the next step.')
          else
            LayoutBuilder(
              builder: (context, constraints) {
                final columns = constraints.maxWidth > 760 ? 3 : constraints.maxWidth > 520 ? 2 : 1;
                return GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: state.draft.images.length,
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: columns,
                    crossAxisSpacing: AppSpacing.md,
                    mainAxisSpacing: AppSpacing.md,
                    childAspectRatio: 1.08,
                  ),
                  itemBuilder: (context, index) {
                    final image = state.draft.images[index];
                    return ProjectImageCard(
                      image: image,
                      onReplace: () => controller.replaceImage(image.id),
                      onRemove: () => controller.removeImage(image.id),
                    );
                  },
                );
              },
            ),
        ],
      ),
    );
  }
}

class _ToolsTagsStep extends StatelessWidget {
  const _ToolsTagsStep({
    required this.draft,
    required this.toolController,
    required this.tagController,
    required this.onAddTool,
    required this.onRemoveTool,
    required this.onAddTag,
    required this.onRemoveTag,
  });

  final PortfolioProjectDraft draft;
  final TextEditingController toolController;
  final TextEditingController tagController;
  final ValueChanged<String> onAddTool;
  final ValueChanged<String> onRemoveTool;
  final ValueChanged<String> onAddTag;
  final ValueChanged<String> onRemoveTag;

  @override
  Widget build(BuildContext context) {
    return _StepCard(
      eyebrow: 'Metadata',
      title: 'Add the tools and tags that make this searchable.',
      subtitle: 'Tools power credibility. Tags help Portique shape sections and recommendations.',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _ChipInput(label: 'Tools used', hint: 'Figma, Flutter, Firebase...', controller: toolController, values: draft.tools, onAdd: onAddTool, onRemove: onRemoveTool),
          const SizedBox(height: AppSpacing.lg),
          _ChipInput(label: 'Tags', hint: 'Mobile, SaaS, Branding...', controller: tagController, values: draft.tags, onAdd: onAddTag, onRemove: onRemoveTag),
        ],
      ),
    );
  }
}

class _LinksStep extends StatelessWidget {
  const _LinksStep({required this.draft, required this.controller});

  final PortfolioProjectDraft draft;
  final ProjectCreationController controller;

  @override
  Widget build(BuildContext context) {
    return _StepCard(
      eyebrow: 'External proof',
      title: 'Connect the work where it already lives.',
      subtitle: 'Behance, Figma, and Dribbble links are optional but help future AI prompts cite source context.',
      child: Column(
        children: [
          TextFormField(
            initialValue: draft.behanceUrl,
            onChanged: controller.updateBehance,
            decoration: const InputDecoration(labelText: 'Behance link', hintText: 'https://behance.net/...'),
          ),
          const SizedBox(height: AppSpacing.md),
          TextFormField(
            initialValue: draft.figmaUrl,
            onChanged: controller.updateFigma,
            decoration: const InputDecoration(labelText: 'Figma link', hintText: 'https://figma.com/...'),
          ),
          const SizedBox(height: AppSpacing.md),
          TextFormField(
            initialValue: draft.dribbbleUrl,
            onChanged: controller.updateDribbble,
            decoration: const InputDecoration(labelText: 'Dribbble link', hintText: 'https://dribbble.com/...'),
          ),
          const SizedBox(height: AppSpacing.md),
          TextFormField(
            initialValue: draft.clientName,
            onChanged: controller.updateClientName,
            decoration: const InputDecoration(labelText: 'Client name (optional)', hintText: 'Acme Studio'),
          ),
        ],
      ),
    );
  }
}

class _OrderingStep extends StatelessWidget {
  const _OrderingStep({required this.draft, required this.controller});

  final PortfolioProjectDraft draft;
  final ProjectCreationController controller;

  @override
  Widget build(BuildContext context) {
    return _StepCard(
      eyebrow: 'Story order',
      title: 'Drag images into the order visitors should experience them.',
      subtitle: 'Put the strongest hero image first, then supporting moments.',
      child: draft.images.isEmpty
          ? const _EmptyHint(message: 'No images uploaded yet.')
          : ReorderableListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: draft.images.length,
              onReorder: controller.reorderImages,
              itemBuilder: (context, index) {
                final image = draft.images[index];
                return ListTile(
                  key: ValueKey(image.id),
                  leading: CircleAvatar(
                    backgroundColor: AppColors.surfaceElevated,
                    child: Text('${index + 1}'),
                  ),
                  title: Text(image.name, maxLines: 1, overflow: TextOverflow.ellipsis),
                  subtitle: Text(image.path, maxLines: 1, overflow: TextOverflow.ellipsis),
                  trailing: const Icon(Icons.drag_handle_rounded),
                );
              },
            ),
    );
  }
}

class _ReviewPreview extends StatelessWidget {
  const _ReviewPreview({required this.draft, required this.onEdit});

  final PortfolioProjectDraft draft;
  final ValueChanged<ProjectCreationStep> onEdit;

  @override
  Widget build(BuildContext context) {
    return _StepCard(
      eyebrow: 'Review',
      title: 'Review the project before AI generation.',
      subtitle: 'You can edit any section, then continue to generate a portfolio-ready case study.',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _ReviewRow(label: 'Name', value: draft.name, onEdit: () => onEdit(ProjectCreationStep.name)),
          _ReviewRow(label: 'Description', value: draft.shortDescription, onEdit: () => onEdit(ProjectCreationStep.description)),
          _ReviewRow(label: 'Bullets', value: '${draft.bulletPoints.length} proof points', onEdit: () => onEdit(ProjectCreationStep.bullets)),
          _ReviewRow(label: 'Images', value: '${draft.images.length} uploaded images', onEdit: () => onEdit(ProjectCreationStep.images)),
          _ReviewRow(label: 'Tools', value: draft.tools.join(', '), onEdit: () => onEdit(ProjectCreationStep.toolsAndTags)),
          _ReviewRow(label: 'Tags', value: draft.tags.join(', '), onEdit: () => onEdit(ProjectCreationStep.toolsAndTags)),
          _ReviewRow(label: 'Links', value: draft.hasLinks ? 'External links attached' : 'No external links', onEdit: () => onEdit(ProjectCreationStep.links)),
        ],
      ),
    );
  }
}

class _StepCard extends StatelessWidget {
  const _StepCard({required this.eyebrow, required this.title, required this.subtitle, required this.child});

  final String eyebrow;
  final String title;
  final String subtitle;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final isWide = Breakpoints.of(context) != DeviceClass.mobile;
    return GlassCard(
      padding: EdgeInsets.all(isWide ? AppSpacing.xl : AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(eyebrow, style: Theme.of(context).textTheme.labelLarge?.copyWith(color: AppColors.gold)),
          const SizedBox(height: AppSpacing.sm),
          Text(title, style: Theme.of(context).textTheme.headlineLarge?.copyWith(fontWeight: FontWeight.w900, height: 1.05)),
          const SizedBox(height: AppSpacing.sm),
          Text(subtitle, style: Theme.of(context).textTheme.titleMedium?.copyWith(color: AppColors.mist, height: 1.45)),
          const SizedBox(height: AppSpacing.xl),
          child,
        ],
      ),
    );
  }
}

class _ChipInput extends StatelessWidget {
  const _ChipInput({required this.label, required this.hint, required this.controller, required this.values, required this.onAdd, required this.onRemove});

  final String label;
  final String hint;
  final TextEditingController controller;
  final List<String> values;
  final ValueChanged<String> onAdd;
  final ValueChanged<String> onRemove;

  @override
  Widget build(BuildContext context) {
    void submit() {
      onAdd(controller.text);
      controller.clear();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: controller,
                decoration: InputDecoration(labelText: label, hintText: hint),
                onSubmitted: (_) => submit(),
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            IconButton.filled(onPressed: submit, icon: const Icon(Icons.add_rounded)),
          ],
        ),
        const SizedBox(height: AppSpacing.md),
        Wrap(
          spacing: AppSpacing.sm,
          runSpacing: AppSpacing.sm,
          children: values
              .map(
                (value) => InputChip(
                  label: Text(value),
                  onDeleted: () => onRemove(value),
                ),
              )
              .toList(),
        ),
      ],
    );
  }
}

class _DismissibleListTile extends StatelessWidget {
  const _DismissibleListTile({required this.index, required this.text, required this.onRemove});

  final int index;
  final String text;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: CircleAvatar(
        backgroundColor: AppColors.surfaceElevated,
        child: Text('${index + 1}'),
      ),
      title: Text(text),
      trailing: IconButton(
        onPressed: onRemove,
        icon: const Icon(Icons.close_rounded),
      ),
    );
  }
}

class _ReviewRow extends StatelessWidget {
  const _ReviewRow({required this.label, required this.value, required this.onEdit});

  final String label;
  final String value;
  final VoidCallback onEdit;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      title: Text(label, style: Theme.of(context).textTheme.labelLarge?.copyWith(color: AppColors.gold)),
      subtitle: Text(value.isEmpty ? 'Not provided' : value),
      trailing: TextButton(onPressed: onEdit, child: const Text('Edit')),
    );
  }
}

class _InlineMessage extends StatelessWidget {
  const _InlineMessage({required this.message, required this.isError});

  final String message;
  final bool isError;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: (isError ? AppColors.rose : AppColors.gold).withAlpha(24),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: (isError ? AppColors.rose : AppColors.gold).withAlpha(96)),
      ),
      child: Row(
        children: [
          Icon(isError ? Icons.error_outline_rounded : Icons.info_outline_rounded, color: isError ? AppColors.rose : AppColors.gold),
          const SizedBox(width: AppSpacing.sm),
          Expanded(child: Text(message)),
        ],
      ),
    );
  }
}

class _EmptyHint extends StatelessWidget {
  const _EmptyHint({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: AppColors.border),
        color: AppColors.surfaceElevated.withAlpha(120),
      ),
      child: Text(message, style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppColors.mist)),
    );
  }
}

class _BottomControls extends StatelessWidget {
  const _BottomControls({required this.state, required this.onNext, required this.onSave});

  final ProjectCreationState state;
  final VoidCallback onNext;
  final VoidCallback onSave;

  @override
  Widget build(BuildContext context) {
    final savedText = state.isSaving
        ? 'Autosaving...'
        : state.lastSavedAt == null
            ? 'Draft autosaves locally'
            : 'Saved ${TimeOfDay.fromDateTime(state.lastSavedAt!).format(context)}';
    return Row(
      children: [
        Expanded(
          child: Text(savedText, style: Theme.of(context).textTheme.labelLarge?.copyWith(color: AppColors.mist)),
        ),
        TextButton.icon(
          onPressed: state.isBusy ? null : onSave,
          icon: const Icon(Icons.save_outlined),
          label: const Text('Save'),
        ),
        const SizedBox(width: AppSpacing.sm),
        PrimaryButton(
          label: state.step == ProjectCreationStep.ordering ? 'Review project' : 'Continue',
          icon: Icons.arrow_forward_rounded,
          onPressed: state.canContinue ? onNext : null,
        ),
      ],
    );
  }
}
