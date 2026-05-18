import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_spacing.dart';
import '../../../core/widgets/app_text_field.dart';
import '../../../core/widgets/glass_card.dart';
import '../../../core/widgets/premium_scaffold.dart';
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
      if (next.hasValue && next.value != null) {
        context.go(PortfolioDashboardScreen.routePath);
      }
    });

    return PremiumScaffold(
      title: 'Welcome back',
      child: GlassCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Sign in to curate your portfolio.', style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w700)),
            const SizedBox(height: AppSpacing.lg),
            AppTextField(label: 'Email', controller: _emailController, keyboardType: TextInputType.emailAddress),
            const SizedBox(height: AppSpacing.md),
            AppTextField(label: 'Password', controller: _passwordController),
            const SizedBox(height: AppSpacing.lg),
            PrimaryButton(
              label: authState.isLoading ? 'Signing in...' : 'Continue',
              icon: Icons.lock_open_rounded,
              onPressed: authState.isLoading
                  ? null
                  : () => ref.read(authControllerProvider.notifier).signIn(
                        _emailController.text.trim(),
                        _passwordController.text,
                      ),
            ),
            if (authState.hasError) ...[
              const SizedBox(height: AppSpacing.md),
              Text(authState.error.toString(), style: TextStyle(color: Theme.of(context).colorScheme.error)),
            ],
          ],
        ),
      ),
    );
  }
}
