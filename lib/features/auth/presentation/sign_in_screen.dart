import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/responsive/breakpoints.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/widgets/app_text_field.dart';
import '../../../core/widgets/glass_card.dart';
import '../../../core/widgets/primary_button.dart';
import '../../portfolio/presentation/portfolio_dashboard_screen.dart';
import '../state/auth_controller.dart';

class SignInScreen extends ConsumerStatefulWidget {
  const SignInScreen({super.key});

  static const routeName = 'sign-in';
  static const routePath = '/sign-in';

  @override
  ConsumerState<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends ConsumerState<SignInScreen> {
  final _emailController = TextEditingController(text: 'founder@portique.app');
  final _passwordController = TextEditingController(text: 'portique-demo');

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authControllerProvider);

    ref.listen(authControllerProvider, (previous, next) {
      if (next.isAuthenticated) {
        context.go(PortfolioDashboardScreen.routePath);
      }
    });

    if (authState.isAuthenticated) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) context.go(PortfolioDashboardScreen.routePath);
      });
    }

    final content = _AuthForm(
      emailController: _emailController,
      passwordController: _passwordController,
      authState: authState,
      onEmailPressed: () => ref.read(authControllerProvider.notifier).signInWithEmail(
            _emailController.text,
            _passwordController.text,
          ),
      onGooglePressed: ref.read(authControllerProvider.notifier).signInWithGoogle,
      onGuestPressed: ref.read(authControllerProvider.notifier).continueAsGuest,
    );

    return Scaffold(
      body: DecoratedBox(
        decoration: const BoxDecoration(
          gradient: RadialGradient(
            center: Alignment.topRight,
            radius: 1.2,
            colors: [Color(0x3D7C5CFF), AppColors.ink],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: AppSpacing.maxContentWidth),
                child: Breakpoints.of(context) == DeviceClass.mobile
                    ? Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          const _AuthHero(),
                          const SizedBox(height: AppSpacing.xl),
                          content,
                        ],
                      )
                    : Row(
                        children: [
                          const Expanded(child: _AuthHero()),
                          const SizedBox(width: AppSpacing.xl),
                          Expanded(child: content),
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

class _AuthHero extends StatelessWidget {
  const _AuthHero();

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          height: 72,
          width: 72,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24),
            gradient: const LinearGradient(colors: [AppColors.gold, AppColors.aurora]),
            boxShadow: const [
              BoxShadow(
                color: Color(0x557C5CFF),
                blurRadius: 36,
                offset: Offset(0, 18),
              ),
            ],
          ),
          child: const Icon(Icons.lock_open_rounded, color: AppColors.ink, size: 34),
        ),
        const SizedBox(height: AppSpacing.lg),
        Text(
          'Enter your private portfolio atelier.',
          style: Theme.of(context).textTheme.displaySmall?.copyWith(
                fontWeight: FontWeight.w900,
                height: 1.02,
                letterSpacing: -1.2,
              ),
        ),
        const SizedBox(height: AppSpacing.md),
        Text(
          'Sign in with Google, use email, or explore Portique as a guest. Your Firebase session will persist automatically once credentials are configured.',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: AppColors.mist,
                height: 1.55,
              ),
        ),
      ],
    );
  }
}

class _AuthForm extends StatelessWidget {
  const _AuthForm({
    required this.emailController,
    required this.passwordController,
    required this.authState,
    required this.onEmailPressed,
    required this.onGooglePressed,
    required this.onGuestPressed,
  });

  final TextEditingController emailController;
  final TextEditingController passwordController;
  final AuthState authState;
  final VoidCallback onEmailPressed;
  final VoidCallback onGooglePressed;
  final VoidCallback onGuestPressed;

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Welcome back',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            'Choose how you want to continue.',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppColors.mist),
          ),
          const SizedBox(height: AppSpacing.lg),
          _AuthMethodButton(
            label: 'Continue with Google',
            icon: Icons.g_mobiledata_rounded,
            isLoading: authState.loadingAction == AuthAction.google,
            onPressed: authState.isBusy ? null : onGooglePressed,
          ),
          const SizedBox(height: AppSpacing.md),
          _DividerLabel(label: 'or use email'),
          const SizedBox(height: AppSpacing.md),
          AppTextField(
            label: 'Email',
            controller: emailController,
            keyboardType: TextInputType.emailAddress,
            textInputAction: TextInputAction.next,
          ),
          const SizedBox(height: AppSpacing.md),
          AppTextField(
            label: 'Password',
            controller: passwordController,
            obscureText: true,
            textInputAction: TextInputAction.done,
          ),
          const SizedBox(height: AppSpacing.lg),
          PrimaryButton(
            label: authState.loadingAction == AuthAction.email ? 'Signing in...' : 'Sign in with email',
            icon: Icons.mail_rounded,
            onPressed: authState.isBusy ? null : onEmailPressed,
          ),
          const SizedBox(height: AppSpacing.md),
          TextButton.icon(
            onPressed: authState.isBusy ? null : onGuestPressed,
            icon: authState.loadingAction == AuthAction.guest
                ? const SizedBox.square(
                    dimension: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.person_outline_rounded),
            label: Text(authState.loadingAction == AuthAction.guest ? 'Opening guest space...' : 'Continue as guest'),
          ),
          if (authState.isRestoring) ...[
            const SizedBox(height: AppSpacing.md),
            const LinearProgressIndicator(minHeight: 3),
          ],
          if (authState.errorMessage != null) ...[
            const SizedBox(height: AppSpacing.md),
            _AuthErrorBanner(message: authState.errorMessage!),
          ],
        ],
      ),
    );
  }
}

class _AuthMethodButton extends StatelessWidget {
  const _AuthMethodButton({
    required this.label,
    required this.icon,
    required this.isLoading,
    required this.onPressed,
  });

  final String label;
  final IconData icon;
  final bool isLoading;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return OutlinedButton.icon(
      onPressed: onPressed,
      icon: isLoading
          ? const SizedBox.square(
              dimension: 18,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
          : Icon(icon, size: 26),
      label: Text(isLoading ? 'Connecting...' : label),
      style: OutlinedButton.styleFrom(
        foregroundColor: AppColors.platinum,
        side: const BorderSide(color: AppColors.border),
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      ),
    );
  }
}

class _DividerLabel extends StatelessWidget {
  const _DividerLabel({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Expanded(child: Divider(color: AppColors.border)),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
          child: Text(label, style: Theme.of(context).textTheme.labelMedium?.copyWith(color: AppColors.muted)),
        ),
        const Expanded(child: Divider(color: AppColors.border)),
      ],
    );
  }
}

class _AuthErrorBanner extends StatelessWidget {
  const _AuthErrorBanner({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.rose.withAlpha(24),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.rose.withAlpha(96)),
      ),
      child: Row(
        children: [
          const Icon(Icons.error_outline_rounded, color: AppColors.rose),
          const SizedBox(width: AppSpacing.sm),
          Expanded(child: Text(message)),
        ],
      ),
    );
  }
}
