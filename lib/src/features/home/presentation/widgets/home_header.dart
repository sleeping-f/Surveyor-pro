import 'package:flutter/material.dart';

import '../../../../core/constants/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';

class HomeHeader extends StatelessWidget {
  const HomeHeader({
    required this.onNewSurveyPressed,
    super.key,
  });

  final VoidCallback onNewSurveyPressed;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final stackButton = constraints.maxWidth < 460;

        final title = Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Surveyor Pro',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              'Road survey workspace for field engineers',
              style: AppTextStyles.muted(context),
            ),
          ],
        );

        final action = FilledButton.icon(
          onPressed: onNewSurveyPressed,
          icon: const Icon(Icons.add),
          label: const Text('New survey'),
        );

        if (stackButton) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              title,
              const SizedBox(height: AppSpacing.md),
              action,
            ],
          );
        }

        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(child: title),
            const SizedBox(width: AppSpacing.md),
            action,
          ],
        );
      },
    );
  }
}
