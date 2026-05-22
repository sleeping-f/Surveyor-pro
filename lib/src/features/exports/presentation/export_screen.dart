import 'package:flutter/material.dart';
import 'package:path/path.dart' as p;
import 'package:share_plus/share_plus.dart';

import '../../../core/constants/app_spacing.dart';
import '../../../core/storage/app_database.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/utils/app_formatters.dart';
import '../../../shared/widgets/app_card.dart';
import '../../../shared/widgets/section_header.dart';
import '../../surveys/data/sqflite_survey_repository.dart';
import '../../surveys/domain/survey_repository.dart';
import '../application/survey_export_controller.dart';
import '../data/survey_csv_export_service.dart';
import '../domain/survey_export_result.dart';

class ExportScreen extends StatefulWidget {
  ExportScreen({
    SurveyRepository? surveyRepository,
    SurveyCsvExportService? exportService,
    super.key,
  })  : surveyRepository = surveyRepository ??
            SqfliteSurveyRepository(database: AppDatabase.instance),
        exportService = exportService ?? SurveyCsvExportService();

  final SurveyRepository surveyRepository;
  final SurveyCsvExportService exportService;

  @override
  State<ExportScreen> createState() => _ExportScreenState();
}

class _ExportScreenState extends State<ExportScreen> {
  late final SurveyExportController _controller;

  @override
  void initState() {
    super.initState();
    _controller = SurveyExportController(
      repository: widget.surveyRepository,
      exportService: widget.exportService,
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
        title: const Text('Exports'),
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
                                title: 'CSV export',
                                subtitle:
                                    'Bundle all offline surveys for sharing.',
                              ),
                              const SizedBox(height: AppSpacing.md),
                              Text(
                                'Exports include images paths, GPS data, and '
                                'survey metadata for reporting.',
                                style: AppTextStyles.muted(context),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: EdgeInsets.fromLTRB(
                        horizontalPadding,
                        0,
                        horizontalPadding,
                        AppSpacing.xl,
                      ),
                      child: Center(
                        child: ConstrainedBox(
                          constraints: const BoxConstraints(
                            maxWidth: AppSpacing.maxContentWidth,
                          ),
                          child: AnimatedSwitcher(
                            duration: const Duration(milliseconds: 220),
                            switchInCurve: Curves.easeOutCubic,
                            switchOutCurve: Curves.easeInCubic,
                            child: switch (state.status) {
                              SurveyExportStatus.exporting =>
                                const _ExportLoadingCard(),
                              SurveyExportStatus.success => _ExportSuccessCard(
                                  result: state.result!,
                                  onShare: () => _shareExport(state.result!),
                                  onExportAgain: _runExport,
                                ),
                              SurveyExportStatus.empty => _ExportEmptyCard(
                                  onExportAgain: _runExport,
                                ),
                              SurveyExportStatus.failure => _ExportFailureCard(
                                  title:
                                      state.failure?.title ?? 'Export failed',
                                  message: state.failure?.message ??
                                      'The export could not be completed.',
                                  onRetry: _runExport,
                                ),
                              SurveyExportStatus.idle => _ExportReadyCard(
                                  onExport: _runExport,
                                ),
                            },
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              );
            },
          );
        },
      ),
    );
  }

  Future<void> _runExport() async {
    await _controller.exportAll();
    if (!mounted) {
      return;
    }

    final state = _controller.state;
    final message = switch (state.status) {
      SurveyExportStatus.success =>
        'CSV export saved to ${p.basename(state.result!.filePath)}.',
      SurveyExportStatus.empty =>
        'No surveys found. Create a survey before exporting.',
      SurveyExportStatus.failure =>
        state.failure?.message ?? 'Export failed.',
      _ => null,
    };

    if (message != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message)),
      );
    }
  }

  Future<void> _shareExport(SurveyExportResult result) async {
    try {
      await Share.shareXFiles(
        [XFile(result.filePath)],
        text: 'Survey CSV export (${result.recordCount} records).',
      );
    } catch (_) {
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Unable to share the export file.'),
        ),
      );
    }
  }
}

class _ExportReadyCard extends StatelessWidget {
  const _ExportReadyCard({
    required this.onExport,
  });

  final VoidCallback onExport;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Prepare offline export',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            'Generate a single CSV file with every saved survey record.',
            style: AppTextStyles.muted(context),
          ),
          const SizedBox(height: AppSpacing.lg),
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              onPressed: onExport,
              icon: const Icon(Icons.file_download_outlined),
              label: const Text('Export CSV'),
            ),
          ),
        ],
      ),
    );
  }
}

class _ExportLoadingCard extends StatelessWidget {
  const _ExportLoadingCard();

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Preparing export...',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: AppSpacing.sm),
          const LinearProgressIndicator(),
          const SizedBox(height: AppSpacing.md),
          Text(
            'Collecting all local survey records and images.',
            style: AppTextStyles.muted(context),
          ),
        ],
      ),
    );
  }
}

class _ExportSuccessCard extends StatelessWidget {
  const _ExportSuccessCard({
    required this.result,
    required this.onShare,
    required this.onExportAgain,
  });

  final SurveyExportResult result;
  final VoidCallback onShare;
  final VoidCallback onExportAgain;

  @override
  Widget build(BuildContext context) {
    final fileName = p.basename(result.filePath);

    return AppCard(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: Theme.of(context)
                      .colorScheme
                      .primaryContainer
                      .withValues(alpha: 0.7),
                  borderRadius: AppSpacing.radius,
                ),
                child: Icon(
                  Icons.check_circle_outline,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Text(
                  'Export ready',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          _ExportDetailRow(
            label: 'File name',
            value: fileName,
          ),
          _ExportDetailRow(
            label: 'Exported',
            value: AppFormatters.shortDateTime(result.exportedAt),
          ),
          _ExportDetailRow(
            label: 'Records',
            value: result.recordCount.toString(),
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            'Share the CSV with your reporting tools or email.',
            style: AppTextStyles.muted(context),
          ),
          const SizedBox(height: AppSpacing.lg),
          Row(
            children: [
              Expanded(
                child: FilledButton.icon(
                  onPressed: onShare,
                  icon: const Icon(Icons.share_outlined),
                  label: const Text('Share file'),
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: OutlinedButton(
                  onPressed: onExportAgain,
                  child: const Text('Export again'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ExportFailureCard extends StatelessWidget {
  const _ExportFailureCard({
    required this.title,
    required this.message,
    required this.onRetry,
  });

  final String title;
  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return AppCard(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: Theme.of(context).textTheme.titleLarge!.copyWith(
                  color: colorScheme.error,
                ),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            message,
            style: AppTextStyles.muted(context),
          ),
          const SizedBox(height: AppSpacing.lg),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh),
              label: const Text('Retry export'),
            ),
          ),
        ],
      ),
    );
  }
}

class _ExportEmptyCard extends StatelessWidget {
  const _ExportEmptyCard({
    required this.onExportAgain,
  });

  final VoidCallback onExportAgain;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'No surveys available',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            'Capture a survey before preparing exports.',
            style: AppTextStyles.muted(context),
          ),
          const SizedBox(height: AppSpacing.lg),
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              onPressed: onExportAgain,
              icon: const Icon(Icons.refresh),
              label: const Text('Check again'),
            ),
          ),
        ],
      ),
    );
  }
}

class _ExportDetailRow extends StatelessWidget {
  const _ExportDetailRow({
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
          Flexible(
            flex: 2,
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: Theme.of(context).textTheme.labelLarge,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}
