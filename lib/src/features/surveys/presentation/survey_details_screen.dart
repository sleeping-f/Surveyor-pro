import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';

import '../../../core/constants/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../shared/widgets/app_card.dart';
import '../domain/survey_record.dart';
import '../domain/survey_repository.dart';
import '../domain/survey_image.dart';
import 'widgets/survey_form_section.dart';

class SurveyDetailsScreen extends StatelessWidget {
  const SurveyDetailsScreen({
    required this.surveyId,
    required this.repository,
    super.key,
  });

  final int surveyId;
  final SurveyRepository repository;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Survey details'),
      ),
      body: FutureBuilder<SurveyRecord?>(
        future: repository.fetchSurveyById(surveyId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.lg),
                child: AppCard(
                  padding: const EdgeInsets.all(AppSpacing.lg),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.error_outline, size: 40),
                      const SizedBox(height: AppSpacing.md),
                      Text(
                        'Unable to load survey',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: AppSpacing.xs),
                      Text(
                        'Try returning to the history list and opening again.',
                        style: AppTextStyles.muted(context),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ),
            );
          }

          final record = snapshot.data;
          if (record == null) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.lg),
                child: AppCard(
                  padding: const EdgeInsets.all(AppSpacing.lg),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.search_off, size: 40),
                      const SizedBox(height: AppSpacing.md),
                      Text(
                        'Survey not found',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: AppSpacing.xs),
                      Text(
                        'The selected record is no longer available locally.',
                        style: AppTextStyles.muted(context),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ),
            );
          }

          return ListView(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.md,
              AppSpacing.sm,
              AppSpacing.md,
              AppSpacing.xl,
            ),
            children: [
              SurveyFormSection(
                title: 'Road details',
                icon: Icons.route,
                children: [
                  _DetailRow(label: 'Project', value: record.projectName),
                  _DetailRow(label: 'Road', value: record.roadName),
                  _DetailRow(label: 'Chainage', value: record.chainage),
                  _DetailRow(label: 'Recorded', value: _formatDate(record.createdAt)),
                ],
              ),
              const SizedBox(height: AppSpacing.md),
              SurveyFormSection(
                title: 'Condition assessment',
                icon: Icons.fact_check_outlined,
                children: [
                  _DetailRow(label: 'Road side', value: record.roadSide.label),
                  _DetailRow(label: 'Distress type', value: record.distressType),
                  _DetailRow(label: 'Severity', value: record.severity.label),
                  _DetailRow(
                    label: 'Notes',
                    value: record.notes.isEmpty ? 'No notes' : record.notes,
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.md),
              SurveyFormSection(
                title: 'Location',
                icon: Icons.gps_fixed,
                children: [
                  if (record.location == null)
                    Text(
                      'GPS was not captured for this record.',
                      style: AppTextStyles.muted(context),
                    )
                  else ...[
                    _DetailRow(
                      label: 'Latitude',
                      value: record.location!.latitude.toStringAsFixed(7),
                    ),
                    _DetailRow(
                      label: 'Longitude',
                      value: record.location!.longitude.toStringAsFixed(7),
                    ),
                    _DetailRow(
                      label: 'Accuracy',
                      value:
                          '${record.location!.accuracyMeters.toStringAsFixed(1)} m',
                    ),
                    _DetailRow(
                      label: 'Captured',
                      value: _formatDate(record.location!.timestamp),
                    ),
                  ],
                ],
              ),
              const SizedBox(height: AppSpacing.md),
              SurveyFormSection(
                title: 'Photos',
                icon: Icons.photo_camera_outlined,
                children: [
                  if (record.images.isEmpty)
                    Text(
                      'No photos were attached.',
                      style: AppTextStyles.muted(context),
                    )
                  else
                    _SurveyImageGallery(images: record.images),
                ],
              ),
            ],
          );
        },
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  const _DetailRow({
    required this.label,
    required this.value,
  });

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.xs),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Text(
              label,
              style: AppTextStyles.muted(context),
            ),
          ),
          Flexible(
            flex: 2,
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: Theme.of(context).textTheme.labelLarge,
            ),
          ),
        ],
      ),
    );
  }
}

class _SurveyImageGallery extends StatelessWidget {
  const _SurveyImageGallery({
    required this.images,
  });

  final List<SurveyImage> images;

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: AppSpacing.sm,
        mainAxisSpacing: AppSpacing.sm,
        childAspectRatio: 4 / 3,
      ),
      itemCount: images.length,
      itemBuilder: (context, index) {
        final image = images[index];
        return ClipRRect(
          borderRadius: AppSpacing.radius,
          child: InkWell(
            onTap: () => _showPreview(context, image),
            child: Image.file(
              File(image.path),
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) {
                return Container(
                  color: Theme.of(context).colorScheme.surfaceContainerLow,
                  child: Icon(
                    Icons.broken_image_outlined,
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                );
              },
            ),
          ),
        );
      },
    );
  }

  void _showPreview(BuildContext context, SurveyImage image) {
    unawaited(
      showDialog<void>(
        context: context,
        builder: (context) {
          return Dialog(
            clipBehavior: Clip.antiAlias,
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 520),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  AspectRatio(
                    aspectRatio: 4 / 3,
                    child: Image.file(
                      File(image.path),
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) {
                        return Container(
                          color: Theme.of(context).colorScheme.surface,
                          child: Icon(
                            Icons.broken_image_outlined,
                            color:
                                Theme.of(context).colorScheme.onSurfaceVariant,
                          ),
                        );
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
      ),
    );
  }
}

String _formatDate(DateTime timestamp) {
  final local = timestamp.toLocal();
  return '${local.year}-${_two(local.month)}-${_two(local.day)} '
      '${_two(local.hour)}:${_two(local.minute)}';
}

String _two(int value) => value.toString().padLeft(2, '0');
