import 'package:flutter/material.dart';

import '../../../app/app_routes.dart';
import '../../exports/presentation/export_screen.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../shared/widgets/app_card.dart';
import '../../../shared/widgets/section_header.dart';
import '../application/home_metrics_controller.dart';
import 'widgets/field_status_card.dart';
import 'widgets/home_header.dart';
import 'widgets/quick_action_card.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late final HomeMetricsController _metricsController;

  @override
  void initState() {
    super.initState();
    _metricsController = HomeMetricsController()..load();
  }

  @override
  void dispose() {
    _metricsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: LayoutBuilder(
        builder: (context, constraints) {
          final horizontalPadding =
              AppSpacing.pagePaddingFor(constraints.maxWidth);
          final isWide = constraints.maxWidth >= 820;

          return SingleChildScrollView(
            padding: EdgeInsets.fromLTRB(
              horizontalPadding,
              AppSpacing.lg,
              horizontalPadding,
              AppSpacing.xl,
            ),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(
                  maxWidth: AppSpacing.maxContentWidth,
                ),
                child: AnimatedBuilder(
                  animation: _metricsController,
                  builder: (context, _) {
                    final state = _metricsController.state;

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        HomeHeader(
                          onNewSurveyPressed: () => _openNewSurvey(context),
                        ),
                        const SizedBox(height: AppSpacing.lg),
                        const SectionHeader(
                          title: 'Quick actions',
                          subtitle: 'Prepared for offline field collection.',
                        ),
                        const SizedBox(height: AppSpacing.md),
                        _QuickActionsGrid(
                          isWide: isWide,
                          onActionSelected: (feature) {
                            if (feature == 'Start survey') {
                              _openNewSurvey(context);
                              return;
                            }

                            if (feature == 'Quick camera') {
                              _openQuickCamera(context);
                              return;
                            }

                            if (feature == 'Export CSV') {
                              _openExports(context);
                              return;
                            }

                            _showPendingFeature(context, feature);
                          },
                        ),
                        const SizedBox(height: AppSpacing.xl),
                        const SectionHeader(
                          title: 'Device data status',
                          subtitle: 'Local counts update from storage.',
                        ),
                        const SizedBox(height: AppSpacing.md),
                        FieldStatusCard(state: state),
                        const SizedBox(height: AppSpacing.xl),
                        const SectionHeader(
                          title: 'Recent surveys',
                          subtitle: 'Saved local records will appear here.',
                        ),
                        const SizedBox(height: AppSpacing.md),
                        const _EmptyRecentSurveysCard(),
                      ],
                    );
                  },
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  void _showPendingFeature(BuildContext context, String feature) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$feature will be connected in a later feature slice.'),
      ),
    );
  }

  void _openNewSurvey(BuildContext context) {
    Navigator.of(context).pushNamed(AppRoutes.newSurvey);
  }

  void _openQuickCamera(BuildContext context) {
    Navigator.of(context).pushNamed(AppRoutes.quickCamera);
  }

  void _openExports(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => ExportScreen(),
      ),
    );
  }
}

class _QuickActionsGrid extends StatelessWidget {
  const _QuickActionsGrid({
    required this.isWide,
    required this.onActionSelected,
  });

  final bool isWide;
  final ValueChanged<String> onActionSelected;

  @override
  Widget build(BuildContext context) {
    final statusColors =
        Theme.of(context).extension<AppStatusColors>() ?? AppStatusColors.light;
    final itemWidth = isWide ? 254.0 : double.infinity;

    final actions = [
      QuickActionCard(
        title: 'Start survey',
        subtitle: 'Create a road segment record',
        icon: Icons.add_circle_outline,
        color: Theme.of(context).colorScheme.primary,
        onTap: () => onActionSelected('Start survey'),
      ),
      QuickActionCard(
        title: 'Quick camera',
        subtitle: 'Watermark GPS automatically',
        icon: Icons.photo_camera_outlined,
        color: statusColors.gps,
        onTap: () => onActionSelected('Quick camera'),
      ),
      QuickActionCard(
        title: 'Export CSV',
        subtitle: 'Prepare field data transfer',
        icon: Icons.file_download_outlined,
        color: statusColors.info,
        onTap: () => onActionSelected('Export CSV'),
      ),
    ];

    return Wrap(
      spacing: AppSpacing.md,
      runSpacing: AppSpacing.md,
      children: actions
          .map(
            (action) => SizedBox(
              width: itemWidth,
              child: action,
            ),
          )
          .toList(),
    );
  }
}

class _EmptyRecentSurveysCard extends StatelessWidget {
  const _EmptyRecentSurveysCard();

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return AppCard(
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: colorScheme.primaryContainer,
              borderRadius: AppSpacing.radius,
            ),
            child: Icon(
              Icons.folder_open_outlined,
              color: colorScheme.onPrimaryContainer,
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'No local surveys yet',
                  style: Theme.of(context).textTheme.titleSmall,
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  'New records will stay available offline before export.',
                  style: AppTextStyles.muted(context),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
