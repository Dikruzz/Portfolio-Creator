import 'package:flutter/material.dart';

import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_spacing.dart';
import '../../../domain/project_creation_models.dart';

class ProjectImageCard extends StatelessWidget {
  const ProjectImageCard({
    required this.image,
    required this.onReplace,
    required this.onRemove,
    super.key,
  });

  final ProjectImageAsset image;
  final VoidCallback onReplace;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surfaceElevated,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(22)),
              child: DecoratedBox(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [Color(0x337C5CFF), Color(0x22D9B56D)],
                  ),
                ),
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    Image.network(
                      image.path,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return const Center(
                          child: Icon(Icons.image_rounded, size: 48, color: AppColors.gold),
                        );
                      },
                    ),
                    Positioned(
                      right: AppSpacing.sm,
                      top: AppSpacing.sm,
                      child: IconButton.filledTonal(
                        onPressed: onRemove,
                        icon: const Icon(Icons.close_rounded),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(image.name, maxLines: 1, overflow: TextOverflow.ellipsis, style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w800)),
                const SizedBox(height: AppSpacing.xs),
                Text(image.mimeType ?? 'Local image', style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppColors.mist)),
                const SizedBox(height: AppSpacing.sm),
                OutlinedButton.icon(
                  onPressed: onReplace,
                  icon: const Icon(Icons.swap_horiz_rounded),
                  label: const Text('Replace'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
