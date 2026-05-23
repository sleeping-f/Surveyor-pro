import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:path/path.dart' as p;

import '../../../core/constants/app_spacing.dart';
import '../../../core/location/domain/location_service.dart';
import '../../../core/location/infrastructure/geolocator_location_service.dart';
import '../../../core/media/domain/image_capture_service.dart';
import '../../../core/media/infrastructure/image_picker_capture_service.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/utils/app_formatters.dart';
import '../../../shared/widgets/app_card.dart';
import '../../../shared/widgets/surveyor_logo.dart';
import '../../../shared/widgets/section_header.dart';
import '../application/quick_camera_controller.dart';
import '../data/quick_camera_processing_service.dart';
import '../domain/quick_camera_result.dart';
import '../domain/quick_camera_settings.dart';

class QuickCameraScreen extends StatefulWidget {
  QuickCameraScreen({
    LocationService? locationService,
    ImageCaptureService? imageCaptureService,
    QuickCameraProcessingService? processingService,
    super.key,
  })  : locationService = locationService ?? const GeolocatorLocationService(),
        imageCaptureService =
            imageCaptureService ?? ImagePickerCaptureService(),
        processingService = processingService ?? QuickCameraProcessingService();

  final LocationService locationService;
  final ImageCaptureService imageCaptureService;
  final QuickCameraProcessingService processingService;

  @override
  State<QuickCameraScreen> createState() => _QuickCameraScreenState();
}

class _QuickCameraScreenState extends State<QuickCameraScreen> {
  late final QuickCameraController _controller;
  QuickCameraSettings _settings = QuickCameraSettings.initial();
  String? _lastChainage;

  @override
  void initState() {
    super.initState();
    _controller = QuickCameraController(
      locationService: widget.locationService,
      imageCaptureService: widget.imageCaptureService,
      processingService: widget.processingService,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: const [
            SurveyorLogo(
              layout: SurveyorLogoLayout.icon,
              height: 28,
            ),
            SizedBox(width: 8),
            Text('Quick camera'),
          ],
        ),
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final horizontalPadding =
              AppSpacing.pagePaddingFor(constraints.maxWidth);

          return AnimatedBuilder(
            animation: _controller,
            builder: (context, _) {
              final state = _controller.state;

              return SingleChildScrollView(
                keyboardDismissBehavior:
                    ScrollViewKeyboardDismissBehavior.onDrag,
                padding: EdgeInsets.fromLTRB(
                  horizontalPadding,
                  AppSpacing.sm,
                  horizontalPadding,
                  AppSpacing.xl,
                ),
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(
                      maxWidth: AppSpacing.maxContentWidth,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SectionHeader(
                          title: 'GPS watermarked capture',
                          subtitle:
                              'Latitude and longitude are stamped automatically.',
                        ),
                        const SizedBox(height: AppSpacing.md),
                        _SettingsCard(
                          settings: _settings,
                          onSettingsChanged: _updateSettings,
                        ),
                        const SizedBox(height: AppSpacing.md),
                        _CaptureCard(
                          state: state,
                          onCapture: _capture,
                        ),
                        if (state.lastResult != null) ...[
                          const SizedBox(height: AppSpacing.md),
                          _LastCaptureCard(result: state.lastResult!),
                        ],
                      ],
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  void _updateSettings(QuickCameraSettings settings) {
    setState(() => _settings = settings);
  }

  void _capture() {
    unawaited(
      _controller.capture(
        settings: _settings,
        requestChainage: _promptChainageIfNeeded,
      ),
    );
  }

  Future<String?> _promptChainageIfNeeded() async {
    final controller = TextEditingController(text: _lastChainage ?? '');
    final result = await showDialog<String?>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Chainage'),
          content: TextField(
            controller: controller,
            decoration: const InputDecoration(
              hintText: 'Example: 0+250',
            ),
            textInputAction: TextInputAction.done,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(null),
              child: const Text('Skip'),
            ),
            FilledButton(
              onPressed: () =>
                  Navigator.of(context).pop(controller.text.trim()),
              child: const Text('Use chainage'),
            ),
          ],
        );
      },
    );
    final trimmed = result?.trim();
    if (trimmed != null && trimmed.isNotEmpty) {
      _lastChainage = trimmed;
    }
    return trimmed?.isEmpty ?? true ? null : trimmed;
  }
}

class _SettingsCard extends StatelessWidget {
  const _SettingsCard({
    required this.settings,
    required this.onSettingsChanged,
  });

