import 'package:flutter/material.dart';

import '../../../../core/constants/app_spacing.dart';
import '../../../../core/location/domain/captured_location.dart';
import '../../../../core/location/domain/location_failure.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/app_formatters.dart';
import '../../../../shared/widgets/app_card.dart';
import '../../application/gps_capture_controller.dart';

class GpsCaptureCard extends StatelessWidget {
  const GpsCaptureCard({
    required this.controller,
    super.key,
  });

  final GpsCaptureController controller;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (context, _) {
        final state = controller.state;

        return AppCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _GpsHeader(state: state),
              const SizedBox(height: AppSpacing.md),
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 180),
                switchInCurve: Curves.easeOutCubic,
                switchOutCurve: Curves.easeInCubic,
                child: switch (state.status) {
                  GpsCaptureStatus.idle => _IdleGpsState(
                      onCapture: () {
                        controller.capture();
                      },
                    ),
                  GpsCaptureStatus.loading => const _LoadingGpsState(),
                  GpsCaptureStatus.success => _CapturedGpsState(
                      location: state.location!,
                      onCapture: () {
                        controller.capture();
                      },
                    ),
                  GpsCaptureStatus.failure => _GpsFailureState(
                      failure: state.failure!,
                      onRetry: () {
                        controller.capture();
                      },
                      onOpenAppSettings: () {
                        controller.openAppSettings();
                      },
                      onOpenLocationSettings: () {
                        controller.openLocationSettings();
                      },
                    ),
                },
              ),
            ],
          ),
        );
      },
    );
  }
}

class _GpsHeader extends StatelessWidget {
  const _GpsHeader({
    required this.state,
  });

  final GpsCaptureState state;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final statusColors =
        Theme.of(context).extension<AppStatusColors>() ?? AppStatusColors.light;
    final location = state.location;
    final Color chipColor = switch (state.status) {
      GpsCaptureStatus.success => _accuracyColor(
          context,
          location?.accuracyLevel ?? GpsAccuracyLevel.poor,
        ),
      GpsCaptureStatus.failure => colorScheme.error,
      GpsCaptureStatus.loading => colorScheme.primary,
      GpsCaptureStatus.idle => statusColors.warning,
    };
    final String label = switch (state.status) {
      GpsCaptureStatus.success => location!.accuracyLevel.label,
      GpsCaptureStatus.failure => 'Action needed',
      GpsCaptureStatus.loading => 'Capturing',
      GpsCaptureStatus.idle => 'Not captured',
    };

    return Row(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: chipColor.withValues(alpha: 0.12),
            borderRadius: AppSpacing.radius,
          ),
          child: Icon(
            Icons.gps_fixed,
            color: chipColor,
          ),
        ),
        const SizedBox(width: AppSpacing.md),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'GPS location',
                style: Theme.of(context).textTheme.titleSmall,
              ),
              const SizedBox(height: AppSpacing.xxs),
              Text(
                'Latitude, longitude and accuracy',
                style: AppTextStyles.muted(context),
              ),
            ],
          ),
        ),
        const SizedBox(width: AppSpacing.sm),
        _StatusChip(
          label: label,
          color: chipColor,
        ),
      ],
    );
  }
}

class _IdleGpsState extends StatelessWidget {
  const _IdleGpsState({
    required this.onCapture,
  });

  final VoidCallback onCapture;

  @override
  Widget build(BuildContext context) {
    return Column(
      key: const ValueKey('idleGpsState'),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Capture a fresh GPS fix before recording field observations.',
          style: AppTextStyles.muted(context),
        ),
        const SizedBox(height: AppSpacing.md),
        SizedBox(
          width: double.infinity,
          child: FilledButton.icon(
            onPressed: onCapture,
            icon: const Icon(Icons.my_location),
            label: const Text('Capture GPS'),
          ),
        ),
      ],
    );
  }
}

class _LoadingGpsState extends StatelessWidget {
  const _LoadingGpsState();

  @override
  Widget build(BuildContext context) {
    return Column(
      key: const ValueKey('loadingGpsState'),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const LinearProgressIndicator(),
        const SizedBox(height: AppSpacing.md),
        Text(
          'Acquiring GPS fix. Keep the phone steady with a clear sky view.',
          style: AppTextStyles.muted(context),
        ),
      ],
    );
  }
}

class _CapturedGpsState extends StatelessWidget {
  const _CapturedGpsState({
    required this.location,
    required this.onCapture,
  });

