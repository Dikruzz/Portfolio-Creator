import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/glass_card.dart';
import '../../../../core/widgets/primary_button.dart';
import '../../../ai/presentation/ai_studio_screen.dart';
import '../../state/project_creation_controller.dart';
import 'project_creation_screen.dart';

class ProjectReviewScreen extends ConsumerWidget {
  const ProjectReviewScreen({super.key});

  static const routeName = 'project-review';
  static const routePath = '/portfolio/create/review';

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(projectCreationControllerProvider);
    final draft = state.draft;
    final payload = ref.read(projectCreationControllerProvider.notifier).toPromptPayload();

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
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: AppSpacing.maxContentWidth),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Project review', style: Theme.of(context).textTheme.displaySmall?.copyWith(fontWeight: FontWeight.w900)),
                    const SizedBox(height: AppSpacing.sm),
                    Text('Confirm the structure, edit anything that feels off, or continue into AI generation.', style: Theme.of(context).textTheme.titleMedium?.copyWith(color: AppColors.mist)),
                    const SizedBox(height: AppSpacing.xl),
                    GlassCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(draft.name, style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.w900)),
                          const SizedBox(height: AppSpacing.sm),
                          Text(draft.shortDescription, style: Theme.of(context).textTheme.titleMedium?.copyWith(color: AppColors.mist)),
                          if (draft.clientName.isNotEmpty) ...[
                            const SizedBox(height: AppSpacing.md),
                            Chip(label: Text('Client: ${draft.clientName}')),
                          ],
                          const SizedBox(height: AppSpacing.lg),
                          _ReviewSection(title: 'Proof bullets', values: draft.bulletPoints),
                          _ReviewSection(title: 'Tools', values: draft.tools),
                          _ReviewSection(title: 'Tags', values: draft.tags),
                          _ReviewSection(title: 'AI payload preview', values: [payload.intent, payload.tone, '${draft.images.length} image references ready']),
                          const SizedBox(height: AppSpacing.lg),
                          Wrap(
                            spacing: AppSpacing.md,
                            runSpacing: AppSpacing.md,
                            children: [
                              OutlinedButton.icon(
                                onPressed: () {
                                  ref.read(projectCreationControllerProvider.notifier).goToStep(ProjectCreationStep.name);
                                  context.go(ProjectCreationScreen.routePath);
                                },
                                icon: const Icon(Icons.edit_rounded),
                                label: const Text('Edit project'),
                              ),
                              PrimaryButton(
                                label: 'Continue to AI generation',
                                icon: Icons.auto_awesome_rounded,
                                onPressed: () => context.go(AiStudioScreen.routePath),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
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

class _ReviewSection extends StatelessWidget {
  const _ReviewSection({required this.title, required this.values});

  final String title;
  final List<String> values;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: Theme.of(context).textTheme.labelLarge?.copyWith(color: AppColors.gold)),
          const SizedBox(height: AppSpacing.sm),
          if (values.isEmpty)
            Text('Not provided', style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppColors.muted))
          else
            ...values.map(
              (value) => Padding(
                padding: const EdgeInsets.only(bottom: AppSpacing.xs),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Padding(
                      padding: EdgeInsets.only(top: 6),
                      child: Icon(Icons.circle, size: 6, color: AppColors.gold),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Expanded(child: Text(value)),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}
