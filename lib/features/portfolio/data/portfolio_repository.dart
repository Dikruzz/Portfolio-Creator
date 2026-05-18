import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/firebase/firebase_placeholders.dart';
import '../domain/portfolio.dart';

final portfolioRepositoryProvider = Provider<PortfolioRepository>((ref) {
  return PortfolioRepository(ref: ref);
});

class PortfolioRepository {
  const PortfolioRepository({required this.ref});

  final Ref ref;

  Future<PortfolioProfile> fetchPortfolio() async {
    final firestore = ref.read(firestoreProvider);
    if (firestore != null) {
      // Replace demo data with Firestore reads from users/{uid}/portfolio.
    }

    return const PortfolioProfile(
      name: 'Avery Stone',
      positioning: 'Product-minded Flutter engineer building elegant AI tools for creative professionals.',
      skills: ['Flutter', 'AI UX', 'Firebase', 'Design Systems'],
      projects: [
        PortfolioProject(
          title: 'Signal Studio',
          role: 'Lead Flutter Engineer',
          summary: 'Designed a multi-platform analytics workspace for creators.',
          impact: '+42% activation',
        ),
        PortfolioProject(
          title: 'Northstar AI',
          role: 'Product Engineer',
          summary: 'Built an AI brief generator with collaborative review flows.',
          impact: '3x faster briefs',
        ),
      ],
    );
  }
}