  final CapturedLocation location;
  final VoidCallback onCapture;

  @override
  Widget build(BuildContext context) {
    return Column(
      key: const ValueKey('capturedGpsState'),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _AccuracyIndicator(location: location),
        const SizedBox(height: AppSpacing.md),
        _LocationValueRow(
          label: 'Latitude',
          value: location.latitude.toStringAsFixed(7),
        ),
        const SizedBox(height: AppSpacing.xs),
        _LocationValueRow(
          label: 'Longitude',
          value: location.longitude.toStringAsFixed(7),
        ),
        const SizedBox(height: AppSpacing.xs),
        _LocationValueRow(
          label: 'Captured',
          value: AppFormatters.shortDateTime(location.timestamp),
        ),
        const SizedBox(height: AppSpacing.md),
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: onCapture,
            icon: const Icon(Icons.refresh),
            label: const Text('Recapture GPS'),
          ),
        ),
      ],
    );
  }
}

class _GpsFailureState extends StatelessWidget {
  const _GpsFailureState({
    required this.failure,
    required this.onRetry,
    required this.onOpenAppSettings,
    required this.onOpenLocationSettings,
  });

  final LocationFailure failure;
  final VoidCallback onRetry;
  final VoidCallback onOpenAppSettings;
  final VoidCallback onOpenLocationSettings;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      key: const ValueKey('failedGpsState'),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          failure.title,
          style: Theme.of(context).textTheme.titleSmall!.copyWith(
                color: colorScheme.error,
              ),
        ),
        const SizedBox(height: AppSpacing.xs),
        Text(
          failure.message,
          style: AppTextStyles.muted(context),
        ),
        const SizedBox(height: AppSpacing.md),
        if (failure.canOpenAppSettings)
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              onPressed: onOpenAppSettings,
              icon: const Icon(Icons.settings),
              label: const Text('Open app settings'),
            ),
          )
        else if (failure.canOpenLocationSettings)
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              onPressed: onOpenLocationSettings,
              icon: const Icon(Icons.location_on_outlined),
              label: const Text('Open location settings'),
            ),
          ),
        if (failure.canRetry) ...[
          if (failure.canOpenAppSettings || failure.canOpenLocationSettings)
            const SizedBox(height: AppSpacing.sm),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh),
              label: const Text('Retry GPS'),
            ),
          ),
        ],
      ],
    );
  }
}

class _AccuracyIndicator extends StatelessWidget {
  const _AccuracyIndicator({
    required this.location,
  });

  final CapturedLocation location;

  @override
  Widget build(BuildContext context) {
    final level = location.accuracyLevel;
    final color = _accuracyColor(context, level);
    final progress = _accuracyProgress(location.accuracyMeters);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                'Accuracy',
                style: Theme.of(context).textTheme.labelLarge,
              ),
            ),
            Text(
              '${location.accuracyMeters.toStringAsFixed(1)} m',
              style: Theme.of(context).textTheme.labelLarge!.copyWith(
                    color: color,
                  ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.xs),
        LinearProgressIndicator(
          value: progress,
          color: color,
          backgroundColor: color.withValues(alpha: 0.14),
          minHeight: 6,
          borderRadius: AppSpacing.radius,
        ),
      ],
    );
  }
}

class _LocationValueRow extends StatelessWidget {
  const _LocationValueRow({
    required this.label,
    required this.value,
  });

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            label,
            style: AppTextStyles.muted(context),
          ),
        ),
        SelectableText(
          value,
          style: Theme.of(context).textTheme.labelLarge,
        ),
      ],
    );
  }
}

class _StatusChip extends StatelessWidget {
  const _StatusChip({
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

Color _accuracyColor(BuildContext context, GpsAccuracyLevel level) {
  final colorScheme = Theme.of(context).colorScheme;
  final statusColors =
      Theme.of(context).extension<AppStatusColors>() ?? AppStatusColors.light;

  return switch (level) {
    GpsAccuracyLevel.excellent => statusColors.success,
    GpsAccuracyLevel.good => colorScheme.primary,
    GpsAccuracyLevel.fair => statusColors.warning,
    GpsAccuracyLevel.poor => colorScheme.error,
  };
}

double _accuracyProgress(double accuracyMeters) {
  final normalized = 1 - (accuracyMeters.clamp(0, 40) / 40);
  return normalized.clamp(0.08, 1).toDouble();
}
