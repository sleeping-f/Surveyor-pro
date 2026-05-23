import 'package:flutter/material.dart';

import '../../../../core/constants/app_spacing.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../shared/widgets/app_card.dart';
import '../../application/home_metrics_controller.dart';

class FieldStatusCard extends StatelessWidget {
  const FieldStatusCard({
    required this.state,
    super.key,
  });

  final HomeMetricsState state;

  @override
  Widget build(BuildContext context) {
    final statusColors =
        Theme.of(context).extension<AppStatusColors>() ?? AppStatusColors.light;
    final metrics = state.metrics;

    return AppCard(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Device data status',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            state.status == HomeMetricsStatus.failure
                ? state.message ?? 'Local counts could not be loaded.'
                : 'Local counts update from stored surveys, images, and exports.',
            style: AppTextStyles.muted(context),
          ),
          const SizedBox(height: AppSpacing.lg),
          _StatusMetric(
            icon: Icons.assignment_turned_in_outlined,
            label: 'Local records',
            value: metrics.localRecords.toString(),
            color: statusColors.success,
          ),
          const SizedBox(height: AppSpacing.md),
          _StatusMetric(
            icon: Icons.edit_note_outlined,
            label: 'Draft surveys',
            value: metrics.draftImages.toString(),
            color: statusColors.warning,
          ),
          const SizedBox(height: AppSpacing.md),
          _StatusMetric(
            icon: Icons.image_outlined,
            label: 'Stored images',
            value: metrics.storedImages.toString(),
            color: statusColors.camera,
          ),
          const SizedBox(height: AppSpacing.md),
          _StatusMetric(
            icon: Icons.ios_share_outlined,
            label: 'Pending exports',
            value: metrics.pendingExports.toString(),
            color: statusColors.info,
          ),
        ],
      ),
    );
  }
}

class _StatusMetric extends StatelessWidget {
  const _StatusMetric({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  final IconData icon;
  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Row(
      children: [
        Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.12),
            borderRadius: AppSpacing.radius,
          ),
          child: Icon(
            icon,
            color: color,
          ),
        ),
        const SizedBox(width: AppSpacing.md),
        Expanded(
          child: Text(
            label,
            style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
          ),
        ),
        Text(
          value,
          style: AppTextStyles.metricValue(context),
        ),
      ],
    );
  }
}
