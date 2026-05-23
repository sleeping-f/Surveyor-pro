import 'package:flutter/material.dart';

import '../../../../core/constants/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../shared/widgets/surveyor_logo.dart';

class HomeHeader extends StatelessWidget {
  const HomeHeader({
    required this.onNewSurveyPressed,
    required this.onAboutPressed,
    super.key,
  });

  final VoidCallback onNewSurveyPressed;
  final VoidCallback onAboutPressed;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final stackButton = constraints.maxWidth < 560;

        final title = Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SurveyorLogo(
              layout: SurveyorLogoLayout.full,
              height: 34,
              iconHeight: 40,
              gap: AppSpacing.sm,
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              'Road survey workspace for field engineers',
              style: AppTextStyles.muted(context),
            ),
          ],
        );

        final actionRow = Wrap(
          spacing: AppSpacing.sm,
          runSpacing: AppSpacing.sm,
          alignment: WrapAlignment.end,
          children: [
            FilledButton.icon(
              onPressed: onNewSurveyPressed,
              icon: const Icon(Icons.add),
              label: const Text('New survey'),
            ),
            OutlinedButton.icon(
              onPressed: onAboutPressed,
              icon: const Icon(Icons.info_outlined),
              label: const Text('Version'),
            ),
          ],
        );

        if (stackButton) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              title,
              const SizedBox(height: AppSpacing.md),
              Row(
                children: [
                  Expanded(
                    child: FilledButton.icon(
                      onPressed: onNewSurveyPressed,
                      icon: const Icon(Icons.add),
                      label: const Text('New survey'),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  IconButton.filledTonal(
                    onPressed: onAboutPressed,
                    tooltip: 'Version info',
                    icon: const Icon(Icons.info_outlined),
                  ),
                ],
              ),
            ],
          );
        }

        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(child: title),
            const SizedBox(width: AppSpacing.md),
            actionRow,
          ],
        );
      },
    );
  }
}
