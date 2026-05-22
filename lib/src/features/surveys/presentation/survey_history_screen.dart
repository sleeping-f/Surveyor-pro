import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';

import '../../../core/constants/app_spacing.dart';
import '../../../core/storage/app_database.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../shared/widgets/app_card.dart';
import '../../../shared/widgets/section_header.dart';
import '../application/survey_history_controller.dart';
import '../data/sqflite_survey_repository.dart';
import '../domain/survey_repository.dart';
import '../domain/survey_summary.dart';
import 'survey_details_screen.dart';

class SurveyHistoryScreen extends StatefulWidget {
  SurveyHistoryScreen({
    SurveyRepository? surveyRepository,
    super.key,
  }) : surveyRepository = surveyRepository ??
            SqfliteSurveyRepository(database: AppDatabase.instance);

  final SurveyRepository surveyRepository;

  @override
  State<SurveyHistoryScreen> createState() => _SurveyHistoryScreenState();
}

class _SurveyHistoryScreenState extends State<SurveyHistoryScreen> {
  late final SurveyHistoryController _controller;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _controller = SurveyHistoryController(
      repository: widget.surveyRepository,
    );
    unawaited(_controller.load());
  }

  @override
  void dispose() {
    _searchController.dispose();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Survey history'),
        actions: [
          IconButton(
            tooltip: 'Refresh',
            onPressed: () => unawaited(_controller.load()),
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final horizontalPadding =
              AppSpacing.pagePaddingFor(constraints.maxWidth);

          return AnimatedBuilder(
            animation: _controller,
            builder: (context, _) {
              final state = _controller.state;

              return CustomScrollView(
                slivers: [
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: EdgeInsets.fromLTRB(
                        horizontalPadding,
                        AppSpacing.sm,
                        horizontalPadding,
                        AppSpacing.md,
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
                                title: 'Saved surveys',
                                subtitle:
                                    'Offline records stored on this device.',
                              ),
                              const SizedBox(height: AppSpacing.md),
                              _SearchField(
                                controller: _searchController,
                                onChanged: _controller.setSearchTerm,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                  switch (state.status) {
                    SurveyHistoryStatus.loading => const SliverFillRemaining(
                        hasScrollBody: false,
                        child: Center(
                          child: CircularProgressIndicator(),
                        ),
                      ),
                    SurveyHistoryStatus.failure => SliverFillRemaining(
                        hasScrollBody: false,
                        child: Center(
                          child: AppCard(
                            padding: const EdgeInsets.all(AppSpacing.lg),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(Icons.cloud_off_outlined, size: 40),
                                const SizedBox(height: AppSpacing.md),
                                Text(
                                  state.failure?.title ??
                                      'Survey storage error',
                                  style:
                                      Theme.of(context).textTheme.titleMedium,
                                ),
                                const SizedBox(height: AppSpacing.xs),
                                Text(
                                  state.failure?.message ??
                                      'Surveys could not be loaded.',
                                  style: AppTextStyles.muted(context),
                                  textAlign: TextAlign.center,
                                ),
                                const SizedBox(height: AppSpacing.md),
                                FilledButton.icon(
                                  onPressed: () => unawaited(_controller.load()),
                                  icon: const Icon(Icons.refresh),
                                  label: const Text('Retry'),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    SurveyHistoryStatus.empty => const SliverFillRemaining(
                        hasScrollBody: false,
                        child: _EmptyHistoryState(),
                      ),
                    SurveyHistoryStatus.ready => SliverPadding(
                        padding: EdgeInsets.fromLTRB(
                          horizontalPadding,
                          0,
                          horizontalPadding,
                          AppSpacing.xl,
                        ),
                        sliver: SliverList(
                          delegate: SliverChildBuilderDelegate(
                            (context, index) {
                              final summary = state.summaries[index];
                              return Padding(
                                padding: const EdgeInsets.only(
                                  bottom: AppSpacing.md,
                                ),
                                child: Center(
                                  child: ConstrainedBox(
                                    constraints: const BoxConstraints(
                                      maxWidth: AppSpacing.maxContentWidth,
                                    ),
                                    child: SurveyHistoryCard(
                                      summary: summary,
                                      onOpenDetails: () => _openDetails(summary),
                                    ),
                                  ),
                                ),
                              );
                            },
                            childCount: state.summaries.length,
                          ),
                        ),
                      ),
                  },
                ],
              );
            },
          );
        },
      ),
    );
  }

  void _openDetails(SurveySummary summary) {
    unawaited(
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => SurveyDetailsScreen(
            surveyId: summary.id,
            repository: widget.surveyRepository,
          ),
        ),
      ),
    );
  }
}

class _SearchField extends StatelessWidget {
  const _SearchField({
    required this.controller,
    required this.onChanged,
  });

  final TextEditingController controller;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      onChanged: onChanged,
      textInputAction: TextInputAction.search,
      decoration: InputDecoration(
        hintText: 'Search by project, road, chainage',
        prefixIcon: const Icon(Icons.search),
        suffixIcon: controller.text.isEmpty
            ? null
            : IconButton(
                tooltip: 'Clear',
                onPressed: () {
                  controller.clear();
                  onChanged('');
                },
                icon: const Icon(Icons.close),
              ),
      ),
    );
  }
}

