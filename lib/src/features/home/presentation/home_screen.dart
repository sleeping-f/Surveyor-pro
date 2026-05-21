import 'package:flutter/material.dart';

import '../../../app/app_routes.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../shared/widgets/app_card.dart';
import '../../../shared/widgets/section_header.dart';
import 'widgets/field_status_card.dart';
import 'widgets/home_header.dart';
import 'widgets/quick_action_card.dart';
import 'widgets/survey_overview_card.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

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
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    HomeHeader(
                      onNewSurveyPressed: () => _openNewSurvey(context),
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    if (isWide)
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            flex: 3,
                            child: SurveyOverviewCard(
                              onResumePressed: () => _showPendingFeature(
                                context,
                                'Survey drafts',
                              ),
                            ),
                          ),
                          const SizedBox(width: AppSpacing.md),
                          const Expanded(
                            flex: 2,
                            child: FieldStatusCard(),
                          ),
                        ],
                      )
                    else ...[
                      SurveyOverviewCard(
                        onResumePressed: () => _showPendingFeature(
                          context,
                          'Survey drafts',
                        ),
                      ),
                      const SizedBox(height: AppSpacing.md),
                      const FieldStatusCard(),
                    ],
                    const SizedBox(height: AppSpacing.xl),
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

                        _showPendingFeature(context, feature);
                      },
                    ),
                    const SizedBox(height: AppSpacing.xl),
                    const SectionHeader(
                      title: 'Recent surveys',
                      subtitle: 'Saved local records will appear here.',
                    ),
                    const SizedBox(height: AppSpacing.md),
                    const _EmptyRecentSurveysCard(),
                  ],
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
        title: 'Capture GPS',
        subtitle: 'Attach chainage and coordinates',
        icon: Icons.gps_fixed,
        color: statusColors.gps,
        onTap: () => onActionSelected('GPS capture'),
      ),
      QuickActionCard(
        title: 'Add photos',
        subtitle: 'Store evidence on device',
        icon: Icons.photo_camera_outlined,
        color: statusColors.camera,
        onTap: () => onActionSelected('Camera capture'),
      ),
      QuickActionCard(
        title: 'Export CSV',
        subtitle: 'Prepare field data transfer',
        icon: Icons.file_download_outlined,
        color: statusColors.info,
        onTap: () => onActionSelected('CSV export'),
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
