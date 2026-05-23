import 'package:flutter/material.dart';

import 'package:surveyor_pro/src/core/app_info/domain/app_info.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../shared/widgets/app_card.dart';
import '../../../../shared/widgets/section_header.dart';

class AppInfoSheet extends StatelessWidget {
  const AppInfoSheet({required this.appInfo, super.key});

  final AppInfo appInfo;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Padding(
      padding: EdgeInsets.fromLTRB(
        AppSpacing.md,
        AppSpacing.sm,
        AppSpacing.md,
        AppSpacing.md + MediaQuery.viewPaddingOf(context).bottom,
      ),
      child: ListView(
        shrinkWrap: true,
        children: [
          const SectionHeader(
            title: 'Version info',
            subtitle: 'Current release metadata from the installed build.',
          ),
          const SizedBox(height: AppSpacing.md),
          AppCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 52,
                      height: 52,
                      decoration: BoxDecoration(
                        color: colorScheme.primaryContainer,
                        borderRadius: AppSpacing.radius,
                      ),
                      child: Icon(
                        Icons.verified_outlined,
                        color: colorScheme.onPrimaryContainer,
                      ),
                    ),
                    const SizedBox(width: AppSpacing.md),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            appInfo.appName,
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                          const SizedBox(height: AppSpacing.xs),
                          Text(
                            'Offline-first survey workspace',
                            style: AppTextStyles.muted(context),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.lg),
                _InfoRow(label: 'Version', value: appInfo.version),
                const SizedBox(height: AppSpacing.sm),
                _InfoRow(label: 'Build', value: appInfo.buildNumber),
                const SizedBox(height: AppSpacing.sm),
                _InfoRow(label: 'Package', value: appInfo.packageName),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          AppCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Release practice',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  'Keep pubspec version, Git tag, and store release notes aligned. The next slice can add remote version checks and update prompts.',
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

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SizedBox(
          width: 92,
          child: Text(
            label,
            style: Theme.of(context).textTheme.labelLarge,
          ),
        ),
        const SizedBox(width: AppSpacing.sm),
        Expanded(
          child: Text(
            value,
            style: AppTextStyles.muted(context),
          ),
        ),
      ],
    );
  }
}