class SurveyHistoryCard extends StatefulWidget {
  const SurveyHistoryCard({
    required this.summary,
    required this.onOpenDetails,
    super.key,
  });

  final SurveySummary summary;
  final VoidCallback onOpenDetails;

  @override
  State<SurveyHistoryCard> createState() => _SurveyHistoryCardState();
}

class _SurveyHistoryCardState extends State<SurveyHistoryCard> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    final summary = widget.summary;

    return AppCard(
      padding: EdgeInsets.zero,
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: InkWell(
                  onTap: widget.onOpenDetails,
                  child: Padding(
                    padding: const EdgeInsets.all(AppSpacing.md),
                    child: Row(
                      children: [
                        _SurveyThumbnail(path: summary.thumbnailPath),
                        const SizedBox(width: AppSpacing.md),
                        Expanded(
                          child: _SurveyHeaderContent(summary: summary),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              IconButton(
                tooltip: _expanded ? 'Collapse' : 'Expand',
                onPressed: () => setState(() => _expanded = !_expanded),
                icon: Icon(
                  _expanded ? Icons.expand_less : Icons.expand_more,
                ),
              ),
              const SizedBox(width: AppSpacing.xs),
            ],
          ),
          AnimatedSize(
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeOutCubic,
            child: _expanded
                ? Padding(
                    padding: const EdgeInsets.fromLTRB(
                      AppSpacing.md,
                      0,
                      AppSpacing.md,
                      AppSpacing.md,
                    ),
                    child: _SurveyExpandedContent(
                      summary: summary,
                      onOpenDetails: widget.onOpenDetails,
                    ),
                  )
                : const SizedBox.shrink(),
          ),
        ],
      ),
    );
  }
}

class _SurveyHeaderContent extends StatelessWidget {
  const _SurveyHeaderContent({
    required this.summary,
  });

  final SurveySummary summary;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          summary.projectName,
          style: textTheme.titleSmall,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: AppSpacing.xxs),
        Text(
          summary.roadName,
          style: AppTextStyles.muted(context),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: AppSpacing.xs),
        Wrap(
          spacing: AppSpacing.sm,
          runSpacing: AppSpacing.xs,
          children: [
            _Chip(label: 'Chainage ${summary.chainage}'),
            _Chip(label: summary.severity.label),
            _Chip(label: _formatDate(summary.createdAt)),
          ],
        ),
      ],
    );
  }
}

class _SurveyExpandedContent extends StatelessWidget {
  const _SurveyExpandedContent({
    required this.summary,
    required this.onOpenDetails,
  });

  final SurveySummary summary;
  final VoidCallback onOpenDetails;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Divider(height: AppSpacing.lg),
        _DetailRow(label: 'Road side', value: summary.roadSide.label),
        _DetailRow(label: 'Distress type', value: summary.distressType),
        _DetailRow(
          label: 'Photos stored',
          value: summary.imageCount.toString(),
        ),
        const SizedBox(height: AppSpacing.sm),
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: onOpenDetails,
            icon: const Icon(Icons.open_in_new),
            label: const Text('Open details'),
          ),
        ),
      ],
    );
  }
}

class _SurveyThumbnail extends StatelessWidget {
  const _SurveyThumbnail({
    required this.path,
  });

  final String? path;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final hasImage = path != null && path!.isNotEmpty;

    return ClipRRect(
      borderRadius: AppSpacing.radius,
      child: Container(
        width: 72,
        height: 72,
        color: colorScheme.surfaceContainerLow,
        child: hasImage
            ? Image.file(
                File(path!),
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) {
                  return _missingThumbnail(colorScheme);
                },
              )
            : _missingThumbnail(colorScheme),
      ),
    );
  }

  Widget _missingThumbnail(ColorScheme colorScheme) {
    return Center(
      child: Icon(
        Icons.photo_outlined,
        color: colorScheme.onSurfaceVariant,
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  const _Chip({
    required this.label,
  });

  final String label;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerLow,
        borderRadius: AppSpacing.radius,
        border: Border.all(
          color: colorScheme.outlineVariant,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.sm,
          vertical: AppSpacing.xxs,
        ),
        child: Text(
          label,
          style: Theme.of(context).textTheme.labelMedium,
        ),
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
        children: [
          Expanded(
            child: Text(
              label,
              style: AppTextStyles.muted(context),
            ),
          ),
          Text(
            value,
            style: Theme.of(context).textTheme.labelLarge,
          ),
        ],
      ),
    );
  }
}

class _EmptyHistoryState extends StatelessWidget {
  const _EmptyHistoryState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: AppCard(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.folder_open_outlined, size: 40),
              const SizedBox(height: AppSpacing.md),
              Text(
                'No surveys saved yet',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: AppSpacing.xs),
              Text(
                'Start a new survey to store offline records here.',
                style: AppTextStyles.muted(context),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
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
