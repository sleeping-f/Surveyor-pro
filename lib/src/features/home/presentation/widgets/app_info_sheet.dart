import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

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
            subtitle: '',
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
                const SizedBox(height: AppSpacing.lg),
                Text(
                  'Created by ',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                InkWell(
                  onTap: () async {
                    final uri = Uri.parse('https://www.linkedin.com/in/md-farhan-sadique-127b61316?utm_source=share_via&utm_content=profile&utm_medium=member_android');
                    if (await canLaunchUrl(uri)) {
                      await launchUrl(uri);
                    }
                  },
                  child: Text(
                    'Md. Farhan Sadique',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: colorScheme.primary,
                          decoration: TextDecoration.underline,
                        ),
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                Text(
                  'Special thanks to:\nMd. Rejaul Haque\n(Retired Sub Asst. Engineer, LGED)',
                  style: Theme.of(context).textTheme.bodyMedium,
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
