import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/ai/presentation/ai_studio_screen.dart';
import '../../features/auth/presentation/sign_in_screen.dart';
import '../../features/onboarding/presentation/onboarding_screen.dart';
import '../../features/portfolio/presentation/portfolio_dashboard_screen.dart';

final appRouterProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: OnboardingScreen.routePath,
    routes: [
      GoRoute(
        path: OnboardingScreen.routePath,
        name: OnboardingScreen.routeName,
        builder: (context, state) => const OnboardingScreen(),
      ),
      GoRoute(
        path: SignInScreen.routePath,
        name: SignInScreen.routeName,
        builder: (context, state) => const SignInScreen(),
      ),
      GoRoute(
        path: PortfolioDashboardScreen.routePath,
        name: PortfolioDashboardScreen.routeName,
        builder: (context, state) => const PortfolioDashboardScreen(),
      ),
      GoRoute(
        path: AiStudioScreen.routePath,
        name: AiStudioScreen.routeName,
        builder: (context, state) => const AiStudioScreen(),
      ),
    ],
  );
});
