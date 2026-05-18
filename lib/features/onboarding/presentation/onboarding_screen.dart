import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/widgets/glass_card.dart';
import '../../../core/widgets/premium_scaffold.dart';
import '../../../core/widgets/primary_button.dart';
import '../../auth/presentation/sign_in_screen.dart';
import '../domain/onboarding_page_data.dart';
import '../state/onboarding_controller.dart';

class OnboardingScreen extends ConsumerWidget {
  const OnboardingScreen({super.key});

  static const routeName = 'onboarding';
  static const routePath = '/';

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final index = ref.watch(onboardingIndexProvider);
    final page = onboardingPages[index];
    final isLastPage = index == onboardingPages.length - 1;

    return PremiumScaffold(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Portique', style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.w800)),
          const SizedBox(height: AppSpacing.xxl),
          GlassCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(page.metric, style: Theme.of(context).textTheme.labelLarge?.copyWith(color: AppColors.gold)),
                const SizedBox(height: AppSpacing.md),
                Text(page.title, style: Theme.of(context).textTheme.displaySmall?.copyWith(fontWeight: FontWeight.w800)),
                const SizedBox(height: AppSpacing.md),
                Text(page.description, style: Theme.of(context).textTheme.titleMedium?.copyWith(color: AppColors.mist)),
                const SizedBox(height: AppSpacing.xl),
                Wrap(
                  spacing: AppSpacing.sm,
                  children: List.generate(
                    onboardingPages.length,
                    (dotIndex) => AnimatedContainer(
                      duration: const Duration(milliseconds: 240),
                      height: 8,
                      width: dotIndex == index ? 36 : 8,
                      decoration: BoxDecoration(
                        color: dotIndex == index ? AppColors.gold : AppColors.border,
                        borderRadius: BorderRadius.circular(999),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.xl),
                PrimaryButton(
                  label: isLastPage ? 'Enter Portique' : 'Continue',
                  icon: Icons.arrow_forward_rounded,
                  onPressed: () {
                    if (isLastPage) {
                      ref.read(onboardingCompletedProvider.notifier).state = true;
                      context.go(SignInScreen.routePath);
                      return;
                    }
                    ref.read(onboardingIndexProvider.notifier).state = index + 1;
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
