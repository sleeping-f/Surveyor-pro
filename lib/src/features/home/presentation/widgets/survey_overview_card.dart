import 'package:flutter/material.dart';

import '../../../../core/constants/app_spacing.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../shared/widgets/app_card.dart';

class SurveyOverviewCard extends StatelessWidget {
  const SurveyOverviewCard({
    required this.onResumePressed,
    super.key,
  });

  final VoidCallback onResumePressed;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final statusColors =
        Theme.of(context).extension<AppStatusColors>() ?? AppStatusColors.light;

    return AppCard(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: colorScheme.primaryContainer,
                  borderRadius: AppSpacing.radius,
                ),
                child: Icon(
                  Icons.route,
                  color: colorScheme.onPrimaryContainer,
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Field workspace',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      'No active road segment survey is running.',
                      style: AppTextStyles.muted(context),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          Wrap(
            spacing: AppSpacing.xs,
            runSpacing: AppSpacing.xs,
            children: [
              _StatusPill(
                label: 'Offline ready',
                color: statusColors.success,
              ),
              _StatusPill(
                label: 'Local-first',
                color: statusColors.gps,
              ),
              _StatusPill(
                label: 'Draft safe',
                color: statusColors.info,
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          Divider(
            color: colorScheme.outlineVariant.withValues(alpha: 0.7),
            height: 1,
          ),
          const SizedBox(height: AppSpacing.lg),
          Text(
            'Planned collection modules',
            style: Theme.of(context).textTheme.titleSmall,
          ),
          const SizedBox(height: AppSpacing.md),
          const _ReadinessGrid(),
          const SizedBox(height: AppSpacing.lg),
          OutlinedButton.icon(
            onPressed: onResumePressed,
            icon: const Icon(Icons.history),
            label: const Text('View drafts'),
          ),
        ],
      ),
    );
  }
}

class _StatusPill extends StatelessWidget {
  const _StatusPill({
    required this.label,
    required this.color,
  });

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: AppSpacing.radius,
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.sm,
          vertical: AppSpacing.xs,
        ),
        child: Text(
          label,
          style: Theme.of(context).textTheme.labelMedium!.copyWith(
                color: color,
              ),
        ),
      ),
    );
  }
}

class _ReadinessGrid extends StatelessWidget {
  const _ReadinessGrid();

  @override
  Widget build(BuildContext context) {
    const items = [
      _ReadinessItem(
        icon: Icons.assignment_outlined,
        label: 'Forms',
      ),
      _ReadinessItem(
        icon: Icons.gps_fixed,
        label: 'GPS',
      ),
      _ReadinessItem(
        icon: Icons.photo_camera_outlined,
        label: 'Photos',
      ),
      _ReadinessItem(
        icon: Icons.storage_outlined,
        label: 'SQLite',
      ),
    ];

    return Wrap(
      spacing: AppSpacing.sm,
      runSpacing: AppSpacing.sm,
      children: items,
    );
  }
}

class _ReadinessItem extends StatelessWidget {
  const _ReadinessItem({
    required this.icon,
    required this.label,
  });

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      constraints: const BoxConstraints(minHeight: 44),
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.xs,
      ),
      decoration: BoxDecoration(
        border: Border.all(
          color: colorScheme.outlineVariant.withValues(alpha: 0.7),
        ),
        borderRadius: AppSpacing.radius,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 18,
            color: colorScheme.primary,
          ),
          const SizedBox(width: AppSpacing.xs),
          Text(
            label,
            style: Theme.of(context).textTheme.labelLarge,
          ),
        ],
      ),
    );
  }
}
