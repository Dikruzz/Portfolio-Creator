import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/ai/presentation/ai_studio_screen.dart';
import '../../features/auth/presentation/sign_in_screen.dart';
import '../../features/onboarding/presentation/onboarding_screen.dart';
import '../../features/onboarding/presentation/splash_screen.dart';
import '../../features/portfolio/presentation/portfolio_dashboard_screen.dart';
import '../../features/portfolio/presentation/project_creation/project_creation_screen.dart';
import '../../features/portfolio/presentation/project_creation/project_review_screen.dart';

final appRouterProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: SplashScreen.routePath,
    routes: [
      GoRoute(
        path: SplashScreen.routePath,
        name: SplashScreen.routeName,
        builder: (context, state) => const SplashScreen(),
      ),
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
        path: ProjectCreationScreen.routePath,
        name: ProjectCreationScreen.routeName,
        builder: (context, state) => const ProjectCreationScreen(),
      ),
      GoRoute(
        path: ProjectReviewScreen.routePath,
        name: ProjectReviewScreen.routeName,
        builder: (context, state) => const ProjectReviewScreen(),
      ),
      GoRoute(
        path: AiStudioScreen.routePath,
        name: AiStudioScreen.routeName,
        builder: (context, state) => const AiStudioScreen(),
      ),
    ],
  );
});