  final QuickCameraSettings settings;
  final ValueChanged<QuickCameraSettings> onSettingsChanged;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Capture settings',
            style: Theme.of(context).textTheme.titleSmall,
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            'Configure optional chainage stamping.',
            style: AppTextStyles.muted(context),
          ),
          const SizedBox(height: AppSpacing.sm),
          CheckboxListTile(
            value: settings.includeChainage,
            contentPadding: EdgeInsets.zero,
            title: const Text('Include chainage'),
            subtitle:
                const Text('Ask for chainage after each captured photo.'),
            onChanged: (value) {
              final include = value ?? false;
              onSettingsChanged(
                settings.copyWith(
                  includeChainage: include,
                  chainageInWatermark: include ? true : false,
                  chainageInFileName: include ? true : false,
                ),
              );
            },
          ),
          if (settings.includeChainage) ...[
            const SizedBox(height: AppSpacing.xs),
            CheckboxListTile(
              value: settings.chainageInWatermark,
              contentPadding: EdgeInsets.zero,
              title: const Text('Add chainage to photo'),
              onChanged: (value) {
                final enabled = value ?? false;
                final hasAny = enabled || settings.chainageInFileName;
                onSettingsChanged(
                  settings.copyWith(
                    chainageInWatermark: enabled,
                    chainageInFileName:
                        hasAny ? settings.chainageInFileName : true,
                  ),
                );
              },
            ),
            CheckboxListTile(
              value: settings.chainageInFileName,
              contentPadding: EdgeInsets.zero,
              title: const Text('Add chainage to file name'),
              onChanged: (value) {
                final enabled = value ?? false;
                final hasAny = enabled || settings.chainageInWatermark;
                onSettingsChanged(
                  settings.copyWith(
                    chainageInFileName: enabled,
                    chainageInWatermark:
                        hasAny ? settings.chainageInWatermark : true,
                  ),
                );
              },
            ),
          ],
        ],
      ),
    );
  }
}

class _CaptureCard extends StatelessWidget {
  const _CaptureCard({
    required this.state,
    required this.onCapture,
  });

  final QuickCameraState state;
  final VoidCallback onCapture;

  @override
  Widget build(BuildContext context) {
    final isBusy = state.isBusy;

    return AppCard(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Capture photo',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            'GPS coordinates will be embedded automatically.',
            style: AppTextStyles.muted(context),
          ),
          if (isBusy) ...[
            const SizedBox(height: AppSpacing.md),
            const LinearProgressIndicator(),
          ],
          if (state.failure != null) ...[
            const SizedBox(height: AppSpacing.md),
            Text(
              state.failure!.title,
              style: Theme.of(context).textTheme.titleSmall!.copyWith(
                    color: Theme.of(context).colorScheme.error,
                  ),
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              state.failure!.message,
              style: AppTextStyles.muted(context),
            ),
          ],
          const SizedBox(height: AppSpacing.md),
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              onPressed: isBusy ? null : onCapture,
              icon: const Icon(Icons.photo_camera_outlined),
              label: Text(isBusy ? 'Capturing...' : 'Take photo'),
            ),
          ),
        ],
      ),
    );
  }
}

class _LastCaptureCard extends StatelessWidget {
  const _LastCaptureCard({
    required this.result,
  });

  final QuickCameraResult result;

  @override
  Widget build(BuildContext context) {
    final fileName = p.basename(result.filePath);

    return AppCard(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Last capture',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: AppSpacing.md),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: AppSpacing.radius,
                child: Image.file(
                  File(result.filePath),
                  width: 96,
                  height: 96,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) {
                    return Container(
                      width: 96,
                      height: 96,
                      color: Theme.of(context).colorScheme.surfaceContainerLow,
                      child: Icon(
                        Icons.broken_image_outlined,
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      fileName,
                      style: Theme.of(context).textTheme.labelLarge,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      'Lat: ${result.location.latitude.toStringAsFixed(6)}',
                      style: AppTextStyles.muted(context),
                    ),
                    Text(
                      'Lon: ${result.location.longitude.toStringAsFixed(6)}',
                      style: AppTextStyles.muted(context),
                    ),
                    if (result.chainage != null &&
                        result.chainage!.isNotEmpty)
                      Text(
                        'Chainage: ${result.chainage}',
                        style: AppTextStyles.muted(context),
                      ),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      AppFormatters.shortDateTime(result.capturedAt),
                      style: Theme.of(context).textTheme.labelMedium,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
