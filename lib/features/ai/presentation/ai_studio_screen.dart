import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/responsive/breakpoints.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/widgets/app_text_field.dart';
import '../../../core/widgets/glass_card.dart';
import '../../../core/widgets/premium_scaffold.dart';
import '../../../core/widgets/primary_button.dart';
import '../../../core/widgets/section_header.dart';
import '../../portfolio/presentation/portfolio_dashboard_screen.dart';
import '../domain/ai_generation_models.dart';
import '../domain/ai_prompt.dart';
import '../state/ai_controller.dart';
import 'widgets/ai_loading_card.dart';

class AiStudioScreen extends ConsumerStatefulWidget {
  const AiStudioScreen({super.key});

  static const routeName = 'ai-studio';
  static const routePath = '/ai-studio';

  @override
  ConsumerState<AiStudioScreen> createState() => _AiStudioScreenState();
}

class _AiStudioScreenState extends ConsumerState<AiStudioScreen> {
  final _goalController = TextEditingController(text: 'case study summary');
  final _contextController = TextEditingController(text: 'Launched a portfolio builder that helps designers win clients.');
  final _toneController = TextEditingController(text: 'premium, confident, concise');
  final _professionController = TextEditingController(text: 'Product Designer');

  @override
  void dispose() {
    _goalController.dispose();
    _contextController.dispose();
    _toneController.dispose();
    _professionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final aiState = ref.watch(aiControllerProvider);
    final controller = ref.read(aiControllerProvider.notifier);

    return PremiumScaffold(
      title: 'AI Studio',
      actions: [
        TextButton.icon(
          onPressed: () => context.go(PortfolioDashboardScreen.routePath),
          icon: const Icon(Icons.dashboard_rounded),
          label: const Text('Dashboard'),
        ),
      ],
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SectionHeader(
            title: 'Generate an AI-ready portfolio system',
            subtitle: 'Use the Responses API architecture when an OpenAI key is configured, or Portique mock responses during local development.',
          ),
          const SizedBox(height: AppSpacing.lg),
          _GenerationPanel(
            aiState: aiState,
            professionController: _professionController,
            toneController: _toneController,
            onGeneratePackage: () => controller.generatePortfolioPackage(
              profession: _professionController.text.trim(),
              tone: _toneController.text.trim(),
            ),
            onGenerateType: (type) => controller.prepareAndGenerateSingle(
              type: type,
              profession: _professionController.text.trim(),
              tone: _toneController.text.trim(),
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          _LegacyPromptPanel(
            aiState: aiState,
            goalController: _goalController,
            contextController: _contextController,
            toneController: _toneController,
            onGenerate: () => controller.generate(
              AiPrompt(
                goal: _goalController.text,
                context: _contextController.text,
                tone: _toneController.text,
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          if (aiState.isLoading)
            AiLoadingCard(message: _loadingMessage(aiState.activeOperation))
          else if (aiState.status == AiGenerationStatus.failure)
            _AiErrorCard(message: aiState.errorMessage ?? 'AI generation failed.', onRetry: controller.retry)
          else
            _GeneratedResults(state: aiState),
        ],
      ),
    );
  }

  String _loadingMessage(AiOperation? operation) {
    return switch (operation) {
      AiOperation.headline => 'Exploring headline angles and market positioning.',
      AiOperation.about => 'Writing a profession-optimized About section.',
      AiOperation.projectSummary => 'Enhancing project proof points and impact language.',
      AiOperation.structure => 'Designing a portfolio structure for conversion.',
      AiOperation.fullPortfolio => 'Generating headline, about, summaries, and structure.',
      null => 'Preparing your portfolio content.',
    };
  }
}

class _GenerationPanel extends StatelessWidget {
  const _GenerationPanel({
    required this.aiState,
    required this.professionController,
    required this.toneController,
    required this.onGeneratePackage,
    required this.onGenerateType,
  });

  final AiStudioState aiState;
  final TextEditingController professionController;
  final TextEditingController toneController;
  final VoidCallback onGeneratePackage;
  final ValueChanged<AiGenerationType> onGenerateType;

  @override
  Widget build(BuildContext context) {
    final isWide = Breakpoints.of(context) != DeviceClass.mobile;
    return GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Portfolio generator', style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w800)),
          const SizedBox(height: AppSpacing.md),
          if (isWide)
            Row(
              children: [
                Expanded(child: AppTextField(label: 'Profession', controller: professionController)),
                const SizedBox(width: AppSpacing.md),
                Expanded(child: AppTextField(label: 'Tone', controller: toneController)),
              ],
            )
          else
            Column(
              children: [
                AppTextField(label: 'Profession', controller: professionController),
                const SizedBox(height: AppSpacing.md),
                AppTextField(label: 'Tone', controller: toneController),
              ],
            ),
          const SizedBox(height: AppSpacing.lg),
          Wrap(
            spacing: AppSpacing.sm,
            runSpacing: AppSpacing.sm,
            children: [
              PrimaryButton(
                label: aiState.isLoading ? 'Generating...' : 'Generate full portfolio',
                icon: Icons.auto_awesome_rounded,
                onPressed: aiState.isLoading ? null : onGeneratePackage,
              ),
              _MiniAction(label: 'Headline', onPressed: aiState.isLoading ? null : () => onGenerateType(AiGenerationType.headline)),
              _MiniAction(label: 'About', onPressed: aiState.isLoading ? null : () => onGenerateType(AiGenerationType.about)),
              _MiniAction(label: 'Project summary', onPressed: aiState.isLoading ? null : () => onGenerateType(AiGenerationType.projectSummary)),
              _MiniAction(label: 'Structure', onPressed: aiState.isLoading ? null : () => onGenerateType(AiGenerationType.structure)),
            ],
          ),
        ],
      ),
    );
  }
}

