import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../auth/state/auth_controller.dart';
import '../../portfolio/presentation/portfolio_dashboard_screen.dart';
import 'onboarding_screen.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  static const routeName = 'splash';
  static const routePath = '/';

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen> with SingleTickerProviderStateMixin {
  bool _readyToRoute = false;
  late final AnimationController _controller;
  late final Animation<double> _fade;
  late final Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..forward();
    _fade = CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic);
    _scale = Tween<double>(begin: 0.92, end: 1).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutBack),
    );

    Timer(const Duration(milliseconds: 1900), () {
      if (!mounted) return;
      _readyToRoute = true;
      _routeForAuthState(ref.read(authControllerProvider));
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _routeForAuthState(AuthState authState) {
    if (!_readyToRoute || authState.isRestoring) return;
    final destination = authState.isAuthenticated
        ? PortfolioDashboardScreen.routePath
        : OnboardingScreen.routePath;
    context.go(destination);
  }

  @override
  Widget build(BuildContext context) {
    ref.listen(authControllerProvider, (previous, next) {
      _routeForAuthState(next);
    });

    return Scaffold(
      body: DecoratedBox(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [AppColors.ink, AppColors.midnight, Color(0xFF170F2E)],
          ),
        ),
        child: Stack(
          children: [
            const Positioned(
              top: -120,
              right: -80,
              child: _AtmosphereOrb(size: 280, color: Color(0x557C5CFF)),
            ),
            const Positioned(
              bottom: -140,
              left: -90,
              child: _AtmosphereOrb(size: 320, color: Color(0x44D9B56D)),
            ),
            Center(
              child: FadeTransition(
                opacity: _fade,
                child: ScaleTransition(
                  scale: _scale,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        height: 92,
                        width: 92,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(32),
                          gradient: const LinearGradient(
                            colors: [AppColors.gold, AppColors.aurora],
                          ),
                          boxShadow: const [
                            BoxShadow(
                              color: Color(0x667C5CFF),
                              blurRadius: 44,
                              offset: Offset(0, 24),
                            ),
                          ],
                        ),
                        child: const Icon(Icons.auto_awesome_rounded, color: AppColors.ink, size: 42),
                      ),
                      const SizedBox(height: AppSpacing.lg),
                      Text(
                        'Portique',
                        style: Theme.of(context).textTheme.displaySmall?.copyWith(
                              fontWeight: FontWeight.w900,
                              letterSpacing: -1.2,
                            ),
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      Text(
                        'Your portfolio, directed by AI.',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(color: AppColors.mist),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AtmosphereOrb extends StatelessWidget {
  const _AtmosphereOrb({required this.size, required this.color});

  final double size;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: size,
      width: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(colors: [color, Colors.transparent]),
      ),
    );
  }
}
