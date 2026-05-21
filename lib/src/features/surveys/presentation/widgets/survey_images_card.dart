import 'dart:io';

import 'package:flutter/material.dart';

import '../../../../core/constants/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../shared/widgets/app_card.dart';
import '../../application/survey_image_controller.dart';
import '../../domain/survey_image.dart';

class SurveyImagesCard extends StatelessWidget {
  const SurveyImagesCard({
    required this.controller,
    super.key,
  });

  final SurveyImageController controller;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (context, _) {
        final state = controller.state;
        final images = state.draft.images;

        return AppCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _SurveyImagesHeader(
                count: images.length,
                isBusy: state.isBusy,
              ),
              const SizedBox(height: AppSpacing.md),
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 180),
                switchInCurve: Curves.easeOutCubic,
                switchOutCurve: Curves.easeInCubic,
                child: switch (state.status) {
                  SurveyImageStatus.loading => const _ImagesLoadingState(),
                  SurveyImageStatus.capturing => _ImagesCapturingState(
                      images: images,
                    ),
                  SurveyImageStatus.failure => _ImagesFailureState(
                      state: state,
                      onRetry: controller.capture,
                    ),
                  SurveyImageStatus.ready => _ImagesReadyState(
                      images: images,
                      onCapture: controller.capture,
                      onPreview: (image) => _showImagePreview(context, image),
                      onRetake: controller.retake,
                      onDelete: controller.delete,
                    ),
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _showImagePreview(BuildContext context, SurveyImage image) {
    showDialog<void>(
      context: context,
      builder: (context) {
        return Dialog(
          clipBehavior: Clip.antiAlias,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 520),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                AspectRatio(
                  aspectRatio: 4 / 3,
                  child: Image.file(
                    File(image.path),
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return const _MissingImagePlaceholder();
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  child: FilledButton.icon(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.check),
                    label: const Text('Done'),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _SurveyImagesHeader extends StatelessWidget {
  const _SurveyImagesHeader({
    required this.count,
    required this.isBusy,
  });

  final int count;
  final bool isBusy;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Row(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: colorScheme.primaryContainer,
            borderRadius: AppSpacing.radius,
          ),
          child: Icon(
            Icons.photo_camera_outlined,
            color: colorScheme.onPrimaryContainer,
          ),
        ),
        const SizedBox(width: AppSpacing.md),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Survey photos',
                style: Theme.of(context).textTheme.titleSmall,
              ),
              const SizedBox(height: AppSpacing.xxs),
              Text(
                'Store local evidence images',
                style: AppTextStyles.muted(context),
              ),
            ],
          ),
        ),
        const SizedBox(width: AppSpacing.sm),
        _ImageCountChip(
          count: count,
          isBusy: isBusy,
        ),
      ],
    );
  }
}

class _ImagesLoadingState extends StatelessWidget {
  const _ImagesLoadingState();

  @override
  Widget build(BuildContext context) {
    return const Column(
      key: ValueKey('imagesLoading'),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        LinearProgressIndicator(),
        SizedBox(height: AppSpacing.md),
        Text('Loading saved photos...'),
      ],
    );
  }
}

class _ImagesCapturingState extends StatelessWidget {
  const _ImagesCapturingState({
    required this.images,
  });

  final List<SurveyImage> images;

  @override
  Widget build(BuildContext context) {
    return Column(
      key: const ValueKey('imagesCapturing'),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const LinearProgressIndicator(),
        const SizedBox(height: AppSpacing.md),
        Text(
          'Waiting for camera...',
          style: AppTextStyles.muted(context),
        ),
        if (images.isNotEmpty) ...[
          const SizedBox(height: AppSpacing.md),
          _ThumbnailStrip(
            images: images,
            onPreview: (_) {},
            onRetake: (_) {},
            onDelete: (_) {},
            enabled: false,
          ),
        ],
      ],
    );
  }
}

class _ImagesFailureState extends StatelessWidget {
  const _ImagesFailureState({
    required this.state,
    required this.onRetry,
  });

  final SurveyImageState state;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      key: const ValueKey('imagesFailure'),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          state.failure?.title ?? 'Image capture failed',
          style: Theme.of(context).textTheme.titleSmall!.copyWith(
                color: colorScheme.error,
              ),
        ),
        const SizedBox(height: AppSpacing.xs),
        Text(
          state.failure?.message ?? 'Try capturing the photo again.',
          style: AppTextStyles.muted(context),
        ),
        const SizedBox(height: AppSpacing.md),
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: onRetry,
            icon: const Icon(Icons.refresh),
            label: const Text('Retry camera'),
          ),
        ),
        if (state.draft.images.isNotEmpty) ...[
          const SizedBox(height: AppSpacing.md),
          _ThumbnailStrip(
            images: state.draft.images,
            onPreview: (_) {},
            onRetake: (_) {},
            onDelete: (_) {},
            enabled: false,
          ),
        ],
      ],
    );
  }
}

