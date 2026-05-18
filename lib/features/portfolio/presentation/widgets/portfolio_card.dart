import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/glass_card.dart';
import '../../domain/portfolio.dart';

class PortfolioCard extends StatelessWidget {
  const PortfolioCard({required this.project, super.key});

  final PortfolioProject project;

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(project.impact, style: Theme.of(context).textTheme.labelLarge?.copyWith(color: AppColors.emerald)),
          const SizedBox(height: AppSpacing.sm),
          Text(project.title, style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800)),
          const SizedBox(height: AppSpacing.xs),
          Text(project.role, style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppColors.gold)),
          const SizedBox(height: AppSpacing.md),
          Text(project.summary, style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppColors.mist)),
        ],
      ),
    );
  }
}
