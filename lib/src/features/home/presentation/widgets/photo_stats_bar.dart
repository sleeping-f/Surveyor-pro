import 'package:flutter/material.dart';

import '../../../../core/constants/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';

class PhotoStatsBar extends StatelessWidget {
  const PhotoStatsBar({
    required this.photoCount,
    super.key,
  });

  final int photoCount;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerLow,
        borderRadius: AppSpacing.radius,
        border: Border.all(
          color: colorScheme.outlineVariant.withValues(alpha: 0.62),
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.photo_library_outlined,
            size: 20,
            color: colorScheme.primary,
          ),
          const SizedBox(width: AppSpacing.sm),
          Text(
            '$photoCount',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(width: AppSpacing.xs),
          Text(
            photoCount == 1 ? 'photo captured' : 'photos captured',
            style: AppTextStyles.muted(context),
          ),
        ],
      ),
    );
  }
}
