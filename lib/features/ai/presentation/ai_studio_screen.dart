import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/widgets/app_text_field.dart';
import '../../../core/widgets/glass_card.dart';
import '../../../core/widgets/premium_scaffold.dart';
import '../../../core/widgets/primary_button.dart';
import '../../../core/widgets/section_header.dart';
import '../../portfolio/presentation/portfolio_dashboard_screen.dart';
import '../domain/ai_prompt.dart';
import '../state/ai_controller.dart';

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

  @override
  void dispose() {
    _goalController.dispose();
    _contextController.dispose();
    _toneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final aiState = ref.watch(aiControllerProvider);

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
            title: 'Generate polished portfolio copy',
            subtitle: 'Use this placeholder flow until your AI backend or Firebase Function is connected.',
          ),
          const SizedBox(height: AppSpacing.lg),
          GlassCard(
            child: Column(
              children: [
                AppTextField(label: 'Goal', controller: _goalController),
                const SizedBox(height: AppSpacing.md),
                AppTextField(label: 'Context', controller: _contextController, maxLines: 4),
                const SizedBox(height: AppSpacing.md),
                AppTextField(label: 'Tone', controller: _toneController),
                const SizedBox(height: AppSpacing.lg),
                Align(
                  alignment: Alignment.centerLeft,
                  child: PrimaryButton(
                    label: aiState.isLoading ? 'Generating...' : 'Generate draft',
                    icon: Icons.auto_awesome_rounded,
                    onPressed: aiState.isLoading
                        ? null
                        : () => ref.read(aiControllerProvider.notifier).generate(
                              AiPrompt(
                                goal: _goalController.text,
                                context: _contextController.text,
                                tone: _toneController.text,
                              ),
                            ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          aiState.when(
            loading: () => const CircularProgressIndicator(),
            error: (error, stackTrace) => Text(error.toString(), style: TextStyle(color: Theme.of(context).colorScheme.error)),
            data: (draft) {
              if (draft == null) return const SizedBox.shrink();
              return GlassCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(draft.title, style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800)),
                    const SizedBox(height: AppSpacing.sm),
                    Text(draft.body, style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: AppColors.mist)),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