class _LegacyPromptPanel extends StatelessWidget {
  const _LegacyPromptPanel({
    required this.aiState,
    required this.goalController,
    required this.contextController,
    required this.toneController,
    required this.onGenerate,
  });

  final AiStudioState aiState;
  final TextEditingController goalController;
  final TextEditingController contextController;
  final TextEditingController toneController;
  final VoidCallback onGenerate;

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Quick prompt lab', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800)),
          const SizedBox(height: AppSpacing.md),
          AppTextField(label: 'Goal', controller: goalController),
          const SizedBox(height: AppSpacing.md),
          AppTextField(label: 'Context', controller: contextController, maxLines: 4),
          const SizedBox(height: AppSpacing.md),
          Align(
            alignment: Alignment.centerLeft,
            child: PrimaryButton(
              label: aiState.isLoading ? 'Generating...' : 'Enhance summary',
              icon: Icons.auto_fix_high_rounded,
              onPressed: aiState.isLoading ? null : onGenerate,
            ),
          ),
        ],
      ),
    );
  }
}

class _GeneratedResults extends StatelessWidget {
  const _GeneratedResults({required this.state});

  final AiStudioState state;

  @override
  Widget build(BuildContext context) {
    final content = state.content;
    final draft = state.legacyDraft;
    if (content == null && draft == null) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (content != null) ...[
          if (content.headline.isNotEmpty) _OutputCard(title: 'Portfolio headlines', body: content.headline),
          if (content.about.isNotEmpty) _OutputCard(title: 'About section', body: content.about),
          if (content.structure.isNotEmpty) _OutputCard(title: 'Portfolio structure', body: content.structure.join('\n')),
          ...content.projectSummaries.map((section) => _OutputCard(title: section.title, body: section.body)),
          ...content.sections.where((section) => section.kind != 'headline' && section.kind != 'about' && section.kind != 'structure').map((section) => _OutputCard(title: section.title, body: section.body)),
        ],
        if (draft != null) _OutputCard(title: draft.title, body: draft.body),
      ],
    );
  }
}

class _OutputCard extends StatelessWidget {
  const _OutputCard({required this.title, required this.body});

  final String title;
  final String body;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.md),
      child: GlassCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800)),
            const SizedBox(height: AppSpacing.sm),
            Text(body, style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: AppColors.mist, height: 1.45)),
          ],
        ),
      ),
    );
  }
}

class _AiErrorCard extends StatelessWidget {
  const _AiErrorCard({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      child: Row(
        children: [
          const Icon(Icons.error_outline_rounded, color: AppColors.rose),
          const SizedBox(width: AppSpacing.md),
          Expanded(child: Text(message)),
          TextButton.icon(
            onPressed: onRetry,
            icon: const Icon(Icons.refresh_rounded),
            label: const Text('Retry'),
          ),
        ],
      ),
    );
  }
}

class _MiniAction extends StatelessWidget {
  const _MiniAction({required this.label, required this.onPressed});

  final String label;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return OutlinedButton(
      onPressed: onPressed,
      style: OutlinedButton.styleFrom(
        foregroundColor: AppColors.platinum,
        side: const BorderSide(color: AppColors.border),
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: 14),
      ),
      child: Text(label),
    );
  }
}
