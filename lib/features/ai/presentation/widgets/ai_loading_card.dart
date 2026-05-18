import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/glass_card.dart';

class AiLoadingCard extends StatefulWidget {
  const AiLoadingCard({required this.message, super.key});

  final String message;

  @override
  State<AiLoadingCard> createState() => _AiLoadingCardState();
}

class _AiLoadingCardState extends State<AiLoadingCard> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      child: Row(
        children: [
          AnimatedBuilder(
            animation: _controller,
            builder: (context, child) {
              return Container(
                height: 54,
                width: 54,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    colors: [
                      AppColors.gold.withAlpha((140 + 90 * _controller.value).round()),
                      AppColors.aurora,
                    ],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.aurora.withAlpha((40 + 80 * _controller.value).round()),
                      blurRadius: 28,
                    ),
                  ],
                ),
                child: const Icon(Icons.auto_awesome_rounded, color: AppColors.ink),
              );
            },
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Portique AI is composing', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800)),
                const SizedBox(height: AppSpacing.xs),
                Text(widget.message, style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppColors.mist)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
