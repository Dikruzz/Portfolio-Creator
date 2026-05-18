import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/widgets/premium_scaffold.dart';
import '../../../core/widgets/primary_button.dart';
import '../../../core/widgets/section_header.dart';
import '../../ai/presentation/ai_studio_screen.dart';
import '../../auth/presentation/sign_in_screen.dart';
import '../../auth/state/auth_controller.dart';
import '../state/portfolio_controller.dart';
import 'widgets/portfolio_card.dart';

class PortfolioDashboardScreen extends ConsumerWidget {
  const PortfolioDashboardScreen({super.key});

  static const routeName = 'portfolio';
  static const routePath = '/portfolio';

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final portfolio = ref.watch(portfolioControllerProvider);
    final authState = ref.watch(authControllerProvider);

    ref.listen(authControllerProvider, (previous, next) {
      if (!next.isRestoring && !next.isAuthenticated) {
        context.go(SignInScreen.routePath);
      }
    });

    return PremiumScaffold(
      title: 'Portfolio',
      actions: [
        TextButton.icon(
          onPressed: () => context.go(AiStudioScreen.routePath),
          icon: const Icon(Icons.auto_awesome_rounded),
          label: const Text('AI Studio'),
        ),
        TextButton.icon(
          onPressed: authState.isBusy
              ? null
              : () => ref.read(authControllerProvider.notifier).signOut(),
          icon: const Icon(Icons.logout_rounded),
          label: const Text('Sign out'),
        ),
      ],
      child: portfolio.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stackTrace) => Text(error.toString(), style: TextStyle(color: Theme.of(context).colorScheme.error)),
        data: (profile) => Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(profile.name, style: Theme.of(context).textTheme.displaySmall?.copyWith(fontWeight: FontWeight.w800)),
            const SizedBox(height: AppSpacing.sm),
            Text(profile.positioning, style: Theme.of(context).textTheme.titleMedium?.copyWith(color: AppColors.mist)),
            const SizedBox(height: AppSpacing.lg),
            Wrap(
              spacing: AppSpacing.sm,
              runSpacing: AppSpacing.sm,
              children: profile.skills.map((skill) => Chip(label: Text(skill))).toList(),
            ),
            const SizedBox(height: AppSpacing.xl),
            Row(
              children: [
                const Expanded(child: SectionHeader(title: 'Featured work', subtitle: 'Case studies ready for AI refinement.')),
                PrimaryButton(
                  label: 'Generate copy',
                  icon: Icons.auto_fix_high_rounded,
                  onPressed: () => context.go(AiStudioScreen.routePath),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.lg),
            LayoutBuilder(
              builder: (context, constraints) {
                final columns = constraints.maxWidth > 840 ? 2 : 1;
                return GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: profile.projects.length,
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: columns,
                    crossAxisSpacing: AppSpacing.md,
                    mainAxisSpacing: AppSpacing.md,
                    childAspectRatio: columns == 1 ? 1.9 : 1.35,
                  ),
                  itemBuilder: (context, index) => PortfolioCard(project: profile.projects[index]),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