class _ImagesReadyState extends StatelessWidget {
  const _ImagesReadyState({
    required this.images,
    required this.onCapture,
    required this.onPreview,
    required this.onRetake,
    required this.onDelete,
  });

  final List<SurveyImage> images;
  final VoidCallback onCapture;
  final ValueChanged<SurveyImage> onPreview;
  final ValueChanged<SurveyImage> onRetake;
  final ValueChanged<SurveyImage> onDelete;

  @override
  Widget build(BuildContext context) {
    if (images.isEmpty) {
      return _EmptyImagesState(
        key: const ValueKey('imagesEmpty'),
        onCapture: onCapture,
      );
    }

    return Column(
      key: const ValueKey('imagesReady'),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _ThumbnailStrip(
          images: images,
          onPreview: onPreview,
          onRetake: onRetake,
          onDelete: onDelete,
        ),
        const SizedBox(height: AppSpacing.md),
        SizedBox(
          width: double.infinity,
          child: FilledButton.icon(
            onPressed: onCapture,
            icon: const Icon(Icons.add_a_photo_outlined),
            label: const Text('Add photo'),
          ),
        ),
      ],
    );
  }
}

class _EmptyImagesState extends StatelessWidget {
  const _EmptyImagesState({
    required this.onCapture,
    super.key,
  });

  final VoidCallback onCapture;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Capture pavement condition, defects, signs, or shoulder context.',
          style: AppTextStyles.muted(context),
        ),
        const SizedBox(height: AppSpacing.md),
        SizedBox(
          width: double.infinity,
          child: FilledButton.icon(
            onPressed: onCapture,
            icon: const Icon(Icons.add_a_photo_outlined),
            label: const Text('Capture photo'),
          ),
        ),
      ],
    );
  }
}

class _ThumbnailStrip extends StatelessWidget {
  const _ThumbnailStrip({
    required this.images,
    required this.onPreview,
    required this.onRetake,
    required this.onDelete,
    this.enabled = true,
  });

  final List<SurveyImage> images;
  final ValueChanged<SurveyImage> onPreview;
  final ValueChanged<SurveyImage> onRetake;
  final ValueChanged<SurveyImage> onDelete;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 172,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: images.length,
        separatorBuilder: (context, index) {
          return const SizedBox(width: AppSpacing.sm);
        },
        itemBuilder: (context, index) {
          final image = images[index];
          return _SurveyImageTile(
            image: image,
            index: index,
            enabled: enabled,
            onPreview: onPreview,
            onRetake: onRetake,
            onDelete: onDelete,
          );
        },
      ),
    );
  }
}

class _SurveyImageTile extends StatelessWidget {
  const _SurveyImageTile({
    required this.image,
    required this.index,
    required this.enabled,
    required this.onPreview,
    required this.onRetake,
    required this.onDelete,
  });

  final SurveyImage image;
  final int index;
  final bool enabled;
  final ValueChanged<SurveyImage> onPreview;
  final ValueChanged<SurveyImage> onRetake;
  final ValueChanged<SurveyImage> onDelete;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return SizedBox(
      width: 142,
      child: Material(
        color: colorScheme.surfaceContainerLow,
        shape: RoundedRectangleBorder(
          borderRadius: AppSpacing.radius,
          side: BorderSide(
            color: colorScheme.outlineVariant.withValues(alpha: 0.7),
          ),
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: InkWell(
                onTap: enabled ? () => onPreview(image) : null,
                child: Image.file(
                  File(image.path),
                  fit: BoxFit.cover,
                  cacheWidth: 320,
                  errorBuilder: (context, error, stackTrace) {
                    return const _MissingImagePlaceholder();
                  },
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.xs,
                vertical: AppSpacing.xxs,
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      'Photo ${index + 1}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.labelMedium,
                    ),
                  ),
                  IconButton(
                    tooltip: 'Retake photo',
                    onPressed: enabled ? () => onRetake(image) : null,
                    icon: const Icon(Icons.camera_alt_outlined),
                    visualDensity: VisualDensity.compact,
                  ),
                  IconButton(
                    tooltip: 'Delete photo',
                    onPressed: enabled ? () => onDelete(image) : null,
                    icon: const Icon(Icons.delete_outline),
                    visualDensity: VisualDensity.compact,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MissingImagePlaceholder extends StatelessWidget {
  const _MissingImagePlaceholder();

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return ColoredBox(
      color: colorScheme.surface,
      child: Center(
        child: Icon(
          Icons.broken_image_outlined,
          color: colorScheme.onSurfaceVariant,
        ),
      ),
    );
  }
}

class _ImageCountChip extends StatelessWidget {
  const _ImageCountChip({
    required this.count,
    required this.isBusy,
  });

  final int count;
  final bool isBusy;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final color = isBusy ? colorScheme.primary : colorScheme.secondary;

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
          '$count saved',
          style: Theme.of(context).textTheme.labelMedium!.copyWith(
                color: color,
              ),
        ),
      ),
    );
  }
}
