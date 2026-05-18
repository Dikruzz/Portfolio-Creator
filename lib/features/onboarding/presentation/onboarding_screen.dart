import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/responsive/breakpoints.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/widgets/glass_card.dart';
import '../../../core/widgets/primary_button.dart';
import '../../auth/presentation/sign_in_screen.dart';
import '../domain/onboarding_page_data.dart';
import '../state/onboarding_controller.dart';

class OnboardingScreen extends ConsumerWidget {
  const OnboardingScreen({super.key});

  static const routeName = 'onboarding';
  static const routePath = '/onboarding';

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(onboardingControllerProvider);
    final controller = ref.read(onboardingControllerProvider.notifier);

    ref.listen(onboardingControllerProvider, (previous, next) {
      if (next.completed) context.go(SignInScreen.routePath);
    });

    return Scaffold(
      body: DecoratedBox(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF101735), AppColors.ink],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: AppSpacing.maxContentWidth),
                child: Column(
                  children: [
                    _OnboardingTopBar(
                      progress: state.progress,
                      canGoBack: state.step > 0,
                      onBack: controller.back,
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    Expanded(
                      child: AnimatedSwitcher(
                        duration: const Duration(milliseconds: 520),
                        switchInCurve: Curves.easeOutCubic,
                        switchOutCurve: Curves.easeInCubic,
                        transitionBuilder: (child, animation) {
                          final offset = Tween<Offset>(
                            begin: const Offset(0.06, 0),
                            end: Offset.zero,
                          ).animate(animation);
                          return FadeTransition(
                            opacity: animation,
                            child: SlideTransition(position: offset, child: child),
                          );
                        },
                        child: _OnboardingStep(
                          key: ValueKey(state.step),
                          state: state,
                          onProfessionSelected: controller.selectProfession,
                          onStyleSelected: controller.selectStyle,
                        ),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    _BottomActionBar(
                      state: state,
                      onPressed: state.canContinue ? controller.next : null,
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

class _OnboardingTopBar extends StatelessWidget {
  const _OnboardingTopBar({
    required this.progress,
    required this.canGoBack,
    required this.onBack,
  });

  final double progress;
  final bool canGoBack;
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        IconButton.filledTonal(
          onPressed: canGoBack ? onBack : null,
          icon: const Icon(Icons.arrow_back_rounded),
        ),
        const SizedBox(width: AppSpacing.md),
        Expanded(child: _AnimatedProgressBar(value: progress)),
        const SizedBox(width: AppSpacing.md),
        Text(
          '${(progress * 100).round()}%',
          style: Theme.of(context).textTheme.labelLarge?.copyWith(color: AppColors.gold),
        ),
      ],
    );
  }
}

class _AnimatedProgressBar extends StatelessWidget {
  const _AnimatedProgressBar({required this.value});

  final double value;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(999),
      child: Container(
        height: 12,
        color: AppColors.surfaceElevated,
        alignment: Alignment.centerLeft,
        child: TweenAnimationBuilder<double>(
          tween: Tween<double>(begin: 0, end: value),
          duration: const Duration(milliseconds: 420),
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

class _OnboardingStep extends StatelessWidget {
  const _OnboardingStep({
    required this.state,
    required this.onProfessionSelected,
    required this.onStyleSelected,
    super.key,
  });

  final OnboardingState state;
  final ValueChanged<String> onProfessionSelected;
  final ValueChanged<String> onStyleSelected;

  @override
  Widget build(BuildContext context) {
    if (state.step < cinematicOnboardingPages.length) {
      return _CinematicIntro(page: cinematicOnboardingPages[state.step]);
    }

    if (state.step == 3) {
      return _SelectionStep(
        eyebrow: 'Step 4 of 5',
        title: 'What kind of work should Portique spotlight first?',
        subtitle: 'Pick one path. You can refine this later from your profile.',
        options: professionOptions,
        selectedId: state.professionId,
        onSelected: onProfessionSelected,
      );
    }

    return _SelectionStep(
      eyebrow: 'Step 5 of 5',
      title: 'Choose the visual direction for your portfolio.',
      subtitle: 'This sets the first theme recommendation and AI writing tone.',
      options: styleOptions,
      selectedId: state.styleId,
      onSelected: onStyleSelected,
    );
  }
}

class _CinematicIntro extends StatelessWidget {
  const _CinematicIntro({required this.page});

  final OnboardingPageData page;

  @override
  Widget build(BuildContext context) {
    final isWide = Breakpoints.of(context) != DeviceClass.mobile;
    final text = _IntroCopy(page: page);
    final visual = _HeroPortal(page: page);

    if (isWide) {
      return Row(
        children: [
          Expanded(child: text),
          const SizedBox(width: AppSpacing.xl),
          Expanded(child: visual),
        ],
      );
    }

    return ListView(
      children: [
        visual,
        const SizedBox(height: AppSpacing.xl),
        text,
      ],
    );
  }
}

class _IntroCopy extends StatelessWidget {
  const _IntroCopy({required this.page});

  final OnboardingPageData page;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(page.eyebrow, style: Theme.of(context).textTheme.labelLarge?.copyWith(color: AppColors.gold)),
        const SizedBox(height: AppSpacing.md),
        Text(
          page.title,
          style: Theme.of(context).textTheme.displaySmall?.copyWith(
                fontWeight: FontWeight.w900,
                letterSpacing: -1.4,
                height: 1.03,
              ),
        ),
        const SizedBox(height: AppSpacing.md),
        Text(
          page.description,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(color: AppColors.mist, height: 1.55),
        ),
      ],
    );
  }
}

class _HeroPortal extends StatelessWidget {
  const _HeroPortal({required this.page});

  final OnboardingPageData page;

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: const Duration(milliseconds: 900),
      curve: Curves.easeOutCubic,
      builder: (context, value, child) {
        return Transform.translate(
          offset: Offset(0, 22 * (1 - value)),
          child: Opacity(opacity: value, child: child),
        );
      },
      child: AspectRatio(
        aspectRatio: 1,
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(42),
            gradient: RadialGradient(
              center: Alignment.topLeft,
              radius: 1.2,
              colors: [...page.gradient.map((color) => color.withAlpha(130)), AppColors.surface],
            ),
            border: Border.all(color: AppColors.border),
          ),
          child: Stack(
            children: [
              Positioned.fill(
                child: Padding(
                  padding: const EdgeInsets.all(AppSpacing.xl),
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(34),
                      border: Border.all(color: Colors.white.withAlpha(28)),
                    ),
                  ),
                ),
              ),
              Center(
                child: Container(
                  height: 132,
                  width: 132,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(colors: page.gradient),
                    boxShadow: const [BoxShadow(color: Color(0x55000000), blurRadius: 42, offset: Offset(0, 24))],
                  ),
                  child: Icon(page.icon, size: 58, color: AppColors.ink),
                ),
              ),
              Positioned(
                left: AppSpacing.lg,
                right: AppSpacing.lg,
                bottom: AppSpacing.lg,
                child: GlassCard(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  child: Row(
                    children: [
                      const Icon(Icons.motion_photos_on_rounded, color: AppColors.gold),
                      const SizedBox(width: AppSpacing.sm),
                      Expanded(
                        child: Text(
                          'Cinematic setup in progress',
                          style: Theme.of(context).textTheme.labelLarge,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SelectionStep extends StatelessWidget {
  const _SelectionStep({
    required this.eyebrow,
    required this.title,
    required this.subtitle,
    required this.options,
    required this.selectedId,
    required this.onSelected,
  });

  final String eyebrow;
  final String title;
  final String subtitle;
  final List<SelectionOption> options;
  final String? selectedId;
  final ValueChanged<String> onSelected;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final columns = constraints.maxWidth > 760 ? 2 : 1;
        return ListView(
          children: [
            Text(eyebrow, style: Theme.of(context).textTheme.labelLarge?.copyWith(color: AppColors.gold)),
            const SizedBox(height: AppSpacing.sm),
            Text(
              title,
              style: Theme.of(context).textTheme.headlineLarge?.copyWith(fontWeight: FontWeight.w900, height: 1.05),
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(subtitle, style: Theme.of(context).textTheme.titleMedium?.copyWith(color: AppColors.mist)),
            const SizedBox(height: AppSpacing.xl),
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: options.length,
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: columns,
                crossAxisSpacing: AppSpacing.md,
                mainAxisSpacing: AppSpacing.md,
                childAspectRatio: columns == 1 ? 3.4 : 2.55,
              ),
              itemBuilder: (context, index) {
                final option = options[index];
                return _SelectionCard(
                  option: option,
                  selected: option.id == selectedId,
                  onTap: () => onSelected(option.id),
                );
              },
            ),
          ],
        );
      },
    );
  }
}

class _SelectionCard extends StatelessWidget {
  const _SelectionCard({required this.option, required this.selected, required this.onTap});

  final SelectionOption option;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return AnimatedScale(
      duration: const Duration(milliseconds: 180),
      scale: selected ? 1.02 : 1,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(26),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 240),
          padding: const EdgeInsets.all(AppSpacing.lg),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(26),
            color: selected ? AppColors.surfaceElevated : AppColors.surface,
            border: Border.all(color: selected ? AppColors.gold : AppColors.border, width: selected ? 1.6 : 1),
            boxShadow: selected
                ? const [BoxShadow(color: Color(0x33D9B56D), blurRadius: 32, offset: Offset(0, 18))]
                : null,
          ),
          child: Row(
            children: [
              Container(
                height: 54,
                width: 54,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(18),
                  gradient: LinearGradient(
                    colors: selected
                        ? const [AppColors.gold, AppColors.aurora]
                        : const [AppColors.surfaceElevated, AppColors.midnight],
                  ),
                ),
                child: Icon(option.icon, color: selected ? AppColors.ink : AppColors.gold),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(option.title, style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800)),
                    const SizedBox(height: 4),
                    Text(option.subtitle, style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppColors.mist)),
                  ],
                ),
              ),
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 180),
                child: selected
                    ? const Icon(Icons.check_circle_rounded, key: ValueKey('selected'), color: AppColors.emerald)
                    : const Icon(Icons.circle_outlined, key: ValueKey('empty'), color: AppColors.border),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _BottomActionBar extends StatelessWidget {
  const _BottomActionBar({required this.state, required this.onPressed});

  final OnboardingState state;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    final isFinal = state.step == OnboardingState.totalSteps - 1;
    return Row(
      children: [
        Expanded(
          child: Text(
            'Step ${state.step + 1} of ${OnboardingState.totalSteps}',
            style: Theme.of(context).textTheme.labelLarge?.copyWith(color: AppColors.mist),
          ),
        ),
        PrimaryButton(
          label: isFinal ? 'Finish setup' : 'Continue',
          icon: isFinal ? Icons.check_rounded : Icons.arrow_forward_rounded,
          onPressed: onPressed,
        ),
      ],
    );
  }
}
