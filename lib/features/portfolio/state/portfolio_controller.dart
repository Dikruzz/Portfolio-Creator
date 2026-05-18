import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/portfolio_repository.dart';
import '../domain/portfolio.dart';

final portfolioControllerProvider = FutureProvider<PortfolioProfile>((ref) async {
  return ref.read(portfolioRepositoryProvider).fetchPortfolio();
});
